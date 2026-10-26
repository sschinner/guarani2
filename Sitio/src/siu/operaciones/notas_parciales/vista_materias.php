<?php
namespace siu\operaciones\notas_parciales;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista_materias extends vista_g3w2
{
    function ini()
    {
		$this->set_template('template_vista_materias');
		
		$clase = 'operaciones\notas_parciales\pagelet_lista_materias';
		$pl = kernel::localizador()->instanciar($clase, 'lista_materias');
		$this->add_pagelet($pl);

        kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_notas_parcial_materias"));
    }
}

?>