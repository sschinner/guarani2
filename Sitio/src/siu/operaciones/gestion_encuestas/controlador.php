<?php
namespace siu\operaciones\gestion_encuestas;

use kernel\kernel;
use kernel\error_kernel;
use siu\modelo\datos\catalogo;
use siu\extension_kernel\controlador_errores_control;
use siu\guarani;
use kernel\util\db\db;
use kernel\util\validador;
use siu\modelo\transacciones\encuestas;

class controlador extends controlador_errores_control
{
    function accion__index()
    {		
		
    }

	/**
	 * @return encuestas
	 */
	function modelo()
	{
		return guarani::encuestas();
	}
	/*
	 * hacia guarani
	 */
    function accion__sincronizar()
    {
		$alcance_id = $this->validate_param('alcance', 'post', validador::TIPO_INT);

		try{
            //valido que el $alcance_id sea valido y este en la DB listo para ser vinculado.
            $this->existe_alcance($alcance_id);

            $alcance = catalogo::consultar('encuestas', 'get_alcance', array('alcance' => $alcance_id));

            //Valido que exista la encuesta en Kolla
            $this->existe_encuesta_kolla($alcance['KOLLA_ID_ENCUESTA']);

			$rta = $this->modelo()->sincronizar_alcance_completo($alcance_id);
            kernel::renderer()->add_to_ajax_response('hubo_error', false);
            kernel::renderer()->add_to_ajax_response('mensaje', kernel::traductor()->trans('sincronizacion_exitosa'));
		}catch(\Exception $e){
			//$this->vista()->pagelet('formulario')->data['mensajes']['error'] = $e->getMessage();
//			print_r($e->getMessage());
            //throw $e;
            kernel::renderer()->add_to_ajax_response('hubo_error', true);
            kernel::renderer()->add_to_ajax_response('mensaje', $e->getMessage());
		}
		//$this->add_var('mensaje', kernel::traductor()->trans('sincronizacion_exitosa'));
	}

    private function existe_encuesta_kolla($kolla_id_encuesta){

        $this->modelo()->get_encuesta_kolla($kolla_id_encuesta);

    }

    private function existe_alcance($alcance_id){
        $existe_alcance = catalogo::consultar('encuestas', 'existe_alcance', array('alcance' => $alcance_id));
        if(!$existe_alcance){
            throw new \Exception(kernel::traductor()->trans('gestion_encuestas.no_existe_alcance', array('%alcance%' => $alcance_id)));
        }
    }
	
}
?>