<?php
namespace siu\operaciones\horarios_cursadas;

use kernel\interfaz\pagelet;
use kernel\kernel;

class pagelet_filtro extends pagelet {
	public function get_nombre()
	{
		return 'filtro';
	}

	function get_js_files()
	{
		$js = parent::get_js_files();
		$archivos = array_merge($js, $this->get_vista_form()->get_js_files());
		return $archivos;
	}

	/**
	 * @return guarani_form
	 */
	function get_form()
	{
		return $this->get_form_builder()->get_formulario();
	}

	function get_vista_form(){
		return $this->get_form_builder()->get_vista();
	}
	
	/**
	* @return builder_form_filtro
	*/
	function get_form_builder()
	{
		return $this->controlador->get_form_builder();
	}

	public function prepare()
	{
		// Obtenemos el formulario del builder
		$form = $this->get_form();
		$form->inicializar();
		$this->add_form($form);
		$datos = $form->get_datos();
		
		if (!empty($datos)){
			$this->add_var_js('turno', $datos['turno']);
			$this->add_var_js('periodo', $datos['periodo']);
		}
		
		$operacion = kernel::ruteador()->get_id_operacion();
		$this->add_var_js('url_buscar_horarios', kernel::vinculador()->crear($operacion, 'index'));
		$this->add_var_js('url_buscar_turnos', kernel::vinculador()->crear($operacion, 'buscar_turnos'));
		$this->add_var_js('url_buscar_periodos', kernel::vinculador()->crear($operacion, 'buscar_periodos'));
		$this->add_var_js('url_autocomplete_materia', kernel::vinculador()->crear($operacion, 'buscar_materia'));
		$this->add_var_js('mensaje_seleccione', kernel::traductor()->trans('horarios_cursadas.filtro_seleccione'));
		$this->add_var_js('url_buscar_materias', kernel::vinculador()->crear($operacion, 'buscar_materias'));
	}
}
?>