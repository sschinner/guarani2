<?php

namespace personalizacionUNL\operaciones\impresion_certificados;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\guarani;
use siu\modelo\datos\catalogo;
use siu\modelo\entidades\unidad_academica;


class pagelet_listado extends pagelet {

    function get_nombre() {
        return 'listado';
    }

    function prepare() {
        // la variable this.data se utiliza luego desde el template
        $this->data = array();
        $operacion = kernel::ruteador()->get_id_operacion();
        $this->data['debePagar'] = true;
        $this->data['urls'] = $this->obtenerUrlDescarga();
        $this->data['accion'] = kernel::vinculador()->crear($operacion, 'invocar_pdf');
        
        // se consume desde la transacción creada anteriormente
    }

    private function obtenerUrlDescarga() {
        $u = new unidad_academica(\siu\guarani::get_ua_id());
        $uA = utf8_encode($u->get_id());
        $parametro['nro_inscripcion'] = guarani::persona()->get_nro_inscripcion();
        $parametro['ua'] = $uA;
        $parametro['carrera'] = guarani::persona()->get_id_carrera_activa();
        
        $urls = catalogo::consultar('certificados', 'mostrar_certif_descarga', $parametro);
        
        return $urls;
    }
    

}
