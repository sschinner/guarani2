<?php
namespace siu\operaciones\_comun\operaciones\reporte;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends vista_g3w2
{
    function ini()
    {
		$clase = 'operaciones\reporte\pagelet_reporte';
		$pl = kernel::localizador()->instanciar($clase, 'items');
		$this->add_pagelet($pl);

		kernel::pagina()->set_etiqueta('titulo', "Reporte");
		kernel::pagina()->set_etiqueta('sub_titulo', "Reporte");
	}
}
?>