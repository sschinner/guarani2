<?php
namespace siu\operaciones\actas;

use kernel\interfaz\pagelet;
use kernel\kernel;

class pagelet_acta_examen extends pagelet {
	public function get_nombre()
	{
		return 'acta_examen';
	}

	public function prepare()
	{
	}
}
?>