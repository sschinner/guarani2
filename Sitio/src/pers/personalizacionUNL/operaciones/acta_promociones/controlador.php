<?php

namespace personalizacionUNL\operaciones\acta_promociones;

use kernel\kernel;
use siu\guarani;
use kernel\nucleo\controlador as controlador_base;
use kernel\util\validador;
use kernel\util\u;
use siu\modelo\datos\catalogo;
use siu\operaciones\_comun\operaciones\reporte\generador_pdf;
use siu\operaciones\_comun\operaciones\reporte\generador_excel;

class controlador extends \siu\operaciones\acta_promociones\controlador {

    protected $acta;
    public $hash_per_lec;
    protected $info;

    function accion__info_acta() {
        $this->acta = $this->validate_param('accion', 'get', validador::TIPO_ALPHANUM);
        $clase = 'operaciones\acta_promociones\pagelet_acta';
        $pl = kernel::localizador()->instanciar($clase, 'items');
        $this->vista()->add_pagelet($pl);

        /* url bot�n Volver */
        $operacion = kernel::ruteador()->get_id_operacion();
        $pl->data['url_back'] = kernel::vinculador()->crear($operacion);
        $pl->data['generar_pdf'] = kernel::vinculador()->crear($operacion, 'promocion_pdf_acta', array('acta' => $this->acta/* , 'tipo_acta'=>$this->tipo_acta */));
        $pl->data['alumnos'] = $this->get_info_acta();
    }

    function get_info_acta() {
        $parametros = array('acta' => $this->acta);

        $datos = catalogo::consultar('docente', 'detalle_acta_promociones', $parametros);
        
        return $datos;
    }

    public function accion__promocion_pdf_acta() {
        $parametros = array('acta' => kernel::request()->get('acta'));
        $data = catalogo::consultar('docente', 'detalle_acta_promociones', $parametros);
        $nombreLogueado=kernel::persona()->get_nombre();
        $pdf = new \personalizacionUNL\operaciones\_comun\operaciones\reporte\generador_pdf_ActaPromocion('P', 'mm', 'A4', true, 'UTF-8', false);
        $pdf->imprimir($data,$nombreLogueado);
        ob_flush();
    }

}

?>