<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_excepciones extends pagelet_base 
{
	public function get_nombre()
	{
		return 'excepciones';
	}

	public function prepare()
	{
		parent::prepare();
		$parametros = array('nro_inscripcion' => $this->controlador->get_nro_inscripcion());
		$datos = catalogo::consultar('alumno', 'excepciones', $parametros);
		$datos = $this->corte_control_multiple($datos);
		$this->data['carreras'] = $datos;
	}
	
	function corte_control_multiple($datos){
		$datos_corte = array();
		
		if(!empty($datos)){
			
			foreach ($datos as $dato) {
				
				if(!$dato['carrera']){
					continue;
				}
				
				$datos_corte[$dato['carrera']]['carrera'] = '('.$dato['carrera'].') '.$dato['nombre_carrera'];
				$datos_corte[$dato['carrera']]['legajo'] = $dato['legajo'];
				$datos_corte[$dato['carrera']]['materia_anio_academico_operaciones'][$dato['materia'].$dato['anio_academico'].$dato['cursada_o_examen']]['materia'] = '('.$dato['materia'].') '.$dato['nombre_materia'];
				$datos_corte[$dato['carrera']]['materia_anio_academico_operaciones'][$dato['materia'].$dato['anio_academico'].$dato['cursada_o_examen']]['anio_academico'] = $dato['anio_academico'];
				$datos_corte[$dato['carrera']]['materia_anio_academico_operaciones'][$dato['materia'].$dato['anio_academico'].$dato['cursada_o_examen']]['operacion'] = $dato['cursada_o_examen'];
				$datos_corte[$dato['carrera']]['materia_anio_academico_operaciones'][$dato['materia'].$dato['anio_academico'].$dato['cursada_o_examen']]['turno_periodo_mesa_nom_com_llamado_coms'][$dato['turno_examen_periodo_lectivo'].$dato['mesa_examen_nombre_comision'].$dato['llamado_comision']]['turno_periodo'] = $dato['turno_examen_periodo_lectivo'];
				$datos_corte[$dato['carrera']]['materia_anio_academico_operaciones'][$dato['materia'].$dato['anio_academico'].$dato['cursada_o_examen']]['turno_periodo_mesa_nom_com_llamado_coms'][$dato['turno_examen_periodo_lectivo'].$dato['mesa_examen_nombre_comision'].$dato['llamado_comision']]['mesa_nom_com'] = $dato['mesa_examen_nombre_comision'];
				if ($dato['cursada_o_examen'] == "Examen") 
				{
					$datos_corte[$dato['carrera']]['materia_anio_academico_operaciones'][$dato['materia'].$dato['anio_academico'].$dato['cursada_o_examen']]['turno_periodo_mesa_nom_com_llamado_coms'][$dato['turno_examen_periodo_lectivo'].$dato['mesa_examen_nombre_comision'].$dato['llamado_comision']]['llamado_com'] = $dato['llamado_comision'];
				}
				
				$excepcion = array(
					'control' => '('.$dato['control_que_falla'].') '.$dato['descripcion_abreviada_control'],
					'problema' => $dato['mensaje_control_exceptuado'],
					'excepcion_otorgada' => '('.$dato['motivo_excepcion'].') '.$dato['descripcion_motivo'],
				);
				
				$datos_corte[$dato['carrera']]['materia_anio_academico_operaciones'][$dato['materia'].$dato['anio_academico'].$dato['cursada_o_examen']]['turno_periodo_mesa_nom_com_llamado_coms'][$dato['turno_examen_periodo_lectivo'].$dato['mesa_examen_nombre_comision'].$dato['llamado_comision']]['excepciones'][] = $excepcion;
				
			}
			
		}
		return $datos_corte;
	}
}
?>