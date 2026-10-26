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

Class FhucCarreras {
    /* --------- variables datosCensalesHefesto---------- */

    public $codigoWS;
    public $mensajeWS;
    public $carreras = array();
    public $tipoUnidad;
   

}

/* ------------------------------------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE xxxxxxxxxxxxxxxxxx - ES INVOCADA POR xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  ------------------------------------------------------------------------------------------------------------- */

class Carreras {

    function datos($tipoTitulo, $plan, $carrera) {

        $fhuc = new FhucCarreras();
        $ua='FHUC';
        $aut = Generales::autenticar();
        if ($aut ==CODIGO_ERROR_AUTENTICACION) {
            $fhuc->codigoWS =CODIGO_ERROR_AUTENTICACION;
            $fhuc->mensajeWS =MENSAJE_ERROR_AUTENTICACION;
            return $fhuc;
        } else {
            if ($tipoTitulo == "" || $plan == "" || $carrera == "") {
                $fhuc->mensajeWS =MENSAJE_ERROR_PARAMETROS;
                $fhuc->codigoWS =CODIGO_ERROR_PARAMETROS;
                return $fhuc;
            }
            /*switch ($tipoUnidad) {
                case "presencial":
                    $db = "alumnado_fhuc";
                    break;
                case "posgrado":
                    $db = "posgrado_fhuc";
                    break;
                case "semi":
                    $db = "semipre_fhuc";
                    break;
            }
            
            $co = ('informix:host=' . HOST . '; service=9086;database=' . $db . '; server=' . SERVER . '; protocol=olsoctcp; EnableScrollableCursors=1;');
            //$co = ('informix:host=guarani.intranet; service=9086;database=' . $db . '; server=rectorado_csm; protocol=olsoctcp; EnableScrollableCursors=1;');
            $objCC = Generales::conectar(true, $co);*/
            
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

                $strSQL = "execute procedure web_serv_carreras_fhuc(" . $plan . ",'" . $carrera . "');";

                $res = $objCC->Execute($strSQL);

                if ($res->fields[0] != "") {
                    $resultado = $res->getRows();
                    $fhuc->codigoWS = CODIGO_OK;
                    $fhuc->mensajeWS = MENSAJE_OK;
                    $fhuc->tipoUnidad=$titulo;
                    $arreglo = array();
                    foreach ($resultado as $resu) {
                        $arreglo['codigoCarrera'] = $resu[0];
                        $arreglo['nombreCarrera'] = $resu[1];
                        $arreglo['plan'] = $resu[2];
                        $arreglo['version'] = $resu[3];
                        $arreglo['codigoMateria'] = $resu[4];
                        $arreglo['nombreMateria'] = $resu[5];
                        $arreglo['obligatoria'] = $resu[6];
                        $arreglo['promediable'] = $resu[7];
                        $arreglo['tipoMateria'] = $resu[8];
                        $fhuc->carreras[] = $arreglo; 
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

function carrerasFhuc($tipoTitulo, $plan, $carrera) {
    $servicio = new Carreras();
    $resultado = $servicio->datos($tipoTitulo, $plan, $carrera);
    return json_encode($resultado);
}

?>
