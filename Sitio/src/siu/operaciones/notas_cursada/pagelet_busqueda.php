<?php
namespace siu\operaciones\notas_cursada;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\guarani;

class pagelet_busqueda extends pagelet
{
	protected $acta;
    function get_nombre()
    {
        return 'busqueda';
    }

	function set_acta($acta)
	{
		$this->acta = $acta;
	}
		
	
	/**
	 *
	 * @return carga_notas_cursada
	 */
	protected function modelo()
	{
		return $this->controlador->modelo();
	}
	
	function get_comision()
	{
		$cabecera = $this->modelo()->info__acta_cabecera($this->acta);
		return $cabecera['COMISION'];
	}
	
    function prepare()
    {
		$this->data = array();
		$this->add_var_js('url_autocomplete', kernel::vinculador()->crear('notas_cursada', 'auto_alumno', $this->get_comision()));
    }
}
?>
