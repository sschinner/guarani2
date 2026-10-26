<?php
namespace siu\operaciones\historial_asistencias;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends \siu\operaciones\_comun\operaciones\reporte\vista
{
	function ini()
	{
		$clase = 'operaciones\historial_asistencias\pagelet_reporte';
		$pl = kernel::localizador()->instanciar($clase, 'items');
		$this->add_pagelet($pl);

		/* url botón Volver */
		$operacion = kernel::ruteador()->get_id_operacion();
		$this->agregar_a_contexto('url_back', kernel::vinculador()->crear($operacion));

		kernel::pagina()->set_etiqueta('titulo', "Historial de Asistencias");	
	}
}
?>