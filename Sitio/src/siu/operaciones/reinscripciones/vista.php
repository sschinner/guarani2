<?php
namespace siu\operaciones\reinscripciones;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends vista_g3w2
{
    function ini()
    {
		$clase = 'operaciones\reinscripciones\pagelet_listado';
		$pl = kernel::localizador()->instanciar($clase, 'listado');
		$this->add_pagelet($pl);
		
        // to-do Agregar a mensajes
        kernel::pagina()->set_etiqueta('titulo', "reinscripciones_a_carreras");
    }
}
?>