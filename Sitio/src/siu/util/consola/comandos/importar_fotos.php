<?php
namespace siu\util\consola\comandos;

use kernel\util\db\db;
use siu\bootstrap;
use siu\guarani;
use Symfony\Component\Console\Input\InputArgument,
    Symfony\Component\Console\Input\InputOption,
    Symfony\Component\Console;

use kernel\util\manejador_archivos;
use kernel\kernel;
use siu\modelo\datos\catalogo;
use siu\modelo\entidades\alumno_foto;

//use kernel\util\db as db;

class importar_fotos extends comando_guarani
{
	protected $input; //Console\Input\InputInterface
	protected $output; //Console\Output\OutputInterface
	protected $foto_count = 0;

    protected static $cliente_kolla;

    protected static $IMAGEN_DEFAULT = 'www/img/iconos/mm_medio.png';
	
	protected function configure()
	{
        $this
        ->setName('importar_fotos')
		->setDescription('Importador de fotos.')
		->setDefinition(array(
			new InputArgument('acceso', InputArgument::REQUIRED, 'El punto de acceso del cuál se quiere importar las fotos')
		))
        /*
		->setDefinition(array(
            new InputArgument('x', InputArgument::REQUIRED, 'First addend'),
            new InputArgument('y', InputArgument::REQUIRED, 'Second addend'),
            new InputOption('round', null, null, 'Round result')
        ))*/
        ->setHelp(sprintf(
				'%sImporta las fotos desde la base al G3W, también las sincroniza con Kolla%s',
				PHP_EOL, 
				PHP_EOL
		));
    }

    /**
     * @return \GuzzleHttp\Client
     */
    protected static function get_cliente_rest()
    {
        if (!isset(self::$cliente_kolla)) {
            self::$cliente_kolla = kernel::proyecto()->get_ws_cliente('kolla');
        }
        return self::$cliente_kolla;
    }

    public static function  get_unidad_gestion()
    {
        return guarani::get_ua_id();
    }

    protected function execute(Console\Input\InputInterface $input, Console\Output\OutputInterface $output)
	{
		$punto_acceso = $input->getArgument('acceso');
		$this->bootstrap_kernel($punto_acceso);
		$count = $this->get_count_fotos();
		if ($count == 0) {
			$output->writeln("Las fotos ya están sincronizadas");
			return;
		} else {
			$output->writeln("Se van a sincronizar $count fotos");
		}
		
		$q = $this->get_prepared_statement();
		$q->bindColumn(1, $ua);
		$q->bindColumn(2, $nro_insc);
		$q->bindColumn(3, $formato);
		$q->bindColumn(4, $foto, \PDO::PARAM_LOB);

        $elementos_rest = array();
		$i = 0;
		while ($q->fetch()) {
			if(($i % 50) == 0) {	
				$output->writeln("$i de $count fotos procesadas...");
			}
			$i++;
			if (strtolower($formato) == 'bmp') {
				// no se soporta el formate bmp xq se usa GD
				continue;
			}
            $nro_insc_trimmed = trim($nro_insc);
			$nombre = $ua.'_'.$nro_insc_trimmed.'.'.strtolower($formato);
			alumno_foto::importar_foto_blob($punto_acceso, $ua, $nro_insc_trimmed, $foto, strtolower($formato));
//			file_put_contents("/tmp/fotoblob_$nro_insc", $foto);

            $elementos = $this->get_elementos_por_persona($nro_insc);

            foreach($elementos as $elemento){
                $elementos_rest[] = array(
                    "elemento" => $elemento['ELEMENTO'],
                    "url_img" => alumno_foto::url_imagen_relativa_kolla($elemento['ID_IMAGEN'])
                );
            }
		}
		$this->copiar_imagen_default($punto_acceso);

        if(!empty($elementos_rest)){
            $output->writeln("Sincronizando fotos con Kolla...");

            $response = self::get_cliente_rest()
                ->put('elementos/masivo',
                    array(
                        'query' => array('unidad_gestion' => self::get_unidad_gestion()),
                        'body'  => rest_encode($elementos_rest)
                    )
                );

            if($response->getStatusCode() != 204){
                $respuesta = rest_decode($response->json());
                $output->writeln("Fallo la sincronización con Kolla: {$respuesta['descripcion']}");
            }
            else{
                $output->writeln("Sincronización con Kolla exitosa...");
            }

        }

		$output->writeln("Proceso finalizado");
    }
	
	protected function get_prepared_statement()
	{
		$sql = "SELECT unidad_academica, nro_inscripcion, formato, foto
                FROM sga_personas_foto
                WHERE sincronizada = 0  AND LOWER(formato) != 'bmp'
                AND foto IS NOT NULL";
		
		$con = kernel::db()->conexion();
		$q = $con->prepare($sql);
		$q->execute();
		return $q;
	}
	
	protected function get_count_fotos()
	{
		$sql = "SELECT count(*) as count
      FROM sga_personas_foto
      WHERE sincronizada = 0 AND LOWER(formato) != 'bmp'
           AND foto IS NOT NULL";
		$data = kernel::db()->consultar_fila($sql);
		
		return $data['COUNT'];
	}

    protected function get_elementos_por_persona($nro_inscripcion)
    {
        $nro_inscripcion = kernel::db()->quote($nro_inscripcion);

        $sql = "
                SELECT e.elemento, p.id_imagen
                FROM sga_personas AS p
                JOIN sga_docentes AS d ON (p.nro_inscripcion=d.nro_inscripcion AND p.unidad_academica = d.unidad_academica)
                JOIN gde_elemento AS e ON (e.legajo_docente=d.legajo)
                WHERE p.nro_inscripcion = {$nro_inscripcion}
                AND p.id_imagen IS NOT NULL
                AND e.tipo_elemento = 4
            ";

        return kernel::db()->consultar($sql, db::FETCH_ASSOC);
    }

	protected function copiar_imagen_default($punto_acceso){
		//para que las pueda acceder kolla
		$origen = bootstrap::get_dir_siu(). "/" .self::$IMAGEN_DEFAULT;
		$destino = kernel::proyecto()->get('imagen_alumno_dir') . '/' . $punto_acceso. '/' .basename($origen);
		copy($origen, $destino);
	}
	// SE DEJA COMENTADO ESTE MÉTODO XQ QUIZÁ SIRVA. CARGA IMAGENES DE PRUEBA
	// PARA TODOS LOS ALUMNOS, NO BUSCA LAS IMAGENES EN LA BASE, SE GENERAN AL AZAR
//    protected function execute(Console\Input\InputInterface $input, Console\Output\OutputInterface $output)
//	{
//		//Consultar todos los nros_inscripcion
//		//elegir un nro azar 1-9
//		$nros_inscripcion = $this->get_nros_inscripcion();
//		
//		$a=0;
//		$fin = count($nros_inscripcion);
//
//		foreach ($nros_inscripcion as $nro_inscripcion) {
//			if ($nro_inscripcion['NRO_INSCRIPCION'] == '1308') {
//				print_r('COLO DETECTED');
//				$path = realpath(dirname(__FILE__)."/../../../var/img_test").'/68.PNG';
//			} else {
//				$path = $this->get_path_foto();
//			}
////			print_r($path);
//			alumno_foto::importar_foto($nro_inscripcion['NRO_INSCRIPCION'], $path);
//			if(($a%100)==0) {
//				echo "$a de $fin\n";
//			}
//			$a++;
//		}
//		//foreach
//			//alumno_foto::importar_foto($nro_inscripcion, $path);
//    }

//	protected function get_path_foto($nro = false)
//	{
//		$dir = realpath(dirname(__FILE__)."/../../../var/img_test");
//		$archivos = manejador_archivos::get_archivos_directorio($dir);
////		$nro = rand(0,count($archivos)-1);
////		print_r($archivos);echo "\n";die();
//		$nro = $this->foto_count;
//		$this->foto_count = (($this->foto_count+1) % 66);
//		if ($this->foto_count == 62) {
//			$this->foto_count++;
//		}
//		return $archivos[$nro];
//	}
}