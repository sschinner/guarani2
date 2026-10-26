<?php

include('tramites.php');

// Auditoria
include_once(dirname(__DIR__) . '/Repositorio/RepositorioWS.php');
/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Credenciales invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */

/* ------------------------------------------
  CLASE QUE CONTIENE LAS VARIABLES A RETORNAR
  ---------------------------------------- */

Class DatosUrlDescargaWS {

    // Variables Generales del WS
    var $codigoWS;
    var $mensajeWS;

}

/* ------------------------------------------------------------------
  FUNCION QUE REGISTRA LA URL DE DESCARGA DE UN CERTIFICADO ANALITICO
  ------------------------------------------------------------------- */

Class ExpedienteUrlWS {

    public $configEntorno;

    function __construct() {
        $this->configEntorno = parse_ini_file("/etc/guarani292/configEntorno.ini", true);
    }

    function notificar($expediente, $urlCertificado, $tipoNotificacion) {
        $url = new DatosUrlDescargaWS();

        // PASO 1: Autentico el usuario y password de webservices
        $datosAutenticar = new stdClass();
        $datosAutenticar->usuario = $this->configEntorno["wsCredenciales"]["userTramites"];
        $datosAutenticar->password = $this->configEntorno["wsCredenciales"]["passTramites"];
        $aut = Generales::autenticarConIni($datosAutenticar);
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $url->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $url->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $url;
        }

        // PASO 2: Verifico integridad de los datos pasados
        if ($expediente == "") {
            $url->codigoWS = CODIGO_ERROR_PARAMETROS;
            $url->mensajeWS = "El expediente no puede ser nulo";
            return $url;
        }
        if ($urlCertificado == "") {
            $url->codigoWS = CODIGO_ERROR_PARAMETROS;
            $url->mensajeWS = "La url de descarga no puede ser nula";
            return $url;
        }
        if ($tipoNotificacion == "" || !in_array($tipoNotificacion, array('MAT_APROB', 'HIST_ACAD', 'CA_PROVISORIO', 'TIT_EN_TRAMITE', 'CA_DEFINITIVO', 'DIPLOMA', 'RETIRAR_DIPLOMA_IMPRESO'))) {
            $url->codigoWS = CODIGO_ERROR_PARAMETROS;
            $url->mensajeWS = "El tipo de notificacion debe ser CA_PROVISORIO, TIT_EN_TRAMITE, CA_DEFINITIVO, DIPLOMA o RETIRAR_DIPLOMA_IMPRESO";
            return $url;
        }

        // PASO 3: Conexion a informix
        $tramites = new Tramites();
        $certificado = $tramites->getCertificado($expediente);
        if ($certificado) {
            $estado = $tramites->registrarUrl($certificado["db"], $expediente, $urlCertificado, $tipoNotificacion);
            $titulo = 'Descarga de certificados';
            switch ($tipoNotificacion) {
                case 'CA_PROVISORIO': 
                    $nombreCertificado = "certificado anal韙ico provisorio";
                    break;
                case 'TIT_EN_TRAMITE': 
                    $nombreCertificado = "certificado de t韙ulo en tr醡ite";
                    break;
                case 'CA_DEFINITIVO': 
                    $nombreCertificado = "certificado anal韙ico definitivo";
                    break;
                case 'DIPLOMA': 
                    $nombreCertificado = "diploma digital";
                    break;
                case 'MAT_APROB': 
                    $nombreCertificado = "certificado de materias aprobadas";
                    break;
                case 'HIST_ACAD': 
                    $nombreCertificado = "certificado de historia acad閙ica";
                    break;
            }
            $mensaje = "Por este medio, le informamos que, el " . $nombreCertificado . " solicitado, ya se encuentra disponible para su descarga.";
			
			if ($tipoNotificacion == 'RETIRAR_DIPLOMA_IMPRESO') {
				$titulo = "T韙ulo Digital impreso";
				$mensaje = "Comunicamos por este medio que su Tr醡ite de Diploma Digital ha finalizado. Le recomendamos que se comunique con la Secretar韆 Administrativa de su Unidad Acad閙ica, luego de las 48hs. h醔iles de recepcionado este mensaje, para coordinar la entrega del Cart髇 Simb髄ico impreso de su Diploma.";
			}

            /* $argumentos = $tramites->obtenerArgumentosCertificado($certificado["db"], $certificado["id"]);
            $ministerial = ($argumentos[0]["version"] == "G2") ? $argumentos[4]['argumento'] : $argumentos[0]['argumento'];
            if (($ministerial == 'N') || ($ministerial == 'S' && $tipoNotificacion == 'P')){
                $mensaje = 'Por este medio, le informamos que, el certificado por ud. solicitado, ya se encuentra disponible para su DESCARGA.';
            }
            if ($ministerial == 'S' && $tipoNotificacion == 'F'){
                $mensaje = 'Le informamos que el tr谩mite del certificado que ha solicitado finaliz贸 con 茅xito. Comun铆quese con el alumnado de su facultad para coordinar su entrega. ';
                $mensaje = 'Tu documentaci贸n de Certificado Anal铆tico registrada por la DNGyFU del Ministerio de Educaci贸n ya se encuentra disponible para su descarga. Pod茅s acceder desde tu Guaran铆 Autogesti贸n, opci贸n Tr谩mites > Descarga certificados.';
            }*/
            $campoBusqueda = 'expediente';
            $datoBusqueda = $expediente;
            $mail = $tramites->enviarMail($titulo, $mensaje, $campoBusqueda, $datoBusqueda);
            if ($estado) {
                $url->codigoWS = CODIGO_OK;
                $url->mensajeWS = MENSAJE_OK;
            } else {
                $url->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                $url->mensajeWS = 'La URL no se ha actualizado - Intentar nuevamente mas tarde';
            }
        } else {
            $url->codigoWS = CODIGO_ERROR_PARAMETROS;
            $url->mensajeWS = 'El numero de expediente no se ha encontrado';
        }

        return $url;
    }

}

function notificarUrlCertificado($expediente, $urlCertificado, $tipoNotificacion) {

	$param = [$expediente, $urlCertificado, $tipoNotificacion];
	$repositorio = new RepositorioWS();
	$repositorio->registrarAuditoria($param, null, 'notificarUrlCertificado', $_SERVER['PHP_AUTH_USER']);

    $servicio = new ExpedienteUrlWS();
    $resultado = $servicio->notificar($expediente, $urlCertificado, $tipoNotificacion);
    return json_encode($resultado);
}
