<?php
namespace siu\modelo\datos\cache;

use kernel\kernel;
use siu\modelo\datos\catalogo;
use siu\modelo\controles\controles;

use kernel\util\db\db;
use kernel\util\manejador_archivos;
use kernel\util\clase_datos;

/**
 * Genera el cacha correspondiente a un legajo
 */
class generar_legajo
{
	protected $carrera;
	protected $legajo;
	protected $nro_inscripcion;
	protected $plan;
	protected $version;
	protected $dir;
	protected $base_clases;

	function __construct($carrera, $legajo, $nro_inscripcion, $plan, $version) 
	{
		//if($legajo=='01-24715193-00') throw new error_guarani('Error generando legajo: ' . $legajo);
		$this->carrera = $carrera;
		$this->legajo = $legajo;
		$this->nro_inscripcion = $nro_inscripcion;
		$this->plan = $plan;
		$this->version = $version;
		$ni = manejador_archivos::nombre_valido($this->nro_inscripcion);
		$this->dir = kernel::proyecto()->get_dir_cache() . '/legajos/datos/' . $ni ;
		if(is_dir($this->dir)){
			manejador_archivos::borrar_directorio($this->dir);
		}
		$this->base_clases = manejador_archivos::nombre_clase_valido('legajo__' . $this->legajo);
	}
	
	function procesar()
	{
		$vista_cursadas = new generar_legajo_vistas_cursada(	$this->carrera,
																$this->legajo,
																$this->nro_inscripcion,
																$this->plan,
																$this->version,
																$this->dir,
																$this->base_clases );
		$vista_cursadas->procesar();
	}
	
}
?>