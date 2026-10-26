<?php

namespace siu\operaciones\encuestas_resultados;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista_encuesta extends vista_g3w2
{
    function ini()
    {
        $this->set_template('template_lista_encuesta');
        
        $clase = 'operaciones\encuestas_resultados\pagelet_listado_encuesta';
        $pl = kernel::localizador()->instanciar($clase, 'listado_encuesta');
        $this->add_pagelet($pl);

        kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_encuestas_resultados"));

    }
}