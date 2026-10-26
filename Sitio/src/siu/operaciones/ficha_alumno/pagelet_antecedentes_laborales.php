<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_antecedentes_laborales extends pagelet_base 
{
	public function get_nombre()
	{
		return 'antecedentes_laborales';
	}

	public function prepare()
	{
		parent::prepare();
		$parametros = array('nro_inscripcion' => $this->controlador->get_nro_inscripcion());
		$datos = catalogo::consultar('alumno', 'antecedentes_laborales', $parametros);
		$this->data['datos'] = $datos;
	}
}
?>