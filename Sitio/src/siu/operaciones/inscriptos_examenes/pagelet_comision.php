<?php
namespace siu\operaciones\inscriptos_examenes;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\modelo\datos\catalogo;

class pagelet_comision extends pagelet {
	public $filtros = array('filtro' => 'T'); //T= Todas, C= Con Inscripciones, S= Sin Inscripciones

	public function get_nombre(){
        return 'comision';
    }

	public function prepare() {
    }
}
?>