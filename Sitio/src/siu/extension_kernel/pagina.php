<?php
namespace siu\extension_kernel;

use kernel\kernel;
use kernel\interfaz\pagina as pagina_base;
use siu\modelo\datos\catalogo;
use siu\guarani;

class pagina extends pagina_base
{
    function get_titulo_completo()
    {
        return 'Guarani - '.$this->get_etiqueta('titulo');
    }
    
    protected function get_contexto_template()
    {
        $contexto = parent::get_contexto_template();
        $contexto['url_img_logo']		  = kernel::vinculador()->vinculo_img('logo-transparente.png');			
		$contexto['url_img_logo_celular'] = kernel::vinculador()->vinculo_recurso('img/logo-celular.png');
		$contexto['url_inicio'] = kernel::vinculador()->crear_home();	
		$contexto['urls_guarani_css'] = kernel::vinculador()->vinculo_css('guarani');
		$contexto['personalizacion']  = kernel::proyecto()->get_personalizacion_activa();
		$contexto['mash_personalizado'] = count($contexto['urls_guarani_css']) > 1;
		$contexto['ga_params'] = kernel::proyecto()->get_ga_params();
        if (! kernel::sesion()->abierta()) {
            return $contexto;
        }

        $contexto['perfil'] = kernel::persona()->perfil();
        $contexto['perfil_activo'] = kernel::persona()->get_id_perfil_activo();
        $contexto['persona']['nombre'] = kernel::persona()->get_nombre();
		
        if (kernel::persona()->perfil()->es('ALU')) {
            $carrera_activa = kernel::persona()->get_info_carrera_activa();
            
			$contexto['persona']['carrera_activa'] = $carrera_activa;
			$lista_carreras = kernel::persona()->get_lista_carreras();
            $contexto['persona']['legajo'] = kernel::persona()->get_id_legajo_activo();
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

        if ($contexto['perfil_activo'] == 'DOC')
            $contexto['persona']['legajo'] = kernel::persona()->get_legajo_docente();

		if ($contexto['perfil_activo'] == 'ALU') 
		{
			$contexto['url_requisitos'] = kernel::vinculador()->crear('requisitos_ingreso');
			$contexto['cant_requisitos'] = guarani::persona()->get_cant_requisitos_pendientes();		
		}
		
        return $contexto;
    }
}

?>