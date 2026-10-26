<?php
namespace siu\operaciones\historia_academica;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends vista_g3w2
{
    function ini()
    {
		$clase = 'operaciones\historia_academica\pagelet_menu_filtros';
		$pl = kernel::localizador()->instanciar($clase, 'menu_filtros');
        $this->add_pagelet($pl);

		$clase = 'operaciones\historia_academica\pagelet_info_historia';
		$pl = kernel::localizador()->instanciar($clase, 'info_historia');
        $this->add_pagelet($pl);

        $clase = 'operaciones\historia_academica\pagelet_notificaciones';
		$pl = kernel::localizador()->instanciar($clase, 'notificaciones');
        $this->add_pagelet($pl);

		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_historia_academica"));
    }
}

?>