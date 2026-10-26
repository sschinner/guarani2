<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_carreras extends pagelet_base 
{
	public function get_nombre()
	{
		return 'carreras';
	}

	public function prepare()
	{
		parent::prepare();
		$parametros = array('nro_inscripcion' => $this->controlador->get_nro_inscripcion());
		$datos = catalogo::consultar('alumno', 'carreras', $parametros);
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
				$datos_corte[$dato['vc_carrera']]['insc_rechazada'] = ($dato['res_insc_carrera'] == "Rechazada");
				$datos_corte[$dato['vc_carrera']]['desc_situacion_insc_carrera'] = $dato['desc_sit_insc_carrera'];
				$datos_corte[$dato['vc_carrera']]['anio_de_inscripcion'] = $dato['vi_anio_acad_insc'];
				$datos_corte[$dato['vc_carrera']]['estado_de_la_inscripcion'] = $dato['res_insc_carrera'].' - '.$dato['desc_sit_insc_carrera'];
				$datos_corte[$dato['vc_carrera']]['ultima_reinscripcion'] = $dato['vi_anio_academico'];
				
				switch($dato['vc_Calidad']) 
	            {
	              case 'A':
	                $calidad = kernel::traductor()->trans('ficha_alumno.activo');
	                break;
	              case 'E':
	                $calidad = kernel::traductor()->trans('ficha_alumno.egresado');
	                break;
	              case 'N':
	                $calidad = kernel::traductor()->trans('ficha_alumno.abandono');
	                break;
	              case 'P':
	                $calidad = kernel::traductor()->trans('ficha_alumno.pasivo');
	                break;
	            }
				
				$datos_corte[$dato['vc_carrera']]['calidad'] = $calidad;
				$datos_corte[$dato['vc_carrera']]['condicion'] = ($dato['vc_Regular'] == 'S')? kernel::traductor()->trans('ficha_alumno.regular') : kernel::traductor()->trans('ficha_alumno.no_regular');
				$datos_corte[$dato['vc_carrera']]['sede_origen'] = '('.$dato['codigo_sede_original'].') '.$dato['sede_original'];
				$datos_corte[$dato['vc_carrera']]['sede_actual'] = '('.$dato['codigo_sede_actual'].') '.$dato['sede_actual'];
				$datos_corte[$dato['vc_carrera']]['tipo_de_ingreso'] = $dato['descripcion_tipo_ingreso'];
				$datos_corte[$dato['vc_carrera']]['resolucion_de_ingreso'] = $dato['resolucion_ingreso'];
				$datos_corte[$dato['vc_carrera']]['observaciones'] = $dato['observaciones'];
				
				$movimiento = array(
					'movimiento' => $dato['vc_Observacion'],
					'plan' => $dato['vc_Plan'],
					'fecha' => (!empty($dato['vd_FechaDesde']))? \DateTime::createFromFormat('Y-m-d', $dato['vd_FechaDesde'])->format('d/m/Y') : null,
				);
				$datos_corte[$dato['vc_carrera']]['movimientos'][] = $movimiento;
				
			}
			
		}
		return $datos_corte;
	}
}
?>