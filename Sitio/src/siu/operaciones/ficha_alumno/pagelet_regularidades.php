<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_regularidades extends pagelet_base 
{
	public function get_nombre()
	{
		return 'regularidades';
	}

	public function prepare()
	{
		parent::prepare();
		$parametros = array('nro_inscripcion' => $this->controlador->get_nro_inscripcion());
		$datos = catalogo::consultar('alumno', 'ficha_alumno_regularidades', $parametros);
		$datos = $this->corte_control_por_carrera($datos);
		
		$this->data['carreras'] = $datos;
	}
	
	function corte_control_por_carrera($datos){
		
		$datos_corte = array();
		if(!empty($datos)){
			
			foreach ($datos as $dato) {
				
				if(!$dato['vc_Carrera']){
					continue;
				}
				
				$datos_corte[$dato['vc_Carrera']]['carrera'] = ($dato['materia_aprobada'] == 'S' ? '* ' : '').'('.$dato['vc_Carrera'].') '.$dato['vc_CarreraNombre'];
				$datos_corte[$dato['vc_Carrera']]['legajo'] = $dato['vc_Legajo'];
				
				switch ($dato['vc_Resultado']) 
				{
					case 'R': 
						$resultado = kernel::traductor()->trans('ficha_alumno.reprobado'); 
						break;
					case 'A':
					case 'P': 
						$resultado = kernel::traductor()->trans('ficha_alumno.aprobado'); 
						break;
					case 'U': 
						$resultado = kernel::traductor()->trans('ficha_alumno.libre'); 
						break;
				}
				
				$materia = array(
					'materia' => '('.$dato['vc_Materia'].') '.$dato['vc_MateriaNombre'],
					'comision' => $dato['nro_resolucion_equivalencia'],
					'nota' => $dato['nota'],
					'resultado' => $resultado,
					'fecha_regularizacion' => ($dato['vd_Regularidad'])? \DateTime::createFromFormat('Y-m-d', $dato['vd_Regularidad'])->format('d/m/Y') : null,
					'fecha_fin_vigencia' => ($dato['vd_FinVigencia'])? \DateTime::createFromFormat('Y-m-d', $dato['vd_FinVigencia'])->format('d/m/Y') : null,
					'origen' => trim($dato['vc_Origen']),
					'acta_resolucion' => (substr(trim($dato['vc_Origen']),0,2) == 'Eq')? $dato['nro_resolucion_equivalencia'] : $dato['nro_acta_regulares'],
					'anio' => trim($dato['vc_Anio']),
					'per_lec' => trim($dato['vc_PerLect']),
					'plan' => trim($dato['vc_PlanReg']),
				);
				
				switch ($dato['vc_Origen']){
					case "Promocionada":
						$materia['link'] = kernel::vinculador()->crear('actas', 'acta_promocion', array('a' => $dato['nro_acta_regulares']));
						break;
					case "Cursada":
						$materia['link'] = kernel::vinculador()->crear('actas', 'acta_cursada', array('a' => $dato['nro_acta_regulares']));
						break;
				}
				$datos_corte[$dato['vc_Carrera']]['materias'][] = $materia;
			}
			
		}
		return $datos_corte;
	}
}
?>