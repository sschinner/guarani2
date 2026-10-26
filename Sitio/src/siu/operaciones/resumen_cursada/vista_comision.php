<?php
namespace siu\operaciones\resumen_cursada;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista_comision extends vista_g3w2
{
	function ini()
	{
        //$this->set_template('template_comision');
        
		$clase = 'operaciones\resumen_cursada\pagelet_comision';
		$pl = kernel::localizador()->instanciar($clase, 'contenido');
		$this->add_pagelet($pl);

		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_resumen_cursada"));
	}
}
?>