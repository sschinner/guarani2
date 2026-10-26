<?php
namespace siu\operaciones\encuestas_kolla;

use kernel\interfaz\pagelet;
use kernel\kernel;

class pagelet_listado_encuestas extends pagelet {
	public function get_nombre()
	{
        return 'listado_encuestas';
    }

	function prepare() 
	{
		$this->data['links_encuesta'] = array();
		
		$pendientes = $this->controlador->get_var('encuestas_pendientes');
		$this->data['links_encuesta'] = $pendientes;

	}
}
?>