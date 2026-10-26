<?php
namespace siu\operaciones\planes_estudio;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;

class pagelet_info_plan extends pagelet
{
	function get_nombre()
	{
		return 'info_plan';
	}

	function prepare()
	{
		
		$this->add_var_js('url_correlativas', kernel::vinculador()->crear('planes_estudio', 'correlativas'));
		$this->add_var_js('url_pdf', kernel::vinculador()->crear('planes_estudio', 'generar_pdf'/*, array(
			'carrera' => $this->data['nro_carrera'],
			'plan' => $this->data['nro_plan'],
			'version' => $this->data['nro_version'],
			'nombre_carrera' => $this->data['nombre_carrera']
			)*/));
		
		/*$this->add_var_js('carrera', $this->data['nro_carrera']);
		$this->add_var_js('plan', $this->data['nro_plan']);
		$this->add_var_js('version', $this->data['nro_version']);
		$this->add_var_js('nombre_carrera', $this->data['nombre_carrera']);*/
		
		$this->add_var_js('ver', ucfirst(kernel::traductor()->trans('plan.ver')));
		$this->add_var_js('ocultar', ucfirst(kernel::traductor()->trans('plan.ocultar')));
	}
}
?>