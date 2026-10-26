<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Usuario y contrase�a invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */
require_once ('bcrypt.php');
require_once ('Repositorio/RepositorioWS.php');

Class HefestoAutenticarUsuario {

    public $codigoWS = '';
    public $mensajeWS;
    public $tipoTitulo;
    public $codigoRetorno;
    public $mensajeRetorno;

}

/* ---------------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE SI EXISTE USUARIO DE AUTOGESTION - ES INVOCADA POR EL SISTEMA HEFESTO
  ---------------------------------------------------------------------------------------- */

Class AutenticarUsuario {

    function autenticar($usuario, $clave, $unidadAcademica, $tipoTitulo) {

        $hefesto = new HefestoAutenticarUsuario();

        $ua = $unidadAcademica;
        $aut = Generales::autenticar();
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $hefesto->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $hefesto->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            $retorno = $hefesto;
            unset($hefesto);
            return $retorno;
        } else {
            if ($ua == "" || $usuario == "" || $clave == "" || $tipoTitulo == "") {
                $hefesto->codigoWS = CODIGO_ERROR_PARAMETROS;
                $hefesto->mensajeWS = MENSAJE_ERROR_PARAMETROS;
                $retorno = $hefesto;
                unset($hefesto);
                return $retorno;
            }

            if ($tipoTitulo == 0) {
                $titulos = Generales::recuperarTipoTituloConCemed($ua);
                $titulos = array_reverse($titulos);
            } else {
                $titulos = array($tipoTitulo);
            }
            // entra con 1
            foreach ($titulos as $titulo) {

                $db = Generales::recuperarDB($ua, $titulo);
                // se conecta a guarani3_
                $objCC = Generales::conectar($db);

                if ($objCC == '3') {
                    $hefesto->codigoWS = CODIGO_ERROR_CONEXION;
                    $hefesto->mensajeWS = MENSAJE_ERROR_CONEXION;
                    $retorno = $hefesto;
                    unset($hefesto);
                    return $retorno;
                } else {
                    if ($titulo == '6') {
                        /**
                         *  Realizo la consulta en CEMED para obtener los datos censales 
                         */
                        $strSQL = "execute procedure web_serv_alu_autent_hefe('" . $usuario . "','" . $clave . "');";
                        $res = $objCC->Execute($strSQL);

                        if ($res->fields[0] != "") {
                            $resultado = $res->getRows();
                            $hefesto->codigoWS = CODIGO_OK;
                            $hefesto->mensajeWS = MENSAJE_OK;
                            $hefesto->tipoTitulo = $titulo;
                            $hefesto->codigoRetorno = $resultado[0][0];
                            if ($resultado[0][0] != 1) {
                                $hefesto->codigoRetorno = false;
                                $hefesto->mensajeRetorno = "No es usuario guarani";
                            } else {
                                $hefesto->codigoRetorno = true;
                                $hefesto->mensajeRetorno = "Es usuario guarani";
                                return $hefesto;
                            }
                        }
                    } else if (($titulo == '7') || (Generales::verificaUAPS($ua, $titulo))) {
                        /**
                         *  Realizo la consulta en Postgres para obtener los datos censales 
                         */
                        $rep = new RepositorioWS();
                        $resul = $rep->validarUsuarioGuarani($usuario, $objCC);
                       
                        if (!empty($resul)) {
                            $hefesto->codigoWS = CODIGO_OK;
                            $hefesto->mensajeWS = MENSAJE_OK;
                            $hefesto->tipoTitulo = $titulo;
                            $hefesto->codigoRetorno = 1;
                            $enc = new bcrypt(10);
                            $hash = md5($clave);
                            $login_ok = ($enc->verify($hash, $resul[0]['clave']));
                            unset($enc);
                            if ($login_ok === FALSE) {
                                $hefesto->codigoRetorno = false;
                                $hefesto->mensajeRetorno = "No es usuario guarani";
                            } else {
                                $hefesto->codigoRetorno = true;
                                $hefesto->mensajeRetorno = "Es usuario guarani";
                                return $hefesto;
                            }
                        } else {
                            
                            $hefesto->codigoRetorno = false;
                            $hefesto->mensajeRetorno = "No es usuario guarani";
                        }
                    } else {
                        /**
                         *  Realizo la consulta en Informix para obtener los datos censales 
                         */
                        $strSQL = "execute procedure web_serv_alu_clave('" . $usuario . "');";
                        $res = $objCC->Execute($strSQL);
                        $objCC->Close();
                        if ($res && ($res->RecordCount() > 0)) {
                            $resultado = $res->getRows();
                            if ($resultado) {
                                $hefesto->codigoWS = CODIGO_OK;
                                $hefesto->mensajeWS = MENSAJE_OK;
                                $hefesto->tipoTitulo = $titulo;
                                $hefesto->codigoRetorno = $resultado[0][0];
                                $enc = new bcrypt(10);

                                $login_ok = ($enc->verify(md5($clave), $resultado[0][1]));
                                unset($enc);
                                if ($login_ok === FALSE) {
                                    $hefesto->codigoRetorno = false;
                                    $hefesto->mensajeRetorno = "No es usuario guarani";
                                } else {
                                    $hefesto->codigoRetorno = true;
                                    $hefesto->mensajeRetorno = "Es usuario guarani";
                                    return $hefesto;
                                }
                            } else {
                                $hefesto->codigoRetorno = false;
                                $hefesto->mensajeRetorno = "No es usuario guarani";
                            }
                        }
                    }
                }
            }

            if ($hefesto->codigoWS == CODIGO_OK) {
                $retorno = $hefesto;
                unset($hefesto);
                return $retorno;
            } else if ($hefesto->codigoWS == "" || $hefesto->codigoRetorno == false) {
                $hefesto->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                $hefesto->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                $retorno = $hefesto;
                unset($hefesto);
                return $retorno;
            }
        }
    }

}

function autenticarUsuarioGuarani($usuario, $clave, $unidadAcademica, $tipoTitulo) {
    $servicio = new AutenticarUsuario();
    //$tipoTitulo = Generales::conversionUATT($unidadAcademica, $tipoTitulo);
    $parametros = array('usuario'=> $usuario, 'clave'=> $clave,
                        'unidadAcademica'=> $unidadAcademica, 'tipoTitulo'=> $tipoTitulo);
    Generales::logLlamada('autenticarUsuarioGuarani', $parametros,false);
    $resultado = $servicio->autenticar($usuario, $clave, strtoupper($unidadAcademica), $tipoTitulo);
    return json_encode($resultado);
}

?>
