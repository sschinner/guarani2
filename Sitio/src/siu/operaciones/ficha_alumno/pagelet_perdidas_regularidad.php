<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_perdidas_regularidad extends pagelet_base 
{
	public function get_nombre()
	{
		return 'perdidas_regularidad';
	}

	public function prepare()
	{
		parent::prepare();
		$this->data['datos'] = $this->get_datos();
	}
	
	function get_datos(){
		$parametros = array('nro_inscripcion' => $this->controlador->get_nro_inscripcion());
		$datos = catalogo::consultar('alumno', 'perdidas_regularidad', $parametros);
		
		$corte = array();
		foreach ($datos as $dato){
			$corte[$dato['carrera']]['carrera'] = $dato['carrera'];
			$corte[$dato['carrera']]['carrera_nombre'] = $dato['carrera_nombre'];
			$corte[$dato['carrera']]['legajo'] = $dato['legajo'];

			$perdida_regularidad['anio_perdida_regularidad'] = $dato['anio_academico'];
			$perdida_regularidad['fecha_perdida_regularidad'] = ($dato['fecha_baja_regularidad'])?\DateTime::createFromFormat('Y-m-d', $dato['fecha_baja_regularidad'])->format('d/m/Y') : null;
			$perdida_regularidad['resolucion_perdida_regularidad'] = $dato['nro_resolucion_baja'];
			$perdida_regularidad['anio_readmision'] = $dato['anio_rehab'];
			$perdida_regularidad['fecha_readmision'] = ($dato['fecha_rehab'])?\DateTime::createFromFormat('Y-m-d', $dato['fecha_rehab'])->format('d/m/Y') : null;
			$perdida_regularidad['resolucion_readmision'] = $dato['nro_resolucion_rehab'];
			$perdida_regularidad['fecha_solucion'] = ($dato['fecha_baja_regularidad'])?\DateTime::createFromFormat('Y-m-d', $dato['fecha_baja_regularidad'])->format('d/m/Y') : null;
			$perdida_regularidad['solucion'] = ($dato['fecha_solucion'])?\DateTime::createFromFormat('Y-m-d', $dato['fecha_solucion'])->format('d/m/Y') : null;
			$perdida_regularidad['motivo_solucion'] = $dato['motivo_solucion'];

			$corte[$dato['carrera']]['perdidas_regularidad'][] = $perdida_regularidad;
			unset($perdida_regularidad);
		}

		return $corte;
	}
}
?>