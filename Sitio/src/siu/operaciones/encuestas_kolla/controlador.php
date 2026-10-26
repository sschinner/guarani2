<?php
namespace siu\operaciones\encuestas_kolla;

use kernel\error_kernel;
use kernel\kernel;
use siu\extension_kernel\controlador_g3w2;
use kernel\util\validador;
use siu\modelo\entidades\encuestas_kolla;

class controlador extends controlador_g3w2
{
	function modelo()
	{
		return null;
	}

    /*Todo lo que se modifique con respecto al listado de encuestas pendientes debe tambien modificarse en:
    * src/siu/operaciones/inicio_alumno/lista_encuestas_pendientes
    */
	function accion__index()
	{
		$pendiente_id = $this->validate_param(0, 'get', validador::TIPO_TEXTO, array(
			'allowempty' => true,
			'default' => null
		)); 
		$pendientes = kernel::persona()->get_encuestas_pendientes();
		if(empty($pendientes)) return; //va a una vista estatica.

		$url_kolla_parsed = parse_url(encuestas_kolla::$url_kolla);
		$domain_kolla = $url_kolla_parsed['scheme']."://".$url_kolla_parsed['host'];
        if(isset($url_kolla_parsed['port']) && $url_kolla_parsed['port'] != '80'){
            $domain_kolla .= ':'.$url_kolla_parsed['port'];
        }
		$this->add_var('domain_kolla', $domain_kolla);


		$this->add_var('url_formulario', null); //inicializo para el iframe
		if(!empty($pendiente_id) && !empty($pendientes)){
			$pedida = $this->validar_esta_pendiente($pendiente_id, $pendientes);
			if($pedida != null){
				$codigo_externo = $pedida['cui'];
				$password = $pedida['password'];
				$habilitacion = $pedida['habilitacion'];
				$formulario = $pedida['formulario'];
				$url = \siu\modelo\entidades\encuestas_kolla::generar_url($habilitacion, $formulario, $codigo_externo, $password);
				$this->add_var('url_formulario', $url); //para el iframe
                $this->add_var('encuesta_seleccionada_id', $pedida['id']); //id de la encuesta seleccionada
			}
		}
		
		
		// corte
		$corte = array();
		foreach($pendientes as $encuesta){
			$corte[$encuesta['id_grupo']]['desplegar_encuestas'] = $encuesta['desplegar_encuestas'];
			$encuesta['link_encuesta'] = kernel::vinculador()->crear('encuestas_kolla', 'index', $encuesta['id']);
			$encuesta['id_eliminacion'] = "kl_".$encuesta['id'];
			if ($encuesta['desplegar_encuestas'] == 1){
				$corte[$encuesta['id_grupo']]['titulo'] = $encuesta['titulo_grupo'];
				$corte[$encuesta['id_grupo']]['encuestas'][] = $encuesta;
			} else {
				$corte[$encuesta['id_grupo']] = $encuesta;
			}
		}
		
		
		$this->add_var('encuestas_pendientes', $corte); //para la lista
		$pagelet = $this->vista()->pagelet('encuesta');
		kernel::renderer()->add($pagelet);
	}
	
	/**
	 * Viene por ajax cuando se captura el callback de js.
	 */
	function accion__encuesta_respondida(){

        if(kernel::request()->isPost()) {
            $token = $this->get_param('t', 'post'); //viene un hash.. se va a decodificar y despues se deberia validar
            $habilitacion = $this->validate_param('h', 'post', validador::TIPO_INT);
            $fecha_respuesta = $this->validate_param('fecha_respuesta', 'post', validador::TIPO_DATE, array('format' => 'Y-m-d', 'default' => null, 'allowempty' => true));
            kernel::log()->add_debug('Param', "token recibido [$token]");

            $ajax_response = array();
            $ajax_response['error_habilitacion'] = false;
            try{
                $a = kernel::persona()->set_encuestas_respondidas($habilitacion, $token, $fecha_respuesta);
                kernel::log()->add_debug('Param', "token decodificado [" . print_r($a, true) . "]");
                $ajax_response['materia'] = $a['formulario'];
            }
            catch(error_kernel $e){
                $ajax_response['error_habilitacion'] = true;
                $ajax_response['mensaje'] = $e->get_mensaje();
                $ajax_response['materia'] = "";
            }

            $this->render_ajax('mensaje', $ajax_response);  // "hola mundo";
        }

	}
	
	/**
	 * Busco en la lista de pendientes si hay una con el id seleccionado
	 * @return mixed la fila si existe, sino null.
	 */
	private function validar_esta_pendiente($pendiente_id, $pendientes){
		foreach ($pendientes as $key => $encuesta){	
			if($encuesta['id'] == $pendiente_id	) 
			{
				kernel::log()->add_debug("trace_kolla_retornando", $key);
				return $pendientes[$key];
			}
		}
		return null;
	}
}
?>
