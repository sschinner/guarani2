<?   include("../includes/session.inc.php");
     require("../adodb/adodb.inc.php");
     require("../adodb/crypt.inc.php");
     include("../library/std_functions.lib.php");
     include("../library/validador.lib.php");
    include("../includes/querystring.php");

    // recupera la unidad academica de la session
        $strUnidadAcademica = getUA();
        // recupera el usuario de la sesi?n
        $strUsuario = getUsuario();
        // recupera el Nro. de Inscripcion de la session
        $strNroInscripcion = getNroInscripcion();
        $intInterfaz = 3;  // es fija la de Internet

     // *********** Controles particulares - Parametros del validador ************
	$qs = Cargar_parametros();
        $strOperacion = $qs["operacion"];

    if (empty($strOperacion)) {
                header("Location: ../notificarse.php?fStatus=".urlencode("-1")."&fMsg=".urlencode("-746, El validador NO recibi? la operaci?n, volv? a la p?gina anterior"));
                exit;
        }

        $intEvento = $qs["evento"];
        if (empty($intEvento)) {
                header("Location: ../notificarse.php?fStatus=".urlencode("-1")."&fMsg=".urlencode("-746, El validador NO recibi? el evento, volv? a la p?gina anterior"));
                exit;
        }

        $intPtoControl = $qs["ptoControl"];
        if (empty($intPtoControl)) {
                header("Location: ../notificarse.php?fStatus=".urlencode("-1")."&fMsg=".urlencode("-746,El validador NO recibi? el punto de control, volv? a la p?gina anterior"));
                exit;
        }

        $strPagAnterior = $qs["pagAnt"];
        if (empty($strPagAnterior)) {
                header("Location: ../notificarse.php?fStatus=".urlencode("-1")."&fMsg=".urlencode("-746,El validador NO recibi? la p?gina anterior, volv? a la p?gina anterior"));
                exit;
        }

        $strPagSiguiente = $qs["pagSig"];
        if (empty($strPagSiguiente)) {
                header("Location: ../notificarse.php?fStatus=".urlencode("-1")."&fMsg=".urlencode("-746, El validador NO recibi? la p?gina siguiente, volv? a la p?gina anterior"));
                exit;
        }

        // ************** Parametros del Pto. de Control ************************
        // recupero los parametros que espera recibir el disparador segun el punto de control
        if ($intPtoControl == 8201) {  // persona elige una Pasant?a


                // tomo el indice para recuperar el valor del tipo de inscripcion
                $strMesaConTodo    = $_POST["fMesaSeleccionada"];   // aca recibe todo junto

                if (empty($strMesaConTodo)) {

                        header("Location: ../notificarse.php?fStatus=".urlencode("-1")."&fMsg=".urlencode("-746, NO has elegido la Pasantia, volve a la pagina anterior"));
                        exit;
                }


                $i = 0;
                $j = 1;
                $j = strpos($strMesaConTodo, "|",$i);
                $intIndice = substr($strMesaConTodo, $i, $j-$i) ;
                $i = $j +1;
                $j = strpos($strMesaConTodo, "|",$i);
                $strUnidadAcademicaAux = urldecode(substr($strMesaConTodo, $i, $j-$i));
                $i = $j + 1;
                $j = strpos($strMesaConTodo, "|",$i);
                $strCarrera = urldecode(substr($strMesaConTodo, $i, $j-$i));
                $i = $j + 1;
                $j = strpos($strMesaConTodo, "|",$i);
                $intPasantia = urldecode(substr($strMesaConTodo, $i, $j-$i));
                $i = $j + 1;
                $j = strpos($strMesaConTodo, "|",$i);
                $strNombreCarrera = urldecode(substr($strMesaConTodo, $i, $j-$i));
                $i = $j + 1;
                $j = strpos($strMesaConTodo, "|",$i);
                $strPasantiaDetalle = urldecode(substr($strMesaConTodo, $i, $j-$i));
                $i = $j + 1;
                $j = strpos($strMesaConTodo, "|",$i);
                $strPlan = urldecode(substr($strMesaConTodo, $i, $j-$i));
                
                 // Legajo de la Persona, segun la pasantia-carrera elegida
                $objCon = conectar();
                $strSQL   = "execute procedure sp820_legajo('" . $strUnidadAcademica . "', '" . $strNroInscripcion . "', '" . $strCarrera . "')";
                $rsInscPas = $objCon->Execute($strSQL);
                $aItems[0]        = $strUnidadAcademica;
                $aItems[1]        = $strNroInscripcion;
                $aItems[2]        = $rsInscPas->fields[0];

                // los paso al array

                $aItems[3]        = $strCarrera;
                $aItems[4]        = $strPlan;
                $aItems[5]        = $intPasantia;


                // si pag. sig. ya trae la operaci?n entonces toma esta operaci?n si no se la agrega
                $strPagDestConParams = $strPagSiguiente . "?operacion=" . urlencode($strOperacion). "&evento=" . urlencode($intEvento).
                                        "&unidadAcademica=" .urlencode($aItems[0]).
                                        "&nro_inscripcion=".urlencode($aItems[1]).
                                        "&legajo=".urlencode($aItems[2]).
                                        "&carrera=".urlencode($aItems[3]).
                                        "&plan=".urlencode($aItems[4]).
                                        "&id_pasantia=".urlencode($aItems[5]);

                $strPagAntConParams = $strPagAnterior;
        }
        elseif ($intPtoControl == 2) {                // persona operacion
                $aItems[0]        = $strUnidadAcademica;
                $aItems[1]        = $strNroInscripcion;
                $aItems[2]        = $strOperacion;
                // si pag. sig. ya trae la operaci?n entonces toma esta operaci?n si no se la agrega
                if (strstr($strPagSiguiente,"operacion="))
                        $strPagDestConParams = $strPagSiguiente;
                else
                        $strPagDestConParams = $strPagSiguiente . "?operacion=" . urlencode($strOperacion);

                $strPagAntConParams = $strPagAnterior;
        }

        // ********** Ejecucion de los controles del Pto. de Control ***********
        // seteo el status2 y status3 en 1 por si no lo uso
        $strStatus2 = "1";
        $strStatus3 = "1";
        $strStatus4 = "1";

        // limpio la cola de mensajes del Pto. de Control y ejecuto los controles
        resetMensajes();

        // ejecuto el disparador
        $strRet = disparar($strUnidadAcademica, $strOperacion, $intEvento , $intInterfaz, $intPtoControl, $aItems);
        $strStatus1 = status($strRet);

        if ($intPtoControl == 8201) {
                $intPtoControlOculto  = 24;
                $aItemsDisp[0]        = $aItems[0];
                $aItemsDisp[1]        = $aItems[3];
                $aItemsDisp[2]        = $aItems[1];

                $strRet          = disparar($strUnidadAcademica, $strOperacion, $intEvento , $intInterfaz, $intPtoControlOculto, $aItemsDisp);
                $strStatus2          = status($strRet);

                $intPtoControlOculto  = 3;
                $aItemsDisp[0]        = $aItems[0];
                $aItemsDisp[1]        = $aItems[3];
                $aItemsDisp[2]        = $aItems[2];
                $aItemsDisp[3]        = $strOperacion;

                $strRet        = disparar($strUnidadAcademica, $strOperacion, $intEvento , $intInterfaz, $intPtoControlOculto, $aItemsDisp);
                $strStatus3        = status($strRet);

                }

        // seteo en OK el resultado de la operacion, evento , pto de control
        $strVarName        = $strOperacion . "_" . $intEvento . "_" . $intPtoControl;
        $strActuaComo      = "M";
        $_SESSION[$strVarName]  = $strActuaComo;

    //Encripto ambos links
    $strPagAntConParams    = ArmaLink($strPagAntConParams);
    $strPagDestConParams  = ArmaLink($strPagDestConParams);


    // evaluo el resultado del disparador
    if (($strStatus1 == "1") && ($strStatus2== "1") && ($strStatus3=="1") && ($strStatus4=="1")){       // OK
        header("Location: " . $strPagDestConParams);
                exit;
        }
        else{
               // defino el titulo
                if (($strStatus1 == "-1") || ($strStatus2 == "-1") || ($strStatus3 == "-1") || ($strStatus4 == "-1")){
                        $strTitulo  = "Problemas !!!";
                        $strLeyenda  = "NO podes continuar";
                }
                else {
                    $strTitulo  = "Advertencia !!!";
                    $strLeyenda  = "Podes continuar";
                }
        }

        // creo la conexi?n
        if (!isset($objCon))
                $objCon = conectar();
?>
<html>
<head>
<title>Guarani3W:u820_validadorPasantia</title>
<link rel="stylesheet" href="../styles/styles.css" type="text/css">
</head>
<body topmargin="0" leftmargin="0" background="../imagenes/sumtextb.jpg" bgcolor="#FFFFFF"
text="#808080" link="#3333CC" vlink="#666699" alink="#990099">
<?
        include("../includes/persona.inc.php");
?>
<br>
<p align="center"><span class="mensajes">No olvides ejecutar la opci?n Finalizar Sesi?n cuando finalices tus tr?mites. Gracias</span></p>
<br>
<?

        if (!empty($_SESSION["sPilaMensajes"])) {
                ?>
                <center>
                <table border="0" cellpadding="0" cellspacing="0" width="65%">
                <tr><td width="100%" bgcolor="white" height="20">
                <span class="nombrecampo"><? echo $strTitulo; ?></span></td>
                </tr></table>
                </center>
                <center>
                <table border="0" cellpadding="0" cellspacing="0" width="65%">
                <?
                for ($j= 0; $j <= count($_SESSION["sPilaMensajes"]) -1; $j++) {
                        $strSQL = "EXECUTE PROCEDURE mme_muestraMensaje('".$_SESSION["sPilaMensajes"][$j][3]."')";
                        $rsMensajes = $objCon->Execute($strSQL);
                        // evaluo el resultado de la operacion
                        $strWarning         = $rsMensajes->fields[0];
                        $strActuaComo        = $_SESSION["sPilaMensajes"][$j][4];
                        ?>
                        <tr>
                        <td width="67%" align="center" bgcolor="#FFFFFF">
                        <span class="contenidocampo"><? echo $strWarning; ?></span> </td>
                        </tr>
                        <?
                }
                print "</table></center>";
                $_SESSION[$strVarName] = $strActuaComo;
        }

  ?>
<br>
<center>
<table border="0" cellpadding="0" cellspacing="0" width="40">
  <tr>
    <td><a href="<? echo $strPagAntConParams; ?>">
    <img src='../imagenes/back.gif' border='0' alt='anterior'></a>
    </td>
<?
        if (($strStatus1 != "-1") && ($strStatus2 != "-1") && ($strStatus3 != "-1")) {
                ?>
                <td>&nbsp;&nbsp;&nbsp;&nbsp; </td>
                <td><a href="<? echo $strPagDestConParams; ?>">
                <img src="../imagenes/forward.gif" border="0" alt="siguiente"></a>
           </td>
                <?
        }
?>
</tr>
</table>
</center>
<br>
<center>
<table border="0" cellpadding="0" cellspacing="0" width="40%">
  <tr>
    <td align="center" width="100%" height="20" bgcolor="darkRed"><span class="mensajes">
    <font color="#FFFFFF"><? echo $strLeyenda; ?></font></span></td>
  </tr>
</table>
</center>
<p>&nbsp;</p>
</body>
</html>

