<?php

namespace personalizacionUNL\operaciones\pasantia;

use Exception;
use kernel\kernel;
use kernel\nucleo\controlador as controlador_base;
use kernel\util\db\db;
use kernel\util\u;
use kernel\util\validador;
use siu\errores\error_procesar_datos_censales;
use siu\guarani;
use siu\modelo\datos\catalogo;
use siu\modelo\entidades\unidad_academica;
use siu\modelo\guarani_notificacion;

class controlador extends \siu\operaciones\_comun\operaciones\reporte\controlador {

    function accion__index() {

        $pagelet = $this->vista()->pagelet('formulario');

        $pagelet->ver_pagina(1);
    }

    function accion__ver_pagina() {
        $pagina = kernel::url()->get_param('pagina', 'get');
        $columna = kernel::url()->get_param('col', 'get');
        $orden = kernel::url()->get_param('ord', 'get');

        $pagelet = $this->vista()->pagelet('formulario');
        $pagelet->ver_pagina($pagina, $columna, $orden);

        kernel::renderer()->add($pagelet);
    }

    function accion__guardar() {

        if (kernel::request()->isPost()) {

            $u = new unidad_academica(guarani::get_ua_id());
            $uA = utf8_encode($u->get_id());

            $parametros = array();
            $parametros['id_pasantia'] = kernel::request()->getPost('pas_id');
            $parametros['legajo'] = kernel::persona()->get_id_legajo_activo();
            $parametros['plan'] = kernel::persona()->get_id_plan_activo();
            $parametros['carrera'] = kernel::persona()->get_id_carrera_activa();
            $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
            $parametros['interface'] = '3';
            $parametros['_ua'] = $uA;


            $control = catalogo::consultar('alumno', 'pasantias_control_ins', $parametros);

            if ($control[0][0] == 1) {
                $datos = catalogo::consultar('alumno', 'pasantias_procesa_ins', $parametros);
                $pagelet = $this->vista()->mostar();
                $this->add_var('formulario', $pagelet);
                kernel::renderer()->add($this->vista()->pagelet('formulario'));
            } else {
                $texto = ($control[0][1]/*'No se puede inscribir a la pasantía selecionada debido a que no cumple con los requisitos.'*/);
                $mensajes[] = new guarani_notificacion(guarani_notificacion::error, $texto);
                $this->add_var('mensajes', $mensajes);
                kernel::renderer()->add($this->vista()->pagelet('formulario2'));
            }
        }
    }

    function accion__baja() {

        if (kernel::request()->isPost()) {

            $u = new unidad_academica(guarani::get_ua_id());
            $uA = utf8_encode($u->get_id());

            $parametros = array();
            $parametros['id_pasantia'] = kernel::request()->getPost('id_pasantia_baja');
            $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
            $parametros['interface'] = '3';
            $parametros['_ua'] = $uA;

            $datos = catalogo::consultar('alumno', 'pasantias_procesa_baja', $parametros);

            if ($datos[0][0] == '1') {
                $pagelet = $this->vista()->mostarBaja();
                $this->add_var('formulario', $pagelet);
                kernel::renderer()->add($this->vista()->pagelet('formulario'));
            } else {
                $contenido = explode(',', $datos[0][1]);


                if ($contenido[0] == '800404') {
                    $texto = utf8_decode('La fecha tope para darse de baja de la pasantía selecionada ha pasado.');
                    $mensajes[] = new guarani_notificacion(guarani_notificacion::error, $texto);
                    $this->add_var('mensajes', $mensajes);

                    kernel::renderer()->add($this->vista()->pagelet('formulario2'));
                } else {
                    $mensajes[] = new guarani_notificacion(guarani_notificacion::error, 'Se ha producido un error, luego de unos minutos vuelva a intentar. Disculpe las molestias.');
                    $this->add_var('mensajes', $mensajes);
                    kernel::renderer()->add($this->vista()->pagelet('formulario'));
                }
            }
        }
    }

}

?>
