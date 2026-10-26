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

/* ------------------------------------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE xxxxxxxxxxxxxxxxxx - ES INVOCADA POR xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  ------------------------------------------------------------------------------------------------------------- */
class AlumnoRegularFhuc {

    var $esAlumno = "";
    var $esRegular = "";
    var $tipoUnidad="";

}

function alumnoReg5aniosFhuc($nroDocumento, $tipoTitulo) {
    $ua = "FHUC";
    //return "sdfsdf   ".$tipoUnidad;

    $aut = Generales::autenticar();
    if ($aut == CODIGO_ERROR_AUTENTICACION) {
        $resul = MENSAJE_ERROR_AUTENTICACION;  
        $resultado = json_encode($resul);
        return $resultado;
    } else {
        if ($nroDocumento == "" || $tipoTitulo=="") {
            $resul = MENSAJE_ERROR_PARAMETROS;  
            $resultado = json_encode($resul);
            return $resultado;
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
                $resul = MENSAJE_ERROR_CONEXION; 
                $resultado = json_encode($resul);
                return $resultado;
            } else {
                //realizo la consulta para ver si es alumno de la $UA

                $strSQL = "execute procedure web_serv_fhuc_5_anios('" . $nroDocumento . "');";

                $res = $objCC->Execute($strSQL);

                if ($res->fields[0] != "") {
                    $resultado = $res->getRows();
                    $regular = new AlumnoRegularFhuc();
                    foreach ($resultado as $resu) {
                        $regular->esAlumno = $resu[0];
                        $regular->esRegular = $resu[1];
                        $regular->tipoUnidad = $titulo;
                    }
                    $resp = json_encode($regular);
                    return $resp;
                } else {
                    $resul = MENSAJE_ERROR_PROCEDIMIENTO;
                    $resultado = json_encode($resul);
                    return $resultado;
                }
            }
        }
    }
}

?>
