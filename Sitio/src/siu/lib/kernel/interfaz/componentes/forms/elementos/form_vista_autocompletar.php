<?php

namespace kernel\interfaz\componentes\forms\elementos;

use kernel\interfaz\componentes\forms\form_elemento;
use kernel\interfaz\componentes\forms\vista_elemento;

class form_vista_autocompletar implements vista_elemento
{

	public static $clase_js = 'js-autocomplete';
	protected $fn_datos;
	protected $fn_formato;

	protected $url;

	public static function to_autocompletar($array, $col_id, $col_desc)
	{
		$json = array();
		foreach ($array as $fila) {
			$json[] = array(
				'id' => $fila[$col_id],
				'label' => $fila[$col_desc]
			);
		}
		return $json;

	}

	public function set_url($url)
	{
		$this->url = $url;
	}

	public function set_fn_datos($fn_datos)
	{
		$this->fn_datos = $fn_datos;
	}

	public function set_fn_formato_fila($fn_formato)
	{
		$this->fn_formato = $fn_formato;
	}


	public function render(form_elemento $elemento)
	{
		$e = $elemento->get_zend_element();
		if (isset($this->url)) {
			$e->setAttrib('class', self::$clase_js . ' ' . $e->getAttrib('class'))
				->setAttrib('data-url', $this->url);
		}
		return $e->renderViewHelper();
	}


	/**
	 * @return boolean Dice si tambien dibuja la etiqueta. Si no la dibuja, se la dibuja
	 * la vista.
	 */
	public function renderiza_label()
	{
		return false;
	}
}