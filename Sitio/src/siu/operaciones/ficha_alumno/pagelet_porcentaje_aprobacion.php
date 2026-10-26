<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_porcentaje_aprobacion extends pagelet_base 
{
	public function get_nombre()
	{
		return 'porcentaje_aprobacion';
	}

	public function prepare()
	{
		parent::prepare();
		$datos = $this->get_datos();
		
		$this->data['datos'] = $datos;
	}
	
	function get_datos(){
		$parametros = array('nro_inscripcion' => $this->controlador->get_nro_inscripcion());
		$datos = catalogo::consultar('alumno', 'porcentaje_aprobacion', $parametros);
		
		$corte = array();
		foreach ($datos as $dato){
			$corte[$dato['carrera']]['carrera'] = $dato['carrera'];
			$corte[$dato['carrera']]['carrera_nombre'] = $dato['carrera_nombre'];
			$corte[$dato['carrera']]['legajo'] = $dato['legajo'];
			$corte[$dato['carrera']]['plan'] = $dato['plan'];
			$corte[$dato['carrera']]['titulo'] = $dato['titulo'];
			$corte[$dato['carrera']]['titulo_nombre'] = $dato['titulo_nombre'];
			$corte[$dato['carrera']]['version'] = $dato['version_plan'];
			$corte[$dato['carrera']]['anio_ingreso'] = $dato['anio_ingreso'];

			$orientacion['orientacion'] = $dato['orientacion'];
			$orientacion['orientacion_nombre'] = $dato['orientacion_nombre'];
			$orientacion['porc_aprob_orient'] = $dato['porcentaje_aprobacion_orientacion'];
			$orientacion['porc_aprob_titulo'] = $dato['porcentaje_aprobacion_titulo'];

			$corte[$dato['carrera']]['orientaciones'][] = $orientacion;
			unset($orientacion);
		}

		return $corte;
	}
}
?>