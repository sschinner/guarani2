<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Usuario y contrase?a invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */

require_once("adodb/adodb.inc.php");
require_once ('Repositorio/RepositorioWS.php');
/* ------------------------------------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE SI UN ALUMNO ES REGULAR - ES INVOCADA EXTERIORMENTE POR EL SISTEMA DE BOLETO UNIVERSITARIO
  ------------------------------------------------------------------------------------------------------------- */

function esAlumno($ti, $ua, $apellido, $nombre, $tdni, $dni, $sexo, $fecha) {

    if (isset($_SERVER['PHP_AUTH_USER']) and isset($_SERVER['PHP_AUTH_PW'])) {
        if ($_SERVER['PHP_AUTH_USER'] == $_SESSION['ws_user'] and $_SERVER['PHP_AUTH_PW'] == $_SESSION['ws_password'])
            $aut = 10;
        else {
            $aut = 1;  // '1': Error de autenticacion - Usuario y contrase?a invalidas.
        }
    } else {
        $aut = 1;  // '2': Error de autenticacion - Usuario y contrase?a invalidas.
    }
    if ($aut == 1) {
        $resul[0][0] = "2";  //2 c?digo de Error_autenticaci?n
        $resul[0][1] = "";
        $resul[0][2] = "";
        $resul[0][3] = "";
        return $resultado = $resul;
    } else {
        if ($ua == "" || $apellido == "" || $nombre == "" || $tdni == "" || $dni == "" || $sexo == "" || $fecha == "") {
            $resul[0][0] = "88";  //88 Error: algun par?metro es vacio.
            $resul[0][1] = "";
            $resul[0][2] = "";
            $resul[0][3] = "";
            return $resultado = $resul;
        }
        //Log para determinar como llegan los datos a consultar
//                $nombre_archivo = "../gobierno/log.txt";
//                if ($archivo = fopen($nombre_archivo, "a")) {
//                    fwrite($archivo, date('d-m-Y H:i:s').'  --  Apellido: ' . $apellido . '  -- Encoding: '.mb_detect_encoding($apellido) .' -- Nombre: ' . $nombre . '  -- Encoding: '.mb_detect_encoding($nombre) .  "\n");
//                }
//                fclose($archivo);				
        //return 1;
        switch ($ua) {
            case "1":
                $db = /*"alumnado_fadu"*/ 'guarani3';
                break;
            case "2":
                $db = /*"alumnado_fbcb"*/ 'guarani3';
                break;
            case "3":
                $db = /* "alumnado_fca" */'guarani3';
                break;
            case "4":
                $db = /* "alumnado_fce" */ 'guarani3';
                break;
            case "5":
                $db = /* "alumnado_fcjs" */'guarani3';
                break;
            case "6":
                $db = /* "alumnado_fcm"; */'guarani3'; 
                break;
            case "7":
                $db = /* "alumnado_fcv" */'guarani3';
                break;
            case "8":
                $db = /*"alumnado_fhuc"*/'guarani3';
                break;
            case "9":
                $db = /* "alumnado_fiq" */'guarani3';
                break;
            case "10":
                $db = /* "alumnado_fich" */ 'guarani3';
                break;
            case "26":
                $db = /* "alumnado_euaa" */'guarani3';
                break;
            case "27":
                $db = /*"alumnado_ism" */ 'guarani3';
                break;
            case "36":
                $db = /* "alumnado_eua" */'guarani3';
                break;
            case "39":
                $resul[0][0] = "1";
                $resul[0][1] = "";
                $resul[0][2] = "";
                $resul[0][3] = "";
                return $resultado = $resul;
                break;
            case "38":
                $db = /*"alumnado_ess"*/ 'guarani3';
                break;
            case "51":
                $db = "semipre_fbcb";
                break;
            case "52":
                $db = "semipre_fhuc";
                break;
            // $db = "fhuc_semi"; break;
            case "53":
                $db = "semipre_ess";
                break;
            case "54":
                $db = "semipre_fbcb";
                break;
             case "89":
                $db = /* "alumnado_fcm"; */'guarani3'; 
                break;
             case "111":
                $db = /* "alumnado_fcm"; */'guarani3'; 
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
        /*putenv("INFORMIXDIR=/opt/informix/");
        putenv("ODBCINI=/etc/odbc.ini");
        putenv("ODBCINSTINI=/etc/odbcinst.ini");
*/
        if ($db != 'guarani3') {
            //$co=('informix:host='.HOST.'; service=9088;database='.$db.'; server = '.SERVER.'; protocol=olsoctcp; EnableScrollableCursors=1;');
            $sTipoCon = "pdo";
            $conexion = ('informix:host=' . HOST . '; service=' . PUERTO . ';database=' . $db . '; server=' . SERVER . '; protocol=olsoctcp; EnableScrollableCursors=1;');

            $usuario = USUARIOCONEXION;
            $password = PASSWORDCONEXION;

            $objCC = & NewADOConnection($sTipoCon);
            if (!$objCC->Connect($conexion, $usuario, $password)) {
                $objCC = "3"; // '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
            } else {
                $strSQL = "SET ROLE guarani";
                $objCC->Execute($strSQL);
            }


            if ($objCC == '3') {
                $resul[0][0] = "3"; //3 c?digo de Error_servicio
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

                $strSQL = "execute procedure web_serv_alu_regular('" . $apellido . "','" . $nombre . "'," . $tdni . "," . $dni . ",'" . $sexo . "','" . $fecha . "');";

                $res = $objCC->Execute($strSQL);

                if ($res->fields[0] != "") {
                    $resultado = $res->getRows();
                    /* $resul[0][0] = utf8_decode($resultado[0][0]);
                      $resul[0][1] = utf8_decode($resultado[0][1]);
                      $resul[0][2] = utf8_decode($resultado[0][2]);
                      $resul[0][3] =  utf8_decode($resultado[0][3]); */
                    $resul[0][0] = iconv("ISO-8859-1", "utf-8", $resultado[0][0]);
                    $resul[0][1] = iconv("ISO-8859-1", "utf-8", $resultado[0][1]);
                    $resul[0][2] = iconv("ISO-8859-1", "utf-8", $resultado[0][2]);
                    $resul[0][3] = iconv("ISO-8859-1", "utf-8", $resultado[0][3]);
                    return $resul;
                } else {
                    $resul[0][0] = "4";   //4 c?digo de Error_inesperado
                    $resul[0][1] = "";
                    $resul[0][2] = "";
                    $resul[0][3] = "";
                    return $resultado = $resul;
                }
            }
        } else {
                $db = Generales::recuperarDB($ua, 7);
                $objCC = Generales::conectar($db);
           
            if ($objCC == '3') {
                $resul[0][0] = "3"; //3 c?digo de Error_servicio
                $resul[0][1] = "";
                $resul[0][2] = "";
                $resul[0][3] = "";
                return $resultado = $resul;
            } else {
                //return $objCC;
                $rep = new RepositorioWS();
                $tdni = 0;
                $resultado = $rep->regularidadMedioBoleto($tdni, $dni, $objCC);
               
                if (!empty($resultado)) {
                    $resul[0][0] =  $resultado[0][0];
                    $resul[0][1] = $resultado[0][1];
                    $resul[0][2] = $resultado[0][2];
                    $resul[0][3] = $resultado[0][3];
                    return $resul;
                }else {
                    $resul[0][0] = "4";   //4 c?digo de Error_inesperado
                    $resul[0][1] = "";
                    $resul[0][2] = "";
                    $resul[0][3] = "Error inesperado - contacte al administrador";
                    return $resultado = $resul;
                }
            }
        }
    }
}

?>
