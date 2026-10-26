<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_titulos extends pagelet_base 
{
	public function get_nombre()
	{
		return 'titulos';
	}

	public function prepare()
	{
		parent::prepare();
		$this->data['datos'] = $this->get_datos();
	}
	
	function get_datos(){
		$parametros = array('nro_inscripcion' => $this->controlador->get_nro_inscripcion());
		$datos = catalogo::consultar('alumno', 'titulos', $parametros);
		
		$corte = array();
		foreach ($datos as $dato){
			$corte[$dato['carrera']]['carrera'] = $dato['carrera'];
			$corte[$dato['carrera']]['carrera_nombre'] = $dato['carrera_nombre'];
			$corte[$dato['carrera']]['legajo'] = $dato['legajo'];
			$corte[$dato['carrera']]['plan'] = $dato['plan'];
			$corte[$dato['carrera']]['version'] = $dato['version'];

			$titulo['titulo'] = $dato['titulo'];
			$titulo['titulo_nombre'] = $dato['titulo_nombre'];
			$titulo['fecha'] = ($dato['fecha_egreso'])?\DateTime::createFromFormat('Y-m-d', $dato['fecha_egreso'])->format('d/m/Y') : null;
			$titulo['expediente'] = $dato['nro_expediente'];
			$titulo['estado'] = $dato['estado'];
			$titulo['estado_nombre'] = $dato['estado_nombre'];

			$corte[$dato['carrera']]['titulos'][] = $titulo;
			unset($titulo);
		}
		return $corte;
	}
}
?>