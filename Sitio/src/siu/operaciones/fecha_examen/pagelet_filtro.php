<?php
namespace siu\operaciones\fecha_examen;

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
        $archivos[] = kernel::vinculador()->vinculo_recurso("js/date-es-AR.js");
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
		$operacion = kernel::ruteador()->get_id_operacion();

		$this->add_var_js('url_buscar', kernel::vinculador()->crear($operacion));
		$this->add_var_js('url_buscar_planes', kernel::vinculador()->crear($operacion, 'buscar_planes'));
		$this->add_var_js('url_buscar_materias', kernel::vinculador()->crear($operacion, 'buscar_materias'));

        $this->add_mensaje_js('msg_error_fechas', kernel::traductor()->trans('fecha_examen.msg_error_fechas'));
        $this->add_mensaje_js('fecha_desde_invalida', kernel::traductor()->trans('fecha_examen.fecha_desde_invalida'));
        $this->add_mensaje_js('fecha_hasta_invalida', kernel::traductor()->trans('fecha_examen.fecha_hasta_invalida'));
        $this->add_mensaje_js('fecha_hasta_menor_fecha_desde', kernel::traductor()->trans('fecha_examen.error_fechas'));
        $this->add_mensaje_js('filtro_todos', ucfirst(kernel::traductor()->trans('fecha_examen.filtro_todos')));

        $this->add_var_js('ver', ucfirst(kernel::traductor()->trans('plan.ver')));
        $this->add_var_js('ocultar', ucfirst(kernel::traductor()->trans('plan.ocultar')));
	}
}
?>