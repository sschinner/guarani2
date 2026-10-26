<?php

namespace personalizacionUA\modelo\transacciones;

use Exception;
use GuzzleHttp\Exception\ClientException;
use kernel\error_kernel_db;
use kernel\kernel;
use siu\errores\error_guarani;
use siu\guarani;
use siu\modelo\datos\catalogo;
use siu\modelo\entidades\alumno_foto;
use siu\modelo\entidades\encuestas_kolla;
//use modelo\entidades\encuestas_kolla;

class encuestas extends \siu\modelo\transacciones\encuestas
{
    
//    function sincronizar_alcance_completo_egresado($alcance)
//	{
//		$datos_habilitacion_kolla = catalogo::consultar('encuestas', 'get_habilitacion', array('alcance' => $alcance));
//                
//		unset($datos_habilitacion_kolla['password']);
//		$punto_acceso = \siu\bootstrap::instancia()->get_id_bloque_acceso();
//		$datos_habilitacion_kolla['url_imagenes_base'] = kernel::proyecto()->get('imagen_alumno_url') . "/$punto_acceso/";
//
//		if ($this->es_habilitacion_sincronizada($datos_habilitacion_kolla)) {
//			klog('Se quizo habilitar una habilitacion ya sincronizada (no deber�a entrar aca)');
//			throw new error_guarani("La habilitaci�n ya est� actualizada");
//		}
//
//		if ($this->es_habilitacion_nueva($datos_habilitacion_kolla)) {
//
//			klog('Registrando nueva habilitaci�n...');
//		} else {
////			if (guarani_fecha::es_menor_igual_a_fecha_actual($datos_habilitacion_g['fecha_desde'])) {
////				throw guarani::error(guarani_mensajes::get('800ENC_habilitacion_iniciada'));
////			}
////			$mje = guarani_mensajes::get('800ENC_habilitacion_modificada');
//			klog('Modificando habilitaci�n...');
//		}
//
//		try {
//			//creo una habilitacion (o si ya estaba la actualizo)
//			$habilitacion_kolla = $this->sincronizar_habilitacion_egresado($alcance, $datos_habilitacion_kolla);
//                        
//			$this->sincronizar_masivo_egresado($alcance, 'elementos');
//                       
//			$this->sincronizar_masivo_egresado($alcance, 'conceptos');
//                       
//			$this->sincronizar_masivo_egresado($alcance, 'formularios', $habilitacion_kolla['habilitacion']);
//                        
//			$reg_actualizados = catalogo::consultar('encuestas', 'actualizar_alcance_sincronizado', array('alcance' => $alcance));
//                       
//                       
//			if ($reg_actualizados != 1) {
//				throw new error_guarani('Existen formularios sin sincronizar');
//			}
//		} catch (ClientException $e) {
//			kernel::log()->add_error($e);
//
//			klog2('request', $e->getRequest());
//			klog2('response', $e->getResponse());
//			try {
//				$response = $e->getResponse()->json();
//				$response = rest_decode($response);
//			} catch (Exception $ex) {
//				//No hay respuesta
//			}
//			if (isset($response['descripcion'])) {
//				$mje = $response['descripcion'] . " " . print_r($response['detalle'], true);
//			} else {
//				$mje = 'Error en la comunicaci�n con Kolla ' . $e->getMessage();
//			}
//			throw new error_guarani($mje);
//		}
////		catch (Exception $exc) {
////			kernel::log()->add_error($exc);
////		}
//		klog('El uso de memoria fue de ' . memory_get_usage());
//	}
//
//
//	protected function sincronizar_habilitacion_egresado($alcance, $params)
//	{
//		unset($params['sincronizar']);
//		if (empty($params['habilitacion'])) {
//			unset($params['habilitacion']);
//			$resultado = \personalizacionUA\modelo\entidades\encuestas_kolla::crear_habilitacion_egresado($params);
//			$id = $resultado['habilitacion'];
//		} else {
//			\personalizacionUA\modelo\entidades\encuestas_kolla::actualizar_habilitacion_egresado($params);
//			$id = $params['habilitacion'];
//		}
//
//		//pido la habilitacion
//		$habilitacion_kolla = \personalizacionUA\modelo\entidades\encuestas_kolla::get_habilitacion_egresado($id);
//
//		if (isset($habilitacion_kolla['habilitacion']) && isset($habilitacion_kolla['password'])) {
//			$params = array(
//				'alcance'         => $alcance,
//				'id_habilitacion' => $habilitacion_kolla['habilitacion'],
//				'password'        => $habilitacion_kolla['password']
//			);
//			catalogo::consultar('encuestas', 'actualizar_alcance_ws', $params);
//		} else {
//			throw new error_guarani("Error al obtener la habilitaci�n en Kolla");
//		}
//		klog('Habilitacion sincronizada', $habilitacion_kolla);
//
//		return $habilitacion_kolla;
//	}
//
//	protected function es_habilitacion_nueva_egresado($datos_habilitacion)
//	{
//		return is_null($datos_habilitacion['habilitacion']);
//	}
//
//	protected function es_habilitacion_sincronizada_egresado($datos_habilitacion)
//	{
//		return $datos_habilitacion['sincronizar'] == 'N';
//	}
//
//
//	protected function sincronizar_masivo_egresado($alcance, $endpoint, $habilitacion = null)
//	{
//
//		$metodo_datos = 'get_' . $endpoint;
//
//		$datos = catalogo::consultar('encuestas', $metodo_datos, array('alcance' => $alcance));
//		$ids_a_sincronizar = array();
//               
//		foreach ($datos as $id => $dato) {
//			if ($dato['generado_en_kolla'] == 'S') {
//				unset($datos[$id]);
//			} else {
//				unset($datos[$id]['generado_en_kolla']);
//				$ids_a_sincronizar[] = $datos[$id]['id'];
//				unset($datos[$id]['id']);
//			}
//		}
//                
//		if (!is_null($habilitacion)) {
//			$url = 'habilitaciones/' . $habilitacion . '/formularios';
//		} else {
//			$url = $endpoint;
//		}
//                 
//		$errores = \personalizacionUA\modelo\entidades\encuestas_kolla::actualizar_masivo_egresado($datos, $url);
//		
//                $total = count($ids_a_sincronizar);
//               
//		if (!empty($errores)) {
//			foreach ($errores as $error) {
//				unset($ids_a_sincronizar[(int) $error['indice']]); //tuvo error
//			}
//		}
//		$metodo_actualizar = 'actualizar_' . $endpoint;
//		$cant = catalogo::consultar('encuestas', $metodo_actualizar, array('alcance' => $alcance, 'ids' => $ids_a_sincronizar));
//               
//		if ($cant != $total) {
//			throw new error_guarani("Se actualizaron parcialmente ($cant de $total) los recursos de $endpoint - No se puede continuar");
//		}
//                
//		klog($cant . " $endpoint actualizados");
//                
//	}
//
//    function actualizar_fechas_alcance_egresado($alcance, $fecha_desde, $fecha_hasta, $kolla_id_habilitacion){
//
//        try{
//
//            kernel::db()->abrir_transaccion();
//
//            catalogo::consultar('encuestas', 'actualizar_fechas_alcance', array(
//                'alcance' => $alcance,
//                'fecha_desde' => $fecha_desde,
//                'fecha_hasta' => $fecha_hasta
//            ));
//
//            if($kolla_id_habilitacion && ($fecha_desde || $fecha_hasta)){//Si esta vinculado con kolla y hay cambios en las fechas...
//                $datos = array("habilitacion" => $kolla_id_habilitacion);
//                if($fecha_desde) $datos["fecha_desde"] = $fecha_desde;
//                if($fecha_hasta) $datos["fecha_hasta"] = $fecha_hasta;
//
//                \personalizacionUA\modelo\entidades\encuestas_kolla::actualizar_habilitacion_egresado($datos);
//            }
//
//            kernel::db()->cerrar_transaccion();
//
//        }
//        catch(error_kernel_db $e){//Error en la base de datos.
//            kernel::db()->abortar_transaccion();
//            throw new Exception(kernel::traductor()->trans('modificar_periodo_alcance.error_base_de_datos'));
//        }
//        catch(error_guarani $e){//Error comunicacion con Kolla.
//            kernel::db()->abortar_transaccion();
//            throw new Exception($e->get_mensaje());
//        }
//
//    }
   
    function get_encuestas_kolla_egresados(){

        return \personalizacionUA\modelo\entidades\encuestas_kolla::get_encuestas_egresados();

    }
    
    function get_encuesta_kolla_egresado($kolla_id_encuesta){

        return \personalizacionUA\modelo\entidades\encuestas_kolla::get_encuesta_egresado($kolla_id_encuesta);

    }
    
}
