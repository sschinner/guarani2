<?php

namespace siu\extension_kernel;

use kernel\interfaz\vistas\vista_pagelets;
use kernel\kernel;

abstract class vista_g3w2 extends vista_pagelets
{
	protected $hay_mensajes = false;
    protected $error = false;
	
	function get_extra_params()
	{
		$params = parent::get_extra_params();
		if (kernel::sesion()->abierta()) {
			$params['cant_mensajes'] = kernel::persona()->get_cantidad_mensajes();
			$params['cant_req_pendientes'] = kernel::persona()->get_cant_requisitos_pendientes();
		}
		
		return $params;
	}
	
	function set_hay_mensajes($hay_mensajes)
    {
        $this->hay_mensajes = $hay_mensajes;
    }
	
	function set_error($error)
	{
		$this->error = $error;
	}
	
    protected function before_render()
    {
        $this->agregar_a_contexto('hay_mensajes', $this->hay_mensajes);
        if ($this->hay_mensajes) {
            // se buscan en el controlador que es donde se generan
            $this->agregar_a_contexto('mensajes', $this->controlador->get_var('mensajes'));
        }
		
        $this->agregar_a_contexto('error', $this->error);
    }
    

	/**
	 * Se agrega una función en especial para poder desactivar la renderización
	 * en caso de haya error
	 * @param type $nombre 
	 */
	function render_pagelet($nombre)
	{
		if (! $this->error) {
			return $this->pagelet($nombre)->render();
		}
		
		return '';
	}
	
	
}
?>
