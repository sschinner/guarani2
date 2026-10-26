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
  $strSQL = "execute procedure sp820_inscPas('" . $parametros["unidad_academica"] . "', '" . $parametros["nro_inscripcion"] . "')";
  $rsInscExam = $objCon->Execute($strSQL);

?>

<html>
  <head>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

    <link rel="stylesheet" href="../styles/styles.css" type="text/css">
    <script type="text/javascript" language="JavaScript" src="../library/guarani.js"></script>
  </head>
  <body class="cuerpo">
    <? 
      include("../includes/persona.inc.php"); 

      if (!$rsInscExam || $rsInscExam->EOF) 
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
          No hay Inscripciones a Pasantías para dar de baja.
        </td>
      </tr>
    </table>
     <?
      } 
        else   
      {
    ?>
    <table class="ayuda_rapida">
      <tr class="ayuda_rapida_titulo">
        <td>
          Ayuda
        </td>
      </tr>
      <tr class="ayuda_rapida_contenido">
        <td>
          Hac&eacute; click en la inscripci&oacute;n que quer&eacute;s dar de baja.
        </td>
      </tr>
      </tr>
    </table>
		<?
      $carrera = "";

		  while (!$rsInscExam->EOF) 
      {
			  if ($carrera != $rsInscExam->fields[1] ) 
        {
          $carrera = $rsInscExam->fields[1];
	  ?>
	  <table class="detalle">
	    <tr class="detalle_contenido"> 
			  <td>
		      Carrera: <b class="detalle_resaltado"> <? echo '(' . $rsInscExam->fields[1] . ') ' . $rsInscExam->fields[3] ?></b>
        </td>
	    </tr>
		</table>
	  <table class="normal">
	    <tr class="normal_titulo">
			  <td width="20%">
				  Pasantía
        </td>
				<td width="80%">
				  Detalle
        </td>
		  </tr>
		  <?
	  		}
		  ?>
		  <tr class="normal" onMouseOver="this.className='normal_sel';" onMouseOut="this.className='normal';">
        <td> 
	        <?
    				  //Preparo la URL para encriptarla
  		    		$url  = $parametros["PagSiguiente"] . 
                    "?operacion=" . $parametros['operacion'] . 
                    "&unidadAcademica=" . $rsInscExam->fields[0] . 
                    "&carrera=" . $rsInscExam->fields[1] . 
                    "&id_pasantia=" . $rsInscExam->fields[2]
		    		?>
			    	<a href="<?echo ArmaLink($url);?>"> 
              <? echo "(" . $rsInscExam->fields[2] . ") " ?>
          </a>
        </td>
			  <td class="normal_centrado">
	        <? echo $rsInscExam->fields[4] ?>
        </td>
			  <?
			    $rsInscExam->MoveNext();
          
          // para saber si debe cerrar la tabla antes de hacer un corte
			    if (!$rsInscExam->EOF) 
			  if ($carrera != $rsInscExam->fields[1] ) 

			    		echo "</table>";
    		  }
	      }
      ?>
    </table>
  </body>
</html>
