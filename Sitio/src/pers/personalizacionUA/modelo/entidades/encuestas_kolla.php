<?php

namespace personalizacionUA\modelo\entidades;

use kernel\kernel;
use kernel\util\ws_cliente;
use kernel\util\ws_mensaje;
use siu\errores\error_guarani;
use siu\guarani;
use siu\modelo\datos\catalogo;

class encuestas_kolla extends \siu\modelo\entidades\encuestas_kolla {

    public static function get_encuestas_egresados() {
        $response = self::get_cliente_rest()
                ->get('encuestas', array('query' => array('unidad_gestion' => 'UNL'),)
        );
        self::validar_response($response, 200, __FUNCTION__);
        return rest_decode($response->json());
    }

    public static function get_encuesta_egresado($id_encuesta) {
        $response = self::get_cliente_rest()
                ->get('encuestas/' . $id_encuesta, array('query' => array('unidad_gestion' => 'UNL'),
            'exceptions' => false)
        );

        if ($response->getStatusCode() == "404") {//Si la encuesta no existe
            throw new error_guarani(kernel::traductor()->trans('errores_kolla.no_existe_encuesta', array('%encuesta%' => $id_encuesta)));
        } else {
            self::validar_response($response, 200, __FUNCTION__);
            return rest_decode($response->json());
        }
    }
    
//    public static function crear_habilitacion_egresado($datos)
//	{
//        
//		$response = self::get_cliente_rest()
//			->post('habilitaciones',
//				array(
//					'query' => array('unidad_gestion' => 'FBCB'),
//					'body'  => rest_encode($datos)
//				)
//			);
//		self::validar_response($response, 201, __FUNCTION__);
//		return rest_decode($response->json());
//	}
//
//	public static function actualizar_habilitacion_egresado($datos)
//	{
//           
//		$id = $datos['habilitacion'];
//		unset($datos['habilitacion']);
//
//		$response = self::get_cliente_rest()
//			->put('habilitaciones/' . $id,
//				array(
//					'query' => array('unidad_gestion' => 'FBCB'),
//					'body'  => rest_encode($datos),
//                    'exceptions' => false
//				)
//			);
//                       
//		self::validar_response($response, 204, __FUNCTION__);
//	}
//
//	public static function get_habilitacion_egresado($id)
//	{
//           // print_r('llega 3');die;
//		$response = self::get_cliente_rest()
//			->get('habilitaciones/' . $id,
//				array(
//					'query' => array('unidad_gestion' => 'FBCB'),
//				)
//			);
//                        
//		self::validar_response($response, 200, __FUNCTION__);
//		return rest_decode($response->json());
//	}
//
//	public static function actualizar_masivo_egresado($recursos, $endpoint)
//	{
//            //print_r('llega 4');die;
//		$response = self::get_cliente_rest()
//			->put($endpoint . '/masivo',
//				array('query'      => array('unidad_gestion' => 'FBCB'),
//				      'body'       => rest_encode($recursos),
//				      'exceptions' => false)
//			);
//                       if('habilitaciones/32/formularios'==$endpoint) {
//                           print_r($endpoint);
//                           print_r($response);die;
//                       }
//		if ($response->getStatusCode() == 204) {
//			return array();
//		}
//                
//		$errores = rest_decode($response->json());
//		klog($response);
//
//		if (isset($errores['errores'])) {
//			return $errores['errores'];
//		}
//
//		throw new error_guarani('No se pudo actualizar ' . $endpoint);
//	}
        
        protected static function validar_response($response, $status, $desc_error)
	{
		if ($response->getStatusCode() != $status) {
			klog('Error en ' . $desc_error . ". Se esperaba $status y se obtuvo {$response->getStatusCode()}");
			kernel::log()->add_debug('respuesta', rest_decode($response->json()));
			throw new error_guarani(kernel::traductor()->trans('errores_kolla.error_comunicacion_con_kolla'));
		}
	}

}
