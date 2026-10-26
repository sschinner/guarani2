<?php
namespace siu\modelo\entidades;
use siu\modelo\datos\catalogo;
use kernel\kernel;
use siu\guarani;
use siu\errores\error_guarani;

/**
 * 
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
class alumno_estado_insc_examen
{
	
	
	const clave_sesion = 'alumno_estado_insc_examen';

	const clave_sesion_det = 'alumno_estado_insc_examen_detalle';
//	const clave_sesion_asig = 'alumno_estado_insc_cursada_asignaciones';

	protected $nro_inscripcion;
	protected $incripciones = array();
	protected $incripciones_detalle = array();

	function __construct($nro_inscripcion)
	{
		$this->nro_inscripcion = $nro_inscripcion;
	}

	function reset()
	{
		unset($this->inscripciones);
		unset($this->inscripciones_detalle);
		catalogo::limpiar_cache('inscripcion_examen','info_inscripciones',
			array('nro_inscripcion' => $this->nro_inscripcion));
		kernel::sesion()->borrar(self::clave_sesion);
		kernel::sesion()->borrar(self::clave_sesion_det);
	}
/*
	//--------------------------------------------
	//
	//--------------------------------------------
	
	function info__asignaciones()
	{
		if(!isset($this->asignaciones)) {
			if(kernel::sesion()->esta_seteada(self::clave_sesion_asig)) {
				$this->asignaciones = kernel::sesion()->get(self::clave_sesion_asig);
			}else{
				$this->asignaciones = catalogo::consultar('inscripcion_cursada','info_asignaciones',
													array('nro_inscripcion' => $this->nro_inscripcion));
				kernel::sesion()->set(self::clave_sesion_asig, $this->asignaciones);
			}
		}
		return $this->asignaciones;
	}

*/
	function info__inscripciones()
	{
		if(!isset($this->inscripciones)) {
			if(kernel::sesion()->esta_seteada(self::clave_sesion)) {
				$this->inscripciones = kernel::sesion()->get(self::clave_sesion);
			}else{
				$this->inscripciones = catalogo::consultar('inscripcion_examen','info_inscripciones',
													array('nro_inscripcion' => $this->nro_inscripcion)
												);
				kernel::sesion()->set(self::clave_sesion, $this->inscripciones);
			}
		}
		
		return $this->inscripciones;
	}
	
	function info__inscripcion($id_mesa)
	{
		$inscripciones = $this->info__inscripciones();
		foreach($inscripciones as $inscripcion) {
			if($inscripcion[catalogo::id] == $id_mesa) {
				return $inscripcion;
			}
		}
		return false;
		
		return array();
		if(!isset($inscripciones[$id_mesa])) {
			throw new error_guarani("No existe una inscripción a la mesa '$id_mesa'");
		}
		return $inscripciones[$id_mesa];
//		if(!isset($this->inscripciones_detalle[$id_mesa])) {
//			if(kernel::sesion()->esta_seteada(self::clave_sesion_det)) {
//				$this->inscripciones_detalle = kernel::sesion()->get(self::clave_sesion_det);
//			}
//			
//			if(! isset($this->inscripciones_detalle[$id_mesa])) {
//				$parametros = array(	'mesa' => $id_mesa,
//										'carrera' => guarani::persona()->get_id_carrera_activa(),
//										'legajo' => guarani::persona()->get_id_legajo_activo()
//									);
//				$this->inscripciones_detalle[$id_mesa] = catalogo::consultar('inscripcion_examen',
//																		    'info_inscripcion', 
//																			$parametros
//																		   );
//				kernel::sesion()->set(self::clave_sesion_det, $this->inscripciones_detalle);
//			}
//		}
//		return $this->inscripciones_detalle[$id_mesa];
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


	function existe_inscripcion_a_examen($materia, $legajo)
	{
		foreach($this->info__inscripciones($legajo) as $inscripcion) {
			if ( $materia == $inscripcion['MATERIA'] ) {
				return $inscripcion[catalogo::id];
			}
		}
		return false;
	}
/*
	//--------------------------------------------
	//	CONTROLES
	//--------------------------------------------

	function existe_superposicion_horaria($id_comision)
	{
		
	}

	function get_cantidad_inscripciones()
	{

	}

	//--------------------------------------------
	//	CALENDARIO
	//--------------------------------------------

	*/
	
	
}

?>