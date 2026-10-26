<?php

namespace personalizacionCEMEDDIPLOMA\extension_kernel;

use kernel\kernel;
use kernel\interfaz\pagina as pagina_base;
use siu\modelo\datos\catalogo;
use siu\guarani;
include_once '../../../instalacion/versionActual.php';

class pagina extends \siu\extension_kernel\pagina {

    
    function get_titulo_completo() {
        return 'Guarani - ' . $this->get_etiqueta('titulo');
    }

    protected function get_contexto_template() {
        $contexto = parent::get_contexto_template();


        $contexto['version'] = VERSION;

        if (COLOR === 'desarrollo') {
            $contexto['estilo'] = "brand-nav-desarrollo";
        } else if (COLOR === 'integracion') {
            $contexto['estilo'] = "brand-nav-integracion";
        }else if (COLOR === 'test') {
            $contexto['estilo'] = "brand-nav-test";    
        } else {
           $contexto['estilo'] = "brand-nav";
        }



        $contexto['url_img_logo'] = kernel::vinculador()->vinculo_img('logo-transparente.png');
        $contexto['url_img_logo_celular'] = kernel::vinculador()->vinculo_recurso('/img/logo-celular.png');
        $contexto['url_inicio'] = kernel::vinculador()->crear_home();
        $contexto['urls_guarani_css'] = kernel::vinculador()->vinculo_css('guarani');
        $contexto['personalizacion'] = kernel::proyecto()->get_personalizacion_activa();
        $contexto['mash_personalizado'] = count($contexto['urls_guarani_css']) > 1;
        if (!kernel::sesion()->abierta()) {
            return $contexto;
        }

        if (kernel::persona()->perfil()->es('ALU')) {
            $carrera_activa = kernel::persona()->get_info_carrera_activa();

            $contexto['persona']['carrera_activa'] = $carrera_activa;
            $lista_carreras = kernel::persona()->get_lista_carreras();
            $contexto['persona']['carreras'] = array(
                'lista' => $lista_carreras,
                'cantidad' => count($lista_carreras),
                'url_operacion' => kernel::vinculador()->crear('inicio_alumno')
            );
        }
        if (kernel::persona()->get_count_perfiles() > 1) {
            $contexto['perfiles'] = kernel::persona()->get_perfiles();
            $contexto['perfil_activo'] = kernel::persona()->get_id_perfil_activo();
        }

        $contexto['url_cambio_perfil'] = kernel::vinculador()->crear('acceso', 'perfil');
        $contexto['url_cambio_carrera'] = kernel::vinculador()->crear('acceso', 'cambiar_carrera');
        $contexto['persona']['url_logout'] = kernel::vinculador()->crear('acceso', 'logout');
        $contexto['persona']['url_configuracion'] = kernel::vinculador()->crear('configuracion');

        $contexto['es_produccion'] = kernel::proyecto()->get_produccion();
        $contexto['log_activo'] = kernel::log()->esta_activo();
        $contexto['barra_dev'] = kernel::proyecto()->get('barra_dev');
        $contexto['log_id'] = kernel::log()->get_id();
        $contexto['url_log'] = kernel::vinculador()->crear_sin_chequeo('logger');
        $contexto['url_log_info'] = kernel::vinculador()->crear_sin_chequeo('logger', 'ajax_info_log');

        $contexto['url_mensajes'] = kernel::vinculador()->crear('mensajes');

        $datos = guarani::persona()->get_cantidad_mensajes();
        if ($datos) {
            $cantidad_mensajes = $datos['TOTAL'] - $datos['LEIDOS'];
            $contexto['cantidad_mensajes'] = $cantidad_mensajes;
        } else {
            $contexto['cantidad_mensajes'] = 0;
        }

        return $contexto;
    }

}

?>