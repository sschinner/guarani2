<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_sanciones extends pagelet_base 
{
	public function get_nombre()
	{
		return 'sanciones';
	}

	public function prepare()
	{
		parent::prepare();
		$parametros = array('nro_inscripcion' => $this->controlador->get_nro_inscripcion());
		$datos = catalogo::consultar('alumno', 'sanciones', $parametros);
		$this->data['datos'] = $datos;
	}
}
?>