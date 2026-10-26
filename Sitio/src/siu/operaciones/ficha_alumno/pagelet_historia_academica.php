<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_historia_academica extends pagelet_base 
{
	public function get_nombre()
	{
		return 'historia_academica';
	}

	public function prepare()
	{
		parent::prepare();
		$parametros = array('nro_inscripcion' => $this->controlador->get_nro_inscripcion());
		$datos = catalogo::consultar('alumno', 'ficha_alumno_historia_academica', $parametros);
		$carreras = $this->corte_control_por_carrera($datos);
		$this->data['carreras'] = $carreras;
	}
	
	function corte_control_por_carrera($datos){
		
		$datos_corte = array();
		
		if(!empty($datos)){
			
			foreach ($datos as $dato) {
				
				if(!$dato['carrera']){
					continue;
				}
				
				$datos_corte[$dato['carrera']]['carrera_nombre'] = '('.$dato['carrera'].') '.$dato['carrera_nombre'];
				$datos_corte[$dato['carrera']]['legajo'] = $dato['legajo'];
				
				$materia = array(
					'materia' => '('.$dato['materia'].') '.$dato['nombre_materia'],
					'plan' => $dato['plan'],
					'fecha' => ($dato['fecha'])? \DateTime::createFromFormat('Y-m-d', $dato['fecha'])->format('d/m/Y') : null,
					'nota' => $dato['nota'],
					'resultado' => $dato['resultado'],
					'aprobacion' => $dato['forma_aprobacion'],
					'folio_fisico' =>  $dato['folio_fisico']
				);
				
				if (substr($dato['forma_aprobacion'],0,2) == 'Ex'){
					$materia['acta_o_resolucion'] = $dato['acta'];
					$materia['link'] = kernel::vinculador()->crear('actas', 'acta_examen', array(
						'a' => $dato['acta'],
						't' => $dato['tipo_acta'],
					));
				}
				elseif (substr($dato['forma_aprobacion'],0,2) == 'Pr'){
					$materia['acta_o_resolucion'] = $dato['acta_promocion'];
					$materia['link'] = kernel::vinculador()->crear('actas', 'acta_promocion', array('a' => $dato['acta_promocion']));
				}
				elseif (substr($dato['forma_aprobacion'],0,2) == 'Eq') {
					$materia['acta_o_resolucion'] = $dato['nro_resolucion'];
				}
				
				$datos_corte[$dato['carrera']]['materias'][] = $materia;
				
			}
		}
		return $datos_corte;
	}
}
?>