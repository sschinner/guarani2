<?php
namespace siu\operaciones\acceso;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends vista_g3w2
{
	function set_pagelet($name)
	{
		$clase = "operaciones\\acceso\\pagelet_$name";
		$pl = kernel::localizador()->instanciar($clase, 'login');
		$this->add_pagelet($pl);
	}
	
    function ini()
    {
		//$this->add_form('login')->desactivar_csrf();
		
		$clase = 'operaciones\acceso\pagelet_contenido_login';
		$pl = kernel::localizador()->instanciar($clase, 'contenido_login');
		$this->add_pagelet($pl);
		
        kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans('tit_acceso'));
    }
}
?>