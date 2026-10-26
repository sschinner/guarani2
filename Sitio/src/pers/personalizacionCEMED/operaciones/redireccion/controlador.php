<?php

namespace personalizacionCEMED\operaciones\redireccion;


use kernel\kernel;
use siu\guarani;
use kernel\nucleo\controlador as controlador_base;
use kernel\util\u;
use kernel\util\validador;
use siu\modelo\datos\catalogo;
use siu\extension_kernel\controlador_errores_control;
use \siu\errores\error_guarani_control;

class controlador extends \siu\operaciones\_comun\operaciones\reporte\controlador
{
    function accion__index() {
              $pagelet = $this->vista()->pagelet('formulario');
              $pagelet->ver_pagina(1);
	}
        
	function accion__ver_pagina(){
		$pagina = kernel::url()->get_param('pagina','get');
		$columna = kernel::url()->get_param('col','get');
		$orden = kernel::url()->get_param('ord','get');
		
		$pagelet = $this->vista()->pagelet('formulario');
		$pagelet->ver_pagina($pagina, $columna, $orden);
		
                kernel::renderer()->add();
	}
        
        
        

}
?>
