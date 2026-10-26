<?php

namespace personalizacionCEMEDDIPLOMA\modelo\transacciones;

use kernel\kernel;
use siu\guarani;
use siu\errores\error_guarani;
use siu\modelo\datos\catalogo;
use siu\errores\error_guarani_usuario;

require_once '../../../clientes_ws/mediosCobro/clientews.php';
use ClienteMediosCobro;

class solicitud_certificados extends \siu\modelo\transacciones\solicitud_certificados {

    function argumentos_certificado($nro_certificado = null) {
        if (!empty($nro_certificado)) {
            $parametros['nro_certificado'] = $nro_certificado;
            $datos = catalogo::consultar('certificados', 'certificados_argumentos', $parametros);
            //print_r($datos);die;			
            $cetificados_datos = $this->lista_certificados();

            if (isset($cetificados_datos[$nro_certificado])) {
                $resultado = array();
                $resultado['id'] = $nro_certificado;
                $resultado['nombre'] = $cetificados_datos[$nro_certificado]['nombre'];
                $resultado['solicitud_pendiente'] = $cetificados_datos[$nro_certificado]['solicitud_pendiente'];
                $resultado['maximo_copias'] = $cetificados_datos[$nro_certificado]['maximo_copias'];
                $resultado['generacion_web'] = $cetificados_datos[$nro_certificado]['generacion_web'];
                $resultado['vigencia'] = $cetificados_datos[$nro_certificado]['vigencia'];

                foreach ($datos as $clave => $valor) {
                    switch ($valor[1]) {
                        case "unidad_academica":
                            $ua_id = \siu\guarani::get_ua_id();
                            $valor[3] = $ua_id;
                            $ua = new \siu\modelo\entidades\unidad_academica($ua_id);
                            $valor['nombre'] = "(" . $ua_id . ") " . $ua->get_nombre();
                            break;
                        case "carrera":
                            $carrera_activa = kernel::persona()->get_info_carrera_activa();
                            $valor['nombre'] = $carrera_activa['nombre'];
                            $valor[3] = $carrera_activa['id'];
                            break;
                        case "legajo":
                            $valor[3] = kernel::persona()->get_id_legajo_activo();
                            break;
                        case "nro_inscripcion":
                            $valor[3] = kernel::persona()->get_nro_inscripcion();
                            break;
                        case "periodo_inscripcio":
                            $valor[3] = kernel::persona()->get_periodo_inscripcion_activo();
                            break;
                        case "titulo":
                            if ($nro_certificado == 100) {
                                $valor['nombre'] = '';
                                $parametros['legajo'] = kernel::persona()->get_id_legajo_activo();
                                $carrera = kernel::persona()->get_info_carrera_activa();
                                $parametros['carrera'] = $carrera['id'];
                                $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
                                $titulo = catalogo::consultar('alumno', 'tipo_titulo', $parametros);
                                $i = 0;
                                if (count($titulo) > 1) {
                                    foreach ($titulo as $fila) {
                                        if ($fila['TIPO_DE_TITULO'] === 'G') {
                                            $valor['nombre'][$i] = $fila['NOMBRE'];
                                            $valor[3][$i] = $fila['TITULO'];
                                        }else{
                                            $valor['nombre'][$i] = '';
                                            $valor[3][$i] = '';
                                        }
                                        $i++;
                                    }
                                    $i = 0;
                                    if ($valor['nombre'][$i] === '') {
                                        $valor['nombre'][$i] = $titulo[0]['NOMBRE'];
                                        $valor[3][$i] = $titulo[0]['TITULO'];
                                    }
                                } else {
                                    $valor['nombre'][$i] = $titulo[0]['NOMBRE'];
                                    $valor[3][$i] = $titulo[0]['TITULO'];
                                }

                                break;
                            } else {
                                $valor['nombre'] = '';
                                $parametros['legajo'] = kernel::persona()->get_id_legajo_activo();
                                $carrera = kernel::persona()->get_info_carrera_activa();
                                $parametros['carrera'] = $carrera['id'];
                                $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
                                $titulo = catalogo::consultar('alumno', 'tipo_titulo', $parametros);
                                if (count($titulo) > 1) {
                                    foreach ($titulo as $fila) {
                                        if ($fila['TIPO_DE_TITULO'] === 'G') {
                                            $valor['nombre'] = $fila['NOMBRE'];
                                            $valor[3] = $fila['TITULO'];
                                        }
                                    }
                                    if ($valor['nombre'] === '') {
                                        $valor['nombre'] = $titulo[0]['NOMBRE'];
                                        $valor[3] = $titulo[0]['TITULO'];
                                    }
                                } else {
                                    $valor['nombre'] = $titulo[0]['NOMBRE'];
                                    $valor[3] = $titulo[0]['TITULO'];
                                }
                                break;
                            }
                        case "nombre_titulo":
                            if ($nro_certificado == 100) {
                                $valor[3] = '';
                                $i = 0;
                                $parametros['legajo'] = kernel::persona()->get_id_legajo_activo();
                                $carrera = kernel::persona()->get_info_carrera_activa();
                                $parametros['carrera'] = $carrera['id'];
                                $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
                                $titulo = catalogo::consultar('alumno', 'tipo_titulo', $parametros);
                                if (count($titulo) > 1) {
                                    foreach ($titulo as $fila) {
                                        if ($fila['TIPO_DE_TITULO'] === 'G') {
                                            $valor[3][$i] = $fila['NOMBRE'];
                                        }else{
                                            $valor[3][$i] = '';
                                        }
                                        $i++;
                                    }
                                    $i = 0;
                                    if ($valor[3][$i] === '') {
                                        $valor[3][$i] = $titulo[0]['NOMBRE'];
                                    }
                                } else {
                                    $valor[3][$i] = $titulo[0]['NOMBRE'];
                                }
                                break;
                            } else {
                                $valor[3] = '';
                                $parametros['legajo'] = kernel::persona()->get_id_legajo_activo();
                                $carrera = kernel::persona()->get_info_carrera_activa();
                                $parametros['carrera'] = $carrera['id'];
                                $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
                                $titulo = catalogo::consultar('alumno', 'tipo_titulo', $parametros);
                                if (count($titulo) > 1) {
                                    foreach ($titulo as $fila) {
                                        if ($fila['TIPO_DE_TITULO'] === 'G') {
                                            $valor[3] = $fila['NOMBRE'];
                                        }
                                    }
                                    if ($valor[3] === '') {
                                        $valor[3] = $titulo[0]['NOMBRE'];
                                    }
                                } else {
                                    $valor[3] = $titulo[0]['NOMBRE'];
                                }
                                break;
                            }
                    }
                    $resultado['argumentos'][$clave] = $valor;
                }
                kernel::log()->add_debug('argumentos', $resultado);

                return $resultado;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    protected function guardar_filas($nro_cert, $key_cert, $args_post) {
        $args_original = $this->argumentos_certificado($nro_cert);
        $params = array('indice_certificado' => $key_cert);
        foreach ($args_original['argumentos'] as $arg) {

            $params['orden'] = $arg[0];
            $tipo = $arg[2];
            if ($arg[4] == 'S') { // es editable
                $params['valor'] = $args_post[$params['orden']];
                // validacion?   case "char": $valor = "'" . DuplicarComillasSimples($val) . "'"; break;
            } else {
                if (is_array($arg[3])) {
                    $params['valor'] = $args_post[3];
                } else {
                    $params['valor'] = $arg[3];
                }
            }
            unset($tipo);

            catalogo::consultar('certificados', 'guardar_argumentos', $params);
        }
    }

    function asignar_identificador_cobro($diplomaSolicitado, $datosWS) {
        
        $error = false;
        
        $claseMdC = new ClienteMediosCobro();       
        $resp1 = $claseMdC->consultarIdentificadorCobro($diplomaSolicitado['identificador_deuda']);    

        // Comunicacion exitosa SIN resultado (string vacio). No existe deuda.
        if (!isset($resp1['faultcode']) && (empty($resp1)) && ($resp1 !== false)) {           
            $resp2 = $claseMdC->notificarNuevoCobro($datosWS);
            
            if (!isset($resp2['faultcode']) && (!empty($resp2)) && ( $resp2 !== false)) {
                $identificadorCobro = $resp2["return"]["codigo"];
}
            
            // Falla WS [notificarNuevoCobro]
            elseif (isset($resp2['faultcode']) || ( $resp2 === false)) {
                $error = true;
            }
        }
        
        // Comunicacion exitosa CON resultado. Ya existe deuda.
        elseif (!isset($resp1['faultcode']) && (!empty($resp1)) && ($resp1 !== false)) {           
            $identificadorCobro = $resp1["return"]["codigo"];
        }
                  
        // Falla WS [consultarIdentificadorCobro]
        elseif (isset($resp1['faultcode']) || ( $resp1 === false)) {
            $error = true;
        }
        
        if (!$error) {
            catalogo::consultar('certificados', 'guardar_identificador_cobro', array(
                'id_certif_pedido'             => $diplomaSolicitado['id_certif_pedido'],
                'identificador_cobro'   => $identificadorCobro
                )); 
        }
        
        return $error;
                    
    }

}
