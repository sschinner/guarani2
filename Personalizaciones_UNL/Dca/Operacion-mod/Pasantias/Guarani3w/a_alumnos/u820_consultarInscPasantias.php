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
  // crea la conexion a la BD
  $objCon = conectar();

  // Consulto las Pasantias en las que esta inscripto
  $strSQL   = "execute procedure sp820_inscpas('" . $parametros["unidad_academica"]  . "', '" . $parametros["nro_inscripcion"] . "')";
  $rsInscPas = $objCon->Execute($strSQL);
?>


<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

  <link rel="stylesheet" href="../styles/styles.css" type="text/css">
    <script type="text/javascript" language="JavaScript" src="../library/guarani.js"></script>
</head>
<body class="cuerpo">
<? include("../includes/persona.inc.php") ?>
<?

//var_dump($parametros["nro_inscripcion"]);
//exit;

if ($rsInscPas->EOF) 
{
    ?>
    <table class="mensaje_ua">
      <tr class="mensaje_ua_titulo">
        <td>
          Mensaje
        </td>
      </tr>
      <tr class="mensaje_ua_contenido">
        <td>
          No existen inscripciones a pasantías.
        </td>
      </tr>
    </table>
    <?
      } 
else 
      {
        $strCarrera = ""; // es para hacer el corte por carrera
        while (!$rsInscPas->EOF) 
        {
          if ($strCarrera != $rsInscPas->fields[1]) 
          {
            $strCarrera = $rsInscPas->fields[1];
    ?>

        <table class="detalle">
          <tr  class="detalle_contenido">
            <td> Carrera: <b class="detalle_resaltado"> <? echo $rsInscPas->fields[3] ?></b>
			</td>
          </tr>

        </table>

        <table class="normal">
          <tr class="normal_titulo">
            <td width="30%">
            Pasantia</td>
            <td width="70%" >
            Detalle</td>
          </tr>
        <?
      }
        $intCarrera = $rsInscPas->fields[1];
        $intIdPasantia = $rsInscPas->fields[2];
        $strCarreraNombre = $rsInscPas->fields[3];
        $strDetallePasantia = $rsInscPas->fields[4];


      ?>
        <tr class="normal">
          <td width="30%" class="normal"><? echo "(" . $rsInscPas->fields[2] . ")" ?></td>
          <td width="5%"><? echo $rsInscPas->fields[4] ?></td>

        </tr>
      <?
      $rsInscPas->MoveNext();
      if (!$rsInscPas->EOF) {
        if ($intCarrera != ($rsInscPas->fields[1]))
          echo "</table>";
          }
    }
  }

?>
</table>
</body>
</html>
