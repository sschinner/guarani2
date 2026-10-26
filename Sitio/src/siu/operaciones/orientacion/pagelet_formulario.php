<?php
namespace siu\operaciones\orientacion;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\guarani;

class pagelet_formulario extends pagelet
{
	function ini()
	{
	}
	
	function get_nombre()
	{
		return 'formulario';
	}

	function hay_mensaje()
	{
		return $this->controlador->get_var('mens_actualizacion');
	}
	
	function prepare()
	{
		$titulos_orientacion = $this->controlador->modelo()->titulos_orientacion();
		$this->data['titulos_orientacion'] = $titulos_orientacion;
		
//		$orientaciones = $this->controlador->modelo()->lista_orientaciones();
//		$this->data['orientaciones'] = $orientaciones;
//		
//		$o_actual = $this->controlador->modelo()->orientacion_actual();
//		$this->data['orientacion_actual'] = $o_actual;
//		
		$link_form = kernel::vinculador()->crear('orientacion', 'seleccionar');
		$link_eliminar_orientacion = kernel::vinculador()->crear('orientacion', 'eliminar_orientacion');
		$this->data['form_url'] = $link_form;
		$this->data['legajo'] = guarani::persona()->get_id_legajo_activo();
		
		$this->add_var_js("confirmacion", ucfirst(kernel::traductor()->trans('confirmacion')));
		$this->add_var_js("mensaje_cambio_orientacion", ucfirst(kernel::traductor()->trans('mensaje_cambio_orientacion')));
		$this->add_var_js("url_eliminar_orientacion", $link_eliminar_orientacion);
		
		$this->add_var_js("cerrar", ucfirst(kernel::traductor()->trans('cerrar')));
		$this->add_var_js("acteptar", ucfirst(kernel::traductor()->trans('acteptar')));
	}
}
?>