<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente. Y realiz� la operaci�n deseada por el cliente.
  '1': Error de autenticacion - Credenciales invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion. Implica alguna condici�n de error del lenguaje, que no es gestionada o en el llamado a la funci�n.
  ------------------------------------------------------------------------------------------ */

Class DatosAltaReinscripcionWS {

    // Variables Generales
    public $codigoWS;
    public $mensajeWS;

    // Variables Locales del procedimiento
}

/* ------------------------------------------------------------------------------------------------------------------
  FUNCION QUE INSERTA UN ALUMNO EN LA UNIDAD ACADEMICA CORRESPONDIENTE. ES INVOCADA POR Ingreso UNL.
  Se debe calcular la clave por default a setear y pasar como par�metro.
  ------------------------------------------------------------------------------------------------------------------- */

Class AtilraAltaReinscripcionWS {

    function insertar($ua, $tipotitulo, $carrera, $tipo_doc, $nro_doc, $pais_documento, $anio_academico, $fecha_reinscrip, $nro_transaccion) {

        $reinscripto = new DatosAltaReinscripcionWS();


        // PASO 1: Autentico el usuario y password de webservices
        $aut = Generales::autenticar();
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $reinscripto->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $reinscripto->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $reinscripto;
        }

        // PASO 2: Verifico integridad de los datos pasados
        if ($ua == "" || $tipotitulo == "" || $carrera == "" || $tipo_doc == "" || $nro_doc == "" || $pais_documento == "" || $anio_academico == "" || $fecha_reinscrip == "" || $nro_transaccion == "") {
            $reinscripto->codigoWS = CODIGO_ERROR_PARAMETROS;
            $reinscripto->mensajeWS = MENSAJE_ERROR_PARAMETROS;
            return $reinscripto;
        }

        // PASO 3: Conexion a informix
        /* $db = Generales::recuperarDB($ua, $tipotitulo);
          $co = ('informix:host=' . HOST . '; service=9086;database=' . $db . '; server=' . SERVER . '; protocol=olsoctcp; EnableScrollableCursors=1;');
          $objCC = Generales::conectar(true, $co); */
        $db = Generales::recuperarDB($ua, $tipotitulo);
        $objCC = Generales::conectar($db);
        if ($objCC == '3') {
            $reinscripto->codigoWS = CODIGO_ERROR_CONEXION;
            $reinscripto->mensajeWS = MENSAJE_ERROR_CONEXION;
            return $reinscripto;
        }

        // PASO 4: Desarrollo la funcion que necesito

        if (($tipotitulo != '7') && (!Generales::verificaUAPS($ua,$tipotitulo))) {
            $strSQL = 'EXECUTE PROCEDURE web_ser_alta_reinsc("' . $ua . '", "' . $carrera . '", "' . $pais_documento . '","' .
                    $tipo_doc . '", "' . $nro_doc . '", "' . $anio_academico . '", "' . $fecha_reinscrip . '", "' .
                    $nro_transaccion . '", "' . "3" . '");';

            $res = $objCC->Execute($strSQL);

            if ($res->fields[0] != "") {
                $datosproc = $res->getRows();
                $reinscripto->codigoWS = $datosproc[0][0];
                $reinscripto->mensajeWS = iconv("ISO-8859-1", "utf-8", $datosproc[0][1]);
                return $reinscripto;
            } else {
                $reinscripto->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                $reinscripto->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                return $reinscripto;
            }
        } else {
            $rep = new RepositorioWS();
            $resul = $rep->setReinscripcion($ua, $tipotitulo, $carrera, $tipo_doc, $nro_doc, $pais_documento, $anio_academico, $fecha_reinscrip, $nro_transaccion, $objCC);
            if (!empty($resul)) {
                $reinscripto->codigoWS = (string)$resul[0][0];
                $reinscripto->mensajeWS = iconv("ISO-8859-1", "utf-8", $resul[0][1]);
                return $reinscripto;
            } else {
                $reinscripto->codigoWS = (string)CODIGO_ERROR_PROCEDIMIENTO;
                $reinscripto->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                return $reinscripto;
            }
        }
    }

}

function altaReinscripcion($ua, $tipotitulo, $carrera, $tipo_doc, $nro_doc, $pais_documento, $anio_academico, $fecha_reinscrip, $nro_transaccion) {
    $servicio = new AtilraAltaReinscripcionWS();
    $resultado = $servicio->insertar($ua, $tipotitulo, $carrera, $tipo_doc, $nro_doc, $pais_documento, $anio_academico, $fecha_reinscrip, $nro_transaccion);
    return json_encode($resultado);
}

?>
