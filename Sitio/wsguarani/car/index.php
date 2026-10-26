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


?>
<html>
    <head>
        <meta http-equiv="Content-type" content="text/html;charset=UTF-8"  name="viewport" content="width=600px, initial-scale=1.0, user-scalable=no">
        <title>Consulta Alumno Regular </title> 
        <script type="text/javascript" language="JavaScript" src="js/jquery-1.7.2.js"></script>
        <script type="text/javascript" language="JavaScript" src="js/jquery-mask.js"></script>
        <script type="text/javascript" language="JavaScript" src="jquery-ui-1.11.4/jquery-ui.min.js"></script>
        <script type="text/javascript" language="JavaScript" src="jquery-ui-1.11.4/jquery-ui.js"></script>
        <link rel="stylesheet" href="jquery-ui-1.11.4/jquery-ui.css" type="text/css">
        <link rel="stylesheet" href="jquery-ui-1.11.4/jquery-ui.min.css" type="text/css">
        <script LANGUAGE="JavaScript">
            $(document).ready(function () {
                $("#resultado").hide();
                $( "#fecha" ).datepicker({dateFormat:"dd/mm/yy"}).datepicker("setDate",new Date());

            });

            function validaCampos() {
                var mens = '';
                if ($("#unidadAca").val() == 0) {
                    mens = 'Debe seleccionar la unidad académica.\n';
                }
                if ($("#apellido").val() == '') {
                    mens = mens + "Debe ingresar el apellido.\n";
                }
                if ($("#nombres").val() == '') {
                    mens = mens + "Debe ingresar el nombre.\n";
                }
                if ($("#tipoDoc").val() == 0) {
                    mens = mens + "Debe seleccionar el tipo de documento.\n";
                }
                if ($("#nroDoc").val() == '') {
                    mens = mens + "Debe ingresar el nro. de documento.\n";
                }
                if ($("#sexo").val() == '') {
                    mens = mens + "Debe ingresar el sexo de la persona.\n";
                }
                if ($("#fecha").val() == '') {
                    mens = mens + "Debe ingresar la fecha.\n";
                }

                if (mens != '') {
                    alert(mens);
                } else {
                    document.forms[0].submit();
                }

            }

            function limpiaDatos() {
                $("#unidadAca").val('0');
                $("#apellido").val('');
                $("#nombres").val('');
                $("#tipoDoc").val('0');
                $("#nroDoc").val('');
                $("#sexo").val('0');
                $("#fecha").val('');
            }

        </script>
        <link rel="stylesheet" href="styles/estilos.css" type="text/css">
        <link rel="stylesheet" href="styles/styles.css" type="text/css">
    </head>
    <body>
        <div>
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
                <form name="regul" method="POST" action="verRegularidad.php" enctype="multipart/form-data">
                    <fieldset  style="width:85%;margin-left:11%;background-color: #DDEFFF;">
                        <legend style="font-family: Arial; font-size:10pt;"><b> Buscar Alumno</b></legend>
                        <br /><br />
                        <table >
                            <tr>
                                <td colspan="2"> 
                                    <span style="margin-left:30px;font-size:10pt;width:100px;" ><b> Unidad Académica:</b> </span>
                                    <select name="unidadAca" id="unidadAca" class="formulario_boton">
                                        <option value="0" selected>Seleccione UA</option>
                                        <option value="1" >FADU</option>
                                        <option value="2" >FBCB</option>
                                        <option value="40" >ESS</option>
                                        <option value="28" >EUAA</option>
                                        <option value="10" >FICH</option>
                                        <option value="8" >FHUC</option>
                                        <option value="9" >FIQ</option>
                                        <option value="7" >FCV</option>
                                        <option value="3" >FCA</option>
                                        <option value="29" >ISM</option>
                                        <option value="5" >FCJS</option>
                                        <option value="4" >FCE</option>
                                        <option value="6" >FCM</option>
                                    </select>
                                    <br />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <br />
                                    <br />
                                    <span style="margin-left:10%;font-size:10pt;" ><b> Apellido:</b> </span>

                                    <input type="text" size="40px;" id="apellido" name="apellido" style="margin-left:10%;" />
                                    <br />
                                </td>
                                <td><br /><br />
                                    <span style="margin-left:30px;font-size:10pt;width:100px;;" ><b> Nombres:</b> </span>
                                    <input type="text" size="40px;" id="nombres" name="nombres" style="margin-left:9%;" />
                                    <br />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <br /><br />
                                    <div style="margin-top:7%;">
                                    <span style="margin-left:30px;font-size:10pt;" ><b> Tipo de documento:</b> </span>

                                    <select name="tipoDoc" id="tipoDoc" class="formulario_boton">
                                        <option value="0" selected>Seleccione</option>
                                        <option value="1" >DNI</option>
                                        <option value="2" >LC</option>
                                        <option value="3" >LE</option>
                                        <option value="4" >PASAPORTE</option>
                                    </select>
                                    <br />
                                    </div>
                                </td>
                                <td><br /><br />
                                    <span style="margin-left:30px;font-size:10pt;width:100px;;" ><b> Nro. documento:</b> </span>
                                    <input type="text" size="40px;" id="nroDoc" name="nroDoc" style="margin-left:9%;" />
                                    <br />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <br /><br />
                                    <span style="margin-left:30px;font-size:10pt;" ><b> Sexo:</b> </span>

                                    <select name="sexo" id="sexo" class="formulario_boton">
                                        <option value="0" selected >Seleccione</option>
                                        <option value="F" >Femenino</option>
                                        <option value="M" >Masculino</option>
                                    </select>
                                    <br /> 
                                </td>
                                <td>
                                    <br /><br />
                                    <span style="margin-left:30px;font-size:10pt;width:100px;" ><b> Fecha:</b> </span>
                                    <input type="text" size="15px;" id="fecha" name="fecha"  style="margin-left:10px;" />

                                    <br />
                                </td>
                            </tr>
                            <tr>
                                <td>
                        </table>
                        <br />

                    </fieldset>
                    <br /><br />
                    <input type="button" value="Limpiar Datos" onClick="limpiaDatos();" style="margin-left:38%;width:100px; height:25px;font-size:10pt;"/>
                    <input type="button" value="Buscar"  onClick="validaCampos();" style="margin-left:8%;width:70px; height:25px;font-size:10pt;"   />
                </form>
                <br />
                <br />
            </div>
        </div>
    </body>
</html>
