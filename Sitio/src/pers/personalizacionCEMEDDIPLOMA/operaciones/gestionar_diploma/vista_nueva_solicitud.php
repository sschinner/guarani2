<?php
namespace personalizacionCEMEDDIPLOMA\operaciones\gestionar_diploma;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista_nueva_solicitud extends vista_g3w2
{
    function ini()
    {
        $clase = 'operaciones\gestionar_diploma\pagelet_nueva_solicitud';
        $pl = kernel::localizador()->instanciar($clase, 'listado');
        $this->add_pagelet($pl); // SE AGREGA EL PAGELET A LA VISTA
        $titulo = utf8_decode("Nueva Solicitud de Título");
        kernel::pagina()->set_etiqueta('titulo', $titulo);
    }
}