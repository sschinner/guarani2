<?php
namespace siu\operaciones\notas_examen;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\guarani;

class pagelet_herramientas extends pagelet
{
    function get_nombre()
    {
        return 'herramientas';
    }
	
	function get_acta()
	{
		return $this->controlador->acta;
	}
	
    function prepare()
    {
		$this->data = array();
		
		$this->add_var_js('max_textarea', pagelet_renglones::MAX_CARACTERES_CORREGIDO_POR);
		$this->add_var_js('texto_invalido', kernel::traductor()->trans('texto_invalido'));
		$this->add_var_js('nota_invalida', kernel::traductor()->trans('nota_invalida'));
		
		$this->add_var_js('url_autocomplete', kernel::vinculador()->crear('notas_examen', 'auto_alumno', $this->get_acta()));
		$notas = $this->controlador->get_escala_js();
		$this->add_var_js('escala', $notas);
    }
}
?>
