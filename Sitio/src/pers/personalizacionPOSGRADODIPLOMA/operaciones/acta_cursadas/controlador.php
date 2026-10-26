<?php
namespace personalizacionPOSGRADODIPLOMA\operaciones\acta_cursadas;

use kernel\kernel;
use siu\guarani;
use kernel\nucleo\controlador as controlador_base;
use kernel\util\u;
use kernel\util\validador;
use siu\modelo\datos\catalogo;
use siu\operaciones\_comun\operaciones\reporte\generador_pdf;
use siu\operaciones\_comun\operaciones\reporte\generador_excel;

class controlador extends \siu\operaciones\acta_cursadas\controlador {

    function accion__info_acta()
	{
		$hash_acta = $this->validate_param('accion', 'get', validador::TIPO_ALPHANUM);
		$this->acta = $this->buscar_acta($hash_acta);
                //$this->tipo_acta = $this->validate_param('tipo_acta', 'get', validador::TIPO_ALPHANUM);
                
		$clase = 'operaciones\acta_cursadas\pagelet_acta';
		$pl = kernel::localizador()->instanciar($clase, 'items');
		$this->vista()->add_pagelet($pl);

		/* url bot�n Volver */
		$operacion = kernel::ruteador()->get_id_operacion();
               
		$pl->data['url_back'] = kernel::vinculador()->crear($operacion);
                $pl->data['generar_pdf'] = kernel::vinculador()->crear($operacion, 'generar_pdf_acta', array('acta'=>$hash_acta/*, 'tipo_acta'=>$this->tipo_acta*/));
		//$pl->data['generar_xls'] = kernel::vinculador()->crear($operacion, 'generar_xls_acta', array('acta'=>$hash_acta/*, 'tipo_acta'=>$this->tipo_acta*/));
		$pl->data['alumnos'] = $this->get_info_acta();
	}
        
        private function buscar_acta($hash_acta)
	{
		$parametros = array(
							'nro_inscripcion' => kernel::persona()->get_nro_inscripcion(), 
							'anio_academico' => null,
							'periodo_lectivo' => null,
							'nombre' => null,
						);
		$datos = catalogo::consultar('docente', 'acta_cursadas', $parametros);
		foreach($datos as $dato){
			if ($dato['URL_ACTA'] == $hash_acta){
				return $dato['ACTA'];
			}
		}
		return false;
	}
        public function accion__generar_pdf_acta(){
		$hash_acta = $this->validate_param('acta', 'get', validador::TIPO_ALPHANUM);
		$this->acta = $this->buscar_acta($hash_acta);
		//$this->tipo_acta = $this->validate_param('tipo_acta', 'get', validador::TIPO_ALPHANUM);
		$data = $this->get_info_acta();
                //print_r($data);die;
		$pdf = new \personalizacionPOSGRADODIPLOMA\operaciones\_comun\operaciones\reporte\generador_pdf_ActaCursada('P', 'mm', 'A4', true, 'UTF-8', false);
                $pdf->imprimir($data);
                ob_flush();
        }
        
       
}
?>
