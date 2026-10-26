<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_antecedentes_docentes extends pagelet_base 
{
	public function get_nombre()
	{
		return 'antecedentes_docentes';
	}

	public function prepare()
	{
		parent::prepare();
		$parametros = array('nro_inscripcion' => $this->controlador->get_nro_inscripcion());
		$datos = catalogo::consultar('alumno', 'antecedentes_docentes', $parametros);
		$datos = $this->corte_control_por_carrera($datos);
		$this->data['carreras'] = $datos;
	}
	
	function corte_control_por_carrera($datos){
		$datos_corte = array();
		
		if(!empty($datos)){
			
			foreach ($datos as $dato) {
				
				if(!$dato['vc_nro_inscrip']){
					continue;
				}
				
				$antecedente = array(
					'institucion' => $dato['vc_nombre_institu'],
					'cargo' => $dato['vc_cargo'],
					'materia' => $dato['vc_materia'],
					'fecha_desde' => $dato['vc_fecha_desde'],
					'fecha_hasta' => $dato['vc_fecha_hasta'],
					'horas_semanales_trabajadas' => $dato['vc_hora_sem_trab']
				);
				$datos_corte[$dato['vc_nro_inscrip']]['antecedentes'][] = $antecedente;
				
			}
			
		}
		return $datos_corte;
	}
}
?>