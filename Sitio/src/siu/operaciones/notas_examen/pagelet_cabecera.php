<?php
namespace siu\operaciones\notas_examen;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\guarani;

class pagelet_cabecera extends pagelet
{
    function get_nombre()
    {
        return 'cabecera';
    }
	
	function get_encabezado()
	{
		$encabezado = $this->controlador->get_encabezado();
		$mapeo_acta = guarani::mapeo_tipo_actas();
		$encabezado['TIPO_ACTA_NOMBRE'] = $mapeo_acta[$encabezado['TIPO_ACTA']];
		return $encabezado;
	}
	
    function prepare()
    {
		$this->data = array();
		$this->data = $this->get_encabezado();
		$this->add_var_js('esconder_escala_notas', kernel::traductor()->trans('esconder_escala_notas'));
		$this->add_var_js('url_escala', kernel::vinculador()->crear('notas_examen', 'info_escala', $this->data['ESCALA_NOTAS']));
    }
}
?>
