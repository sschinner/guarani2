<?php

namespace siu\modelo\transacciones;

use Exception;
use GuzzleHttp\Exception\ClientException;
use kernel\error_kernel_db;
use kernel\kernel;
use siu\errores\error_guarani;
use siu\guarani;
use siu\modelo\datos\catalogo;
use siu\modelo\entidades\alumno_foto;
use siu\modelo\entidades\encuestas_kolla;

class encuestas
{

	function sincronizar_alcance_completo($alcance)
	{
		$datos_habilitacion_kolla = catalogo::consultar('encuestas', 'get_habilitacion', array('alcance' => $alcance));

		unset($datos_habilitacion_kolla['password']);
		$punto_acceso = \siu\bootstrap::instancia()->get_id_bloque_acceso();
		$datos_habilitacion_kolla['url_imagenes_base'] = kernel::proyecto()->get('imagen_alumno_url') . "/$punto_acceso/";

		if ($this->es_habilitacion_sincronizada($datos_habilitacion_kolla)) {
			klog('Se quizo habilitar una habilitacion ya sincronizada (no debería entrar aca)');
			throw new error_guarani("La habilitación ya está actualizada");
		}

		if ($this->es_habilitacion_nueva($datos_habilitacion_kolla)) {

			klog('Registrando nueva habilitación...');
		} else {
//			if (guarani_fecha::es_menor_igual_a_fecha_actual($datos_habilitacion_g['fecha_desde'])) {
//				throw guarani::error(guarani_mensajes::get('800ENC_habilitacion_iniciada'));
//			}
//			$mje = guarani_mensajes::get('800ENC_habilitacion_modificada');
			klog('Modificando habilitación...');
		}

		try {
			//creo una habilitacion (o si ya estaba la actualizo)
			$habilitacion_kolla = $this->sincronizar_habilitacion($alcance, $datos_habilitacion_kolla);

			$this->sincronizar_masivo($alcance, 'elementos');

			$this->sincronizar_masivo($alcance, 'conceptos');

			$this->sincronizar_masivo($alcance, 'formularios', $habilitacion_kolla['habilitacion']);

			$reg_actualizados = catalogo::consultar('encuestas', 'actualizar_alcance_sincronizado', array('alcance' => $alcance));

			if ($reg_actualizados != 1) {
				throw new error_guarani('Existen formularios sin sincronizar');
			}
		} catch (ClientException $e) {
			kernel::log()->add_error($e);

			klog2('request', $e->getRequest());
			klog2('response', $e->getResponse());
			try {
				$response = $e->getResponse()->json();
				$response = rest_decode($response);
			} catch (Exception $ex) {
				//No hay respuesta
			}
			if (isset($response['descripcion'])) {
				$mje = $response['descripcion'] . " " . print_r($response['detalle'], true);
			} else {
				$mje = 'Error en la comunicación con Kolla ' . $e->getMessage();
			}
			throw new error_guarani($mje);
		}
//		catch (Exception $exc) {
//			kernel::log()->add_error($exc);
//		}
		klog('El uso de memoria fue de ' . memory_get_usage());
	}


	protected function sincronizar_habilitacion($alcance, $params)
	{
		unset($params['sincronizar']);
		if (empty($params['habilitacion'])) {
			unset($params['habilitacion']);
			$resultado = encuestas_kolla::crear_habilitacion($params);
			$id = $resultado['habilitacion'];
		} else {
			encuestas_kolla::actualizar_habilitacion($params);
			$id = $params['habilitacion'];
		}

		//pido la habilitacion
		$habilitacion_kolla = encuestas_kolla::get_habilitacion($id);

		if (isset($habilitacion_kolla['habilitacion']) && isset($habilitacion_kolla['password'])) {
			$params = array(
				'alcance'         => $alcance,
				'id_habilitacion' => $habilitacion_kolla['habilitacion'],
				'password'        => $habilitacion_kolla['password']
			);
			catalogo::consultar('encuestas', 'actualizar_alcance_ws', $params);
		} else {
			throw new error_guarani("Error al obtener la habilitación en Kolla");
		}
		klog('Habilitacion sincronizada', $habilitacion_kolla);

		return $habilitacion_kolla;
	}

	protected function es_habilitacion_nueva($datos_habilitacion)
	{
		return is_null($datos_habilitacion['habilitacion']);
	}

	protected function es_habilitacion_sincronizada($datos_habilitacion)
	{
		return $datos_habilitacion['sincronizar'] == 'N';
	}


	protected function sincronizar_masivo($alcance, $endpoint, $habilitacion = null)
	{

		$metodo_datos = 'get_' . $endpoint;

		$datos = catalogo::consultar('encuestas', $metodo_datos, array('alcance' => $alcance));
		$ids_a_sincronizar = array();
		foreach ($datos as $id => $dato) {
			if ($dato['generado_en_kolla'] == 'S') {
				unset($datos[$id]);
			} else {
				unset($datos[$id]['generado_en_kolla']);
				$ids_a_sincronizar[] = $datos[$id]['id'];
				unset($datos[$id]['id']);
			}
		}

		if (!is_null($habilitacion)) {
			$url = 'habilitaciones/' . $habilitacion . '/formularios';
		} else {
			$url = $endpoint;
		}

		$errores = encuestas_kolla::actualizar_masivo($datos, $url);
		$total = count($ids_a_sincronizar);

		if (!empty($errores)) {
			foreach ($errores as $error) {
				unset($ids_a_sincronizar[(int) $error['indice']]); //tuvo error
			}
		}
		$metodo_actualizar = 'actualizar_' . $endpoint;
		$cant = catalogo::consultar('encuestas', $metodo_actualizar, array('alcance' => $alcance, 'ids' => $ids_a_sincronizar));

		if ($cant != $total) {
			throw new error_guarani("Se actualizaron parcialmente ($cant de $total) los recursos de $endpoint - No se puede continuar");
		}
		klog($cant . " $endpoint actualizados");
	}

    function actualizar_fechas_alcance($alcance, $fecha_desde, $fecha_hasta, $kolla_id_habilitacion){

        try{

            kernel::db()->abrir_transaccion();

            catalogo::consultar('encuestas', 'actualizar_fechas_alcance', array(
                'alcance' => $alcance,
                'fecha_desde' => $fecha_desde,
                'fecha_hasta' => $fecha_hasta
            ));

            if($kolla_id_habilitacion && ($fecha_desde || $fecha_hasta)){//Si esta vinculado con kolla y hay cambios en las fechas...
                $datos = array("habilitacion" => $kolla_id_habilitacion);
                if($fecha_desde) $datos["fecha_desde"] = $fecha_desde;
                if($fecha_hasta) $datos["fecha_hasta"] = $fecha_hasta;

                encuestas_kolla::actualizar_habilitacion($datos);
            }

            kernel::db()->cerrar_transaccion();

        }
        catch(error_kernel_db $e){//Error en la base de datos.
            kernel::db()->abortar_transaccion();
            throw new Exception(kernel::traductor()->trans('modificar_periodo_alcance.error_base_de_datos'));
        }
        catch(error_guarani $e){//Error comunicacion con Kolla.
            kernel::db()->abortar_transaccion();
            throw new Exception($e->get_mensaje());
        }

    }

    function get_encuesta_kolla($kolla_id_encuesta){

        return encuestas_kolla::get_encuesta($kolla_id_encuesta);

    }

    function get_encuestas_kolla(){

        return encuestas_kolla::get_encuestas();

    }


}