<?php

/* -----------------------------------------------------------------------------------------
CODIGO DE ERRORES DE WEBSERVICES:
'0': OK - La funcion se ejecuto correctamente.
'1': Error de autenticacion - Usuario y contrase�a invalidas.
'2': Error de parametros - Algun campo es vacio.
'3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
'4': Error de procedimiento - Algo salio mal dentro de la funcion.
------------------------------------------------------------------------------------------*/

require_once("adodb/adodb.inc.php");
include_once("/etc/guarani-webservices/bedeliaunl/ws_parametros.php");
include_once("../general.php");
include_once("../configServer.php");

/* --------------------------------------------------------
INCLUYO LAS FUNCIONES QUE PUEDE REALIZAR ESTE CLIENTE DE WS
-------------------------------------------------------- */
include_once("../comisionesCursadas.php");



$comentarioComisionCursadas = "<ul>El servicio web retorna informacion sobre las comisiones de cursadas para un determinado año y periodo lectivo, esto es materia, tipo de clase, profesor, dia y hora, etc, de la comisión.
<li>El Input se describe arriba</li>
            <li>El Output es un JSON que contiene el siguiente objeto:</li> 
<li>stdClass Object(</li>
            <li>[codigoWS] => 0 (integer)</li>
            <li>[mensajeWS] => OK - Servicio Web correcto. (string)</li>            
            <li>[materias] =></li>
                <blockquote><li>Array([0] => stdClass Object(</li>
                           <blockquote><li> [nombreMateria] => (string)</li>
                            <li>[codigoMateria'] = (string)</li>
                            <li>[codigoCarrera'] = (string)</li>
                            <li>[nombreCarrera'] = (string)</li>
                            <li>[comision'] = (string)</li>
                            <li>[nombreComision'] = (string)</li>
                            <li>[apellido'] = (string)</li>
                            <li>[nombreProfesor'] = (string)</li>
                            <li>[documentoProfesor'] = (string)</li>
                            <li>[diaSemana'] = (string)</li>
                            <li>[nombreDia'] = (string)</li>
                            <li>[tipoClase'] = (string)</li>
                            <li>[horaInicio'] = (string)</li>
                            <li>[horaFin'] = (string)</li>
                            <li>[nombreAula'] = (string)</li>
                            <li>[nombreEdificio'] = (string)</li>
                            <li>[anioCursada] => (string)</li></blockquote>)</blockquote>
                        <li>)</li></ul>
        <ul> Tipos de codigoWS : mensajeWS:
            <blockquote>
                <li> 0 : OK - Servicio Web correcto.</li>
                <li> 1 : Error de autenticacion - Usuario y contraseña invalidas.</li>
                <li> 2 : Error de parametros - Algun campo es vacio.</li>
                <li> 3 : Error de conexion - La conexion a la base de datos no se pudo establecer correctamente. </li>
                <li> 4 : Error de procedimiento - Algo salio mal dentro de la funcion. </li>
            </blockquote> 
        </ul>";
        
        
?>