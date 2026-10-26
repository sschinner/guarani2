<?php

namespace kernel\nucleo;

use kernel\acceso\login_manager;
use kernel\error_kernel;
use kernel\kernel;

class sesion
{
	const tipo_web = 0;
	const tipo_shell = 1;
		

    function __construct()
    {
		session_name($this->get_session_name());
		$secure_cookie = (kernel::proyecto()->get_ssl_alcance() == ruteador::SSL_ALCANCE_ALL);
		session_set_cookie_params(0, $this->get_cookie_path(), $this->get_cookie_domain(), $secure_cookie, true);
        session_start();
		
    }

	protected function get_session_name()
	{
		$alias = '';
		if (! is_null(kernel::proyecto()->get_alias())) {
			$alias = ltrim(kernel::proyecto()->get_alias(), '/'); // se saca la / del principio del alias
		}
		$postfix = $alias.'_'.kernel::proyecto()->get_bloque_acceso();
		
		return "siu_sess_$postfix";
	}
	
	protected function get_cookie_domain()
	{
		$server = kernel::proyecto()->get_server_name();
		// hay que hacer esto para que ande en chrome
		// https://code.google.com/p/chromium/issues/detail?id=56211
		if ($server == 'localhost') {
			$server = null;
		}
		
		return $server;
	}
	
	protected function get_cookie_path()
	{
		if (! is_null(kernel::proyecto()->get_alias())) {
			return kernel::proyecto()->get_alias();
		} else {
			return '/';
		}
	}
	

	function abrir_sin_autenticacion($id_persona)
	{
		$this->abrir_sesion($id_persona, false);
	}
	
	public function abrir_sesion($id_persona, $remember)
	{
        session_regenerate_id(true);
		$this->set('__kernel_ses_abierta', true);
        $this->set('__kernel_id_persona', $id_persona);
        $this->set('__kernel_id_login', $id_persona);
//        $this->set('__kernel_ses_start', time());
//        $this->set('__kernel_ses_last_request', time());
        if ($remember) {
            session_set_cookie_params(86400*30);	
        }
		//kernel::persona(true); // Recargar la persona		
	}

    /**
     * Devuelve verdadero si existe actualmente un usuario logueado, sino false
     */
    function abierta()
    {
        $clave = '__kernel_ses_abierta';
        return $this->esta_seteada($clave) && $this->get($clave);
    }
    
    /**
     *
     * @return el id de la persona logueada
     */
    function get_id_persona()
    {
        return $this->get('__kernel_id_persona');
    }
    
	/**
	 *
	 * @return string el valor que introdujo en el campo nombre al loguearse
	 */
	function get_id_login()
    {
        return $this->get('__kernel_id_login');
    }
    
    function set($clave, $valor)
    {
        $_SESSION[$clave] = $valor;
    }
    
    function get($clave)
    {
        return $_SESSION[$clave];
    }
	
	function get_con_default($clave, $default = false)
	{
		if (!$this->esta_seteada($clave)) {
			return $default;
		}
		
		return $this->get($clave);
	}
    
    function borrar($clave)
    {
        unset($_SESSION[$clave]);
    }
    
    function esta_seteada($clave)
    {
        return isset($_SESSION[$clave]);
    }
    
    function cerrar()
    {
		session_regenerate_id(true);	
        $sessionName = session_name();
        $sessionCookie = session_get_cookie_params();
        setcookie($sessionName, false, $sessionCookie['lifetime'], $sessionCookie['path'], $sessionCookie['domain'], $sessionCookie['secure']);    
        session_destroy();
    }

}

?>
