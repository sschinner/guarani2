<?php

function conectar_postgre($strCheck = true) {
  
   //******* CONEXION DEV ***********//
   //   $conexion = pg_connect("host='guarani-03.intranet' port='5485' dbname='capic_db' user='postgres' password='postgres'") or die("No se pudo realizar la conexi�n");
      
   //******* CONEXION INTEGRACION ***********//
    //$conexion = pg_connect("host='guarani3db-integracion' port='5432' dbname='capic_db' user='capic_owner' password='mk5ljhbaIpw'") or die("No se pudo realizar la conexi�n");
   

    //******* CONEXION PRODUCCION  ***********//
    $conexion = pg_connect("host='localhost' port='5432' dbname='capic_db' user='capic_owner' password='HgvQKfVx'") or die("No se pudo realizar la conexi�n");



    if (!$conexion) {
        echo "<CENTER>
              Problemas de conexion con la base de datos.
              </CENTER>";
        exit;
    }
    return $conexion;
}

function conectar_informix($strCheck = true, $Odbc) {
    $sTipoCon = "odbc";
    /* if (!isset($sTipoCon))
      {
      header("Location: ../notificarse.php?fueraFrameSet=1&fStatus=-1&fMsg=".urlencode("La sesion finaliz�. Tenes que ingresar de nuevo al sistema."));
      exit;
      } */
    $objCC = ADONewConnection($sTipoCon);

    $objCC->Connect($Odbc, "", "", "");
    // Si la conexion es ODBC el locale se setea en US
    // para poder unificar el pasaje de paremtros DATE
    // los parametros tipo DATE se pasan con $db->DBDate()
    //if (strtoupper($sTipoCon) == "ODBC")
    //   $objCC->SetDateLocale('US');
    //U820: Personalizaci�n para restringir permisos
    $strSQL = "SET ROLE guarani";
    $objCC->Execute($strSQL);

    return $objCC;
}

function Carga_parametros() {
    $objCon = conectar();

    if (isset($_GET["qs"])) {
        $crypt = new MD5Crypt();
        $qs_crypt = $crypt->Decrypt($_GET["qs"], qs_clave);

        parse_str($qs_crypt, $qs);
        $parametros = array_merge($qs, $_POST);
    } else
        $parametros = $_POST;

    if (array_key_exists("nombre_operacion", $parametros))
        $_SESSION["ses_nombre_operacion"] = urldecode($parametros["nombre_operacion"]);

    foreach ($_SESSION as $key => $value) {
        if (substr($key, 0, 4) == "ses_")
            $parametros[substr($key, 4)] = $_SESSION[$key];

        if (substr($key, 0, 9) == "par_oper_")
            $parametros[substr($key, 9)] = $_SESSION[$key];
    }

    // Ahora saco la pagina siguiente y anterior si es que existen...
    $sPagina = ereg_replace('^' . $parametros["sALIAS"], '', $_SERVER["SCRIPT_NAME"]);


    if (isset($parametros["operacion"])) {
        $strSQL = "EXECUTE PROCEDURE sp_paginas_net('" . $parametros["operacion"] . "','" . $sPagina . "','" . $_SESSION["ses_interfaz"] . "');";
        $rsPaginas = $objCon->Execute($strSQL);

        $iOrden = $rsPaginas->fields[2];
        $_SESSION["ses_titulo_pagina"] = $rsPaginas->fields[3];
        $parametros["titulo_pagina"] = $rsPaginas->fields[3];

        while (!$rsPaginas->EOF) {
            if ($iOrden > $rsPaginas->fields[1] && ($rsPaginas->fields[1] != $rsPaginas->fields[2]))
                $parametros["PagAnterior"] = $parametros["sALIAS"] . $rsPaginas->fields[0];
            else
                $parametros["PagSiguiente"] = $parametros["sALIAS"] . $rsPaginas->fields[0];

            /* Tengo carpetas? */
            if ($rsPaginas->fields[4] != "") {
                $strSQL = "EXECUTE PROCEDURE sp_paginas('" . $rsPaginas->fields[4] . "')";
                $rsSubPag = $objCon->Execute($strSQL);

                if (!$rsSubPag->EOF) {
                    $parametros["sub_paginas"] = $rsSubPag->RecordCount();
                    $i = 1;
                    while (!$rsSubPag->EOF) {
                        $parametros["sub_pagina_" . $i]["titulo"] = $rsSubPag->fields[2];
                        $parametros["sub_pagina_" . $i]["pagina"] = $rsSubPag->fields[3];
                        $rsSubPag->MoveNext();
                        $i++;
                    }
                }
            }

            $rsPaginas->MoveNext();
        }
    }
    return $parametros;
}

?>
