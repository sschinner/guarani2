<?php
namespace siu\operaciones\reinscripciones;

use kernel\interfaz\pagelet;
use kernel\kernel;
use \siu\modelo\datos\catalogo;

class pagelet_listado extends pagelet
{
	function get_nombre()
	{
		return 'listado';
	}

	function prepare()
	{
        $this->add_var_js('mostrar_detalle', kernel::traductor()->trans('reinscripciones.mostrar_detalle'));
        $this->add_var_js('ocultar_detalle', kernel::traductor()->trans('reinscripciones.ocultar_detalle'));
	}

    function datos(){
        $datos = $this->controlador->datos();
        
        $operacion = kernel::ruteador()->get_id_operacion();
        foreach($datos as $key => $val){
            if (!empty($val['NRO_TRANS'])){
                $datos[$key]['URL_COMP'] = kernel::vinculador()->crear($operacion, 'generar_comprobante', array($val[catalogo::id]));
            } else {
                $datos[$key]['URL_COMP'] = "-.-";
            }
        }
        
        return $datos;
    }
}
?>