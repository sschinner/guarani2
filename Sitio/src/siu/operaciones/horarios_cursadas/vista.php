<?php
namespace siu\operaciones\horarios_cursadas;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends vista_g3w2
{
    function ini()
    {
		$clase = 'operaciones\horarios_cursadas\pagelet_filtro';
		$pl = kernel::localizador()->instanciar($clase, 'filtro');
        $this->add_pagelet($pl);
	
		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_horarios_cursadas"));
    }
}
?>