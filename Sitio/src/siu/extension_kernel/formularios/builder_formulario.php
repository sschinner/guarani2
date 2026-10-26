<?php
/**
 * Created by IntelliJ IDEA.
 * User: alejandro
 * Date: 8/27/13
 * Time: 12:13 PM
 * To change this template use File | Settings | File Templates.
 */

namespace siu\extension_kernel\formularios;


use siu\guarani;

abstract class builder_formulario {

	/**
	 * @var guarani_form
	 */
	private $form;
	/**
	 * @var guarani_vista_form
	 */
	protected $vista;

	/**
	 * Arreglo para el layout_grilla
	 */
	protected abstract function get_configuracion_layout_grilla();

	protected abstract function get_id_html();

	protected abstract function get_action();

	protected abstract function generar_definicion(guarani_form $form, fabrica_formularios $fabrica);

	/**
	 * La primera vez que se invoca se genera el form, luego no se aplican cambios
	 * @return guarani_form
	 */
	public function get_formulario(){
		if(!isset($this->form)){
			$this->form = $this->instanciar_formulario();
		}
		return $this->form;
	}

	/**
	 * La primera vez que se invoca se configura la vista,
	 * se utilice la vista.
	 * @return guarani_vista_form
	 */
	public function get_vista(){

		if(!isset($this->vista)){
			$this->vista = $this->instanciar_vista_formulario();
		}
		return $this->vista;
	}

	protected function instanciar_formulario()
	{
		$fabrica = guarani::formularios();
		$form = $fabrica->formulario();
		$form->set_action($this->get_action());
		$form->set_id_html($this->get_id_html());
		$this->generar_definicion($form, $fabrica);
		return $form;
	}

	protected function instanciar_vista_formulario()
	{
		$fabrica = guarani::formularios();
		$form = $this->get_formulario();
		$vista = $fabrica->formulario_vista();
		$salida = $fabrica->formulario_salida_html();
		$vista->configurar($form, $this->get_configuracion_layout_grilla(), $salida);
		return $vista;
		//$form->set_vista_helper($this->vista);
	}

}