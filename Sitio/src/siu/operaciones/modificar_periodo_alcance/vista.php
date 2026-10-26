<?php
namespace siu\operaciones\modificar_periodo_alcance;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends vista_g3w2
{
    function ini()
    {
        $clase = 'operaciones\modificar_periodo_alcance\pagelet_encuestas';
        $pl = kernel::localizador()->instanciar($clase, 'encuestas');
        $this->add_pagelet($pl);

        kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("modificar_periodo_alcance.titulo"));
    }
}
?>