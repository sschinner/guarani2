<?php
namespace siu\operaciones\admin_operaciones;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends vista_g3w2
{
    function ini()
    {
        $clase = 'operaciones\admin_operaciones\pagelet_operaciones';
        $pl = kernel::localizador()->instanciar($clase, 'operaciones');
        $this->add_pagelet($pl);

        kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_administrar_operaciones"));
    }
}

?>