<?php
namespace siu\modelo\entidades;
use siu\modelo\datos\catalogo;
use kernel\kernel;
use siu\errores\error_guarani;
use siu\guarani;

/**
 * Valida cosas relacionadas con estado global:
 *		- superposicion horaria entre selecciones
 *		- tope de inscripciones
 * 
 * Provee informacion a la barra de estado de inscripciones
 * Provee informacion a los certificados y pantallas de inscripcion
 *
 * Esto no se maneja con el cache normal a sesion porque
 * es un bloque que se crea/limpia junto
 * 
 */
class alumno_estado_insc_cursada
{
	protected $nro_inscripcion;
	protected $inscripciones;

	function __construct($nro_inscripcion)
	{
		$this->nro_inscripcion = $nro_inscripcion;
	}

	function reset()
	{
		unset($this->inscripciones);
		catalogo::limpiar_cache('inscripcion_cursada','asignaciones',
							array('nro_inscripcion' => $this->nro_inscripcion));
                catalogo::limpiar_cache('inscripcion_cursada','inscripciones',
                                                        array('nro_inscripcion' => $this->nro_inscripcion));
	}

	//--------------------------------------------
	//
	//--------------------------------------------
	
	function info__asignaciones()
	{
		return catalogo::consultar('inscripcion_cursada','asignaciones',
							array('nro_inscripcion' => $this->nro_inscripcion));
	}

	function info__inscripciones()
	{
                if(!isset($this->inscripciones)) {
                        $this->inscripciones = catalogo::consultar('inscripcion_cursada','inscripciones',
                                                                                        array('nro_inscripcion' => $this->nro_inscripcion));
                }
                return $this->inscripciones;
	}
	
	function info__inscripcion($id_comision)
	{
		foreach($this->info__inscripciones() as $insc) {
			if($insc['COMISION']==$id_comision){
				return $insc;
			}
		}
		return array();
	}

	//--------------------------------------------
	// INFO
	//--------------------------------------------

	function get_ids_materias_inscripto()
	{
		$materias = array();
		foreach($this->info__inscripciones() as $inscripcion) {
			$materias[] = $inscripcion['MATERIA'];
		}
		return $materias;
	}

	/**
	 *
	 * @param type $materia
	 * @return boolean
	 */
	function existe_inscripcion_materia($materia)
	{
		foreach($this->info__inscripciones() as $inscripcion) {
			if ( $materia == $inscripcion['MATERIA'] ) {
				return $inscripcion['COMISION'];
			}
		}
		return false;
	}
	
	/**
	 *
	 * @param type $materia
	 * @return array devuelve un arreglo de comisiones a las que está inscripto
	 */
	function get_inscripciones_materia($materia)
	{
		$rs = array();
		foreach($this->info__inscripciones() as $inscripcion) {
			if ( $materia == $inscripcion['MATERIA'] ) {
				$rs[] = $inscripcion;
			}
		}
		
		return $rs;
	}
	
}

?>