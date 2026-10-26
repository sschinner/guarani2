<?php
namespace siu\operaciones\notas_examen;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista_actas extends vista_g3w2
{
    function ini()
    {
		$this->set_template('template_vista_actas');
		
		$clase = 'operaciones\notas_examen\pagelet_actas';
		$pl = kernel::localizador()->instanciar($clase, 'actas');
		$this->add_pagelet($pl);
		
		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_notas_examen"));		
    }

}

?>