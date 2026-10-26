<?php

namespace kernel;

class error_kernel_notificaciones extends error_kernel_usuario
{    
    function set_data($titulo, $mensajes)
    {
        $this->params['titulo'] = $titulo;
		$parsed = array();
		
		foreach ($mensajes as $mensaje) {
			$parsed[] = ($mensaje instanceof \kernel\interface_notificacion) ? $mensaje->como_arreglo() : $mensaje;
		}
        $this->params['mensajes'] = $parsed;
    }
}

?>
