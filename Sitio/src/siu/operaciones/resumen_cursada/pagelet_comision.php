<?php
namespace siu\operaciones\resumen_cursada;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\modelo\datos\catalogo;

class pagelet_comision extends pagelet {
	public function get_nombre(){
		return 'comision';
	}

	public function prepare()
	{
	}
}
?>