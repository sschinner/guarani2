<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_requisitos extends pagelet_base 
{
	public function get_nombre()
	{
		return 'requisitos';
	}

	public function prepare()
	{
		parent::prepare();
		$parametros = array('nro_inscripcion' => $this->controlador->get_nro_inscripcion());
		$datos = catalogo::consultar('alumno', 'requisitos', $parametros);
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
				
				$requisito = array(
					'requisito' => $dato['req_nombre'],
					'fecha_presentacion' => ($dato['req_fecha'])? \DateTime::createFromFormat('Y-m-d', $dato['req_fecha'])->format('d/m/Y') : null,
					'obligatorio' => ($dato['obligatorio'] == 'S' ? kernel::traductor()->trans('ficha_alumno.si') : kernel::traductor()->trans('ficha_alumno.no')),
					'exceptuado' => ($dato['exceptuado'] == 'S' ? kernel::traductor()->trans('ficha_alumno.si') : kernel::traductor()->trans('ficha_alumno.no')),
					'prorroga' => ($dato['fecha_prorroga'])? \DateTime::createFromFormat('Y-m-d', $dato['fecha_prorroga'])->format('d/m/Y') : null,
					'observaciones' => $dato['req_obser'],
				);
				$datos_corte[$dato['carrera']]['requisitos'][] = $requisito;
				
			}
			
		}
		return $datos_corte;
	}
}
?>