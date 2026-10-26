<?php

namespace personalizacionUNL\operaciones\tasa_egreso;


use kernel\kernel;
use siu\guarani;
use kernel\nucleo\controlador as controlador_base;
use kernel\util\u;
use kernel\util\validador;
use siu\modelo\datos\catalogo;

class controlador extends \siu\operaciones\_comun\operaciones\reporte\controlador
{
    function accion__index() {
		$pagelet = $this->vista()->pagelet('items');
                
		$pagelet->ver_pagina(1);
	}

	function accion__ver_pagina(){
		$pagina = kernel::url()->get_param('pagina','get');
		$columna = kernel::url()->get_param('col','get');
		$orden = kernel::url()->get_param('ord','get');
		
		$pagelet = $this->vista()->pagelet('items');
		$pagelet->ver_pagina($pagina, $columna, $orden);
		
                kernel::renderer()->add($pagelet);
	}
        
        function accion__generar_pdf(){
            
            $pdf = new \personalizacionUNL\operaciones\_comun\operaciones\reporte\generador_pdf_TasaEgreso('P', 'mm', 'A4', true, 'UTF-8', false);
            $pdf->imprimir($this->vista()->pagelet('items'));
            ob_flush();
            
        }
        
        
//    function accion__info_acta()
//	{
//		$hash_acta = $this->validate_param('accion', 'get', validador::TIPO_ALPHANUM);
//		$this->acta = $this->buscar_acta($hash_acta);
//
//		$clase = 'operaciones\acta_cursadas\pagelet_acta';
//		$pl = kernel::localizador()->instanciar($clase, 'items');
//                
//		$this->vista()->add_pagelet($pl);
//
//		/* url bot�n Volver */
//		$operacion = kernel::ruteador()->get_id_operacion();
//		$pl->data['url_back'] = kernel::vinculador()->crear($operacion);
//		$pl->data['alumnos'] = $this->get_info_acta();
//	}
//
//	function get_info_acta(){
//		$parametros = array('acta' => $this->acta);
//		$datos = catalogo::consultar('docente', 'detalle_acta_cursada', $parametros);
//		return $datos;
//	}
//
//	function accion__filtrar(){
//		$filtros = array();
//		$filtros['anio_academico'] = $this->get_anio_by_id($this->validate_param('filtro_anio', 'get', validador::TIPO_ALPHANUM, array('allowempty' => true)));
//		$this->hash_per_lec = $this->get_param('filtro_per_lectivo', 'get');
//		$filtros['periodo_lectivo'] = $this->get_per_lec_by_id($this->hash_per_lec);
//		$filtros['nombre'] = $this->validate_param('filtro_nombre_materia', 'get', validador::TIPO_ALPHANUM, array('allowempty' => true));
//		$pagelet = $this->vista()->pagelet('items');
//		$pagelet->set_filtros($filtros);
//		kernel::renderer()->add($pagelet);
//	}
//
//	private function get_anio_by_id($id){
//		$aa = catalogo::consultar('unidad_academica', 'anios_academicos');
//
//		foreach($aa as $anio){
//			if ($anio['_ID_'] == $id){
//				return $anio['ANIO_ACADEMICO'];
//			}
//		}
//		return null;
//	}
//
//	private function get_per_lec_by_id($id){
//		$pl = catalogo::consultar('unidad_academica', 'periodos_lectivos');
//
//		foreach($pl as $periodo){
//			if ($periodo['_ID_'] == $id){
//				return $periodo['PERIODO_LECTIVO'];
//			}
//		}
//		return null;
//	}
//
//	function accion__buscar_periodos_lectivos(){
//		$anio = $this->get_anio_by_id($this->validate_param('anio', 'post', validador::TIPO_ALPHANUM));
//		
//		$periodos = catalogo::consultar('unidad_academica',
//										'buscar_periodos_lectivos',
//										array('anio' => $anio)
//										);
//		$this->render_raw_json($periodos);
//	}
//
//	private function buscar_acta($hash_acta)
//	{
//		$parametros = array(
//							'nro_inscripcion' => kernel::persona()->get_nro_inscripcion(), 
//							'anio_academico' => null,
//							'periodo_lectivo' => null,
//							'nombre' => null,
//						);
//		$datos = catalogo::consultar('docente', 'acta_cursadas', $parametros);
//		foreach($datos as $dato){
//			if ($dato['URL_ACTA'] == $hash_acta){
//				return $dato['ACTA'];
//			}
//		}
//		return false;
//	}
}
?>
