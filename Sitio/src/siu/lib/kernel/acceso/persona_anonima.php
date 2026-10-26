<?php

namespace kernel\acceso;
use kernel\kernel;

class persona_anonima extends persona_con_derechos
{
    protected $perfil;
    
    function __construct()
    {
        $this->perfil = factory_perfil::instancia()->construir('anonimo', kernel::proyecto()->get('bloque_acceso'));
    }
    
	// Cualquier llamada no reconocida a la persona anónima se interpreta como 
	// el deseo de ejecutar un método de la persona logueada, por eso se redirige
	// a la operación de login
	function __call($name, $arguments) {
		throw new \kernel\nucleo\nuevo_request($this->perfil->get_parametro('login'), 'login');
    }
	
    function perfil()
    {
        return $this->perfil;
    }

    function get_perfiles()
    {
        return array('anonimo');
    }

    function set_perfil_activo($id_perfil)
    {
    }
    
    function get_locale()
    {
        return false;
    }

	function get_id()
	{
		return '-1';
	}
	
    public function get_nombre()
    {
        return '';
    }
	
	public function get_name()
	{
		return '';
	}
}

?>
