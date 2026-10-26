<?php

namespace siu\extension_kernel;

use kernel\nucleo\controlador as controlador_base;
use kernel\nucleo\ruteador;
use kernel\util\u;
use kernel\kernel;
use kernel\nucleo\finalizador_request;
use siu\guarani;

/**
 * @property helper_controlador_g3w2 $helper
 */
abstract class controlador_g3w2 extends controlador_base
{

    protected $helper;

    public function __construct(){

        if(!isset($this->helper)){
            $this->helper = kernel::localizador()->instanciar('extension_kernel\helper_controlador_g3w2');
        }

    }

    /**
     * @return helper_controlador_g3w2
     */
    protected function get_helper(){
        return $this->helper;
    }

	/**
	 *
	 * @param type $key
	 * @param type $method
	 * @param string $type valores posibles: string, int, float, url, string_array, int_array
	 * @param array 
	 *	allow_quotes: boolean
	 *  trim: boolean
	 * @return type 
	 */
	protected function get_param($key, $method = 'post', $type = 'string', $options = array())
	{
		$value = ($method == 'post') ? kernel::request()->getPost($key) :  kernel::url()->get_param($key);
		return u::sanitize_value($value, $type, $options);
	}
	
	protected function force_ssl()
	{
        if ((kernel::proyecto()->get_ssl_alcance() == ruteador::SSL_ALCANCE_NONE) || (!kernel::proyecto()->get_ssl_redirigir_ssl())) {
            return;
        }
		
		if (!isset($_SERVER['HTTPS']) || $_SERVER["HTTPS"] != "on") {
			header("Location: ".kernel::url()->self(true));
			die;
		}
	}

    /**
     * Ventana que se ejecuta antes de ejecutar una acción
     */
    protected function pre_accion()
    {
        $this->get_helper()->pre_accion();
    }
}

?>
