<?php

namespace kernel\interfaz\componentes\forms;

use kernel\nucleo\controlador;
use kernel\util\validador;

abstract class vista_form
{

	/**
	 * @var form
	 */
	protected $form;

	/**
	 * //la salida del layout
	 */
	protected $salida;

	/**
	 * @var layout_vista
	 */
	protected $layout;


	function get_salida()
	{
		return $this->salida;
	}

	function render()
	{
		$html =	$this->render_encabezado();
		$html .= $this->render_cuerpo();
		$html .= $this->render_cierre();
		return $html;
	}

	function render_encabezado()
	{
		$this->form->inicializar();
		$this->form->evt_pre_render();
		return $this->layout->render_encabezado();
	}

	function render_cuerpo()
	{
		return $this->layout->render_cuerpo();
	}

	function render_cierre()
	{
		return $this->layout->render_cierre();
	}

	function render_acciones()
	{
		$this->form->inicializar(); //puede que se llame primero. Igual se cachea la inicializacion
		return $this->layout->render_acciones();
	}


}