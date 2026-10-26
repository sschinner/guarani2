<?php

namespace kernel\nucleo;
use kernel\kernel;

class nuevo_request extends \Exception
{
    protected $operacion;
    protected $accion;
    protected $ssl;
	protected $url;
	protected $mensaje_post_nav = false;
    
    function __construct($operacion = 'home', $accion = 'index', $ssl = false)
    {
        $this->operacion = $operacion;
        $this->accion = $accion;
		$this->ssl = $ssl;
    }
    
	function set_url($url)
	{
		$this->url = $url;
	}
	
	function tiene_mensaje_post_nav()
	{
		return $this->mensaje_post_nav !== false;
	}
	
	function set_mensaje_post_nav($mensaje)
	{
		$this->mensaje_post_nav = $mensaje;
	}
	
	function get_mensaje_post_nav()
	{
		return $this->mensaje_post_nav;
	}
	
    function get_url()
    {
        $op  = $this->get_operacion();
        $ac  = $this->get_accion();
        $url = (isset($this->url)) ? $this->url : kernel::vinculador()->crear($op, $ac, array(), array(
			'ssl' => $this->ssl
		));
        
        return $url;
    }
    
    function get_operacion()
    {
        return $this->operacion;
    }
    
    function get_accion()
    {
        return $this->accion;
    }    
}

?>
