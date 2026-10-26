<?php

namespace personalizacionCEMED\operaciones\pasantia;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;
use siu\modelo\guarani_notificacion;

class vista extends vista_g3w2 {

    function ini() {
        $clase = 'operaciones\pasantia\pagelet_reporte';
        $pl = kernel::localizador()->instanciar($clase, 'formulario');
        $this->add_pagelet($pl);

        $clase = 'operaciones\pasantia\pagelet_reporte2';
        $pl = kernel::localizador()->instanciar($clase, 'formulario2');
        $this->add_pagelet($pl);
        $titulo = utf8_decode("Pasantías");
        kernel::pagina()->set_etiqueta('titulo', $titulo);
    }

    function mostar() {
        $clase = 'operaciones\pasantia\pagelet_reporte2';
        $pl = kernel::localizador()->instanciar($clase, 'formulario2');

        $this->add_pagelet($pl);
        $titulo = utf8_decode("Pasantías");
        kernel::pagina()->set_etiqueta('titulo', $titulo);
    }

    function mostarBaja() {
        $clase = 'operaciones\pasantia\pagelet_reporte';
        $pl = kernel::localizador()->instanciar($clase, 'formulario');
        $this->add_pagelet($pl);

        $clase = 'operaciones\pasantia\pagelet_reporte2';
        $pl = kernel::localizador()->instanciar($clase, 'formulario2');
        $this->add_pagelet($pl);
        $titulo = utf8_decode("Pasantías");
        kernel::pagina()->set_etiqueta('titulo', $titulo);
    }

}
?>

