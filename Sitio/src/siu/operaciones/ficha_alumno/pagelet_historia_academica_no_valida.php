<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_historia_academica_no_valida extends pagelet_base 
{
	public function get_nombre()
	{
		return 'historia_academica_no_valida';
	}

	public function prepare()
	{
		parent::prepare();
		$parametros = array('nro_inscripcion' => $this->controlador->get_nro_inscripcion());
		$datos = catalogo::consultar('alumno', 'historia_academica_no_valida', $parametros);
		$datos = $this->corte_control_por_carrera($datos);
		$this->data['carreras'] = $datos;
	}
	
	function corte_control_por_carrera($datos){
		$datos_corte = array();
		
		if(!empty($datos)){
			
			foreach ($datos as $dato) {
				
				if(!$dato['carrera']){
					continue;
				}
				
				$datos_corte[$dato['carrera']]['carrera'] = '('.$dato['carrera'].') '.$dato['carrera_nombre'];
				$datos_corte[$dato['carrera']]['legajo'] = $dato['legajo'];
				
				switch($dato['resultado']) 
				{
					case "A": 
						$resultado = kernel::traductor()->trans('ficha_alumno.aprobado'); 
						break;
					case "R": 
						$resultado = kernel::traductor()->trans('ficha_alumno.reprobado'); 
						break;
					case "P": 
						$resultado = kernel::traductor()->trans('ficha_alumno.promocion');
						break;
				};

				switch($dato['estado_nota'])
				{
					case 'I': 
						$estado_de_la_nota = kernel::traductor()->trans('ficha_alumno.invalidado'); 
						break;
					case 'N': 
						$estado_de_la_nota = kernel::traductor()->trans('ficha_alumno.anulado');  
						break;
					case 'B': 
						$estado_de_la_nota = kernel::traductor()->trans('ficha_alumno.baja');  
						break;
					case 'A': 
						$estado_de_la_nota = kernel::traductor()->trans('ficha_alumno.activo');  
						break;
				} 

				$historia = array(
					'materia' => '('.$dato['materia'].') '.$dato['nombre_materia'],
					'plan' => $dato['plan'],
					'fecha' => ($dato['fecha'])? \DateTime::createFromFormat('Y-m-d', $dato['fecha'])->format('d/m/Y') : null,
					'nota' => $dato['nota'],
					'resultado' => $resultado,
					'aprobacion' => $dato['forma_aprobacion'],
					'acta_o_resolucion' => $dato['acta_resolucion'],
					//'acta_o_resolucion' => $acta_o_resolucion,
					'estado_de_la_nota' => $estado_de_la_nota,
					'detalle' => kernel::traductor()->trans('ficha_alumno.ver_detalle'),
					'fecha_movimiento' => $dato['fecha_movimiento'],
					'nro_resolucion_movimiento' => $dato['nro_resolucion_movimiento'],
					'observaciones_movimiento' => $dato['observaciones_movimiento'],
					'desc_abreviada_movimiento' => $dato['desc_abreviada_movimiento'],
				);
				$datos_corte[$dato['carrera']]['historias'][] = $historia;
				
			}
			
		}
		return $datos_corte;
	}
}
?>
