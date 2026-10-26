<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_certificados_solicitados extends pagelet_base 
{
	public function get_nombre()
	{
		return 'certificados_solicitados';
	}

	public function prepare()
	{
		parent::prepare();
		$parametros = array('nro_inscripcion' => $this->controlador->get_nro_inscripcion());
		$datos = catalogo::consultar('alumno', 'certificados_solicitados', $parametros);
		$this->data['certificados'] = $datos;
	}
	
}
?>