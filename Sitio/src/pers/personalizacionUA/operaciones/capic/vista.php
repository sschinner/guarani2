<?php

namespace personalizacionUA\operaciones\capic;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;
use siu\modelo\guarani_notificacion;

class vista extends vista_g3w2 {

    function ini() {
        $clase = 'operaciones\capic\pagelet_reporte';
        $pl = kernel::localizador()->instanciar($clase, 'formulario');
        $this->add_pagelet($pl);

        $clase = 'operaciones\capic\pagelet_reporte4';
        $pl = kernel::localizador()->instanciar($clase, 'formulario2');
        $this->add_pagelet($pl);
        $titulo = utf8_decode("Movilidad");
        kernel::pagina()->set_etiqueta('titulo', $titulo);
    }

    function mostar() {
        $clase = 'operaciones\capic\pagelet_reporte2';
        $pl = kernel::localizador()->instanciar($clase, 'formulario2');

        $this->add_pagelet($pl);
        $titulo = utf8_decode("Movilidad");
        kernel::pagina()->set_etiqueta('titulo', $titulo);
    }

    function inscribir() {
        /*$clase = 'operaciones\capic\pagelet_reporte2';
        $pl = kernel::localizador()->instanciar($clase, 'formulario');
        $this->add_pagelet($pl);*/

        $clase = 'operaciones\capic\pagelet_reporte3';
        $pl = kernel::localizador()->instanciar($clase, 'formulario');
        $this->add_pagelet($pl);
        /*$titulo = utf8_decode("Movilidad");
        kernel::pagina()->set_etiqueta('titulo', $titulo);*/
        
        $clase = 'operaciones\capic\pagelet_reporte4';
        $pl = kernel::localizador()->instanciar($clase, 'formulario2');
        $this->add_pagelet($pl);
        $titulo = utf8_decode("Movilidad");
        kernel::pagina()->set_etiqueta('titulo', $titulo);
    }

}
?>

