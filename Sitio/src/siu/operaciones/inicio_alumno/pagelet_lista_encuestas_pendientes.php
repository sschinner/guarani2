<?php

namespace siu\operaciones\inicio_alumno;

use kernel\kernel;
use kernel\interfaz\pagelet;

class pagelet_lista_encuestas_pendientes extends pagelet
{
	function get_nombre()
	{
		return 'lista_encuestas_pendientes';
	}

	function prepare()
	{
		$this->data['encuestas_pendientes'] = $this->controlador->info_encuestas_pendientes();
		$this->data['url_operacion_pendientes'] = kernel::vinculador()->crear('encuestas_kolla');

		$this->add_mensaje_js('msj_ancho_completo', ucfirst(kernel::traductor()->trans('inicio_alumno.msj_ancho_completo')));
		$this->add_mensaje_js('msj_ancho_3col', ucfirst(kernel::traductor()->trans('inicio_alumno.msj_ancho_3col')));
		kernel::log()->add_debug('encuestas_pendientes', $this->data);
	}
}
?>