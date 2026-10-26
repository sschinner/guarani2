<?php
namespace siu\util\consola\comandos;
use DJJob_informix;
use DJWorker_informix;
use Exception;
use kernel\kernel;
use kernel\util\MailJob;
use PDO;
use Symfony\Component\Console;

require_once(__DIR__ . "/../../../lib/DJJob/DJJob_informix.php");

class enviar_emails extends comando_guarani
{

    protected function configure()
	{
        $this
            ->setName('enviar_emails')
            ->setDescription('Envia todos los emails encolados')
            ->setHelp(sprintf(
                '%sEnvia todos los emails encolados.%s',
                PHP_EOL,
                PHP_EOL
            ));
    }

    //https://github.com/jfloff/djjob-zf2
    protected function execute(Console\Input\InputInterface $input, Console\Output\OutputInterface $output) {
        $this->bootstrap_kernel();

        $output->writeln("<comment>Inicio del proceso de encolado de emails enviados desde Guaran� Gesti�n...</comment>");

        //Traigo todos los bloques de acceso
        $accesos = kernel::proyecto()->get_accesos();

        //Por cada bloque de acceso (conexión a la DB)
        foreach($accesos as $key => $acceso){

            $this->bootstrap_kernel($key);

            $output->writeln("<comment>Encolando los emails de la Unidad de Gestión: '{$acceso['ua']}'...</comment>");

            try{

                $bloque_acceso = $acceso['database'];
                $pdo = new \PDO("informix:host={$bloque_acceso['host']}; service={$bloque_acceso['service']}; database={$bloque_acceso['database']}; server={$bloque_acceso['server']}; protocol={$bloque_acceso['protocol']}; EnableScrollableCursors={$bloque_acceso['EnableScrollableCursors']}", $bloque_acceso['LogonID'], $bloque_acceso['pwd']);

                //Recupero todos los emails enviados desde Guaran� Gesti�n pendientes de env�o
                $sql = "SELECT a.anuncio, a.fecha_desde, a.fecha_hasta, a.titulo_anuncio, a.mensaje, cp.e_mail
                    FROM gda_anuncios AS a
                    JOIN gda_anuncios_log AS al ON (a.anuncio = al.anuncio)
                    JOIN gda_anun_conf_pers as cp ON (al.unidad_academica = cp.unidad_academica AND al.nro_inscripcion = cp.nro_inscripcion)
                    WHERE a.enviado_por_mail = 'S'
                          AND a.fecha_hasta >= TODAY
                          AND al.envio_mail = 'P'
                          AND cp.recibe_mail = 'S'
                          AND cp.e_mail IS NOT NULL
                    ORDER BY a.anuncio
                    ";

                $mensajes = array();
                $anuncio = 0;
                $rows = $pdo->query($sql);

                if(!$rows){//si hubo un error en la consulta que recupera los emails
                    $output->writeln("<error>Error en la consulta que recupera los emails para la Unidad de Gestión: '{$acceso['ua']}'</error>");
                    continue;
                }

                foreach ($rows as $row) {

                    //Seteo los datos del email (asunto, mensaje, etc.)
                    if($row['ANUNCIO'] != $anuncio){
                        $anuncio = $row['ANUNCIO'];

                        $mensajes[$row['ANUNCIO']]['fecha_desde'] = $row['FECHA_DESDE'];
                        $mensajes[$row['ANUNCIO']]['fecha_hasta'] = $row['FECHA_HASTA'];
                        $mensajes[$row['ANUNCIO']]['titulo'] = $row['TITULO_ANUNCIO'];
                        $mensajes[$row['ANUNCIO']]['mensaje'] = $row['MENSAJE'];
                    }
                    //Seteo los destinatarios del email
                    $mensajes[$row['ANUNCIO']]['destinatarios'][] = $row['E_MAIL'];
                }

                $sth = $pdo->prepare("UPDATE gda_anuncios_log
                                  SET envio_mail = 'E'
                                  WHERE envio_mail = 'P' AND anuncio = :anuncio");

                $cant_max_destinatarios_por_email = kernel::proyecto()->get_cant_max_destinatarios_por_email();

                $tpl = kernel::agregar_path_templates(dirname(__FILE__) . '/template_mail');
                $tpl1 = kernel::load_template($tpl . '/mail_de_gestion.twig');
                foreach($mensajes as $key => $mensaje){

                    $cuerpo = $tpl1->render(array('mensaje' => $mensaje['mensaje']));

                    $mailjob = new MailJob('', $mensaje['titulo'], $cuerpo, null, '', 'utf-8', $mensaje['fecha_desde'], $pdo);

                    $destinatarios = $mensaje['destinatarios'];

                    $bloques_destinatarios = array();
                    if($cant_max_destinatarios_por_email == 0){//Se envia un solo email con todos los destinatarios
                        $bloques_destinatarios[0] = $destinatarios;
                    }
                    else{//Se envian varios emails paginados por el valor de $cant_max_destinatarios_por_email
                        $bloques_destinatarios = array_chunk($destinatarios, $cant_max_destinatarios_por_email);
                    }

                    $pdo->beginTransaction();

                    //Por cada bloque de destinatarios se envia un email
                    foreach($bloques_destinatarios as $bloque_destinatarios){
                        $mailjob->set_hacia($bloque_destinatarios);
                        $mailjob->set_html(true);
                        //Encolo los emails para enviar luego
                        $mailjob->sendLater();
                    }

                    //Marco el email como enviado (luego lo enviara el cron)
                    $sth->execute(array(':anuncio' => $key));

                    $pdo->commit();
                }

                $output->writeln("<info>Se encolaron ".count($mensajes)." emails para la Unidad de Gestión: '{$acceso['ua']}'...</info>");

            }
            catch(\Exception $e){
                // $pdo->rollBack();
                $output->writeln("<error>Falló el encolado de emails para la Unidad de Gestión: '{$acceso['ua']}', las causas del error son:</error>");
                $output->writeln("<error>".$e->getMessage()."</error>");
                $output->writeln("<error>".$e->getTraceAsString()."</error>");
            }


            $output->writeln("<comment>Inicio del proceso de envío de emails encolados para la Unidad de Gestión: '{$acceso['ua']}'...</comment>");

            //Desbloqueo los jobs
            $pdo->exec("UPDATE jobs SET attempts = 0, locked_at = NULL, locked_by = NULL, failed_at = NULL, error = NULL WHERE queue = 'email'");

            \DJJob_informix::setConnection($pdo);

            $cant_emails_a_enviar_por_corrida_cron = kernel::proyecto()->get_cant_emails_a_enviar_por_corrida_cron();

            $worker = new \DJWorker_informix(array(
                'queue' => 'email',
                "run_forever" => false,
                "count" => $cant_emails_a_enviar_por_corrida_cron
            ));
            $worker->start();
        }

        $output->writeln("<comment>Fin del proceso de envío de emails encolados, ante cualquier inconveniente verifique la tabla jobs de la base de datos.</comment>");

    }

}