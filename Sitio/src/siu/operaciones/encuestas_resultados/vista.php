<?php

namespace siu\operaciones\encuestas_resultados;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends vista_g3w2
{
    function ini()
    {
        
        $this->set_template('template');

        $clase = 'operaciones\encuestas_resultados\pagelet_filtros';
        $pl = kernel::localizador()->instanciar($clase, 'filtros');
        $this->add_pagelet($pl);
        
        $clase = 'operaciones\encuestas_resultados\pagelet_listado_encuestas';
        $pl = kernel::localizador()->instanciar($clase, 'listado_encuestas');
        $this->add_pagelet($pl);
        
        kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_encuestas_resultados"));

    }
}