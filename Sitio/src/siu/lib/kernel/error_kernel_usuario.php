<?php

namespace kernel;

class error_kernel_usuario extends error_kernel
{
	protected $codigo_response = -1;
	
	function set_codigo_response($codigo)
	{
		$this->codigo_response = $codigo;
	}
	
	function get_codigo_response()
	{
		return $this->codigo_response;
	}
}

?>
