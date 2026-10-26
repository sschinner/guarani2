<?php
namespace siu\util\consola\comandos;

use Symfony\Component\Console\Input\InputArgument,
    Symfony\Component\Console\Input\InputOption,
    Symfony\Component\Console\Formatter\OutputFormatterStyle,
    Symfony\Component\Console;

use siu\guarani;
use kernel\kernel;
use kernel\util\db\dba;
use kernel\error_kernel_db;
use kernel\util\bcrypt;

class migrar_claves extends comando_guarani
{
//	protected $dir;
//protected $clase_def = "_info_catalogo";
//	protected $info = array();

	protected function configure()
	{
		parent::configure();
        $this
        ->setName('migrar_claves')
		->setDescription('Migra claves a nueva encriptación')
		->setDefinition(array(
            new InputArgument('acceso', InputArgument::REQUIRED, 'ID del bloque de acceso a de la Base que se quiere migrar las claves')
        ))
        ->setHelp(sprintf(
				'%sMigra claves a nuevo esquema de encriptación%s',
				PHP_EOL, 
				PHP_EOL
		));
    }

	
    protected function imprimir($parametros, $TITULO='')
    {
        echo $TITULO . "\n\n";
        foreach ($parametros as $key => $parametro) {
                echo $key . ": " .$parametro ."\n"; 
        }
        echo "\n\n";
    }
    
    function writeln($texto, $output, $estilo=null)
    {
        $letra=null;
        $fondo=null;
        if (isset($estilo)) {
            switch ($estilo) {
               case 'exito':
                    $letra = 'white';
                    $fondo = 'green';
               break;
               case 'falla':
                    $letra = 'white';
                    $fondo = 'red';
               break;
               default:
                    break;
            }
           $style = new OutputFormatterStyle($letra, $fondo, array('bold', 'blink'));
           $output->getFormatter()->setStyle($estilo, $style);
           $output->writeln("<$estilo>$texto</$estilo>");
        } else {
           $output->writeln($texto);
        }
        
    }
	
    protected function execute(Console\Input\InputInterface $input, Console\Output\OutputInterface $output)
	{

        //$options = $input->getOptions();
		$punto_acceso = $input->getArgument('acceso');
		if ($punto_acceso) {
            $this->bootstrap_kernel($punto_acceso);
        }
        $parametros_aplicacion	= kernel::proyecto()->get_parametros_db();
        $parametros_modificados = $parametros_aplicacion;
        $db      = dba::conectar($parametros_modificados);
		//$sql	 = "SELECT clave FROM aca_usuarios_ag";
		//$datos	 = $db->consultar_fila($sql);
		//$primer_bit = substr($datos['CLAVE'], 0, 1);
		
		//if (empty($datos) || strcmp($primer_bit,'$')!= 0) { // La migración ya fue realizada?		
			try {
				$helper = $this->getHelper('dialog');
				$preg = $helper->ask($output, 'Recomendamos realizar un backup de la base antes de migrar las claves. Desea continuar? (s/[n]) ', 'n');
				if($preg == 's'){
					$enc = new bcrypt(10);
					$this->writeln('Migrando las contraseñas...',$output , 'exito');
					//$sql = "SELECT identificacion, clave FROM aca_usuarios_ag";
					$sql = "SELECT identificacion, clave FROM aca_usuarios_ag WHERE clave NOT LIKE ('$2a%')";
					$datos = $db->consultar($sql);
					$db->abrir_transaccion();
					foreach ($datos as $dato) {
							$clave = $enc->hash($dato['CLAVE']);
							$sql = "UPDATE aca_usuarios_ag SET clave = '$clave' WHERE identificacion = '{$dato['IDENTIFICACION']}'\n";
							//$sql = "SELECT identificacion, '$clave' FROM aca_usuarios_ag WHERE identificacion = '{$dato['IDENTIFICACION']}'\n";
							$db->ejecutar($sql);
							echo ".";
							//$this->manejador_interface->progreso_avanzar();
					}
					echo "\n";
					$this->writeln('La migración fue realizada con éxito',$output , 'exito');
					$db->cerrar_transaccion();
				} else {
					$this->writeln('Se canceló la migración',$output , 'falla');
				}
			} catch (error_kernel_db $e) {
				$this->writeln('Error al migrar claves', $output, 'falla');
				$db->abortar_transaccion();
				//$this->manejador_interface->mensaje($e->getMessage());
				}
	//} else {
	//	$this->writeln('La migración ya fue realizada previamente',$output , 'falla');
	//}
}
}
