<?php
namespace siu\operaciones\historia_academica;

use \kernel\interfaz\pagelet;
use \kernel\kernel;

class pagelet_menu_filtros extends pagelet
{   
    function get_nombre()
    {
        return 'menu_filtros';
    }
    
    function prepare()
    {
		$this->add_var_js('checks', $this->data['filtros']);
    }
}
?>
