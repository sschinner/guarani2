<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Credenciales invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */

//require_once("adodb/adodb.inc.php");
require_once ('bcrypt.php');
require_once ('Repositorio/RepositorioWS.php');
/* ------------------------------------------
  CLASE QUE CONTIENE LAS VARIABLES A RETORNAR
  ---------------------------------------- */

Class DatosWifiWS {

    // Variables Generales del WS
    var $codigoWS;
    var $mensajeWS;
    // Variables Locales del procedimiento
    var $codigoValidacion = 0;
    var $mensajeValidacion;

}

/* ------------------------------------------------------------------------------------------------
  FUNCION QUE INSERTA UN REGISTRO DE ENCUESTA COMPLETA DE GRADUADOS. ES INVOCADA POR EL SISTEMA DE AUTENTICACIÓN WIFI DE TELEMÁTICA
  ------------------------------------------------------------------------------------------------- */

Class UsuarioWifiWS {

    function autenticar($ua, $tipotitulo, $tipodoc, $nrodoc, $clave) {

        $wifi = new DatosWifiWS();

        // PASO 1: Autentico el usuario y password de webservices
        $aut = Generales::autenticar();
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $wifi->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $wifi->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $wifi;
        }

        // PASO 2: Verifico integridad de los datos pasados
        if ($ua == "" || $tipotitulo == "" || $tipodoc == "" || $nrodoc == "" || $clave == "") {
            $wifi->codigoWS = CODIGO_ERROR_PARAMETROS;
            $wifi->mensajeWS = MENSAJE_ERROR_PARAMETROS;
            return $wifi;
        }

        // PASO 3: ConexiOn a informix

        if ($tipotitulo == 0) {
            $titulos = Generales::recuperarTipoTitulo($ua);
        } else {
            $titulos = array($tipotitulo);
        }

        $estado = 0;
        foreach ($titulos as $titulo) {

            $db = Generales::recuperarDB($ua, $titulo);
            $objCC = Generales::conectar($db);

            if ($objCC == '3') {
                $wifi->codigoWS = CODIGO_ERROR_CONEXION;
                $wifi->mensajeWS = MENSAJE_ERROR_CONEXION;
                return $wifi;
            } else if (($titulo != '7') && (!Generales::verificaUAPS($ua,$titulo))) {
                
                // PASO 4: Desarrollo la funcion que necesito
                $strSQL = "EXECUTE PROCEDURE web_serv_autent_wifi(" . $tipodoc . ", '" . $nrodoc . "', '" . $clave . "');"; // devuelve la clave en caso OK
                $salida = $objCC->Execute($strSQL);


                if ($salida->fields[0] != "") {



                    $datosproc = $salida->getRows();
                    $wifi->codigoWS = CODIGO_OK;
                    $wifi->mensajeWS = MENSAJE_OK;


                    if ($datosproc[0][0] == 0 || $datosproc[0][0] == -4) { //Existe el usuario y la clave que se propone NO ES trivial (0); Existe el usuario y la clave que se propone ES trivial (-4)
                        // Ahora tengo que verificar la Clave
                        $enc = new bcrypt(10);

                        $login_ok = ($enc->verify($clave, $datosproc[0][1]));
                        if ($login_ok) {

                            if ($datosproc[0][0] == 0) {
                                $wifi->codigoValidacion = $datosproc[0][0];
                                $wifi->mensajeValidacion = "OK";
                                return $wifi;
                            } else {
                                //$wifi->codigoValidacion = $datosproc[0][0];
                                $datosproc[0][1] = "Clave Trivial - Debe resetear la clave en Guaraní";
                            }
                        } else {
                            $datosproc[0][0] = "-3";
                            $datosproc[0][1] = "Usuario o Clave Incorrectos";
                        }

                        if ($datosproc[0][0] < $estado) {
                            $wifi->codigoValidacion = $datosproc[0][0];
                            $wifi->mensajeValidacion = utf8_encode($datosproc[0][1]);
                            $estado = $datosproc[0][0];
                        }
                    } else {
                        if ($datosproc[0][0] < $estado) {
                            $wifi->codigoValidacion = $datosproc[0][0];
                            $wifi->mensajeValidacion = utf8_encode($datosproc[0][1]);
                            $estado = $datosproc[0][0];
                        }
                    }
                } else {
                    // Para controlar errores en la Invocacion desde el WS - Se conviene en Retornar de la Funcion del WS para garantizar integridad
                    $wifi->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                    $wifi->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                    return $wifi;
                }
            } else {
                
                $rep = new RepositorioWS();
                $resultado = $rep->autenticarWifi($tipodoc, $nrodoc, $objCC);
              
                if (!empty($resultado)) {
                    $wifi->codigoWS = CODIGO_OK;
                    $wifi->mensajeWS = MENSAJE_OK;
                    if ($resultado[0][0] == 0) {
                       
                        $resultado = $rep->validarUsuarioWifi($tipodoc, $nrodoc, $objCC);
                        $enc = new bcrypt(10);
                        $hash = $clave;
                        $login_ok = ($enc->verify($hash, $resultado[0]['clave']));
                        unset($enc);
                        if ($login_ok === FALSE) {
                            $wifi->codigoValidacion = '-3';
                            $wifi->mensajeValidacion = "Usuario o Clave Incorrectos";
                            return $wifi;
                        } else {
                            $wifi->codigoValidacion = '0';
                            $wifi->mensajeValidacion = "OK";
                            return $wifi;
                        }
                    } else if ($resultado[0][0] == -1 || $resultado[0][0] == -2 || $resultado[0][0] == -3) {
                        $wifi->codigoValidacion = $resultado[0][0];
                        $wifi->mensajeValidacion = $resultado[0][1];
                    }
                } else {
                    // Para controlar errores en la Invocacion desde el WS - Se conviene en Retornar de la Funcion del WS para garantizar integridad
                    $wifi->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                    $wifi->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                    return $wifi;
                }
            } // If error de conexion
        } // Foreach
        return $wifi;
    }

}

function autenticarUsuarioWifi($ua, $tipotitulo, $tipodoc, $nrodoc, $clave) {

    $servicio = new UsuarioWifiWS();
    $parametros = array('ua'=> $ua, 'tipotitulo'=> $tipotitulo, 'tipodoc'=> $tipodoc,'nrodoc'=> $nrodoc,'clave'=> $clave);
    Generales::logLlamada('autenticarUsuarioWifi', $parametros,false);
    $resultado = $servicio->autenticar($ua, $tipotitulo, $tipodoc, $nrodoc, $clave);
    return json_encode($resultado);
}

?>
