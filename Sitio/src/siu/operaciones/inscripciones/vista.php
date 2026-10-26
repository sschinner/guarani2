<?php
namespace siu\operaciones\inscripciones;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends vista_g3w2
{
    function ini()
    {
		$clase = 'operaciones\inscripciones\pagelet_examenes';
		$pl = kernel::localizador()->instanciar($clase, 'examenes');
		$this->add_pagelet($pl);
		
		$clase1 = 'operaciones\inscripciones\pagelet_cursadas';
		$pl1 = kernel::localizador()->instanciar($clase1, 'cursadas');
		$this->add_pagelet($pl1);
	
        kernel::pagina()->set_etiqueta('titulo', "Mis inscripciones");
        kernel::pagina()->set_etiqueta('sub_titulo', "");
    }
}
?>