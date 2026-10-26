<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_promedios extends pagelet_base 
{
	public function get_nombre()
	{
		return 'promedios';
	}

	public function prepare()
	{
		parent::prepare();
		$parametros = array('nro_inscripcion' => $this->controlador->get_nro_inscripcion());
		$datos = catalogo::consultar('alumno', 'promedios', $parametros);
		$this->data['datos'] = $datos;
	}
}
?>