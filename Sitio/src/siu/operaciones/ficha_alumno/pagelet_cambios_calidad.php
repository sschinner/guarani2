<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_cambios_calidad extends pagelet_base 
{
	public function get_nombre()
	{
		return 'cambios_calidad';
	}

	public function prepare()
	{
		parent::prepare();
		$parametros = array('nro_inscripcion' => $this->controlador->get_nro_inscripcion());
		$datos = catalogo::consultar('alumno', 'cambios_calidad', $parametros);
		$datos = $this->corte_control_por_carrera($datos);
		$this->data['carreras'] = $datos;
	}
	
	function corte_control_por_carrera($datos){
		$datos_corte = array();
		
		if(!empty($datos)){
			
			foreach ($datos as $dato) {
				
				if(!$dato['vc_carrera']){
					continue;
				}
				
				$datos_corte[$dato['vc_carrera']]['carrera'] = '('.$dato['vc_carrera'].') '.$dato['vc_carrera_nombre'];
				$datos_corte[$dato['vc_carrera']]['legajo'] = $dato['vc_legajo'];
				
				$cambio = array(
					'calidad' => $dato['vc_calidad_desc'],
					'fecha' => ($dato['vd_fecha'])? \DateTime::createFromFormat('Y-m-d H:i:s', $dato['vd_fecha'])->format('d/m/Y') : null,
					'motivo' => $dato['vc_MotivoDesc'],
					'resolucion' => $dato['vc_NroResolucion'],
					'observaciones' => $dato['vc_observaciones']
				);
				$datos_corte[$dato['vc_carrera']]['cambios'][] = $cambio;
				
			}
			
		}
		return $datos_corte;
	}
}
?>