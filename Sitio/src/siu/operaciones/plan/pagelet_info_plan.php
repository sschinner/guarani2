<?php
namespace siu\operaciones\plan;

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
        $controlador = kernel::ruteador()->get_id_operacion();
		$this->add_var_js('url_correlativas', kernel::vinculador()->crear('plan', 'correlativas'));
		$this->add_var_js('url_pdf', kernel::vinculador()->crear('plan', 'generar_pdf'));
		$this->add_var_js('url_xls', kernel::vinculador()->crear('plan', 'generar_excel'));
        $this->add_var_js('url_verificar_correlativas', kernel::vinculador()->crear($controlador, 'verificar_correlativas'));

		$this->add_var_js('ver', ucfirst(kernel::traductor()->trans('plan.ver')));
		$this->add_var_js('ocultar', ucfirst(kernel::traductor()->trans('plan.ocultar')));
	}
}
?>