<?php
namespace siu\operaciones\reinscripciones;

use kernel\kernel;
use siu\extension_kernel\controlador_g3w2;
use siu\guarani;
use kernel\util\validador;
use \siu\modelo\datos\catalogo;

class controlador extends controlador_g3w2
{
    function modelo()
    {
		return guarani::reinscripcion_carerra();
    }
	
    function accion__index()
    {
    }
    
    function datos(){
        return $this->modelo()->reinscripciones();
    }
    
    function decodificar_nro_trans($hash){
        $datos = $this->datos();
        foreach ($datos as $dato){
            if ($dato[catalogo::id] == $hash){
                return $dato['NRO_TRANS'];
            }
        }
        return false;
    }
    
    function accion__generar_comprobante()
	{
		$hash = $this->validate_param(0, 'get', validador::TIPO_ALPHANUM);
		$nro_trans = $this->decodificar_nro_trans($hash);
        
        if ($nro_trans != false) {
            $datos = $this->modelo()->datos_comprobante($nro_trans);        
            $path_archivo = kernel::proyecto()->get_dir_temp().'/reins_'.  uniqid().'.png';
            $generador_comp = kernel::localizador()->instanciar('operaciones\reinscripciones\generador_comprobantes_reinscripcion');
            $generador_comp->set_path_destino($path_archivo);
            $generador_comp->set_tipo_generacion(generador_comprobantes_reinscripcion::TIPO_GENERACION_STREAM);
            $generador_comp->generar_comprobante($datos);
        }
		$this->finalizar_request();
	}
}
?>