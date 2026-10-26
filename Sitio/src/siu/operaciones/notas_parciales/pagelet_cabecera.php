<?php
namespace siu\operaciones\notas_parciales;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\guarani;

class pagelet_cabecera extends pagelet
{
	const ESTADO_EDICION = 'edicion';
	const ESTADO_LISTADO = 'listado';
	public $estado;
	
	function get_nombre()
    {
        return 'cabecera';
    }

	function es_edicion() {
		if (!isset($this->estado)) {
			$this->estado == self::ESTADO_EDICION;
		}
		
		if ($this->estado == self::ESTADO_EDICION){
			return true;
		}
		return false;
	}
	
    function prepare()
    {
		$this->data = array();
		$this->data = $this->controlador->get_encabezado();
		$this->add_var_js('esconder_escala_notas', kernel::traductor()->trans('esconder_escala_notas'));
		$this->add_var_js('url_escala', kernel::vinculador()->crear('notas_parciales', 'info_escala', $this->data['ESCALA_NOTAS']));
    }
}
?>
