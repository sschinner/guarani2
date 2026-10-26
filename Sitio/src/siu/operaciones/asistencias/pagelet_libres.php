<?php
namespace siu\operaciones\asistencias;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_libres extends pagelet
{
    function get_nombre()
    {
        return 'libres';
    }
	
	function get_alumnos()
	{
		$comision_id = $this->controlador->comision_id;
		$alumnos = $this->controlador->modelo()->listado_alumnos_libres($comision_id);
		
		return $alumnos;
	}
	
	function prepare()
	{
		$this->data['alumnos'] = $this->get_alumnos();
		$this->data['encabezado'] = $this->controlador->modelo()->get_comision($this->controlador->comision_id);
	}
}
?>