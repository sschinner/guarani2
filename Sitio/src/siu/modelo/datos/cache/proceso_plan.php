<?php
namespace siu\modelo\datos\cache;

use kernel\kernel;
use siu\errores\error_guarani;
use siu\modelo\datos\catalogo;
use kernel\util\manejador_archivos;
use kernel\util\clase_datos;

/**
 *	Prepara el proceso de generacion de cache.
 * 
 *	INVOCACION:
 *		- x carrera
 *		- todas las carreras
 *		- usar tabla de actualizacion (la levanta y la borrar)
 * 
 *	Genera un DIR de trabajo.
 *	Arma una lista de alumnos, la divide en bloques, arma una clase por bloque
 *	Arma una clase cabecera con el plan de ejecucion
 * 
 *	- retorna el path de la carpeta donde quedo el plan
 */

class proceso_plan
{
	protected $id_plan;
	protected $dir;
	protected $hilos;
	protected $alumnos = array();
	protected $alumnos_x_lote;

	static function get_id_ultimo_plan()
	{
		$dir = kernel::proyecto()->get_dir_cache() . '/legajos/procesos/';
		$planes = manejador_archivos::get_archivos_directorio($dir);
		$temp = array();
		foreach($planes as $plan){
			$temp[] = basename($plan);
		}
		sort($temp);
		return array_pop($temp);
	}

	static function get_info_plan($plan)
	{
		$dir = kernel::proyecto()->get_dir_cache() . '/legajos/procesos/' . $plan ;
		if(!is_dir($dir)) {
			throw new error_guarani("No existe el PLAN: {$plan}");
		}
		$id = "_plan";
		$path = $dir . '/' . $id . '.php';
		if(!file_exists($path)) {
			throw new error_guarani("No existe la cabecera del PLAN: {$plan}");
		}
		require_once($path);
		$clase = "\\siu\\cache\\legajo\\proceso\\{$id}";
		$dao = new $clase();
		return $dao->get_info();
	}

	static function limpiar_planes()
	{
		$dir = kernel::proyecto()->get_dir_cache() . '/legajos/procesos/';
		manejador_archivos::borrar_directorio($dir);
	}

	static function limpiar_datos()
	{
		$dir = kernel::proyecto()->get_dir_cache() . '/legajos/datos/';
		manejador_archivos::borrar_directorio($dir);
	}


	static function buscar_alumno($plan, $alumno)
	{

	}

	//----------------------------------------------

	function __construct($hilos) 
	{
		$this->hilos = $hilos;
		$this->id_plan = date("Ymd_His");
		$this->dir = kernel::proyecto()->get_dir_cache() . '/legajos/procesos/' . $this->id_plan ;	
	}

	function get_cantidad_alumnos()
	{
		return count($this->alumnos);
	}

	function get_cantidad_alumnos_x_lote()
	{
		return $this->alumnos_x_lote;
	}

	function cargar_alumnos_carrera($carrera)
	{
		$validas = catalogo::consultar('sistema', 'cache_lista_carreras');
		//print_r($validas);
		$existe = false;
		foreach($validas as $info){
			if($info['CARRERA']==$carrera) {
				$existe = true;
				break;
			}
		}
		if(!$existe) throw new error_guarani('No existe la carrera seleccionada: '.$carrera);
		$this->alumnos = catalogo::consultar('sistema', 'cache_lista_alumnos_carrera',
												array('CARRERA'=>$carrera));
	}
	
	function cargar_alumnos_ua()
	{
		$this->alumnos = catalogo::consultar('sistema', 'cache_lista_alumnos_ua');
	}
	
	function cargar_alumnos_solicitud_actualizacion()
	{
		die('No implementado');
	}
	
	function procesar()
	{
		if(empty($this->alumnos)) throw new error_guarani('No hay alumnos para procesar');
		if(!is_dir($this->dir)) {
			manejador_archivos::crear_arbol_directorios($this->dir);
		}
		$cantidad = count($this->alumnos);
		$this->alumnos_x_lote = ceil($cantidad / $this->hilos);
		// LOTES
		$lotes = array();
		for($a=0;$a<$this->hilos;$a++) {
			$bloque_alumnos = array_slice($this->alumnos,($a*$this->alumnos_x_lote),$this->alumnos_x_lote,true);
			$id = "lote__{$a}";
			$clase = new clase_datos($id,null,'siu\cache\legajo\proceso', false);
			$clase->agregar_metodo_datos('get_alumnos', $bloque_alumnos);
			$path = $this->dir . '/' . $id . '.php';
			$clase->guardar($path);	
			$lotes[] = $a;
		}
		// CABECERA
		$id = "_plan";
		$clase = new clase_datos($id,null,'siu\cache\legajo\proceso', false);
		$info['cantidad_alumnos']= $cantidad;
		$info['cantidad_lotes']=$this->hilos;
		$info['cantidad_alumnos_lote']= $this->alumnos_x_lote;
		$info['lista_lotes']=$lotes;
		$clase->agregar_metodo_datos('get_info', $info);
		$path = $this->dir . '/' . $id . '.php';
		$clase->guardar($path);	
		return $this->id_plan;
	}
}
?>