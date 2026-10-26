<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;
use kernel\kernel;

class pagelet_filtro extends pagelet 
{
	protected $form_builder;
	
	public function get_nombre()
	{
		return 'filtro';
	}

	function get_js_files()
	{
		$archivos = parent::get_js_files();
		$archivos = array_merge($archivos, $this->get_vista_form()->get_js_files());
		return $archivos;
	}
	
	function get_vista_form(){
		return $this->get_builder_form()->get_vista();
	}
	
	/**
	* @return builder_form_nombres
	*/
	function get_builder_form()
	{
		// se hace esta función para no construir cada vez el builder
		if (! isset($this->form_builder)) {
				$this->form_builder = kernel::localizador()->instanciar('operaciones\ficha_alumno\filtro\builder_form_filtro');
		}

		return $this->form_builder;
	}

	public function prepare()
	{
		$this->add_var_js('url_autocomplete_filtro', kernel::vinculador()->crear('ficha_alumno', 'auto_alumno'));
		$this->add_mensaje_js('no_se_encontraron_alumnos', ucfirst(kernel::traductor()->trans('ficha_alumno.no_se_encontraron_alumnos')));
		$this->add_mensaje_js('esconder_menu', ucfirst(kernel::traductor()->trans('ficha_alumno.esconder_menu')));
		$this->add_mensaje_js('mostrar_menu', ucfirst(kernel::traductor()->trans('ficha_alumno.mostrar_menu')));
		
		// Obtenemos el formulario del builder
		$form = $this->get_builder_form()->get_formulario();
		// Lo inicializamos
		$form->inicializar();
		// Se agrega al pagelet
		$this->add_form($form);
		
		$this->data['datos_alumno'] = $this->controlador->get_datos_alumno();
	}
}
?>