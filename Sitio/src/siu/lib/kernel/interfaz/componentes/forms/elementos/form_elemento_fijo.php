<?php

namespace kernel\interfaz\componentes\forms\elementos;

use kernel\error_kernel;
use kernel\interfaz\componentes\forms\form_elemento;
use kernel\interfaz\componentes\forms\form_elemento_config;
use kernel\kernel;

class form_elemento_fijo extends form_elemento
{
	protected $html;
	protected $data_html5;
	
	function __construct($nombre, $def)
	{
		parent::__construct($nombre, $def);
		$this->def[form_elemento_config::elemento] = array('tipo' => 'fijo');
		$this->data_html5 = array();
	}

	function set_html($html)
	{
		$this->html = $html;
	}

	function evt_pre_render()
	{
		$this->guardar_valor_sesion();
	}
	
	protected function get_clave_sesion()
	{
		return "campo_fijo-" . $this->id_form . "-" . $this->nombre;
	}
	
	protected function guardar_valor_sesion()
	{
		$guardar = array(
			'valor' => $this->get_valor(),
			'data_html5' => $this->data_html5
		);
		kernel::sesion()->set($this->get_clave_sesion(), $guardar);
	}
	
	function set_valor_desde_sesion()
	{
		$valor_sesion = kernel::sesion()->get($this->get_clave_sesion());
		kernel::sesion()->borrar($this->get_clave_sesion());
		$this->set_valor($valor_sesion['valor']);
		$this->data_html5 = $valor_sesion['data_html5'];
	}
	
	function get_html()
	{
		return $this->html;
	}

	function validar()
	{
		return true;
	}

	function set_valor($valor)
	{
		$this->html = $valor;
	}

	function get_valor()
	{
		return $this->html;
	}

	function set_data_html5($key, $valor)
	{
		$this->data_html5[$key] = $valor;
	}
	
	function get_data_html5()
	{
		return $this->data_html5;
	}
	
	
	function set_valor_desde_post($valor)
	{
		throw new error_kernel("No se puede setear el valor de un campo fijo a través del post");
	}

}

?>
