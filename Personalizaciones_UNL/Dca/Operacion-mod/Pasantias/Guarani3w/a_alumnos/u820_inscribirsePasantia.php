<?
include("../includes/session.inc.php");
require("../adodb/adodb.inc.php");
require("../adodb/crypt.inc.php");
include("../library/std_functions.lib.php");
include("../library/validador.lib.php");

  // Llama a la funcion que toma los parametros de la página.
  $parametros = Cargar_parametros();

  // Si viene del notificador de errores o mensajes de pntos de control no ejecuto nuevamente el control
  if (!isset($parametros["Notificarse"]))
  {
    // limpio la cola de mensajes del Pto. de Control y ejecuto los controles
    resetMensajes();

    // LLamo al validador
    $resultado = ejecutar_puntos_pagina($parametros["unidad_academica"],$parametros["operacion"],$_SERVER["SCRIPT_NAME"]);

    // Verifico el resultado y resuelvo si sigue o muestra el error ...
    if ($resultado <= 0)
    {
      $url = ArmaLink("../notificarse_controles.php?fStatus=" . $resultado . "&PagAnterior=" . $parametros["PagAnterior"] . "&operacion=" . $parametros["operacion"] . "&PagSiguiente=" . $_SERVER["SCRIPT_NAME"] . "&ParamsPagSiguiente=" . $ParamsPagSiguiente);
      header("Location: $url");
      exit;
    }
  }

	// interfaz= Internet
	$strInterfaz = 3;

 	// Recupero los datos capturados en el form anterior
	if (! isset($parametros["carrera"])) {
        $url = ArmaLink("../notificarse.php?fStatus=" . urlencode(-1) . "&fMsg=" . urlencode("-746, NO has elegido la carrera, volvé a la página correspondiente")."&operacion=".urlencode($parametros["operacion"]));
        header("Location: $url");
		exit;
	}
	if (! isset($parametros["legajo"])) {
        $url = ArmaLink("../notificarse.php?fStatus=" . urlencode(-1) . "&fMsg=" . urlencode("-746, NO has elegido el legajo, volvé a la página correspondiente")."&operacion=".urlencode($parametros["operacion"]));
        header("Location: $url");
		exit;
	}

	if (! isset($parametros["id_pasantia"])) {
        $url = ArmaLink("../notificarse.php?fStatus=" . urlencode(-1) . "&fMsg=" . urlencode("-746, NO has elegido la pasantía, volvé a la página correspondiente")."&operacion=".urlencode($parametros["operacion"]));
        header("Location: $url");
		exit;
	}

  // ACA EMPIEZA UNA TRANSACCION, ya que grabo la inscripcion y los mensajes (si los hay)
  $objCon = conectar();
  $objCon->BeginTrans();
  // Genero el sql para insertar la inscripcion
  $strSQL = "execute procedure sp820_i_inscPasantias('" . $parametros["unidad_academica"] . "', '" .
                     $parametros["nro_inscripcion"] . "', '" .
                     $parametros["legajo"] . "', '" .
                     $parametros["carrera"] . "', '" .
                     $parametros["plan"] . "', " .
                     $parametros["id_pasantia"] . ", " .
                     $strInterfaz .")";

  $rsInscExam = $objCon->Execute($strSQL);


  // evaluo el resultado de la operacion
  $strStatus = $rsInscExam->fields[0];
  $strMsg   = $rsInscExam->fields[1];
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