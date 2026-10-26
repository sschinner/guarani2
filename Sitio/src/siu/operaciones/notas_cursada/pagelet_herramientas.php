<?php
namespace siu\operaciones\notas_cursada;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\guarani;

class pagelet_herramientas extends pagelet
{
    function get_nombre()
    {
        return 'herramientas';
    }
		
	function get_comision()
	{
		$cabecera = $this->controlador->get_encabezado();
		return $cabecera['COMISION'];
	}
	
    function prepare()
    {
		$this->data = array();
		
		$this->add_var_js('max_textarea', pagelet_renglones::MAX_CARACTERES_CORREGIDO_POR);
		$this->add_var_js('texto_invalido', kernel::traductor()->trans('texto_invalido'));
		$this->add_var_js('nota_invalida', kernel::traductor()->trans('nota_invalida'));
		$this->add_var_js('asistencia_invalida', kernel::traductor()->trans('asistencia_invalida'));
		
		$notas = $this->controlador->get_escala_js();
		$this->add_var_js('escala', $notas);
        
        $encabezado = $this->controlador->get_encabezado();
        $this->add_var_js('fecha_inicio', $encabezado['FECHA_INICIO']);
		$this->add_var_js('fecha_fin', date('d/m/Y'));
		$this->add_var_js('fecha_invalida', kernel::traductor()->trans('fecha_invalida_acta', array(
			'%1%' => $encabezado['FECHA_INICIO'],
			'%2%' => date('d/m/Y')
		)));
        
        $this->data['condiciones'] = $this->controlador->modelo()->info__condiciones();
    }
}
?>
