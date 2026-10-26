<?php
namespace siu\modelo\entidades;
use kernel\kernel;
use kernel\util\ws_cliente;
use kernel\util\ws_mensaje;
use siu\errores\error_guarani;
use siu\guarani;
use siu\modelo\datos\catalogo;

class encuestas_kolla
{
	public static $url_kolla;
	protected static $pendientes;
	protected static $respondidas;
	protected static $cliente_kolla;

        /**
	 * Devuelve un arreglo asociativo para que se acople al código del g3w3, y se
	 * facilite mantenerlo. No cambiar los nombres, salvo que se cambien alla.
	 */
	static function get_encuestas_pendientes($nro_inscripcion)
	{
		if(!isset(self::$pendientes)){
			self::$url_kolla = kernel::proyecto()->get_url_kolla();
			$parametros = array('nro_inscripcion' => $nro_inscripcion);
			$encuestas_p = catalogo::consultar('encuestas', 'encuestas_pendientes', $parametros);
			kernel::log()->add_debug('encuestas pendientes', $encuestas_p);

			$res = array();

			foreach ($encuestas_p as $key => $dato) {
				$datos = array();
				$datos['URL'] = "no hay url";
				$datos['titulo'] = $dato['ENCUESTA_TITULO'] .' - ' .$dato['FORMULARIO_TITULO'];
				$datos['id'] = $dato['ID'];
				$datos['id_grupo'] = $dato['ID_GRUPO'];
				$datos['alcance_titulo'] = $dato['ALCANCE_TITULO'];
				$datos['titulo_grupo'] = $dato['TITULO_GRUPO'];
				$datos['cui'] = $dato['RESPUESTA'];
				$datos['password'] = $dato['KOLLA_PASSWORD'];
				$datos['habilitacion'] = $dato['KOLLA_ID_HABILITACION'];

				$datos['desplegar_encuestas'] = $dato['DESPLEGAR_ENCUESTAS'];
				$datos['item'] = $dato['FORMULARIO'];
				$datos['respuesta'] = $dato['RESPUESTA'];
				$datos['item_titulo'] = $dato['FORMULARIO_TITULO'];
				$datos['encuesta_respondida'] = $dato['ENCUESTA_RESPONDIDA'];
				$datos['formulario'] = $dato['FORMULARIO'];
				$res[] = $datos;
			}
			self::$pendientes = $res;
		}
		return self::$pendientes;

	}

    static function get_encuestas_respondidas($nro_inscripcion, $fecha_desde, $fecha_hasta, $legajo_docente, $materia)
    {
        if(!isset(self::$respondidas)){
            self::$url_kolla = kernel::proyecto()->get_url_kolla();
            $parametros = array(
                'nro_inscripcion' => $nro_inscripcion,
                'fecha_desde' => $fecha_desde,
                'fecha_hasta' => $fecha_hasta,
                'legajo_docente' => $legajo_docente,
                'materia' => $materia
            );
            $encuestas_r = catalogo::consultar('encuestas', 'encuestas_respondidas', $parametros);

            kernel::log()->add_debug('encuestas respondidas', $encuestas_r);
            self::$respondidas = $encuestas_r;
        }
        return self::$respondidas;

    }

    static function set_encuestas_respondidas($nro_inscripcion, $hab, $token, $fecha_respuesta)
    {
            $parametros = array('habilitacion' => $hab);
            $datos = catalogo::consultar('encuestas', 'password_habilitacion', $parametros);

            kernel::log()->add_debug('password', $datos[0]);
            if (count($datos) != 1) {
        kernel::log()->add_debug('Error habilitacion', "No se encontró la habilitación, o hay mas de una habilitación para esta encuesta, corrobore corriendo esta consulta: SELECT COUNT(*) AS cant_habilitaciones FROM gde_encues_alcance WHERE kolla_id_habilitacion = {$hab};");
        throw new \kernel\error_kernel(kernel::traductor()->trans("encuestas_kolla.error_habilitacion"));
                    return;
            }
            $password = $datos[0][0];
            $res = url_encuestas::decodificar_token_callback_js($token, $password);
            kernel::log()->add_debug('datosencuesta', $res);

            //chequeo que se desencripto bien.
            if ($res['habilitacion'] != $hab) {
                    kernel::log()->add_debug('Error habilitacion', $res);
        throw new \kernel\error_kernel(kernel::traductor()->trans("encuestas_kolla.error_habilitacion"));
                    return;
            }
            //$item_respondido = $res['formulario'];
            $codigo_alumno = (int) $res['codigo_externo']; //es un entero porque es el "respuesta" de la tabla.
            $parametros = array('nro_inscripcion' => $nro_inscripcion, 'respuesta' => $codigo_alumno, 'fecha_respuesta' => $fecha_respuesta);
            $actualizadas = catalogo::consultar('encuestas', 'marcar_respondida', $parametros);
            return $res;
    }

    static function generar_url($id_hab, $id_form, $cod_externo, $password_hab, $accion=null, $cod_recuperacion=null, $hash_validacion=null)
    {
        kernel::log()->add_debug('kolla_url', "$id_hab, $id_form, $cod_externo, $password_hab");
        if(!is_null($accion)) kernel::log()->add_debug('accion', $accion);
        if(!is_null($cod_recuperacion)) kernel::log()->add_debug('cod_recuperacion', $cod_recuperacion);
        if(!is_null($hash_validacion)) kernel::log()->add_debug('hash_validacion', $hash_validacion);
        self::$url_kolla = kernel::proyecto()->get_url_kolla();
        $url_base = self::$url_kolla; //'http://localhost/kolla/3.2/aplicacion.php';
        $token_seguridad = url_encuestas::get_token_seguridad($password_hab, $id_hab, $id_form, $cod_externo, $accion, $cod_recuperacion, $hash_validacion);
        return url_encuestas::gen_url($url_base, $id_hab, $token_seguridad);
    }

    public static function  get_unidad_gestion()
    {
            return guarani::get_ua_id();
    }

    public static function get_encuestas()
    {
        $response = self::get_cliente_rest()
                    ->get('encuestas',
                           array('query' => array('unidad_gestion' => self::get_unidad_gestion()), 'exceptions' => false)
                         );

        if($response->getStatusCode() == "404"){
                throw new error_guarani(kernel::traductor()->trans('errores_kolla.parametros_incorrectos'));
        }
        elseif ($response->getStatusCode() == "400"){
                throw new error_guarani(kernel::traductor()->trans('errores_kolla.error_acceso_externo'));
        }else {
            self::validar_response($response, 200, __FUNCTION__);
            return rest_decode($response->json());
        }
    }

    public static function get_encuesta($id_encuesta)
    {
        $response = self::get_cliente_rest()
            ->get('encuestas/'.$id_encuesta,
                array('query' => array('unidad_gestion' => self::get_unidad_gestion()),
                      'exceptions' => false)
            );

        if($response->getStatusCode() == "404"){//Si la encuesta no existe
            throw new error_guarani(kernel::traductor()->trans('errores_kolla.no_existe_encuesta', array('%encuesta%' => $id_encuesta)));
        }
        else{
            self::validar_response($response, 200, __FUNCTION__);
            return rest_decode($response->json());
        }
    }
    // Consulta la lista de bloques de la encuesta $id_encuesta 
    public static function get_encuesta_bloques($id_encuesta) {
        
        $response = self::get_cliente_rest()
                ->get("encuestas/{$id_encuesta}/bloques", 
                       array(
                           'query' => array('unidad_gestion' => self::get_unidad_gestion()), 
                            'exceptions' => false
                            )
                     );
                
        klog2('URL de servicio rest kolla (encuestas/{$id_encuesta}/bloques):', $response->getEffectiveUrl());
        
        if($response->getStatusCode() == "404"){//La Unidad de Gestion o la encuesta no existe
            throw new error_guarani(kernel::traductor()->trans('errores_kolla.parametros_incorrectos'));
        }
        elseif ($response->getStatusCode() == "400") {//No se pudo validar la encuesta
            throw new error_guarani(kernel::traductor()->trans('errores_kolla.no_existe_encuesta', array('%encuesta%' => $id_encuesta)));
        }
        else{
            self::validar_response($response, 200, __FUNCTION__);
            $bloques = rest_decode($response->json());
            foreach ($bloques['detalle'] as $key => $bloque) {
                $bloques['detalle'][$key][catalogo::id] = catalogo::generar_id($bloque['bloque']);
            }
            return ($bloques);
        }
    }
    
    //Consulta la lista de preguntas del bloque $id_bloque de la encuesta $id_encuesta
    public static function get_preguntas($id_encuesta, $id_bloque) {
        
        $response = self::get_cliente_rest()
                ->get("encuestas/{$id_encuesta}/bloques/{$id_bloque}/preguntas", 
                      array('query' => array('unidad_gestion' => self::get_unidad_gestion()),'exceptions' => false)
        );
        
        klog2('URL de servicio rest kolla encuestas/{$id_encuesta}/bloques/{$id_bloque}/preguntas:', $response->getEffectiveUrl());
                
        if($response->getStatusCode() == "404"){//La Unidad de Gestion o la encuesta o el bloque no existe
            throw new error_guarani(kernel::traductor()->trans('errores_kolla.parametros_incorrectos'));
        }
        elseif ($response->getStatusCode() == "400") {//No se pudo validar la encuesta
            throw new error_guarani(kernel::traductor()->trans('errores_kolla.no_existe_encuesta', array('%encuesta%' => $id_encuesta)));
        }
        else{
            self::validar_response($response, 200, __FUNCTION__);
            $preguntas = rest_decode($response->json());
            foreach ($preguntas['detalle']['detalle'] as $key => $pregunta) {
                $preguntas['detalle']['detalle'][$key][catalogo::id] = catalogo::generar_id($pregunta['pregunta']);
            }
            return ($preguntas);
        }                
    }
    
    //Consulta la respuesta de la pregunta $id_pregunta para la encuesta $id_encuesta
    public static function get_respuesta($id_habilitacion, $id_formulario, $id_encuesta, $id_elemento, $id_bloque, $id_pregunta, $pregunta_orden) {
        
        $response = self::get_cliente_rest()->get("habilitaciones/{$id_habilitacion}/formularios/{$id_formulario}/encuestas/{$id_encuesta}/elementos/{$id_elemento}/bloque/{$id_bloque}/pregunta/{$id_pregunta}/orden/{$pregunta_orden}/respuestas",
                                                  array('query' => array('unidad_gestion' => self::get_unidad_gestion(),
                                                                         'limite' => kernel::proyecto()->get_encuestas_cantidad_maxima_respuestas_kolla()
                                                                        ),
                                                        'exceptions' => false)
                                                  );
        
        klog2("URL de servicio rest kolla \n(habilitaciones/{$id_habilitacion}/formularios/{$id_formulario}/encuestas/{$id_encuesta}/elementos/{$id_elemento}/bloque/{$id_bloque}/pregunta/{$id_pregunta}/orden/$pregunta_orden/respuestas)", $response->getEffectiveUrl());
        
        if($response->getStatusCode() == "404"){//Alguno de los parámetros no existe
            throw new error_guarani(kernel::traductor()->trans('errores_kolla.no_existe_parametros'));
        }
        elseif ($response->getStatusCode() == "400") {//No se pudieron validar los datos ingresados
            throw new error_guarani(kernel::traductor()->trans('errores_kolla.parametros_incorrectos'));
        }
        else{        
            self::validar_response($response, 200, __FUNCTION__);
            $respuesta = rest_decode($response->json());

            return ($respuesta);
        }
    }

    public static function get_encuesta_completa ($id_habilitacion, $id_formulario, $id_encuesta, $id_elemento){

        $response = self::get_cliente_rest()->get("habilitaciones/{$id_habilitacion}/formularios/{$id_formulario}/encuestas/{$id_encuesta}/elementos/{$id_elemento}/respuestas",
            array('query' => array('unidad_gestion' => self::get_unidad_gestion(),
                'limite' => kernel::proyecto()->get_encuestas_cantidad_maxima_respuestas_kolla()
            ),
                'exceptions' => false
            )
        );

        klog2("URL de servicio rest kolla \n(habilitaciones/{$id_habilitacion}/formularios/{$id_formulario}/encuestas/{$id_encuesta}/elementos/{$id_elemento}/respuestas", $response->getEffectiveUrl());

        if ($response->getStatusCode() == "404") {//Alguno de los parámetros no existe
            throw new error_guarani(kernel::traductor()->trans('errores_kolla.no_existe_parametros'));
        } elseif ($response->getStatusCode() == "400") {//No se pudieron validar los datos ingresados
            throw new error_guarani(kernel::traductor()->trans('errores_kolla.parametros_incorrectos'));
        } else {
            self::validar_response($response, 200, __FUNCTION__);
            $respuesta = rest_decode($response->json());

            return ($respuesta);
        }

    }

    public static function crear_habilitacion($datos)
	{
		$response = self::get_cliente_rest()
			->post('habilitaciones',
				array(
					'query' => array('unidad_gestion' => self::get_unidad_gestion()),
					'body'  => rest_encode($datos)
				)
			);
		self::validar_response($response, 201, __FUNCTION__);
		return rest_decode($response->json());
	}

	public static function actualizar_habilitacion($datos)
	{
		$id = $datos['habilitacion'];
		unset($datos['habilitacion']);

		$response = self::get_cliente_rest()
			->put('habilitaciones/' . $id,
				array(
					'query' => array('unidad_gestion' => self::get_unidad_gestion()),
					'body'  => rest_encode($datos),
                    'exceptions' => false
				)
			);

		self::validar_response($response, 204, __FUNCTION__);
	}

	public static function get_habilitacion($id)
	{

		$response = self::get_cliente_rest()
			->get('habilitaciones/' . $id,
				array(
					'query' => array('unidad_gestion' => self::get_unidad_gestion()),
				)
			);
		self::validar_response($response, 200, __FUNCTION__);
		return rest_decode($response->json());
	}

	public static function actualizar_masivo($recursos, $endpoint)
	{
		$response = self::get_cliente_rest()
			->put($endpoint . '/masivo',
				array('query'      => array('unidad_gestion' => self::get_unidad_gestion()),
				      'body'       => rest_encode($recursos),
				      'exceptions' => false)
			);
		if ($response->getStatusCode() == 204) {
			return array();
		}

		$errores = rest_decode($response->json());
		klog($response);

		if (isset($errores['errores'])) {
			return $errores['errores'];
		}

		throw new error_guarani('No se pudo actualizar ' . $endpoint);
	}

	/**
	 * @return \GuzzleHttp\Client
	 */
	protected static function get_cliente_rest()
	{
            klog('get_cliente_rest');
		if (!isset(self::$cliente_kolla)) {
			self::$cliente_kolla = kernel::proyecto()->get_ws_cliente('kolla');
		}
		return self::$cliente_kolla;
	}

	protected static function validar_response($response, $status, $desc_error)
	{
		if ($response->getStatusCode() != $status) {
			klog('Error en ' . $desc_error . ". Se esperaba $status y se obtuvo {$response->getStatusCode()}");
			kernel::log()->add_debug('respuesta', rest_decode($response->json()));
			throw new error_guarani(kernel::traductor()->trans('errores_kolla.error_comunicacion_con_kolla'));
		}
	}
}

?>
