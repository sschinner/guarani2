<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_inscripciones_cursadas extends pagelet_base 
{
	public function get_nombre()
	{
		return 'inscripciones_cursadas';
	}

	public function prepare()
	{
		parent::prepare();
		$this->data['datos'] = $this->get_datos();
	}
	
	function get_datos(){
		$parametros = array('nro_inscripcion' => $this->controlador->get_nro_inscripcion());
		$datos = catalogo::consultar('alumno', 'rep_inscripciones_cursadas', $parametros);
		
		$corte = array();
		foreach ($datos as $dato){
			$corte[$dato['carrera']]['carrera'] = $dato['carrera'];
			$corte[$dato['carrera']]['carrera_nombre'] = $dato['catedra_nombre_reducido'];
			$corte[$dato['carrera']]['plan'] = $dato['plan'];
			$corte[$dato['carrera']]['legajo'] = $dato['legajo'];
			

			$materia['materia'] = $dato['materia'];
			$materia['materia_nombre'] = $dato['materia_nombre'];
			$materia['comision'] = $dato['comision_nombre'];
			$materia['fecha_inscripcion'] = ($dato['fecha_insc'])?\DateTime::createFromFormat('Y-m-d', $dato['fecha_insc'])->format('d/m/Y') : null;
			$materia['calidad'] = $dato['calidad_insc'];
			$materia['estado'] = $dato['estado'];

			$corte[$dato['carrera']]['materias'][] = $materia;
			unset($materia);
		}

		return $corte;		
	}	
}
?>