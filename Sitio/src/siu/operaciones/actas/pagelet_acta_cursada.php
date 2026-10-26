<?php
namespace siu\operaciones\actas;

use kernel\interfaz\pagelet;
use kernel\kernel;

class pagelet_acta_cursada extends pagelet {
	public function get_nombre()
	{
		return 'acta_cursada';
	}

	public function prepare()
	{
	}
}
?>