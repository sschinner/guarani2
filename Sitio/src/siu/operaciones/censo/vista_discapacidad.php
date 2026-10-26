<?php
namespace siu\operaciones\censo;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista_discapacidad extends vista_g3w2
{
	function ini()
	{
        $clase = 'operaciones\censo\pagelet_lista_forms';
		$pl = kernel::localizador()->instanciar($clase, 'lista_forms');
		$this->add_pagelet($pl);
        
        $clase = 'operaciones\censo\pagelet_datos_discapacidad';
		$pl = kernel::localizador()->instanciar($clase, 'formulario');
		$this->add_pagelet($pl);
		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans('tit_datos_censales'));
	}
}
?>