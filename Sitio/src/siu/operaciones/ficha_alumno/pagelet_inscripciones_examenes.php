<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_inscripciones_examenes extends pagelet_base 
{
	public function get_nombre()
	{
		return 'inscripciones_examenes';
	}

	public function prepare()
	{
		parent::prepare();
		$this->data['datos'] = $this->get_datos();
	}
	
	function get_datos(){
		$parametros = array('nro_inscripcion' => $this->controlador->get_nro_inscripcion());
		$datos = catalogo::consultar('alumno', 'rep_inscripciones_examenes', $parametros);
		
		$corte = array();
		foreach ($datos as $dato){
			$corte[$dato['carrera']]['carrera'] = $dato['carrera'];
			$corte[$dato['carrera']]['carrera_nombre'] = $dato['nombre_carrera_reducido'];
			$corte[$dato['carrera']]['legajo'] = $dato['legajo'];

			$examen['materia'] = $dato['materia'];
			$examen['materia_nombre'] = $dato['nombre_materia_completo'];
			$examen['turno'] = $dato['turno_examen'];
			$examen['llamado'] = $dato['llamado'];
			$examen['mesa'] = $dato['mesa_examen'];
			//$examen['sede'] = $dato['sede'];
			//$examen['sede_nombre'] = $dato['nombre_sede'];
			$examen['tipo_inscripcion'] = $dato['tipo_insc_nombre'];
			$examen['estado'] = $dato['estado_nombre'];
			$examen['nro_transaccion'] = $dato['nro_transaccion'];
			
			$corte[$dato['carrera']]['examenes'][] = $examen;
			unset($examen);
		}

		return $corte;
	}	
}
?>