<?php

namespace kernel\interfaz\componentes\forms;


abstract class layout_vista
{

	/**
	 * @var salida
	 */
	protected $salida;
	/**
	 * @var form
	 */
	protected $form;


	public function set_salida($salida)
	{
		$this->salida = $salida;
	}

	public function set_form($form)
	{
		$this->form = $form;
	}

	/**
	 * Imprime/retorna completamente el formulario con un solo llamado. Util para
	 * cuando no se desea incluir contenido adicional en el form.
	 * NO incluye las acciones
	 */
	public function render_completo()
	{
		$this->render_encabezado();
		$this->render_cuerpo();
		$this->render_cierre();
	}

	/**
	 * Imprime/retorna solo el tag form para poder incluir el submit en el encabezado por ej.
	 */
	public abstract function render_encabezado();

	/**
	 * Cierra el tag incluido por render_encabezado()
	 */
	public abstract function render_cierre();

	/**
	 * Imprime/retorna el contenido del formulario
	 */
	public abstract function render_cuerpo();

	/**
	 * Imprime/retorna las acciones del formulario (submit y otras)
	 */
	public abstract function render_acciones();


}