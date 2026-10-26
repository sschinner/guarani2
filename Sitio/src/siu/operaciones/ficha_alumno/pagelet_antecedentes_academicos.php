<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_antecedentes_academicos extends pagelet_base 
{
	public function get_nombre()
	{
		return 'antecedentes_academicos';
	}

	public function prepare()
	{
		parent::prepare();
		$parametros = array('nro_inscripcion' => $this->controlador->get_nro_inscripcion());
		$datos = catalogo::consultar('alumno', 'antecedentes_academicos', $parametros);
		$datos = $this->corte_control_por_carrera($datos);
		$this->data['carreras'] = $datos;
	}
	
	function corte_control_por_carrera($datos){
		$datos_corte = array();
		
		if(!empty($datos)){
			
			foreach ($datos as $dato) {
				
				if(!$dato['vc_nro_inscrip']){
					continue;
				}	
				
				switch (trim($dato['vc_categoria_coneau'])) {
					case 'T':
						$categoria_coneau = kernel::traductor()->trans('ficha_alumno.en_tramite');
						break;
					case 'N':
						$categoria_coneau = kernel::traductor()->trans('ficha_alumno.ninguna');
						break;
					default:
						$categoria_coneau = $dato['vc_categoria_coneau'];
				}
				
				$antecedente = array(
					'titulo_superior' => $dato['vc_nombre_titsuper'],
					'otorgado_por' => $dato['vc_nombre_institu'],
					'fecha_de_ingreso' => $dato['vc_fecha_ingreso'],
					'fecha_de_egreso' => $dato['vc_fecha_egreso'],
					'categoria_coneau' => $categoria_coneau
				);
				
				$datos_corte[$dato['vc_nro_inscrip']]['antecedentes'][] = $antecedente;
			}
			
		}
		return $datos_corte;
	}
}
?>