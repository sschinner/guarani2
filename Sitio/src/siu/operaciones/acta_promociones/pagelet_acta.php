<?php
namespace siu\operaciones\acta_promociones;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\modelo\datos\catalogo;

class pagelet_acta extends pagelet {
    protected $acta;
    
	public function get_nombre(){
        return 'acta';
    }

	public function prepare() {
    }
}
?>