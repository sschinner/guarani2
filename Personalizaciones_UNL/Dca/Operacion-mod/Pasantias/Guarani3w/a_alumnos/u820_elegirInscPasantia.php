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

  // crea la conexion a la BD
  $objCon = conectar();

  // Datos de las Pasantias
  $strSQL   = "execute procedure sp820_pasvig('" . $parametros["unidad_academica"] . "', '" . $parametros["nro_inscripcion"] . "')";
  $rsPasVig = $objCon->Execute($strSQL);

?>

<html>
  <head>
    <link rel="stylesheet" href="../styles/styles.css" type="text/css">
    <script type="text/javascript" language="JavaScript" src="../library/guarani.js"></script>
    <script Language="JavaScript">

      function enviar(operacion, unidad_academica, 
                      carrera, legajo, plan, id_pasantia) 
      {
        document.forms[0].operacion.value = operacion;
        document.forms[0].unidad_academica.value = unidad_academica;
        document.forms[0].carrera.value = carrera;
        document.forms[0].plan.value = plan;
        document.forms[0].legajo.value = legajo;
        document.forms[0].id_pasantia.value = id_pasantia;
        
		document.forms[0].submit();
      }
    </script>
  </head>
  <body class="cuerpo">
    <? 
      include("../includes/persona.inc.php");

      if (!$rsPasVig || $rsPasVig->EOF) 
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
          No existen Pasantias definidas.
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
          Elegí una Pasantía para inscribirte
        </td>
      </tr>        
    </table>
    <table class="detalle">
      <tr class="detalle_contenido">
        <td>
          Legajo: <b class="detalle_resaltado"><? echo $parametros["legajo"] ?></b>
        </td>
      </tr> 
    </table>
    <form method="POST" action="<? echo $parametros["PagSiguiente"]  ?>">
      <input type="hidden" name="operacion" value="">
      <input type="hidden" name="unidad_academica" value="">
      <input type="hidden" name="carrera" value="">
      <input type="hidden" name="legajo" value="">
      <input type="hidden" name="plan" value="">
	  <input type="hidden" name="id_pasantia" value="">
	  	<?
		    $intCnt = 0;
		    
        // Es para hacer el corte por (carrera)
    		$strCarrera = "";

    		while (!$rsPasVig->EOF) 
        {
          $intCnt++;

    			if ($strCarrera != ($rsPasVig->fields[1])) 
          {

      ?>
      <table class="detalle">
        <tr class="detalle_contenido">
          <td>
            Carrera: <b class="detalle_resaltado"><? echo $rsPasVig->fields[1] . "-" . $rsPasVig->fields[3] ?></b>
          </td>
        </tr>
      </table>
	    <table class="normal" >
	      <tr class="normal_titulo">
			<td width="20%">
		        Pasantía
		    </td>
			<td width="80%">
	          Detalle
			</td>
		  </tr>
			  <?
			    };
			  ?>
      <tr class="normal" onMouseOver="this.className='normal_sel';" onMouseOut="this.className='normal';" >
		<td>
            <a href="#" onclick="<? 
              echo  "enviar('" . $parametros["operacion"] . 
                         "','" . $parametros["unidad_academica"] . 
                         "','" . urlencode($rsPasVig->fields[1]) .  
                         "','" . $parametros["legajo"] . 
                         "','" . urlencode($rsPasVig->fields[5]) . 
                         "'," . urlencode($rsPasVig->fields[2]) .
                         ")" ;
                    ?>" >
			        <? echo "(" . $rsPasVig->fields[2] . ") " ?>
             </a>
          </td>
		  <td class="normal_centrado">
			      <? echo $rsPasVig->fields[4] ?>
          </td>
	 </tr>
			  <?
			    $rsPasVig->MoveNext();

    			if (!$rsPasVig->EOF) // para saber si debe cerrar la tabla antes de hacer un corte
    				if ($strCarrera != ($rsPasVig->fields[1]))
    					echo "</table>";
    		  }
		    ?>
  		  </table>
		  </form>
		<?
  	}
	  ?>
  </body>
</html>