<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_actividades_extracurriculares extends pagelet_base 
{
	public function get_nombre()
	{
		return 'actividades_extracurriculares';
	}

	public function prepare()
	{
		parent::prepare();
		$datos = $this->get_datos();
		$this->data['datos'] = $datos;
	}
	
	
	function get_datos(){
		$parametros = array('nro_inscripcion' => $this->controlador->get_nro_inscripcion());
		$datos = catalogo::consultar('alumno', 'actividades_extracurriculares', $parametros);
	
		$corte = array();
		foreach ($datos as $dato){
			$corte[$dato['carrera']]['carrera'] = $dato['carrera'];
			$corte[$dato['carrera']]['carrera_nombre'] = $dato['carrera_nombre'];
			$corte[$dato['carrera']]['legajo'] = $dato['legajo'];
		
			$area['area'] = $dato['area'];
			$area['area_nombre'] = $dato['area_nombre'];
			$area['resolucion'] = $dato['resol_activ'];
			$area['actividad'] = $dato['actividad_nombre'];
			$area['fecha'] = ($dato['fecha'])?\DateTime::createFromFormat('Y-m-d', $dato['fecha'])->format('d/m/Y') : null;
			$area['puntaje'] = $dato['puntaje'];

			$corte[$dato['carrera']]['areas'][] = $area;
			unset($area);
		}

		return $corte;
	}
}
?>