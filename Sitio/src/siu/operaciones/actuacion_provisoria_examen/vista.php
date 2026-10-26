<?php
namespace siu\operaciones\actuacion_provisoria_examen;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends \siu\operaciones\_comun\operaciones\reporte\vista
{
    function ini()
    {
		$clase = 'operaciones\actuacion_provisoria_examen\pagelet_reporte';
		$pl = kernel::localizador()->instanciar($clase, 'items');
        $this->add_pagelet($pl);
	
        kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_actuacion_provisoria_examen"));
    }
}
?>