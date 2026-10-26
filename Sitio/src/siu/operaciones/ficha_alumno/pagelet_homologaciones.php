<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_homologaciones extends pagelet_base 
{
	public function get_nombre()
	{
		return 'homologaciones';
	}

	public function prepare()
	{
		parent::prepare();
		$parametros = array('nro_inscripcion' => $this->controlador->get_nro_inscripcion());
		$datos = catalogo::consultar('alumno', 'homologaciones', $parametros);
		$datos = $this->corte_control_por_carrera($datos);
		$this->data['carreras'] = $datos;
	}
	
	function corte_control_por_carrera($datos){
		$datos_corte = array();
		
		if(!empty($datos)){
			
			foreach ($datos as $dato) {
				
				if(!$dato['carrera']){
					continue;
				}
				
				$datos_corte[$dato['carrera']]['carrera'] = '('.$dato['carrera'].') '.$dato['carrera_nombre'];
				$datos_corte[$dato['carrera']]['legajo'] = $dato['legajo'];
				$datos_corte[$dato['carrera']]['plan'] = $dato['plan'];
				
				$homologacion = array(
					'materia' => '('.$dato['materia'].') '.$dato['nombre_materia'],
					'fecha' => ($dato['fecha'])? \DateTime::createFromFormat('Y-m-d', $dato['fecha'])->format('d/m/Y') : null,
				);
				$datos_corte[$dato['carrera']]['homologaciones'][] = $homologacion;
				
			}
			
		}
		return $datos_corte;
	}
}
?>