<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Usuario y contrase�a invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */

Class BibliotecaD1WS {

    public $codigoWS = '';
    public $mensajeWS = '';
    public $mensajeValidacion;
    public $datos = array();

}

/* -----------------------------------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE SI UN ALUMNO ES INGRESANTE O REALIZO EL SUR2 - ES INVOCADA  POR EL SISTEMA DE BIBLIOTECAS
  ------------------------------------------------------------------------------------------------------------ */

Class BibliotecaSurD1 {

    function SurD1($ua, $anio_academico, $tipoTitulo) {
        $biblioteca = new BibliotecaD1WS();


        $aut = Generales::autenticar();
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $biblioteca->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $biblioteca->mensajeWS = "Error de autenticacion - Credenciales invalidas.";
            return $biblioteca;
        } else {
            if ($ua == "" || $anio_academico == "" || $tipoTitulo == "") {
                $biblioteca->mensajeWS = MENSAJE_ERROR_PARAMETROS;
                $biblioteca->codigoWS = CODIGO_ERROR_PARAMETROS;
                return $biblioteca;
            }

            if ($tipoTitulo == 0) {
                $titulos = Generales::recuperarTipoTituloConCemed($ua);
                //$titulos = array_reverse($titulos);
            } else {
                $titulos = array($tipoTitulo);
            }

            foreach ($titulos as $titulo) {

                $db = Generales::recuperarDB($ua, $titulo);
                $objCC = Generales::conectar($db);
              
                if ($objCC == '3' /*|| !isset($objCC->host)*/) {
                    //if ($biblioteca->codigoWS === '') {
                        $biblioteca->codigoWS = CODIGO_ERROR_CONEXION;
                        $biblioteca->mensajeWS = MENSAJE_ERROR_CONEXION;
                    //}
                    return $biblioteca;
                } else if (($titulo != '7')) {
                    //realizo la consulta para obtener los datos censales
                    $strSQL = "execute procedure web_serv_sur_d1_bibl('" . $ua . "'," . $anio_academico . ");";
                    $res = $objCC->Execute($strSQL);
                  
                    if ($res->fields[0] != "" && !empty($res)) {
                        $resultado = $res->getRows();
                        
                        if ($resultado[0][0] == 0 || $resultado[0][0] == -1) {
                            $biblioteca->codigoWS = CODIGO_OK;
                            $biblioteca->mensajeWS = MENSAJE_OK;
                            $biblioteca->mensajeValidacion = utf8_decode($resultado[0][1]);
                            $arreglo = array();
                            foreach ($resultado as $resu) {
                                $arreglo['nombre'] = utf8_decode($resu[2]);
                                $arreglo['apellido'] = utf8_decode($resu[3]);
                                $arreglo['tipoDocumento'] = $resu[4];
                                $arreglo['nroDocumento'] = $resu[5];
                                $arreglo['pasaporte'] = $resu[6];
                                $arreglo['tipoUsuario'] = $resu[7];
                                $arreglo['unidadAcademica'] = $resu[8];
                                $arreglo['carrera'] = $resu[9];
                                $arreglo['nombreCarrera'] = utf8_decode($resu[10]);
                                $arreglo['fechaVencimiento'] = $resu[11];
                                $arreglo['email'] = $resu[12];
                                $arreglo['direccionRes'] = utf8_decode($resu[13]);
                                $arreglo['localidadRes'] = utf8_decode($resu[14]);
                                $arreglo['provinciaRes'] = utf8_decode($resu[15]);
                                $arreglo['paisRes'] = $resu[16];
                                $arreglo['telefonoRes'] = $resu[17];
                                $arreglo['faxRes'] = $resu[18];
                                $arreglo['direccionPro'] = utf8_decode($resu[19]);
                                $arreglo['localidadPro'] = utf8_decode($resu[20]);
                                $arreglo['provinciaPro'] = utf8_decode($resu[21]);
                                $arreglo['paisPro'] = $resu[22];
                                $arreglo['telefonoPro'] = $resu[23];
                                $arreglo['faxPro'] = $resu[24];
                                $biblioteca->datos[] = $arreglo;
                            }
                        } else {
                            $biblioteca->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                            $biblioteca->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                            return $biblioteca;
                        }
                    }
                }
            }
            return $biblioteca;
        }
    }

}

function verificaSurD1($ua, $anio_academico, $tipoTitulo) {
    $servicio = new BibliotecaSurD1();
    $resultado = $servicio->SurD1(strtoupper($ua), $anio_academico, $tipoTitulo);
    return json_encode($resultado);
}

?>
