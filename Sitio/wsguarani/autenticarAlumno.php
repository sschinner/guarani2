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
//define("URL_AUTENTICA_SIGUV_REST", "https://www.unlvirtual.edu.ar/test/campusvirtual/ws/autenticarUsuario?");

Class AtributosAutenticar {

    public $codigoWS;
    public $mensajeWS;
    public $tipoTitulo;
    public $codigoRetorno;
    public $mensajeRetorno;

}

/* ---------------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE SI EXISTE USUARIO DE AUTOGESTION - ES INVOCADA POR EL SISTEMA HEFESTO
  ---------------------------------------------------------------------------------------- */

Class Autenticar {

    function autenticarUsuario($usuario, $clave, $unidadAcademica, $tipoTitulo,$credenciales) {

        $alumno = new AtributosAutenticar();
        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('siguv','hefesto', 'telematica', 'gea', 'bedeliamovil');
        $ua = $unidadAcademica;
        
        $aut = Generales::autenticarAutorizar($usuarios,$passwords,$permitidos);
        
        //$aut = Generales::autenticar();
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $alumno->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $alumno->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            $retorno = $alumno;
            unset($alumno);
            return $retorno;
        } else {
            if ($ua == "" || $usuario == "" || $clave == "" || $tipoTitulo == "") {
                $alumno->codigoWS = CODIGO_ERROR_PARAMETROS;
                $alumno->mensajeWS = MENSAJE_ERROR_PARAMETROS;
                $retorno = $alumno;
                unset($alumno);
                return $retorno;
            }

            
            if (Generales::verificaUnidadAcademica($unidadAcademica)) {
                if ($tipoTitulo == 0) {
                    $titulos = Generales::recuperarTipoTituloConCemed($unidadAcademica);
                    $titulos = array_reverse($titulos);
                } else {
                    $titulos = array($tipoTitulo);
                }
            } else {
                $alumno->setMensajeWS(utf8_encode("Error de parametros - Unidad Acad�mica " . $unidadAcademica . " inexistente - Verifique"));
                $alumno->setCodigoWS(CODIGO_ERROR_PARAMETROS);
                $retorno = $alumno;
                unset($alumno);
                return $retorno;
            }

            foreach ($titulos as $titulo) {

                $db = Generales::recuperarDB($ua, $titulo);
                $objCC = Generales::conectar($db);

                if ($objCC == '3') {
                    $alumno->codigoWS = CODIGO_ERROR_CONEXION;
                    $alumno->mensajeWS = MENSAJE_ERROR_CONEXION;
                    $retorno = $alumno;
                    unset($alumno);
                    return $retorno;
                } else {
                    /**
                     * CEMED
                     */
                    if ($titulo == '6') {
                        
                        $alumno->tipoTitulo = $titulo;
                        $resultado = json_decode(self::autenticaSiguv($usuario, $clave));

                        if ($resultado->codigoWS === 0 && $resultado->codigoRetorno === 0) {
                            $alumno->codigoWS = CODIGO_OK;
                            $alumno->mensajeWS = MENSAJE_OK;
                            
                        } else {
                            $alumno->codigoRetorno == false;
                            $alumno->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                            $alumno->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                        }
                        if ($resultado->mensajeRetorno->esUsuario) {                         
                            $alumno->codigoRetorno = true;
                            $alumno->mensajeRetorno = "Es usuario guarani CEMED: $db";
                            return $alumno;
                        } else {
                            $alumno->codigoRetorno = false;
                            $alumno->mensajeRetorno = "No es usuario guarani";
                        }
                    } else if (($titulo == '7') || (Generales::verificaUAPS($ua, $titulo))) {
                        /**
                         *  Realizo la consulta en Postgres para obtener los datos censales 
                         */
                        $rep = new RepositorioWS();
                        $resul = $rep->validarUsuarioGuarani($usuario, $objCC);
                        $alumno->codigoWS = CODIGO_OK;
                        $alumno->mensajeWS = MENSAJE_OK;

                        if (!empty($resul)) {
                            $alumno->tipoTitulo = $titulo;
                            $alumno->codigoRetorno = 1;
                            $enc = new bcrypt(10);
                            $hash = md5($clave);
                            $login_ok = ($enc->verify($hash, $resul[0]['clave']));
                            unset($enc);
                            if ($login_ok === FALSE) {
                                $alumno->codigoRetorno = false;
                                $alumno->mensajeRetorno = "No es usuario guarani";
                                $alumno->tipoTitulo = 0;
                            } else {
                                $alumno->codigoRetorno = true;
                                $alumno->mensajeRetorno = "Es usuario guarani";
                                return $alumno;
                            }
                        } else {
                            $alumno->codigoRetorno = false;
                            $alumno->mensajeRetorno = "No es usuario guarani";
                            $alumno->tipoTitulo = 0;
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
                                $alumno->codigoWS = CODIGO_OK;
                                $alumno->mensajeWS = MENSAJE_OK;
                                $alumno->tipoTitulo = $titulo;
                                $alumno->codigoRetorno = $resultado[0][0];
                                $enc = new bcrypt(10);

                                $login_ok = ($enc->verify(md5($clave), $resultado[0][1]));
                                unset($enc);
                                if ($login_ok === FALSE) {
                                    $alumno->codigoRetorno = false;
                                    $alumno->mensajeRetorno = "No es usuario guarani";
                                    $alumno->tipoTitulo = 0;
                                } else {
                                    $alumno->codigoRetorno = true;
                                    $alumno->mensajeRetorno = "Es usuario guarani G2: " . $db;
                                    return $alumno;
                                }
                            } else {
                                $alumno->codigoRetorno = false;
                                $alumno->mensajeRetorno = "No es usuario guarani";
                                $alumno->tipoTitulo = 0;
                            }
                        }
                    }
                }
            }

            if ($alumno->codigoWS == CODIGO_OK) {
                $retorno = $alumno;
                unset($alumno);
                return $retorno;
            } else if ($alumno->codigoWS == "" || $alumno->codigoRetorno == false) {
                $alumno->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                $alumno->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                $retorno = $alumno;
                unset($alumno);
                return $retorno;
            }
        }
    }

    private function autenticaSiguv($usuario, $clave) {

        $username = 'hefesto';
        $password = 'h3f3st4';
        $url = URL_AUTENTICA_SIGUV_REST . "usuario=" . $usuario . "&clave=" . $clave;
        $digest = hash('sha256', "$username:$password");
        $headers = array('Content-Type:application/json', 'Authorization: Digest ' .$digest);
        
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_DIGEST);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);

        $result = curl_exec($ch);
        curl_close($ch);

        return $result;
    }

}

function autenticarAlumno($usuario, $clave, $unidadAcademica, $tipoTitulo) {
    $servicio = new Autenticar();
    $credenciales = new Credenciales();
    $parametros = array('usuario'=> $usuario, 'clave'=> $clave,
                        'unidadAcademica'=> $unidadAcademica, 'tipoTitulo'=> $tipoTitulo);
    Generales::logLlamada('autenticarAlumno', $parametros,false);
   
    $resultado = $servicio->autenticarUsuario($usuario, $clave, strtoupper(trim($unidadAcademica)), $tipoTitulo,$credenciales);
    return json_encode($resultado);
}

?>
