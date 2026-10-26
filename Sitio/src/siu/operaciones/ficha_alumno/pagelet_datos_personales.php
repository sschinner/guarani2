<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_datos_personales extends pagelet_base
{
	public function get_nombre()
	{
		return 'datos_personales';
	}

	public function prepare()
	{
		parent::prepare();
		$parametros = array('nro_inscripcion' => $this->controlador->get_nro_inscripcion());
		$datos = catalogo::consultar('alumno', 'datos_personales', $parametros);
		if (!empty($datos)){
			$datos = $datos[0];
		}
		$this->data['datos'] = $datos;
	}
}
?>