<?php
namespace siu\operaciones\estado_titulo;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends vista_g3w2
{
    function ini()
    {
		$clase = 'operaciones\estado_titulo\pagelet_titulos';
		$pl = kernel::localizador()->instanciar($clase, 'titulos');
        $this->add_pagelet($pl);
	
        kernel::pagina()->set_etiqueta('titulo', "Estado de título");
    }
}
?>