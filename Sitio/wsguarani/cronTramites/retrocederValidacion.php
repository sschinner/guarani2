<?php

include_once('tramites.php');
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

Class DatosRetrocesoWS {

    // Variables Generales del WS
    var $codigoWS;
    var $mensajeWS;

}

/* ----------------------------------------------------------------
  FUNCION QUE REGISTRA LA VUELTA ATRAS DE UN TRAMITE DE CERTIFICADO
  ----------------------------------------------------------------- */

Class ExpedienteValidadoWS {

    public $configEntorno;

    function __construct() {
        $this->configEntorno = parse_ini_file("/etc/guarani292/configEntorno.ini", true);
    }

    function retroceder($expediente, $motivoRechazo) {
        $exp = new DatosRetrocesoWS();

        // PASO 1: Autentico el usuario y password de webservices
        $datosAutenticar = new stdClass();
        $datosAutenticar->usuario = $this->configEntorno["wsCredenciales"]["userTramites"];
        $datosAutenticar->password = $this->configEntorno["wsCredenciales"]["passTramites"];
        $aut = Generales::autenticarConIni($datosAutenticar);
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $exp->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $exp->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $exp;
        }

        // PASO 2: Verifico integridad de los datos pasados
        if ($expediente == "") {
            $exp->codigoWS = CODIGO_ERROR_PARAMETROS;
            $exp->mensajeWS = "El expediente no puede ser nulo";
            return $exp;
        }
        
        // PASO 3: Conexion a informix
        $tramites = new Tramites();
        $certificado = $tramites->getCertificado($expediente);
        if ($certificado) {
            $estado = $tramites->rechazarValidacion($certificado["db"], $expediente, $motivoRechazo);
            if ($estado) {
                $exp->codigoWS = CODIGO_OK;
                $exp->mensajeWS = MENSAJE_OK;
            } else {
                $exp->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                $exp->mensajeWS = 'El tramite no se ha rechazado - Intentar nuevamente mas tarde';
            }
        } else {
            $exp->codigoWS = CODIGO_ERROR_PARAMETROS;
            $exp->mensajeWS = 'El numero de expediente no se ha encontrado';
        }

        return $exp;
    }

}

function retrocederValidacion($expediente, $motivoRechazo) {

    $servicio = new ExpedienteValidadoWS();
    $resultado = $servicio->retroceder($expediente, $motivoRechazo);
    return json_encode($resultado);
}
