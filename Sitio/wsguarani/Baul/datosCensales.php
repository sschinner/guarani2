<?php

require_once ('Repositorio/RepositorioWS.php');
/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Usuario y contraseña invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */

//require_once("adodb/adodb.inc.php");

Class AtributosDatosCensales {

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
    public $nroCelular;
    public $compCelular;

}

/* ---------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE DATOS CENSALES DE UN ALUMNO - ES INVOCADA POR EL SISTEMA KUNTUR
  ---------------------------------------------------------------------------------- */

Class DatosCensalesAlumno {

    function datos($usuario, $unidadAcademica, $tipoTitulo) {
        $datos = new AtributosDatosCensales();
        $resultado = '';
        $ua = $unidadAcademica;
        $aut = Generales::autenticar();
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $datos->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $datos->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $datos;
        } else {
            if ($ua == "" || $usuario == "" || $tipoTitulo == "") {
                $datos->mensajeWS = MENSAJE_ERROR_PARAMETROS;
                $datos->codigoWS = CODIGO_ERROR_PARAMETROS;
                return $datos;
            }

            if ($tipoTitulo == 0) {
                $titulos = Generales::recuperarTipoTituloConCemed($ua);
                // $titulos = array_reverse($titulos);
            } else {
                $titulos = array($tipoTitulo);
            }

            foreach ($titulos as $titulo) {

                $db = Generales::recuperarDB($ua, $tipoTitulo);
                $objCC = Generales::conectar($db);

                if ($objCC == '3') {
                    $datos->codigoWS = CODIGO_ERROR_CONEXION;
                    $datos->mensajeWS = MENSAJE_ERROR_CONEXION;
                    return $datos;
                } else if (($titulo != '7') && (!Generales::verificaUAPS($ua, $titulo))) {
                    /**
                     *  Realizo la consulta en Informix para obtener los datos censales 
                     */
                    $strSQL = "execute procedure web_serv_dat_cen_hefe('" . $usuario . "');";
                    $res = $objCC->Execute($strSQL);

                    if ($res->fields[0] != "") {
                        $resultado = $res->getRows();
                        $datos->codigoWS = CODIGO_OK;
                        $datos->mensajeWS = MENSAJE_OK;
                        $datos->tipoTitulo = $titulo;
                    } else {
                        $datos->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                        $datos->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                        //return $datos;
                    }
                } else {
                    /**
                     *  Realizo la consulta en Postgres para obtener los datos censales 
                     */
                    $rep = new RepositorioWS();
                    $resultado = $rep->obtenerDatosCensales($usuario, $objCC);
                    if (!empty($resultado)) {
                        $datos->codigoWS = CODIGO_OK;
                        $datos->mensajeWS = MENSAJE_OK;
                        $datos->tipoTitulo = $titulo;
                    } else {
                        $datos->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                        $datos->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                    }
                }
                if ($datos->codigoWS == CODIGO_OK) {
                    /**
                     *  Mapeo de valores obtenidos 
                     */
                    foreach ($resultado as $resu) {
                        if ($resu[0] == 0)
                            $datos->codigoRetorno = false;
                        else
                            $datos->codigoRetorno = true;

                        $datos->tipoDocumento = $resu[1];
                        $datos->nroDocumento = $resu[2];
                        $datos->fechaNacimiento = $resu[3];
                        setlocale(LC_ALL, 'en_US');
                        $datos->apellido = iconv("ISO-8859-1", "utf-8", $resu[4]);
                        $datos->nombre = iconv('ISO-8859-1', 'UTF-8//TRANSLIT', $resu[5]);
                        if ($resu[6] == 'F' || $resu[6] == '2') {
                            $datos->sexo = 2;
                        } else {
                            $datos->sexo = 1;
                        }
                        $datos->localidadProc = iconv("ISO-8859-1", "utf-8", $resu[7]);
                        $datos->cpProc = $resu[8];
                        $datos->localidadRes = iconv("ISO-8859-1", "utf-8", $resu[9]);
                        $datos->cpRes = $resu[10];
                        $datos->direccionRes = iconv("ISO-8859-1", "utf-8", $resu[11]);
                        $datos->nroRes = $resu[12];
                        $datos->pisoRes = $resu[13];
                        $datos->deptoRes = $resu[14];
                        $datos->unidad = $resu[15];
                        $datos->telefono = $resu[16];
                        $datos->email = $resu[17];
                        $datos->nroCelular = $resu[18];
                        $datos->compCelular = $resu[19];
                    }
                    if ($datos->codigoRetorno == true) {
                        return $datos;
                    }
                } else {
                    $datos->codigoRetorno = false;
                }
            }
            return $datos;
        }
    }

}

function datosCensales($usuario, $unidadAcademica, $tipoTitulo = 0) {
    $servicio = new DatosCensalesAlumno();
    //$tipoTitulo = Generales::conversionUATT($unidadAcademica, $tipoTitulo);
    $resultado = $servicio->datos($usuario, strtoupper($unidadAcademica), $tipoTitulo);
    return json_encode($resultado);
}

?>
