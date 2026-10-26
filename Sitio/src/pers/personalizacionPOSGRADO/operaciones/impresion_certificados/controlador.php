<?php

namespace personalizacionPOSGRADO\operaciones\impresion_certificados;

use kernel\kernel;
use siu\extension_kernel\controlador_g3w2;

require_once '../../../clientes_ws/nuxeo/clientews.php';

use ClienteNuxeo;

class controlador extends controlador_g3w2 {

    function modelo() {
        return null;
    }

    function accion__index() {

        $pagelet = $this->vista()->pagelet('listado');
//       kernel::renderer()->add($this->vista()->pagelet('listado'));
        kernel::renderer()->add($pagelet);
    }

    function accion__invocar_pdf() {

        //print_r($_GET['url']);die;
        $path = $_GET['url'];//'/default-domain/workspaces/Cargos/Cargo_nota_FIQ-0868593-17';
        $nuxeo = new ClienteNuxeo();
        $nuxeo->obtenerArchivo($path);
    }

}
