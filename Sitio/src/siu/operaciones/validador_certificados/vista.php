<?php
namespace siu\operaciones\validador_certificados;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends vista_g3w2
{
    function ini()
    {
		$clase = 'operaciones\validador_certificados\pagelet_validador';
		$pl = kernel::localizador()->instanciar($clase, 'validador');
		$this->add_pagelet($pl);
		
		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("validador_certificados.titulo"));
    }
    
    function set_pagelet($name)
    {
    	$clase = 'operaciones\validador_certificados\pagelet_'.$name;
    	$pl = kernel::localizador()->instanciar($clase, 'validador');
		$this->add_pagelet($pl);
    }
   
    function render_pagelet($nombre)
    {
    	return $this->pagelet($nombre)->render();
    }
    
}