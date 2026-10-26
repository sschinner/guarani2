<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Usuario y contraseña invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */

//require_once("adodb/adodb.inc.php");

Class HorariosComisiones {
    /* --------- variables datosCensalesHefesto---------- */

    public $codigoWS;
    public $mensajeWS;
    public $materia = array();

}

/* ------------------------------------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE xxxxxxxxxxxxxxxxxx - ES INVOCADA POR xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  ------------------------------------------------------------------------------------------------------------- */

class Cursadas {

    function datos($ua, $anio_academico, $periodo_lectivo, $tipoTitulo) {

        $fhuc = new HorariosComisiones();

        $aut = Generales::autenticar();
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $fhuc->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $fhuc->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $fhuc;
        } else {
            if ($tipoTitulo == "" || $anio_academico == "" || $periodo_lectivo == "" || $ua == "") {
                $fhuc->mensajeWS = MENSAJE_ERROR_PARAMETROS;
                $fhuc->codigoWS = CODIGO_ERROR_PARAMETROS;
                return $fhuc;
            }

            if ($tipoTitulo == 0) {
                $titulos = Generales::recuperarTipoTitulo($ua);
            } else {
                $titulos = array($tipoTitulo);
            }
            foreach ($titulos as $titulo) {

                $db = Generales::recuperarDB($ua, $titulo);
                $objCC = Generales::conectar($db);
                if ($objCC == '3') {
                    $fhuc->codigoWS = CODIGO_ERROR_CONEXION;
                    $fhuc->mensajeWS = MENSAJE_ERROR_CONEXION;
                    return $fhuc;
                } else {

                    //realizo la consulta para ver si es alumno de la $UA

                    $strSQL = "execute procedure web_serv_horario_catedra(" . $anio_academico . ",'" . $periodo_lectivo . "');";

                    $res = $objCC->Execute($strSQL);



                    if ($res->fields[0] != "") {
                        $resultado = $res->getRows();
                        $fhuc->codigoWS = CODIGO_OK;
                        $fhuc->mensajeWS = MENSAJE_OK;
                        $arreglo = array();
                        foreach ($resultado as $resu) {
                            $arreglo['nombreMateria'] = (string)utf8_encode($resu[0]);
                            $arreglo['codigoMateria'] = (string) $resu[1];
                            $arreglo['codigoCarrera'] = (string) $resu[2];
                            $arreglo['nombreCarrera'] = (string) utf8_encode($resu[3]);
                            $arreglo['comision'] = (string) $resu[4];
                            $arreglo['nombreComision'] = (string) $resu[5];
                            $arreglo['apellido'] = (string) utf8_encode($resu[6]);
                            $arreglo['nombreProfesor'] = (string) utf8_encode($resu[7]);
                            $arreglo['documentoProfesor'] = (string) $resu[8];
                            $arreglo['diaSemana'] = (string) $resu[9];
                            $arreglo['nombreDia'] = (string) utf8_encode($resu[10]);
                            $arreglo['tipoClase'] = (string) utf8_encode($resu[11]);
                            $arreglo['horaInicio'] = (string) $resu[12];
                            $arreglo['horaFin'] = (string) $resu[13];
                            $arreglo['nombreAula'] = (string) utf8_encode($resu[14]);
                            $arreglo['nombreEdificio'] = (string) utf8_encode($resu[15]);
                            $arreglo['anioCursada'] = (string) $resu[16];
                            $fhuc->materia[] =  $arreglo;
                        }

                        return $fhuc;
                    } else {
                        $fhuc->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                        $fhuc->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                        return $fhuc;
                    }
                }
            }
        }
    }

}

function comisionesCursadas($ua, $anio_academico, $periodo_lectivo, $tipoTitulo) {
    $servicio = new Cursadas();
    $resultado = $servicio->datos($ua, $anio_academico, $periodo_lectivo, $tipoTitulo);
    return json_encode($resultado);
}
?>

