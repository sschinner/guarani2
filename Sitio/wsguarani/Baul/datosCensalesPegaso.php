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

Class PegasoCensales {

    public $codigoWS;
    public $mensajeWS;
    public $codigoRetorno;
    public $tipoTitulo;
    public $tipoUnidadAcademica;
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
    public $grupoSanguineo;
    public $factorSanguineo;

}

/* ---------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE DATOS CENSALES DE UN ALUMNO - ES INVOCADA POR EL SISTEMA PEGASO
  ---------------------------------------------------------------------------------- */

class DatosCensales {

    function datos($usuario, $ua, $tipoTitulo) {

        $pegaso = new PegasoCensales();

        $aut = Generales::autenticar();
        if ($aut ==CODIGO_ERROR_AUTENTICACION) {
            $pegaso->codigoWS =CODIGO_ERROR_AUTENTICACION;
            $pegaso->mensajeWS =MENSAJE_ERROR_AUTENTICACION;
            return $pegaso;
        } else {
            if ($usuario == "" || $ua == "" || $tipoTitulo == "") {
                $pegaso->mensajeWS =MENSAJE_ERROR_PARAMETROS;
                $pegaso->codigoWS =CODIGO_ERROR_PARAMETROS;
                return $pegaso;
            }

            if ($tipoTitulo == 0) {
                $titulos = Generales::recuperarTipoTitulo($ua);
                $titulos = array_reverse($titulos);
            } else {
                $titulos = array($tipoTitulo);
            }

            foreach ($titulos as $titulo) {

                /*$db = Generales::recuperarDB($ua, $titulo);

                //$co = ('informix:host=guarani.intranet; service=9086;database=' . $db . '; server=rectorado_csm; protocol=olsoctcp; EnableScrollableCursors=1;');
                $co = ('informix:host=' . HOST . '; service=9086;database=' . $db . '; server=' . SERVER . '; protocol=olsoctcp; EnableScrollableCursors=1;');
                $objCC = Generales::conectar(true, $co);
                */
                $db = Generales::recuperarDB($ua, $titulo);
                $objCC = Generales::conectar($db);

                if ($objCC == '3') {
                    $pegaso->codigoWS = CODIGO_ERROR_CONEXION;
                    $pegaso->mensajeWS = MENSAJE_ERROR_CONEXION;
                    return $pegaso;
                } else {
                    //realizo la consulta para ver si es alumno de la $UA
                    $strSQL = "execute procedure web_serv_dat_cen_pegaso('" . $usuario . "');";
                    $res = $objCC->Execute($strSQL);

                    if ($res->fields[0] != "") {
                        $resultado = $res->getRows();
                        $pegaso->codigoWS = CODIGO_OK;
                        $pegaso->mensajeWS = MENSAJE_OK;
                        $pegaso->tipoTitulo=$titulo;
                        foreach ($resultado as $resu) {
                            if ($resu[0] == 0)
                                $pegaso->codigoRetorno = false; //$resu[0];
                            else
                                $pegaso->codigoRetorno = true;

                            $hayDatos = true;
                            $pegaso->tipoDocumento = $resu[1];
                            $pegaso->nroDocumento = $resu[2];
                            $pegaso->fechaNacimiento = $resu[3];
                            $pegaso->apellido = $resu[4];
                            $pegaso->nombre = $resu[5];
                            $pegaso->sexo = $resu[6];
                            $pegaso->localidadProc = $resu[7];
                            $pegaso->cpProc = $resu[8];
                            $pegaso->localidadRes = $resu[9];
                            $pegaso->cpRes = $resu[10];
                            $pegaso->direccionRes = $resu[11];
                            $pegaso->nroRes = $resu[12];
                            $pegaso->pisoRes = $resu[13];
                            $pegaso->deptoRes = $resu[14];
                            $pegaso->unidad = $resu[15];
                            $pegaso->telefono = $resu[16];
                            $pegaso->email = $resu[17];
                            $pegaso->grupoSanguineo = $resu[18];
                            $pegaso->factorSanguineo = $resu[19];
                        }
                        if ($pegaso->codigoRetorno == true) {
                            return $pegaso;
                        }
                    }
                }
            }
            if ($pegaso->codigoWS == '0') {
                return $pegaso;
            } else if ($pegaso->codigoWS != "0" ) {
                $pegaso->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                $pegaso->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                return $pegaso;
            }
        }
    }

}

function datosCensalesPegaso($usuario, $ua, $tipoTitulo = 0) {
    $servicio = new DatosCensales();
    $resultado = $servicio->datos($usuario, $ua, $tipoTitulo);
    return json_encode($resultado);
}

?>
