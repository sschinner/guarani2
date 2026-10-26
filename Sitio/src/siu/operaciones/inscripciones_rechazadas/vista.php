<?php
namespace siu\operaciones\inscripciones_rechazadas;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends \siu\operaciones\_comun\operaciones\reporte\vista
{
    function ini()
    {
		$clase = 'operaciones\inscripciones_rechazadas\pagelet_reporte';
		$pl = kernel::localizador()->instanciar($clase, 'items');
        $this->add_pagelet($pl);
	
        kernel::pagina()->set_etiqueta('titulo', "titulo");
        kernel::pagina()->set_etiqueta('sub_titulo', "sub titulo");
    }
}
?>