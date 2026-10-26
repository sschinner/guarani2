<?php
namespace kernel\util;

use kernel\kernel;

class url
{
	const MAX_LENGHT_OPERACION = 30;
    const MAX_LENGHT_ACCION = 30;
	protected $pretty_urls;
	protected $params;
	
	function __construct($pretty_urls = false)
	{
		$this->pretty_urls = $pretty_urls;
		$this->params = $this->parse_params();
	}

	function self($force_ssl = false) 
	{
		if (! $force_ssl) {
			$s = empty($_SERVER["HTTPS"]) ? '' : ($_SERVER["HTTPS"] == "on") ? "s" : "";
		} else {
			$s = 's';
		}
		$protocol = u::strleft(strtolower($_SERVER["SERVER_PROTOCOL"]), "/").$s;
		return $protocol."://".$_SERVER['SERVER_NAME'].$_SERVER['REQUEST_URI'];
	}
	
	/**
	 * 
	 * @param boolean $bool 
	 */
	function set_pretty_urls($bool)
	{
		$this->pretty_urls = $bool;
		$this->params = $this->parse_params();
	}
	
	protected function parse_params()
	{
		$rs = array();
		if ($this->pretty_urls) {
			if (isset($_GET['__p'])) {
				$params = explode('/', $_GET['__p']);
				foreach ($params as $key => $param) {
					$param = str_replace(vinculador::TRANSFORMADOR_BARRA, '/', $param);
					$index = strpos($param, vinculador::SEPARADOR_PARAM_PRETTY_URLS);
					if ($index === false) {
						if (!empty($param)) {
							$rs[$key] = $param;
						}
					} else {
						$nombre = substr($param, 0, $index);
						$rs[$nombre] = substr($param, $index + 1);
					}
				}
			}
		} else {
			$rs = $_GET;
		}

		return $rs;
	}
	
	function show_params()
	{
		var_dump($this->params);
	}
	
	/**
	 * Comunica al manejador de url que la acción no fue especificada. Entonces
	 * el parámetro que vino en $_GET['__a'] es en realidad el primer parámetro de
	 * la operación por defecto
	 */
	function notificar_accion_no_especificada()
	{
		if (isset($_GET['__a'])) {
			array_unshift($this->params, $_GET['__a']);
		}
	}
	
	function get_controlador()
	{
		if (!isset($_GET['__o'])||!$_GET['__o']) {
			return kernel::persona()->perfil()->get_parametro('index');
		}
		
		return u::sanitize($_GET['__o'], 'php', self::MAX_LENGHT_OPERACION);
	}
	
	function get_accion()
	{
		if (!isset($_GET['__a'])) {
			return kernel::persona()->perfil()->get_accion_defecto($this->get_controlador());
		}
		
		return u::sanitize($_GET['__a'], 'php', self::MAX_LENGHT_ACCION);
	}
	
	function get_params()
	{
		return $this->params;
	}
	
	function get_param($key, $raw = false, $default = null)
	{
		$params = $this->get_params();
		if (!isset($params[$key])) {
			if (isset($_GET[$key])) {
				if ($raw) {
					return $_GET[$key];
				} else {
					return urldecode($_GET[$key]);
				}
			} else {
				return $default;
//				throw new \kernel\error_kernel("El parámetro $key no existe");
			}
		}
		
		return $params[$key];
	}
	
	function get_params_sync($id_bolsa = false)
	{
		$sync = $this->get_param(vinculador::KEY_PARAMS_SYNC);
		$controlador = $this->get_controlador();
		$accion = $this->get_accion();
		$id_bolsa = ($id_bolsa === false) ? kernel::vinculador()->get_id_bolsa($controlador, $accion) : $id_bolsa;
		
		return kernel::bolsas()->buscar($id_bolsa, $sync);
	}
	
	function get_param_sync($key, $id_bolsa = false)
	{
		$params = $this->get_params_sync($id_bolsa);
		if (!isset($params[$key])) {
			throw new \kernel\error_kernel("El parámetro $key no existe");
		}
		return $params[$key];
	}
	
	/**
	 *
	 * @param type $key
	 * @return type 
	 */
	function hay_param($key)
	{
		$params = $this->get_params();
		return (isset($params[$key]) && !empty($params[$key])) ||  isset($_GET[$key]);
	}
	
	function hay_param_sync($key)
	{
		if (! $this->hay_param(vinculador::KEY_PARAMS_SYNC)) {
			return false;
		}
		
		$params = $this->get_params_sync();
		return isset($params[$key]);
	}
}

?>
