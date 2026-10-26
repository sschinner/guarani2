<?php
header('Content-type: text/html; charset=utf-8');
$dia=date("l");

if ($dia=="Monday") $dia="Lunes";
if ($dia=="Tuesday") $dia="Martes";
if ($dia=="Wednesday") $dia="Miércoles";
if ($dia=="Thursday") $dia="Jueves";
if ($dia=="Friday") $dia="Viernes";
if ($dia=="Saturday") $dia="Sabado";
if ($dia=="Sunday") $dia="Domingo";

$mes=date("F");

if ($mes=="January") $mes="Enero";
if ($mes=="February") $mes="Febrero";
if ($mes=="March") $mes="Marzo";
if ($mes=="April") $mes="Abril";
if ($mes=="May") $mes="Mayo";
if ($mes=="June") $mes="Junio";
if ($mes=="July") $mes="Julio";
if ($mes=="August") $mes="Agosto";
if ($mes=="September") $mes="Setiembre";
if ($mes=="October") $mes="Octubre";
if ($mes=="November") $mes="Noviembre";
if ($mes=="December") $mes="Diciembre";

$anio=date("Y");
$dia2=date("d");

include_once("/etc/guarani-webservices/gobierno/ws_parametros.php");
include_once("../general.php");
include_once("../configServer.php");
require_once('../nusoap/lib/nusoap.php');
$wsdl = WSDLG . "/gobierno?wsdl"; //el nombre del archivo servidor

$client = new nusoap_client($wsdl, 'wsdl');
$client->setCredentials("wsguarani", "WSgua23rect", "basic");
$err = $client->getError();
if ($err) {
    // error if any
    echo 'Constructor error' . $err;
}


$apellido = $_POST['apellido'];
$apellido = iconv("ISO-8859-1", "utf-8", $apellido);
$nombre = $_POST['nombres'];
$nombre = iconv("ISO-8859-1", "utf-8", $nombre);
$unidadAca = $_POST['unidadAca'];
$tipoDoc = $_POST['tipoDoc'];
$nroDoc = $_POST['nroDoc'];
$sexo = $_POST['sexo'];
$fecha = $_POST['fecha'];

$param = array('TI' => '1', 'UA' => $unidadAca, 'apellido' => $apellido, 'nombre' => $nombre, 'Tdni' => $tipoDoc, 'dni' => $nroDoc, 'sexo' => $sexo, 'fecha' => $fecha);

$resultado = $client->call('esAlumno', $param);
?>
<html >



    <head>
        <meta http-equiv="Content-type" content="text/html;charset=UTF-8">﻿
        <title>Consulta Alumno Regular </title> 
        <link rel="stylesheet" href="styles/estilos.css" type="text/css">
        <script type="text/javascript" language="JavaScript" src="js/jquery-1.7.2.js"></script>
        <script type="text/javascript" language="JavaScript" src="js/jquery-mask.js"></script>
        <link rel="stylesheet" href="styles/styles.css" type="text/css">
    </head>
    <div class="cabecera">
        <div>
            <img src="imagenes/universidad-nacional-del-litoral.png">
            <span class="fecha"><?php echo "$dia, $dia2 de $mes de $anio"; ?></span>
        </div>
    </div>
    <div align='center'>
        <h1>Consulta Alumno Regular</h1>
    </div>
    <div   style="margin-left:auto;margin-right:auto;margin-top:30px ;width:50%;height:50%;">
        <br />
        <br />
        <fieldset  style="width:85%;margin-left:11%;background-color: #DDEFFF;">
            <legend style="font-family: Arial; font-size:10pt;"><b> Estado del Alumno</b></legend>
            <br />
            <br />
            <div id="resultado" style="margin-left:15%;" >

                <?php
                if ($resultado[0][1] == 2) {
                    ?><span style="margin-left:30px;font-size:11pt;" > 
                        <b><p><?php echo "Usuario o password No VALIDO"; ?></p></b> </span><?php
            } else if ($resultado[0][1] == 88) {
                    ?><span style="margin-left:30px;font-size:11pt;" > 
                        <b><p><?php echo "Error: Algun campo es vacio."; ?></p></b> </span><?php
                } else if ($resultado[0][1] == 1) {
                    ?><span style="margin-left:30px;font-size:11pt;" > 
                        <b><p><?php echo "Error: Error de institucion."; ?></p></b> </span><?php
                } else if ($resultado[0][1] == 3) {
                    ?><span style="margin-left:30px;font-size:11pt;" > 
                        <b><p><?php echo "Error de servicio."; ?></p></b> </span><?php
                } else if ($resultado[0][1] == 4) {
                    ?><span style="margin-left:30px;font-size:11pt;" > 
                        <b><p><?php echo "Error inesperado."; ?></p></b> </span><?php } else {
                    ?>	
                    <br>
                    <span style="margin-left:2%;font-size:12pt;" > Apellido: </span><span style="margin-left:5%;font-size:12pt;" > <b> <?php if (trim($resultado[0][1]) != "") echo $resultado[0][1];
                    else echo $_POST['apellido']; ?></b> </span>
                    <br><span style="margin-left:2%;font-size:12pt;" > Nombres: </span><span style="margin-left:4%;font-size:12pt;" > <b><?php if (trim($resultado[0][2]) != "") echo ($resultado[0][2]);
                    else echo $_POST['nombres']; ?></b> </span><?

                    ?><br> <span style="margin-left:10px;font-size:12pt;" > Estado: </span><span style="margin-left:7%;font-size:11pt;" > <b><?php
                            switch ($resultado[0][0]) :
                                case 5:
                                    echo "NO EXISTENTE.";
                                    ?></b>
                                <br> <br><br>
                                <fieldset  style="width:85%;margin-left:0px;background-color:  #DDEFFF;" id="causas" >
                                    <legend style="font-family: Times; font-size:11pt;"><b> Posibles causas:</b></legend>
                                    <UL type = square>
                                        <LI>La persona buscada no existe en la unidad académica seleccionada
                                        <LI>Verifique la unidad académica y el tipo y nro. de documento
                                    </UL>
                                </fieldset>	<b>
                                    <?php
                                    break;
                                case 6:
                                    echo "REGULAR";
                                    break;
                                case 7:
                                    echo "REGULAR CON ERRORES EN EL APELLIDO O NOMBRE";
                                    break;
                                case 8:
                                    echo "NO REGULAR";
                                    ?></b>
                                <br> <br><br>
                                <fieldset  style="width:85%;margin-left:0px;;background-color: #DDEFFF;" id="causas" >
                                    <legend style="font-family: Times; font-size:11pt;"><b> Posibles causas:</b></legend>

                                    <UL type = square>
                                        <LI>No tiene generado el legajo
                                        <LI>No realizó la reinscripción anual
                                        <LI>Se encuentra en alguno de los posibles estados: egresado, pasivo, abandono o no regular en carrera 
                                    </UL>
                                </fieldset>	<b>
                                    <?php
                                    break;
                                case 9:
                                    echo "NO REGULAR CON ERRORES EN EL APELLIDO O NOMBRE";
                                    break;
                                default:
                                    echo "REPITA LA OPERACION";

                            endswitch;
                        }
                        ?></b></span>
            </div>
            <br />
            <br />
        </fieldset>
        <br />
        <br />
        <div>
            <input type="button" value="Volver atrás" style="margin-left:25%;width:130px; height:25px;font-size:10pt;" onclick="history.back()" />
            <input type="button" value="Nueva Busqueda" onclick= "location.href = 'index.php'"  style="margin-left:25%;width:130px; height:25px;font-size:10pt;"/>
        </div>
    </div>
</div>
</body>
</html>