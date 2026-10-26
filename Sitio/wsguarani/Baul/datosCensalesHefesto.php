<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Usuario y contrase�a invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */

//require_once("adodb/adodb.inc.php");

/* ----------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE DATOS CENSALES DE UN ALUMNO - ES INVOCADA POR EL SISTEMA HEFESTO
  ----------------------------------------------------------------------------------- */

Class HefestoDatosCensales {
    /* --------- variables datosCensalesHefesto---------- */

    public $codigoWS;
    public $mensajeWS;
    public $tipoTitulo;
    public $codigoRetorno;
    public $tipoDocumento;
    public $nroDocumento;
    public $fechaNacimiento;
    public $apellido;
    public $nombre;
    public $sexo;
    public $localidadProc;
    public $cpProc;
    public $localidadRes;
    public $cpRes;
    public $direccionRes;
    public $nroRes;
    public $pisoRes;
    public $deptoRes;
    public $unidad;
    public $telefono;
    public $email;

}

class DatosCensales {

    function datos($usuario, $unidadAcademica, $tipoTitulo) {

        $hefesto = new HefestoDatosCensales();

        $ua = $unidadAcademica;
        $aut = Generales::autenticar();
        if ($aut ==CODIGO_ERROR_AUTENTICACION) {
            $hefesto->codigoWS =CODIGO_ERROR_AUTENTICACION;
            $hefesto->mensajeWS =MENSAJE_ERROR_AUTENTICACION;
            $retorno = $hefesto;
            unset($hefesto);
            return $retorno;
        } else {
            if ($ua == "" || $usuario == "" || $tipoTitulo == "") {
                $hefesto->mensajeWS =MENSAJE_ERROR_PARAMETROS;
                $hefesto->codigoWS =CODIGO_ERROR_PARAMETROS;
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
            
            foreach ($titulos as $titulo) {
                
                $db = Generales::recuperarDB($ua, $titulo);
                $objCC = Generales::conectar($db);
               
                if ($objCC == '3') {
                    $hefesto->codigoWS = CODIGO_ERROR_CONEXION;
                    $hefesto->mensajeWS = MENSAJE_ERROR_CONEXION;
                    $retorno = $hefesto;
                    unset($hefesto);
                    return $retorno;
                } else {
                    //realizo la consulta para obtener los datos censales
                    $strSQL = "execute procedure web_serv_dat_cen_hefe('" . $usuario . "');";
                    $res = $objCC->Execute($strSQL);
                    $objCC->Close();
                    if ($res && ($res->RecordCount() > 0)) {
                        $resultado = $res->getRows();
                        if ($resultado) {
                            $hefesto->codigoWS = CODIGO_OK;
                            $hefesto->mensajeWS = MENSAJE_OK;
                            $hefesto->tipoTitulo = $titulo;

                            foreach ($resultado as $resu) {
                                if ($resu[0] == 0)
                                    $hefesto->codigoRetorno = false;
                                else
                                    $hefesto->codigoRetorno = true;

                                $hefesto->tipoDocumento = $resu[1];
                                $hefesto->nroDocumento = $resu[2];
                                $hefesto->fechaNacimiento = $resu[3];
                                $hefesto->apellido = iconv("ISO-8859-1", "utf-8", $resu[4]);
                                $hefesto->nombre = iconv("ISO-8859-1", "utf-8", $resu[5]);
                                $hefesto->sexo = $resu[6];
                                $hefesto->localidadProc = ($resu[7]);
                                $hefesto->cpProc = $resu[8];
                                $hefesto->localidadRes = ($resu[9]);
                                $hefesto->cpRes = $resu[10];
                                $hefesto->direccionRes = iconv("ISO-8859-1", "utf-8", $resu[11]);
                                $hefesto->nroRes = $resu[12];
                                $hefesto->pisoRes = $resu[13];
                                $hefesto->deptoRes = $resu[14];
                                $hefesto->unidad = $resu[15];
                                $hefesto->telefono = $resu[16];
                                $hefesto->email = $resu[17];
                            }
                            if ($hefesto->codigoRetorno == true) {
                                $retorno = $hefesto;
                                unset($hefesto);
                                return $retorno;
                            }
                        }
                    }
                }
            }
            if ($hefesto->codigoWS == '0') {
                $retorno = $hefesto;
                unset($hefesto);
                return $retorno;
            } else if ($hefesto->codigoWS != "0") {
                $hefesto->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                $hefesto->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                $retorno = $hefesto;
                unset($hefesto);
                return $retorno;
            }
        }
    }

}

function datosCensalesHefesto($usuario, $unidadAcademica, $tipoTitulo = 0) {
    $servicio = new DatosCensales();
    $resultado = $servicio->datos($usuario, strtoupper($unidadAcademica), $tipoTitulo);
    return json_encode($resultado);
}

?>
