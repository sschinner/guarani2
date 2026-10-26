<?php
namespace siu\operaciones\vincular_encuestas;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends vista_g3w2
{
    function ini()
    {
        $clase = 'operaciones\vincular_encuestas\pagelet_encuestas';
        $pl = kernel::localizador()->instanciar($clase, 'encuestas');
        $this->add_pagelet($pl);

        kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("vincular_encuestas.titulo"));
    }
}
?>