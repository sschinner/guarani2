<?php

namespace personalizacionUNL\operaciones\gestionar_diploma;

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
        $this->data = array();
        
        $operacion = kernel::ruteador()->get_id_operacion();
        
        $parametro['nro_inscripcion'] = guarani::persona()->get_nro_inscripcion();
        $parametro['nro_certificado'] = $this->controlador->get_nroCertificado();
        $parametro['carrera'] = guarani::persona()->get_id_carrera_activa();

        $certificadosSolicitados = catalogo::consultar('certificados', 'buscar_certificados_solicitados', $parametro);
        
        $this->data['accionDiploma'] = kernel::vinculador()->crear($operacion, 'invocar_pdf_diploma');
        $this->data['accionTituloTramite'] = kernel::vinculador()->crear($operacion, 'invocar_pdf_tramite');
        $this->data['accionCertificadoAnalitico'] = kernel::vinculador()->crear($operacion, 'invocar_pdf_certificado');
        
        $this->data['lista_certificados'] = $certificadosSolicitados;
       
        $this->data['sexo'] = guarani::persona()->get_sexo();
        $operacion = kernel::ruteador()->get_id_operacion();
        $this->data['url_nueva_solicitud'] = kernel::vinculador()->crear($operacion, 'nueva_solicitud');
        $this->data['url_visualizar'] = kernel::vinculador()->crear($operacion, 'visualizar');
     
    }

}
