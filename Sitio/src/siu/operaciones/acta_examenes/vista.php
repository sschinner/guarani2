<?php
namespace siu\operaciones\acta_examenes;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends \siu\operaciones\_comun\operaciones\reporte\vista
{
    function ini()
    {
		$clase = 'operaciones\acta_examenes\pagelet_reporte';
		$pl = kernel::localizador()->instanciar($clase, 'items');
        $this->add_pagelet($pl);
	
        kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_actas_examen"));
    }
}
?>