<?php

namespace siu\extension_kernel\formularios;

use kernel\interfaz\componentes\forms\form;
use kernel\interfaz\componentes\forms\salida_layout_grilla;
use kernel\interfaz\componentes\forms\vista_form;
use kernel\kernel;
use kernel\nucleo\controlador;

class guarani_vista_form extends vista_form
{

	/**
	 * @var salida_bootstrap_grilla
	 */
	protected $salida;

	/**
	 * Configuracion defalut para hacer forms.
	 * @param form $form  el formulario
	 * @param array $grilla_conf la descripcion del layout
	 * @param $salida
	 */
	function configurar(form $form, $grilla_conf, salida_layout_grilla $salida){
		$this->layout = new guarani_layout_grilla($grilla_conf);
		$this->layout->set_salida($salida);
		$this->layout->set_form($form);
		$this->salida = $salida;
		$this->form = $form;
	}

	function get_js_files()
	{
		$archivos = array();
		$archivos[] = kernel::vinculador()->vinculo_recurso("js/lib/plugin.form.js");
		$archivos[] = kernel::vinculador()->vinculo_recurso("js/plugin_botonera.js");
		$archivos[] = kernel::vinculador()->vinculo_recurso("js/plugin_autocompletar.js");
		return $archivos;
	}




}