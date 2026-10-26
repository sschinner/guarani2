<?php
namespace siu\operaciones\reinscripcion;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends vista_g3w2
{
    function ini()
    {
		$clase = 'operaciones\reinscripcion\pagelet_form_reinscripcion';
		$pl = kernel::localizador()->instanciar($clase, 'form_reinscripcion');
        $this->add_pagelet($pl);
		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_reinscripcion"));
    }
}
?>