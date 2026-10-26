<?php

namespace siu\operaciones\reinscripcion;

use kernel\interfaz\pagelet;
use kernel\kernel;

class pagelet_form_reinscripcion extends pagelet
{
    function get_nombre()
    {
        return 'form_reinscripcion';
    }

    function prepare()
    {
		$this->data = array();
		$this->data['es_necesaria_reinscripcion'] = $this->controlador->modelo()->es_necesaria_reinscripcion();		
		$this->data['mensajes'] = $this->controlador->get_var('mensajes');
		$this->data['msj_error'] = $this->controlador->get_var('msj_error');
		$this->data['hay_msj_error'] = false;	

                if (is_array($this->data['msj_error'])) {
                        foreach($this->data['msj_error'] as $mensaje) {
                                if ($mensaje->es_error()) {
                                        $this->data['hay_msj_error'] = true;
                                }
                        }
                }

		$hubo_error = false;
		if (is_array($this->data['mensajes'])) {
			foreach($this->data['mensajes'] as $mensaje) {
				if ($mensaje->es_error()) {
					$hubo_error = true;
				}
			}
		}
        
        if (!kernel::sesion()->esta_seteada('dcensales_revision_completa') || !kernel::sesion()->get('dcensales_revision_completa')){
            $url = kernel::vinculador()->crear('censo');
            $notif['mtipo'] = "E";
            $notif['raw'] = true;
            $notif['mcuerpo'] = kernel::traductor()->trans('reinscripcion.revisar_datos_censales', array('%1%' => $url));
            
            $this->data['mensajes'][] = $notif;
            $hubo_error = true;
        }
        
		$this->data['hubo_error'] = $hubo_error;
		$this->data['url_reinscripcion'] = kernel::vinculador()->crear('reinscripcion', 'reinscribir');
        
    }
}
?>
