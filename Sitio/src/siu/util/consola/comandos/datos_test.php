<?php
namespace siu\util\consola\comandos;

use Symfony\Component\Console\Input\InputArgument,
    Symfony\Component\Console\Input\InputOption,
    Symfony\Component\Console;

use siu\guarani;
use kernel\kernel;
use kernel\util\clase_datos;

class datos_test extends Console\Command\Command
{
	protected $input; //Console\Input\InputInterface
	protected $output; //Console\Output\OutputInterface

	protected function configure()
	{
        $this
        ->setName('datos_test')
		->setDescription('Generar datos de casos de test.')
        /*
		->setDefinition(array(
            new InputArgument('x', InputArgument::REQUIRED, 'First addend'),
            new InputArgument('y', InputArgument::REQUIRED, 'Second addend'),
            new InputOption('round', null, null, 'Round result')
        ))*/
        ->setHelp(sprintf(
				'%sGenera datos para los casos de test.%s',
				PHP_EOL, 
				PHP_EOL
		));
    }

    protected function execute(Console\Input\InputInterface $input, Console\Output\OutputInterface $output)
	{
		$this->input = $input;
		$this->output = $output;
		$datos = $this->usuarios_alumnos();
		$path =  guarani::dir() .  '/../test/modelo';
		$path = realpath($path);
		$path .= '/casos_test.php';
		$clase = new clase_datos('casos_test', null, 'test\modelo');
		$clase->agregar_metodo_datos('get_alumnos', $datos);
		$clase->guardar($path);
    }
	
	/*
	 * --select first 10 nro_inscripcion, count(*)  as carreras FROM sga_alumnos group by nro_inscripcion order by carreras desc;
--SELECT * from aca_usuarios_ag where tipo_usuario = 'ALU' AND nro_inscripcion = 'J002'
SELECT * from sga_alumnos where nro_inscripcion = 'J002'
	 */	
	function usuarios_alumnos()
	{
		$cantidad = 4;
		$temp = array();
		$sql ="select first {$cantidad} nro_inscripcion, count(*)  as carreras 
				FROM sga_alumnos 
				where regular = 'S'
				group by nro_inscripcion 
				order by carreras desc;";
		$alumnos = kernel::db()->consultar($sql);
		foreach($alumnos as $alumno) {
			$nro = $alumno['NRO_INSCRIPCION'];
			$sql = "SELECT * from aca_usuarios_ag where tipo_usuario = 'ALU' AND nro_inscripcion = '$nro'\n";
			//echo $sql;
			$usuario = kernel::db()->consultar_fila($sql);	
			//print_r($usuario);
			if($usuario && isset($usuario['IDENTIFICACION'])) {
				$temp[] = array('identificacion' => $usuario['IDENTIFICACION'],
								'clave'	=> $usuario['CLAVE'],
								'nro_inscripcion' => $alumno['NRO_INSCRIPCION'],
								'carreras' => $alumno['CARRERAS']);
			}
		}
		return $temp;
	}
	
}