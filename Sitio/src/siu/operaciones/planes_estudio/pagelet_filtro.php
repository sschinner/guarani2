<?php
namespace siu\operaciones\planes_estudio;

use kernel\interfaz\pagelet;
use kernel\kernel;

class pagelet_filtro extends pagelet {
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

	/**
	 * @return guarani_form
	 */
	function get_form()
	{
		return $this->get_builder_form()->get_formulario();
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
				$this->form_builder = kernel::localizador()->instanciar('operaciones\planes_estudio\filtro\builder_form_filtro');
		}

		return $this->form_builder;
	}

	public function prepare()
	{
		// Obtenemos el formulario del builder
		$form = $this->get_builder_form()->get_formulario();
		// Lo inicializamos
		$form->inicializar();
		// Se agrega al pagelet
		$this->add_form($form);
		
		$operacion = kernel::ruteador()->get_id_operacion();
		$this->add_var_js('url_buscar_planes', kernel::vinculador()->crear($operacion, 'buscar_planes'));
		$this->add_var_js('url_buscar_versiones', kernel::vinculador()->crear($operacion, 'buscar_versiones'));
		$this->add_mensaje_js('filtro_seleccione_plan', ucfirst(kernel::traductor()->trans('planes_estudio.filtro_seleccione_plan')));
		$this->add_mensaje_js('filtro_seleccione_version', ucfirst(kernel::traductor()->trans('planes_estudio.filtro_seleccione_version')));
	}
}
?>