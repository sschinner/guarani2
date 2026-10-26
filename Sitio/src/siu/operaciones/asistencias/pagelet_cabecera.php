<?php
namespace siu\operaciones\asistencias;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\guarani;

class pagelet_cabecera extends pagelet
{	
    function get_nombre()
    {
        return 'cabecera';
    }

    function prepare()
    {
		$this->data = array();
		$this->data = $this->controlador->get_clase_encabezado();
    }
}
?>
