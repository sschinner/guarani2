<?php
namespace siu\operaciones\notas_parciales;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\guarani;

class pagelet_herramientas extends pagelet
{
	protected $acta;
    function get_nombre()
    {
        return 'herramientas';
    }
	
	function set_acta($acta)
	{
		$this->acta = $acta;
	}
	
	function get_comision()
	{
		$cabecera = $this->controlador->modelo()->info__acta_cabecera($this->acta);
		return $cabecera['COMISION'];
	}
	
    function prepare()
    {
		$this->data = array();
		$this->add_var_js('max_textarea', pagelet_edicion_notas::MAX_CARACTERES_CORREGIDO_POR);
		$this->add_var_js('texto_invalido', kernel::traductor()->trans('texto_invalido'));
		$this->add_var_js('nota_invalida', kernel::traductor()->trans('nota_invalida'));
		
//		$this->add_var_js('url_autocomplete', kernel::vinculador()->crear('notas_cursada', 'auto_alumno', $this->get_comision()));		
		
		$notas = $this->controlador->get_escala_js();
		$this->add_var_js('escala', $notas);
    }
}
?>
