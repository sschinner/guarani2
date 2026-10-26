<?php

namespace siu\extension_kernel\formularios\elementos;


class guarani_elemento_vista {


	protected $fn;

	function __construct($funcion)
	{
		$this->fn = $funcion;
	}

	public function render(){

		$funcion = $this->fn;

		return $funcion();
	}

}