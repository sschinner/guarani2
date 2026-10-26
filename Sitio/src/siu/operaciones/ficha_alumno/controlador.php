<?php
namespace siu\operaciones\ficha_alumno;

use kernel\kernel;
use siu\extension_kernel\controlador_g3w2;
use kernel\util\validador;
use siu\modelo\datos\catalogo;

class controlador extends controlador_g3w2
{
	private $nro_inscripcion = null;
	private $datos_alumno = null;
                  private $categorias = array(
                            'alumno' => array(1,5,6),
                            'carreras' => array(2,13,18,4,19),
                            'titulos' => array(12,20,3),
                            'historia_academica' => array(8,10,7,14,17,15,16,9,11),
                            'antecedentes' => array(23,21,22),
                            );
	
	function modelo()
	{
		return null;
	}
	
	function accion__index()
	{
		$reporte = $this->validate_param('r', 'get', validador::TIPO_TEXTO, array('allowempty' => true));
		if (!empty($reporte)){
			$clase = 'operaciones\ficha_alumno\pagelet_datos_personales';
			$pl = kernel::localizador()->instanciar($clase, 'reporte');
			$this->vista()->add_pagelet($pl);
		}
		
		$clase = 'operaciones\ficha_alumno\pagelet_filtro';
		$pl = kernel::localizador()->instanciar($clase, 'filtro');
		$this->vista()->add_pagelet($pl);
	}
	
	function accion__cargar_reporte()
	{
		$reporte = $this->validate_param('r', 'get', validador::TIPO_TEXTO, array('allowempty' => true));
		if (!empty($reporte)){
			switch ($reporte){
				case 1:
					$clase = 'operaciones\ficha_alumno\pagelet_datos_personales';
					break;
				case 2:
					$clase = 'operaciones\ficha_alumno\pagelet_carreras';
					break;
				case 3:
					$clase = 'operaciones\ficha_alumno\pagelet_promedios';
					break;
				case 4:
					$clase = 'operaciones\ficha_alumno\pagelet_perdidas_regularidad';
					break;
				case 5:
					$clase = 'operaciones\ficha_alumno\pagelet_sanciones';
					break;
				case 6:
					$clase = 'operaciones\ficha_alumno\pagelet_certificados_solicitados';
					break;
				case 7:
					$clase = 'operaciones\ficha_alumno\pagelet_regularidades';
					break;
				case 8:
					$clase = 'operaciones\ficha_alumno\pagelet_historia_academica';
					break;
				case 9:
					$clase = 'operaciones\ficha_alumno\pagelet_actividades_extracurriculares';
					break;
				case 10:
					$clase = 'operaciones\ficha_alumno\pagelet_historia_academica_no_valida';
					break;
				case 11:
					$clase = 'operaciones\ficha_alumno\pagelet_homologaciones';
					break;
				case 12:
					$clase = 'operaciones\ficha_alumno\pagelet_titulos';
					break;
				case 13:
					$clase = 'operaciones\ficha_alumno\pagelet_requisitos';
					break;
				case 14:
					$clase = 'operaciones\ficha_alumno\pagelet_inscripciones_cursadas';
					break;
				case 15:
					$clase = 'operaciones\ficha_alumno\pagelet_inscripciones_examenes';
					break;
				case 16:
					$clase = 'operaciones\ficha_alumno\pagelet_excepciones';
					break;
				case 17:
					$clase = 'operaciones\ficha_alumno\pagelet_prorrogas_regularidad';
					break;
				case 18:
					$clase = 'operaciones\ficha_alumno\pagelet_cambios_calidad';
					break;
				case 19:
					$clase = 'operaciones\ficha_alumno\pagelet_porcentaje_aprobacion';
					break;
				case 20:
					$clase = 'operaciones\ficha_alumno\pagelet_tramite_titulos';
					break;
				case 21:
					$clase = 'operaciones\ficha_alumno\pagelet_antecedentes_laborales';
					break;
				case 22:
					$clase = 'operaciones\ficha_alumno\pagelet_antecedentes_academicos';
					break;
				case 23:
					$clase = 'operaciones\ficha_alumno\pagelet_antecedentes_docentes';
					break;
				default:
					$clase = 'operaciones\ficha_alumno\pagelet_datos_personales';
			}

			$pl = kernel::localizador()->instanciar($clase, 'reporte');
			$this->vista()->add_pagelet($pl);
			
			$clase1 = 'operaciones\ficha_alumno\pagelet_filtro';
			$pl1 = kernel::localizador()->instanciar($clase1, 'filtro');
			$this->vista()->add_pagelet($pl1);
		
			kernel::renderer()->add($pl);
		
		}
	}
	
	/**
	 * Autocompletado de alumno 
	 */
	function accion__auto_alumno()
	{
		$term = $this->validate_param('term', 'get', validador::TIPO_TEXTO);
		
		if (empty($term)) {
			$this->render_raw_json(array());
			return;
		}
		
                                    $term_decode = utf8_decode($term);
		$parametros = array('term' => $term_decode);
		$raw_data = catalogo::consultar('alumno', 'buscar_alumno', $parametros);
		
		$data = array();
		foreach ($raw_data as $alumno) {
			$data[] = array(
				'id' => kernel::vinculador()->crear('ficha_alumno', 'index', array(
					0	=> $alumno['__ID__'],
					'term' => $term,
					'r' => 1,
				)),
				'label' => $alumno[1]
			);
		}
		$this->render_raw_json($data);
	}
	
	function get_nro_inscripcion(){
		if (!is_null($this->nro_inscripcion)){
			return $this->nro_inscripcion;
		}
		
		$hash = $this->validate_param(0, 'get', validador::TIPO_TEXTO, array('allowempty' => true));
		$term = $this->validate_param('term', 'get', validador::TIPO_TEXTO, array('allowempty' => true));
		
		if (empty($term) or empty($hash)) {
			return false;
		}
		
		$parametros = array('term' => $term);
		$raw_data = catalogo::consultar('alumno', 'buscar_alumno', $parametros);

		foreach ($raw_data as $alumno) {
			if ($alumno['__ID__'] == $hash){
				$this->nro_inscripcion = $alumno[0];
				$this->datos_alumno = $alumno[2];
				return $alumno[0];
			}
		}
		return false;
	}
	
	function get_datos_alumno(){
		$this->get_nro_inscripcion();
		return $this->datos_alumno;
	}

                  function get_categoria_actual(){
                        $r = $this->validate_param('r', 'get', validador::TIPO_TEXTO, array('allowempty' => true));

                        if(!empty($r)) {
                            foreach($this->categorias as $clave_cat => $id_items){
                                if(in_array($r, $id_items)){
                                    $categoria_actual = trans('ficha_alumno.menu_categoria.'.$clave_cat);
                                    break;
                                }
                            }
                        }
                        return $categoria_actual;
                  }
	
	function get_reporte_actual(){
		$r = $this->validate_param('r', 'get', validador::TIPO_TEXTO, array('allowempty' => true));
		
		if (empty($r)) {
			return false;
		}
		
		return $r;
	}
	
	function get_menu_reportes(){
		$hash = $this->validate_param(0, 'get', validador::TIPO_TEXTO, array('allowempty' => true));
		$term = $this->validate_param('term', 'get', validador::TIPO_TEXTO, array('allowempty' => true));
		
		if (empty($term) or empty($hash)) {
			return false;
		}
		$menu = array();
		
		foreach($this->categorias as $clave_cat => $id_items){
			foreach($id_items as $item){
				$menu_item = array(
					'id' => $item,
					'texto' => trans('ficha_alumno.menu.'.$item),
					'link'	=> kernel::vinculador()->crear('ficha_alumno', 'cargar_reporte', array(
						0	=> $hash,
						'term' => utf8_encode($term),
						'r' => $item,
					))
				);
				$menu[$clave_cat]['categoria_nombre'] = trans('ficha_alumno.menu_categoria.'.$clave_cat);
				$menu[$clave_cat]['items'][] = $menu_item;
			}
		}
		return $menu;
	}
}
?>