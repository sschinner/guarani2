<?
 include("../includes/session.inc.php");
  require("../adodb/adodb.inc.php");
  require("../adodb/crypt.inc.php");
  include("../library/std_functions.lib.php");
  include("../library/validador.lib.php");  

  // Llama a la funcion que toma los parametros de la página.
  $parametros = Cargar_parametros();

  // Si viene del notificador de errores o mensajes de pntos de control no ejecuto nuevamente el control
 if (!isset($parametros["Notificarse"])) {
    // limpio la cola de mensajes del Pto. de Control y ejecuto los controles
    resetMensajes();
    resetPuntosControl();

    // LLamo al validador
    $resultado = ejecutar_puntos_pagina($parametros["unidad_academica"],$parametros["operacion"],$_SERVER["SCRIPT_NAME"]);

    // Verifico el resultado y resuelvo si sigue o muestra el error ...
    if ($resultado <= 0){
      $url = ArmaLink("../notificarse_controles.php?fStatus=" . $resultado . "&PagAnterior=folder.php&PagSiguiente=" . $_SERVER["SCRIPT_NAME"] . "&operacion=" . $parametros["operacion"]);
      header("Location: $url");
      exit();
    }
  }

	// interfaz= Internet
	$strInterfaz = 3;

  // crea la conexión a la BD
  $objCon = conectar();
  $objCon->BeginTrans();
  $strSQL = "execute procedure sp820_d_inscPas('" . $parametros[unidad_academica] . "', '" . $parametros[nro_inscripcion] . "', " . $parametros[id_pasantia] . ", " . $strInterfaz . ")";

  $rsDesinscExam = $objCon->Execute($strSQL);
  // evaluo el resultado de la operacion
  $strStatus  = $rsDesinscExam->fields[0];
  $strMsg    = $rsDesinscExam->fields[1];
	if ($strStatus != 1) {
		// limpio la variable de session del ultimo punto de control (que incluye a varios)
		$objCon->RollbackTrans();
        $url = ArmaLink("../notificarse.php?fStatus=" . urlencode($strStatus) . "&fMsg=" . urlencode($strMsg)."&operacion=".urlencode($parametros["operacion"]));
        header("Location: $url");
		exit;
	}
	// hago el COMMIT
	$objCon->CommitTrans();
	
	// armo los argumentos y muestro el resultado
    $url = ArmaLink("../notificarse.php?fStatus=" . urlencode($strStatus) . "&fMsg=" . urlencode($strMsg)."&operacion=".urlencode($parametros["operacion"]));
    header("Location: $url");
	exit;
?>
