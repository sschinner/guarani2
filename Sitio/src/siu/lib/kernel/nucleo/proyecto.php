<?php
namespace kernel\nucleo;

use kernel\util\manejador_archivos;
use kernel\error_kernel;
use kernel\util;

class proyecto implements \kernel\nucleo\interface_proyecto
{
	protected $db_param;
	protected $alias;
	protected $dir_log;
	protected $dir_instalacion;
	protected $dir_cache;
	protected $dir_perfiles;
	protected $dir_temp;
	protected $clase_persona;
	protected $clase_login;
	protected $clase_pagina;
	protected $bloque_acceso;
	protected $encoding;
    protected $extensiones;
    
    function __construct($extensiones = array())
    {
        $this->extensiones = $extensiones;
    }

    function get($param) 
    {
		if($this->tiene($param)) {
	        return $this->extensiones[$param];
		} else {
			throw new error_kernel('No existe el parametro de configuracion: '. $param);
		}
    }
	
    function tiene($param)
    {
        return array_key_exists($param, $this->extensiones);
    }
    
	function nulo($param)
	{
		return is_null($this->extensiones[$param]);
	}
	
	function set_bloque_acceso($id)
	{
		$this->bloque_acceso = $id;
	}
	
	function get_bloque_acceso()
	{
		return $this->bloque_acceso;
	}
	
	function get_server_name()
	{
		if ($this->tiene('server_name') && ! $this->nulo('server_name')) {
			return $this->get('server_name');
		}
		
		if (isset($_SERVER['SERVER_NAME'])) {
			return $_SERVER['SERVER_NAME'];	
		}
		
		return '';
	}
	
	function get_parametros_db()
	{
		return $this->get('db');
	}

	function set_encoding($enc)
	{
		$this->encoding = $enc;
	}
	
	function get_encoding()
	{
		if (! isset($this->encoding)) {
			return 'utf-8';
		} 
		
		return $this->encoding;
	}
	
	function is_utf8()
	{
		return $this->encoding == 'utf-8';
	}
	
	function get_produccion()
	{
		return $this->get('produccion');
	}
	
	function get_alias()
	{
		return $this->get('alias');
	}

	function get_dir_instalacion()
	{
		return $this->get('dir_instalacion');
	}
	
	function get_dir_log()
	{
		return $this->get('dir_log');
	}

	function get_dir_cache()
	{
		return $this->get('dir_cache');
	}

    function get_dir_ops_inactivas()
    {
        return $this->get('dir_ops_inactivas');
    }

	function get_dir_temp()
	{
        if (!is_dir($this->get('dir_temp'))) {
            manejador_archivos::crear_arbol_directorios($this->get('dir_temp'));
        }

		return $this->get('dir_temp');
	}

    function get_dir_perfiles()
	{
		return $this->get('dir_perfiles');
	}

    function get_clase_persona()
	{
		return $this->get('clase_persona');
	}
	
	function hay_personalizacion_activa()
	{
		return $this->get_personalizacion_activa() != '';
	}
	
	function get_personalizacion_activa()
	{
		return $this->get('personalizacion');
	}

	function get_clase_persona_anonima()
	{
		return $this->get('clase_persona_anonima');
	}

    function get_clase_pagina()
    {
        return $this->get('clase_pagina');
    }
    
	function get_clase_logger()
    {
		if ($this->tiene('clase_logger')) {
			return $this->get('clase_logger');
		}
		return false;
    }
    
    function get_default_locale()
    {
        return 'en';
    }
    
    function get_url_recursos()
    {
        return $this->get('url_recursos');
    }
	
	function get_custom_session_handler()
	{
		return false;
	}
	
	function es_pipe_nav()
	{
		if ($this->tiene('pipe_nav')) {
			return $this->get('pipe_nav');
		}
		
		return true;
	}
	
	function get_ajax_nav()
	{
		if ($this->tiene('ajax_nav')) {
			return $this->get('ajax_nav');
		}
		
		return true;
	}

    function get_ssl_alcance()
    {
        if ($this->tiene('ssl_alcance')) {
            return $this->get('ssl_alcance');
        }

        return 'none';
    }

    function get_ssl_redirigir_ssl()
    {
        if ($this->tiene('ssl_redirigir_ssl')) {
            return $this->get('ssl_redirigir_ssl');
        }

        return true;
    }

	function get_parametros_smtp()
	{
		if ($this->tiene('smtp')) {
			return $this->get('smtp');
		}
		
		throw new \kernel\error_kernel('No hay parametros smtp definidos en el archivo de configuración');
	}
	
	function usa_captcha()
	{
		return $this->get('usa_captcha');
	}
	
	function get_captcha_intentos_login()
	{
		return $this->get('intentos_login_captcha');
	}
	
	function get_captcha_site_key()
	{
		return $this->get('captcha_site_key');
	}

	function get_captcha_secret_key()
	{
		return $this->get('captcha_secret_key');
	}
	
	function usa_proxy()
	{
		return $this->get('usa_proxy');
	}
	
	function get_parametros_proxy()
	{
		return $this->get('parametros_proxy');
	}

	function get_login_config()
	{
		return $this->get('login_config');
	}

	function get_fuente_usuarios()
	{
		return $this->get('fuente_usuarios');
	}
	
	function get_ga_params()
	{
		return $this->get('ga_params');
	}

	
	function get_ws_config()
	{
		return $this->get('servicios_web');
	}


	/**
	 * Provee un cliente instanciado con la configuracion de get_ws_config. El proyecto puede
	 * crear el cliente a su criterio si requiere
	 * @param $id_servicio
	 * @return \GuzzleHttp\Client
	 * @throws \kernel\error_kernel
	 */
	function get_ws_cliente($id_servicio)
	{
		$ws_conf = $this->get_ws_config();
		$consumidos = $ws_conf['consumidos'];
		if (! isset($consumidos[$id_servicio])) {
			throw new error_kernel("El servicio web '$id_servicio' no existe en el archivo de configuración");
		}
		$servicio = $consumidos[$id_servicio];
		if($servicio['tipo'] == 'rest'){
			$cliente = new util\ws_cliente_rest($consumidos[$id_servicio]['parametros']);
			return $cliente->guzzle();
		}else {
			return new \kernel\util\ws_cliente($id_servicio, $ws_conf[$id_servicio]);
		}

	}


    /**
     * Función que se ejecuta inmediatamente antes de conectarse a la DB.
     */
    public function pre_conexion(){}

    /**
     * Función que se ejecuta inmediatamente después de conectarse a la DB.
     * @param util\db\interface_db $conexion
     */
    public function pos_conexion($conexion){}

}

?>