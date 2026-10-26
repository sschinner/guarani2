<?php
namespace siu\operaciones\validador_certificados;

use kernel\interfaz\pagelet;
use kernel\kernel;

class pagelet_validador extends pagelet{
	
	public function get_nombre(){
        return 'validador';
    }
    
    function prepare()
    {
    	$this->data['url_validar'] = kernel::vinculador()->crear('validador_certificados', 'validar');
        $this->data['mensajes'] = $this->controlador->get_var('mensajes');

        $this->add_mensaje_js('error_debe_ingresar_codigo_validacion', kernel::traductor()->trans('validador_certificados.error_debe_ingresar_codigo_validacion'));
        $this->add_mensaje_js('error_codigo_validacion_invalido', kernel::traductor()->trans('validador_certificados.error_codigo_validacion_invalido'));
    }
    
    function ini()
    {
    }

}