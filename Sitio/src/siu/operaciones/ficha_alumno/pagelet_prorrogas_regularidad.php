<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_prorrogas_regularidad extends pagelet_base 
{
	public function get_nombre()
	{
		return 'prorrogas_regularidad';
	}

	public function prepare()
	{
		parent::prepare();
		$this->data['datos'] = $this->get_datos();
	}
	
	function get_datos(){
		$parametros = array('nro_inscripcion' => $this->controlador->get_nro_inscripcion());
		$datos = catalogo::consultar('alumno', 'prorrogas_regularidad', $parametros);
		
		$corte = array();
		foreach ($datos as $dato){
			$corte[$dato['carrera']]['carrera'] = $dato['carrera'];
			$corte[$dato['carrera']]['carrera_nombre'] = $dato['carrera_nombre'];
			$corte[$dato['carrera']]['legajo'] = $dato['legajo'];
		
			$prorroga['materia'] = $dato['materia'];
			$prorroga['materia_nombre'] = $dato['materia_nombre'];
			$prorroga['origen_regularidad'] = (!empty($dato['tipo']))? ucfirst(kernel::traductor()->trans('ficha_alumno.rep_prorrogas_regularidad.origen.'.strtoupper($dato['tipo']))):null;
			$prorroga['fecha_alta_prorroga'] = (empty($dato['fecha_prorroga']))? ucfirst(kernel::traductor()->trans('ficha_alumno.rep_prorrogas_regularidad.sin_vencimiento')):($dato['fecha_prorroga'])?\DateTime::createFromFormat('Y-m-d', $dato['fecha_prorroga'])->format('d/m/Y') : null;
			$prorroga['fin_vigencia_anterior'] = (empty($dato['fin_vigencia_reg_ant']))? ucfirst(kernel::traductor()->trans('ficha_alumno.rep_prorrogas_regularidad.sin_vencimiento')):($dato['fin_vigencia_reg_ant'])?\DateTime::createFromFormat('Y-m-d', $dato['fin_vigencia_reg_ant'])->format('d/m/Y') : null;
			$prorroga['fecha_prorrogada'] = (empty($dato['prorroga_hasta']))? ucfirst(kernel::traductor()->trans('ficha_alumno.rep_prorrogas_regularidad.sin_vencimiento')):($dato['prorroga_hasta'])?\DateTime::createFromFormat('Y-m-d', $dato['prorroga_hasta'])->format('d/m/Y') : null;
			$prorroga['link'] = kernel::vinculador()->crear('actas', 'acta_cursada', array(
							'a' => $dato['acta'],
						));

			$corte[$dato['carrera']]['prorrogas'][] = $prorroga;
			unset($prorroga);
		}

		return $corte;
	}
}