<?php
namespace siu\operaciones\asistencias;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista_libres extends vista_g3w2
{
	function ini()
	{
		$this->set_template('template_vista_libres');

		$clase = 'operaciones\asistencias\pagelet_libres';
		$pl = kernel::localizador()->instanciar($clase, 'libres');
		$this->add_pagelet($pl);

		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_asistencia_alumnos_libres"));

		/* url botón Volver */
		$operacion = kernel::ruteador()->get_id_operacion();
		$this->agregar_a_contexto('url_back', kernel::vinculador()->crear($operacion));
	}
}

?>