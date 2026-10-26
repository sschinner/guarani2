<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Usuario y contraseÃ±a invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */

//require_once("adodb/adodb.inc.php");

Class FhucHorarios {
    /* --------- variables datosCensalesHefesto---------- */

    public $codigoWS;
    public $mensajeWS;
    public $materia = array();
    public $tipoUnidad;

}

/* ------------------------------------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE xxxxxxxxxxxxxxxxxx - ES INVOCADA POR xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  ------------------------------------------------------------------------------------------------------------- */

class Cursadas {

    function datos($tipoTitulo, $anio_academico, $periodo_lectivo) {

        $fhuc = new FhucHorarios();
        $ua = "FHUC";
        $aut = Generales::autenticar();
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $fhuc->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $fhuc->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $fhuc;
        } else {
            if ($tipoTitulo == "" || $anio_academico == "" || $periodo_lectivo == "") {
                $fhuc->mensajeWS = MENSAJE_ERROR_PARAMETROS;
                $fhuc->codigoWS = CODIGO_ERROR_PARAMETROS;
                return $fhuc;
            }
           
            if ($tipoTitulo == 0) {
                $titulos = Generales::recuperarTipoTitulo($ua);
                //$titulos = array_reverse($titulos);
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
                        $fhuc->tipoUnidad = $titulo;
                        $arreglo = array();

                        foreach ($resultado as $resu) {

                            $arreglo['nombreMateria'] = utf8_encode($resu[0]);//strtoupper(Generales::sanearString($resu[0]));//utf8_decode($resu[0]);
                            $arreglo['codigoMateria'] = $resu[1];
                            $arreglo['codigoCarrera'] = $resu[2];
                            $arreglo['nombreCarrera'] = utf8_encode($resu[3]);
                            $arreglo['comision'] = $resu[4];
                            $arreglo['nombreComision'] = utf8_encode($resu[5]);
                            $arreglo['apellido'] = utf8_encode($resu[6]);
                            $arreglo['nombreProfesor'] = utf8_encode($resu[7]);
                            $arreglo['documentoProfesor'] = $resu[8];
                            $arreglo['diaSemana'] = $resu[9];
                            $arreglo['nombreDia'] = $resu[10];
                            $arreglo['tipoClase'] = $resu[11];
                            $arreglo['horaInicio'] = $resu[12];
                            $arreglo['horaFin'] = $resu[13];
                            $arreglo['nombreAula'] = $resu[14];
                            $arreglo['nombreEdificio'] = $resu[15];
                            $fhuc->materia[] = $arreglo;
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

function cursadasFhuc($tipoTitulo, $anio_academico, $periodo_lectivo) {
    $servicio = new Cursadas();
    $resultado = $servicio->datos($tipoTitulo, $anio_academico, $periodo_lectivo);
    return json_encode($resultado);
}

?>
