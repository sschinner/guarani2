<?php

namespace personalizacionUA\operaciones\solicitud_certificado;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\modelo\datos\catalogo;

class pagelet_errorws extends \siu\operaciones\solicitud_certificado\pagelet_formulario {

    public function get_nombre() {
        return 'errorws';
    }

    function prepare() {

    }
}

?>