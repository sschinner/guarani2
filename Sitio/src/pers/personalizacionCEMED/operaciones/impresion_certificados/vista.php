<?php
namespace personalizacionCEMED\operaciones\impresion_certificados;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends vista_g3w2
{
    function ini()
    {
        $clase = 'operaciones\impresion_certificados\pagelet_listado';
        $pl = kernel::localizador()->instanciar($clase, 'listado');
        $this->add_pagelet($pl); // SE AGREGA EL PAGELET A LA VISTA
        $titulo = utf8_decode("Impresión Certificados");
        kernel::pagina()->set_etiqueta('titulo', $titulo);
    }
}