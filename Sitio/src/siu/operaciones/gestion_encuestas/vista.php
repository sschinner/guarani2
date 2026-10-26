<?php
namespace siu\operaciones\gestion_encuestas;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends vista_g3w2
{
    function ini()
    {
		$clase = 'operaciones\gestion_encuestas\pagelet_formulario';
		$pl = kernel::localizador()->instanciar($clase, 'formulario');
        $this->add_pagelet($pl);
		
		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_kolla_alcance"));
    }
}
?>