<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_tramite_titulos extends pagelet_base 
{
	public function get_nombre()
	{
		return 'tramite_titulos';
	}

	public function prepare()
	{
		parent::prepare();
		$this->data['datos'] = $this->get_datos();
	}
	
	function get_datos(){
		$parametros = array('nro_inscripcion' => $this->controlador->get_nro_inscripcion());
		$datos = catalogo::consultar('alumno', 'tramite_titulos', $parametros);
		
		$corte = array();
		if (!empty($datos)){
			$tiene_diplomado = false;
			foreach ($datos as $dato){
				$corte[$dato['carrera']]['carrera'] = $dato['carrera'];
				$corte[$dato['carrera']]['carrera_nombre'] = $dato['carrera_nombre'];
				$corte[$dato['carrera']]['legajo'] = $dato['legajo'];
				$corte[$dato['carrera']]['plan'] = $dato['plan'];
				$corte[$dato['carrera']]['titulo'] = $dato['titulo'];
				$corte[$dato['carrera']]['titulo_nombre'] = $dato['titulo_nombre'];
				$corte[$dato['carrera']]['fecha_egreso'] = ($dato['fecha_egreso'])? \DateTime::createFromFormat('Y-m-d', $dato['fecha_egreso'])->format('d/m/Y') : null;
				$corte[$dato['carrera']]['fecha_jura'] = ($dato['fecha_colacion'])? \DateTime::createFromFormat('Y-m-d', $dato['fecha_colacion'])->format('d/m/Y') : null;

				$tramite['fecha'] = ($dato['fecha_seguimiento'])? \DateTime::createFromFormat('Y-m-d', $dato['fecha_seguimiento'])->format('d/m/Y') : null;
				$tramite['expediente'] = $dato['nro_expediente'];
				$tramite['estado'] = $dato['estado'];
				$tramite['estado_tramite'] = $dato['estado_nombre'];
				$tramite['promedio_con_aplazos'] = $dato['promedio_general'];
				$tramite['promedio_sin_aplazos'] = $dato['promedio_sin_aplazos'];

				$corte[$dato['carrera']]['tramites'][] = $tramite;
				unset($tramite);

				if ($dato['estado'] == "D"){
					$tiene_diplomado = true;
				}
			}
			$corte[$dato['carrera']]['tiene_diplomado'] = $tiene_diplomado;
		}
		return $corte;
	}
}
?>