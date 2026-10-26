<?php
namespace kernel;

class error_kernel extends \Exception
{
	protected $params = array();
	protected $force_ajax = false;
	
	function get_params()
	{
		return $this->params;
	}
	
	function get_mensaje()
	{
		return $this->getMessage();
	}
	
	function add_param($key, $value) 
	{
		$this->params[$key] = $value;
	}
	
	function force_ajax($val)
	{
		$this->force_ajax = $val;
	}
	
	function get_force_ajax()
	{
		return $this->force_ajax;
	}
}


?>