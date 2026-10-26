<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Usuario y contrase�a invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */

require_once("adodb/adodb.inc.php");

/* --------------------------------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE SI UN ALUMNO ES ACTIVO Y REGULAR - ES INVOCADA POR EL SISTEMA DE COMEDOR UNIVERSITARIO
  --------------------------------------------------------------------------------------------------------- */

function verificaActivoRegular($ti, $ua, $apellido, $nombre, $tdni, $dni, $sexo, $fecha) {
    $aut = autenticar();
    if ($aut == 2) {
        $resul[0][0] = "2";  //2 c�digo de Error_autenticaci�n
        $resul[0][1] = "";
        $resul[0][2] = "";
        $resul[0][3] = "";
        return $resultado = $resul;
    } else {
        if ($ua == "" || $apellido == "" || $nombre == "" || $tdni == "" || $dni == "" || $sexo == "" || $fecha == "") {
            $resul[0][0] = "88";  //88 Error: algun par�metro es vacio.
            $resul[0][1] = "";
            $resul[0][2] = "";
            $resul[0][3] = "";
            return $resultado = $resul;
        }

        //return 1;
        switch ($ua) {
            case "1":
                $odbc = "alumnado_fadu";
                break;
            case "2":
                $odbc = "alumnado_fbcb";
                break;
            case "3":
                $odbc = "alumnado_fca";
                break;
            case "4":
                $odbc = "alumnado_fce";
                break;
            case "5":
                $odbc = "alumnado_fcjs";
                break;
            case "6":
                $odbc = "alumnado_fcm";
                break;
            case "7":
                $odbc = "alumnado_fcv";
                break;
            case "8":
                $odbc = "alumnado_fhuc";
                break;
            case "9":
                $odbc = "alumnado_fiq";
                break;
            case "10":
                $odbc = "alumnado_fich";
                break;
            case "28":
                $odbc = "alumnado_euaa";
                break;
            case "29":
                $odbc = "alumnado_ism";
                break;
            case "38":
                $resul[0][0] = "1";
                $resul[0][1] = "";
                $resul[0][2] = "";
                $resul[0][3] = "";
                return $resultado = $resul;
                break;
            case "40":
                $odbc = "alumnado_ess";
                break;
            case "53":
                $odbc = "semipre_fbcb";
                break;
            case "54":
                $odbc = "fhuc_semi";
                break;
            case "55":
                $odbc = "semipre_ess";
                break;
            case "56":
                $odbc = "semipre_fbcb";
                break;
            case "1381":
                $resul[0][0] = "1";
                $resul[0][1] = "";
                $resul[0][2] = "";
                $resul[0][3] = "";
                return $resultado = $resul;
                break;
            case "1382":
                $resul[0][0] = "1";
                $resul[0][1] = "";
                $resul[0][2] = "";
                $resul[0][3] = "";
                return $resultado = $resul;
                break;
        }



        //conexion a informix
        putenv("INFORMIXDIR=/opt/informix/");
        putenv("ODBCINI=/etc/odbc.ini");
        putenv("ODBCINSTINI=/etc/odbcinst.ini");
        //$co = ('informix:host=guarani.intranet; service=9086;database=' . $odbc . '; server=rectorado_csm; protocol=olsoctcp; EnableScrollableCursors=1;');
        $co = ('informix:host=' . HOST . '; service=9086;database=' . $db . '; server=' . SERVER . '; protocol=olsoctcp; EnableScrollableCursors=1;');

        $objCC = @conectar(true, $co);
        if ($objCC == '11') {
            $resul[0][0] = "3"; //3 c�digo de Error_servicio
            $resul[0][1] = "";
            $resul[0][2] = "";
            $resul[0][3] = "";
            return $resultado = $resul;
        } else {

            //realizo la consulta para ver si es alumno de la $UA

            $apellido = iconv("utf-8", "ISO-8859-1", $apellido);
            $nombre = iconv("utf-8", "ISO-8859-1", $nombre);

            $ape = explode("'", $apellido);
            if (!empty($ape[1])) {
                $apellido = $ape[0] . "-" . $ape[1];
            }

            $nom = explode("'", $nombre);
            if (!empty($nom[1])) {
                $nombre = $nom[0] . "-" . $nom[1];
            }
            $strSQL = "execute procedure web_serv_alu_reg_com('" . $apellido . "','" . $nombre . "'," . $tdni . "," . $dni . ",'" . $sexo . "','" . $fecha . "');";

            $res = $objCC->Execute($strSQL);



            if ($res->fields[0] != "") {
                $resultado = $res->getRows();
                $resultado[0][1] = iconv("ISO-8859-1", "utf-8", $resultado[0][1]);
                $resultado[0][2] = iconv("ISO-8859-1", "utf-8", $resultado[0][2]);
                $resultado[0][3] = iconv("ISO-8859-1", "utf-8", $resultado[0][3]);
                return $resultado;
            } else {
                $resul[0][0] = "4";   //4 c�digo de Error_inesperado
                $resul[0][1] = "";
                $resul[0][2] = "";
                $resul[0][3] = "";
                return $resultado = $resul;
            }
        }
    }
}

?>
