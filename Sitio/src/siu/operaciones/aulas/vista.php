<?php
namespace siu\operaciones\aulas;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends \siu\operaciones\_comun\operaciones\reporte\vista
{
    function ini()
    {
		$clase = 'operaciones\aulas\pagelet_reporte';
		$pl = kernel::localizador()->instanciar($clase, 'items');
        $this->add_pagelet($pl);
	
		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_aulas"));
    }
}
?>