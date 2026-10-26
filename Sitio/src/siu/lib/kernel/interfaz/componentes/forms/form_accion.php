<?php

namespace kernel\interfaz\componentes\forms;


class form_accion {
	public $id;
	public $innerHtml;
	public $type;
	public $name;

	protected $vista_accion;


	/**
	 * @param string $id  id_html
	 * @param $innerHtml
	 * @param string $type submit por defecto, podría ser button

	 */
	function __construct($id, $innerHtml, $type = 'submit')
	{
		$this->id = $id;
		$this->innerHtml = $innerHtml;
		$this->type = $type;
	}


	/**
	 * @return vista_accion
	 */
	function get_vista_helper()
	{
		return $this->vista_accion;
	}

	function set_vista_helper(vista_accion $vista)
	{
		$this->vista_accion = $vista;
		return $vista;
	}

	public function set_id($id)
	{
		$this->id = $id;
		return $this;
	}

	public function set_name($name)
	{
		$this->name = $name;
		return $this;
	}


	public function set_type($type)
	{
		$this->type = $type;
		return $this;
	}


}