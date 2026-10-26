<?php
namespace siu\operaciones\reinscripcion;

use kernel\kernel;
use siu\extension_kernel\controlador_errores_control;
use siu\guarani;

class controlador extends controlador_errores_control
{

    protected $nro_transaccion = null;

    public function get_nro_transaccion(){
        return $this->nro_transaccion;
    }

    static function activar_modo_reinscripcion($op_retorno = null)
	{
		kernel::sesion()->set('datos_censales_reinscripcion', 1);
        if (isset($op_retorno)){
            kernel::sesion()->set('datos_censales_retorno', $op_retorno);
        }
	}
	
	protected static function modo_reinscripcion_activado()
	{
		return kernel::sesion()->esta_seteada('datos_censales_reinscripcion');
	}

	protected static function get_operacion_retorno()
	{
        if (kernel::sesion()->esta_seteada('datos_censales_retorno')){
            return kernel::sesion()->get('datos_censales_retorno');
        }
        return false;
	}
	
	static function desactivar_modo_reinscripcion()
	{
		kernel::sesion()->borrar('datos_censales_reinscripcion');
	}
		
    function modelo()
    {
		return guarani::reinscripcion_carerra();
    }
	
	function ini()
	{
		\siu\modelo\controles\proceso_control::set_ejecutar_controles_reinscripcion(false);
	}
    
    function accion__index()
    {
			$this->exec_fn_modelo('puede_reinscribirse');
			$mensajes= $this->get_var('mensajes');
			if(!empty($mensajes))
			{
				$this->add_var('msj_error',$mensajes);
			}	
			self::activar_modo_reinscripcion();						
		}
    
    function accion__reinscribir()
    {
		if (kernel::request()->isPost()) {
            $hubo_error = $this->exec_fn_modelo('reinscribir');
			if (self::modo_reinscripcion_activado()) {
				self::desactivar_modo_reinscripcion();
				$operacion_retorno = self::get_operacion_retorno();
				if (!empty($operacion_retorno)) {
					$this->nuevo_request($operacion_retorno);
				}
			} else {
				kernel::renderer()->add($this->vista()->pagelet('form_reinscripcion'));
			}

            kernel::renderer()->add_to_ajax_response('hubo_error', $hubo_error);
            if(!$hubo_error){
                $nro_transaccion = $this->get_nro_transaccion();
                kernel::renderer()->add_to_ajax_response('msg_exito', kernel::traductor()->trans('reinscripcion_mensaje_exito', array('%transaccion%' => $nro_transaccion)));
            }
		}
    }
	
	protected function modelo__puede_reinscribirse()
	{
		$this->add_var('mensajes', $this->modelo()->puede_reinscribirse());
	}
	
	protected function modelo__reinscribir()
	{
        $this->nro_transaccion = $this->modelo()->reinscribir();
	}
}
?>