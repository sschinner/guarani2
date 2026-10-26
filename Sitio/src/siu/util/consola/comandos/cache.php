<?php
namespace siu\util\consola\comandos;

use Symfony\Component\Console\Input\InputArgument,
    Symfony\Component\Console\Input\InputOption,
    Symfony\Component\Console;

use kernel\kernel;
use siu\errores\error_guarani;
use kernel\util\manejador_archivos;
use siu\modelo\datos\cache\proceso_plan;
use siu\modelo\datos\cache\proceso_monitor;
use siu\modelo\datos\cache\proceso_ejecutar_lote;

/**
 * Esta clase tiene 3 entradas:
 * 
 *		1) Armar plan proceso cache: lista de alumnos en bloques (fuente, cantidad hilos) -> dir
 *			fuentes: 
 *		2) Ejecutar hilo proceso cache (dir) -> log
 *		3) Monitor del proceso	(dir)
 *		4) RUN
 *			- Invoca la entrada (1)
 *			- Dispara N procesos asincronos (2)
 *			- Dispara el monitor (3)
 */

class cache extends Console\Command\Command {

	protected $operaciones = array(	'plan','procesar_lote','procesar_lotes',
									//'abortar','buscar_alumno',
									//'monitor','resumen',
									'limpiar_planes', 'limpiar_datos');

	protected function configure()
	{
        $this
        ->setName('cache')
		->setDescription('Compilar datos para el proceso de inscripcion.')
		->addArgument('operacion', InputArgument::REQUIRED, 'Operación a realizar')
		// planificar
		->addOption('carrera', null, InputOption::VALUE_REQUIRED, 'Carrera a compilar', null)
		->addOption('hilos', null, InputOption::VALUE_REQUIRED, 'Hilos simultaneos', 1)
		->addOption('solicitudes', null, InputOption::VALUE_NONE, 'Procesar solicitudes de refresco')
		// ejecutar
		->addOption('plan', null, InputOption::VALUE_REQUIRED, 'Plan a ejecutar', null)
		->addOption('lote', null, InputOption::VALUE_REQUIRED, 'Lote de alumnos a ejecutar', null)
		->addOption('log', null, InputOption::VALUE_NONE, 'Log a archivo')
		->addOption('aviso', null, InputOption::VALUE_REQUIRED, 'Informar cada N legajos',20)
        ->setHelp(sprintf(
				'%sCompila datos relativos a alumnos para el proceso de inscripcion.%s',
				PHP_EOL, 
				PHP_EOL
		));
    }

    protected function execute(Console\Input\InputInterface $input, Console\Output\OutputInterface $output)
	{
		kernel::log()->set_activo(false);
		$operacion = $input->getArgument('operacion');
		switch($operacion) {
			case 'plan':
				$plan = $this->planificar($input, $output);
				break;
			case 'procesar_lote':
				$this->procesar_lote($input, $output);
				break;
			case 'procesar_lotes':
				$this->procesar_lotes($input, $output);
				break;
			case 'abortar':
				$this->abortar($input, $output);
				break;
			case 'monitor':
				$this->monitor($input, $output);
				break;
			case 'resumen':
				$this->resumen($input, $output);
				break;
			case 'limpiar_planes':
				proceso_plan::limpiar_planes();
				break;
			case 'limpiar_datos':
				proceso_plan::limpiar_datos();
				break;
			default;
				 throw new error_guarani("La operacion '$operacion' no existe. Opciones validas: ".
											implode(',',$this->operaciones));
		}
    }

	protected function planificar($input, $output)
	{
		$hilos = $input->getOption('hilos');
		$carrera = $input->getOption('carrera');
		$solicitudes = $input->getOption('solicitudes');
		$plan = new proceso_plan($hilos);
		if(isset($carrera)){
			$plan->cargar_alumnos_carrera($carrera);
		}  elseif ($solicitudes) {
			$plan->cargar_alumnos_solicitud_actualizacion();
		} else {
			$plan->cargar_alumnos_ua();
		}
		$id = $plan->procesar();
		$output->write("PLAN: $id",true);
		$output->write("Alumnos: " . $plan->get_cantidad_alumnos(),true);
		$output->write("Alumnos x Lote: " . $plan->get_cantidad_alumnos_x_lote(),true);
		return $id;
	}

	protected function procesar_lote($input, $output)
	{
		$plan = $input->getOption('plan');
		if(!isset($plan)) {
			$plan = proceso_plan::get_id_ultimo_plan();
			$output->write("Utilizando el ultimo plan: $plan",true);
		}
		$lote = $input->getOption('lote');
		if(!isset($lote)) {
			throw new error_guarani('El lote no esta definido. Utilizar --lote');
		}
		$log = $input->getOption('log');
		$aviso = $input->getOption('aviso');
		$proceso = new proceso_ejecutar_lote($plan, $lote, $log, $aviso);
		$proceso->procesar();
	}

	protected function procesar_lotes($input, $output)
	{
		$plan = $input->getOption('plan');
		if(!isset($plan)) {
			$plan = proceso_plan::get_id_ultimo_plan();
			$output->write("Utilizando el ultimo plan: $plan",true);
		}
		$info = proceso_plan::get_info_plan($plan);
		//$aviso = $info['cantidad_alumnos_lote'] / 10;
		$aviso = $input->getOption('aviso');
		//$aviso = ($aviso < 20) ? 20 : $aviso;
		foreach($info['lista_lotes'] as $lote) {
			$comando = "/home/jb/proyectos/g3w2/trunk/bin/guarani cache procesar_lote --lote=$lote --aviso=$aviso --log & \n";
			echo $comando;
			$stdout='';
			$stderr='';
			manejador_archivos::ejecutar($comando,$stdout,$stderr);
			$output->write("LOTE $lote procesando",true);
		}
	}

	protected function monitor($input, $output)
	{
		$plan = $input->getOption('plan');
		if(!isset($plan)) {
			$plan = proceso_plan::get_id_ultimo_plan();
			$output->write("Utilizando el ultimo plan: $plan",true);
		}
		proceso_monitor::estado_actual($plan);
	}

	protected function resumen()
	{

	}

	protected function abortar()
	{

	}

}