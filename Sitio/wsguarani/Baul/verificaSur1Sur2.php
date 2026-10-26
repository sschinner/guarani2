<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Usuario y contrase�a invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */

Class BibliotecaWS {

    public $codigoWS;
    public $mensajeWS;
    public $mensajeValidacion;
    public $tipoDocumento;
    public $nroDocumento;
    public $pasaporte;
    public $tipoUsuario;
    public $unidadAcademica;
    public $fechaVencimiento;
    public $carrera;
    public $apellido;
    public $nombre;
    public $email;
    public $localidadRes;
    public $direccionRes;
    public $provinciaRes;
    public $paisRes;
    public $telefonoRes;
    public $faxRes;
    public $localidadPro;
    public $direccionPro;
    public $provinciaPro;
    public $paisPro;
    public $telefonoPro;
    public $faxPro;

}

/* -----------------------------------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE SI UN ALUMNO ES INGRESANTE O REALIZO EL SUR2 - ES INVOCADA  POR EL SISTEMA DE BIBLIOTECAS
  ------------------------------------------------------------------------------------------------------------ */

Class BibliotecaSur1Sur2 {

    function Sur1Sur2($ua, $anio_academico, $tipo_documento, $nro_documento, $tipoTitulo) {
        $biblioteca = new BibliotecaWS();


        $aut = Generales::autenticar();
        if ($aut ==CODIGO_ERROR_AUTENTICACION) {
            $biblioteca->codigoWS =CODIGO_ERROR_AUTENTICACION;
            $biblioteca->mensajeWS = "Error de autenticacion - Credenciales invalidas.";
            return $biblioteca;
        } else {
            if ($ua == "" || $anio_academico == "" || $tipo_documento == "" || $nro_documento == "" || $tipoTitulo == "") {
                $biblioteca->mensajeWS =MENSAJE_ERROR_PARAMETROS;
                $biblioteca->codigoWS =CODIGO_ERROR_PARAMETROS;
                return $biblioteca;
            }

            if ($tipoTitulo == 0) {
                $titulos = Generales::recuperarTipoTituloConCemed($ua);
               // $titulos = array_reverse($titulos);
            } else {
                $titulos = array($tipoTitulo);
            }

            foreach ($titulos as $titulo) {
                
                $db = Generales::recuperarDB($ua, $titulo);
                $objCC = Generales::conectar($db);
              
                if ($objCC == '3') {
                    $biblioteca->codigoWS = CODIGO_ERROR_CONEXION;
                    $biblioteca->mensajeWS = MENSAJE_ERROR_CONEXION;
                    return $biblioteca;
                } else if (($titulo != '7')) {

                    //realizo la consulta para ver si es alumno de la $UA

                    $strSQL = "execute procedure web_serv_sur_d2_bibl('" . $ua . "'," . $anio_academico . "," . $tipo_documento . ",'" . $nro_documento . "');";

                    $res = $objCC->Execute($strSQL);


                    if ($res->fields[0] != "") {
                        $resultado = $res->getRows();
                        if ($resultado[0][0] == 0 || $resultado[0][0] == -1) {
                            $biblioteca->codigoWS = CODIGO_OK;
                            $biblioteca->mensajeWS = MENSAJE_OK;
                            $biblioteca->mensajeValidacion = utf8_decode($resultado[0][1]);
                            $biblioteca->nombre = utf8_decode($resultado[0][2]);
                            $biblioteca->apellido = utf8_decode($resultado[0][3]);
                            $biblioteca->tipoDocumento = $resultado[0][4];
                            $biblioteca->nroDocumento = $resultado[0][5];
                            $biblioteca->pasaporte = $resultado[0][6];
                            $biblioteca->tipoUsuario = $resultado[0][7];
                            $biblioteca->unidadAcademica = $resultado[0][8];
                            $biblioteca->carrera = $resultado[0][9];
                            $biblioteca->fechaVencimiento = $resultado[0][10];
                            $biblioteca->email = $resultado[0][11];
                            $biblioteca->direccionRes = $resultado[0][12];
                            $biblioteca->localidadRes = $resultado[0][13];
                            $biblioteca->provinciaRes = $resultado[0][14];
                            $biblioteca->paisRes = $resultado[0][15];
                            $biblioteca->telefonoRes = $resultado[0][16];
                            $biblioteca->faxRes = $resultado[0][17];
                            $biblioteca->direccionPro = $resultado[0][18];
                            $biblioteca->localidadPro = $resultado[0][19];
                            $biblioteca->provinciaPro = $resultado[0][20];
                            $biblioteca->paisPro = $resultado[0][21];
                            $biblioteca->telefonoPro = $resultado[0][22];
                            $biblioteca->faxPro = $resultado[0][23];
                            return $biblioteca;
                        } else {
                            $biblioteca->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                            $biblioteca->mensajeWS = "Error de procedimiento - Algo salio mal dentro de la funcion.";
                        }
                    } else {
                        $biblioteca->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                        $biblioteca->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                    }
                }
            }
            return $biblioteca;
        }
    }

}

function verificaSur1Sur2($ua, $anio_academico, $tipo_documento, $nro_documento, $tipoTitulo) {
    $servicio = new BibliotecaSur1Sur2();
    $resultado = $servicio->Sur1Sur2(strtoupper($ua), $anio_academico, $tipo_documento, $nro_documento, $tipoTitulo);
    return json_encode($resultado);
}

?>
