<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Credenciales invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */

/* ------------------------------------------------------------------------------------------------
  FUNCION QUE INSERTA UN REGISTRO DE ENCUESTA COMPLETA DE GRADUADOS. ES INVOCADA POR EL SISTEMA KOLLA
  ------------------------------------------------------------------------------------------------- */

Class KollaDatosWs {
    /* --------- variables generales de WS ---------- */

    public $codigoWS;
    public $mensajeWS;

    /* --------- variables encuestaCompleta ---------- */
}

Class KollaEncuestaCompleta {

    function DatosEncuesta($ua, $tipodoc, $nrodoc, $codigotit, $fechafinenc, $nrotransaccion) {
        
        $encuesta = new KollaDatosWs();
        $aut = Generales::autenticar();

        // PASO 1: Autentico el usuario y password de webservices
        if ($aut ==CODIGO_ERROR_AUTENTICACION) {
            $encuesta->codigoWS =CODIGO_ERROR_AUTENTICACION;
            $encuesta->mensajeWS = "Error de autenticacion - Credenciales invalidas.";
            return $encuesta;
        }

        // PASO 2: Verifico integridad de los datos pasados
        if ($ua == "" || $tipodoc == "" || $nrodoc == "" || $codigotit == "" || $fechafinenc == "" || $nrotransaccion == "") {
            $encuesta->mensajeWS =MENSAJE_ERROR_PARAMETROS;
            $encuesta->codigoWS =CODIGO_ERROR_PARAMETROS;
            return $encuesta;
        }

        // PASO 3: Conexi�n a informix
        $host = 'guarani.intranet';
        $server = 'rectorado_csm';
       /* $db = Generales::recuperarDB($ua, 1);
        
        //$co = ('informix:host=' . $host . '; service=9086;database=' . $db . '; server=' . $server . '; protocol=olsoctcp; EnableScrollableCursors=1;');
        $co = ('informix:host=' . HOST . '; service=9086;database=' . $db . '; server=' . SERVER . '; protocol=olsoctcp; EnableScrollableCursors=1;');
        $objCC = Generales::conectar(true, $co);*/
        
        $db = Generales::recuperarDB($ua, 1);
        $objCC = Generales::conectar($db);
        if ($objCC == '3') {
            $encuesta->codigoWS = CODIGO_ERROR_CONEXION;
            $encuesta->mensajeWS = MENSAJE_ERROR_CONEXION;
            return $encuesta;
        }

        // PASO 4: Desarrollo la funcion que necesito
        $strSQL = "EXECUTE PROCEDURE web_serv_enc_kolla('" . $ua . "', " . $tipodoc . ", '" . $nrodoc . "', " . $codigotit . ", '" . $fechafinenc . "','" . $nrotransaccion . "');";
        $res = $objCC->Execute($strSQL);

        if ($res->fields[0] == 0) {
            $encuesta->codigoWS = "0";
            $encuesta->mensajeWS = "La funcion se ejecuto correctamente.";
            return $encuesta;
        } else {
            $resultado = $res->getRows();
            $encuesta->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
            $encuesta->mensajeWS = "Error de procedimiento: " . iconv("ISO-8859-1", "utf-8", $resultado[0][1]);
            return $encuesta;
        }
    }

}

function encuestaCompleta($ua, $tipodoc, $nrodoc, $codigotit, $fechafinenc, $nrotransaccion) {
    $servicio = new KollaEncuestaCompleta();
    $resultado = $servicio->DatosEncuesta($ua, $tipodoc, $nrodoc, $codigotit, $fechafinenc, $nrotransaccion);
    return json_encode($resultado);
}

?>
