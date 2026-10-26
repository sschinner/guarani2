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
include("/etc/guarani-webservices/wifi/ws_parametros.php");
include_once("/etc/guarani-webservices/credenciales/credenciales.php");
include("../general.php");
include_once("../configServer.php"); 
/* --------------------------------------------------------
INCLUYO LAS FUNCIONES QUE PUEDE REALIZAR ESTE CLIENTE DE WS
-------------------------------------------------------- */
include("../autenticarUsuarioWifi.php");



$comentarioAutenticarUsuarioWifi = "<ul>El servicio web determina si una persona es usuario del sistema Guarani. 
            <li>El Input se describe arriba</li>
            <li>El Output es un JSON que contiene el siguiente objeto:</li>    
            <li>stdClass Object(</li>
            <li>[codigoWS] => 0 (integer)</li>
            <li>[mensajeWS] => OK - Servicio Web correcto. (string)</li>
            <li>[codigoValidacion] => integer </li>
            <li>[mensajeValidacion] => (string)</li>
            <li>)</li>
    </ul>
    <ul> Tipos de codigoWS : mensajeWS:
            <blockquote>
                <li> 0 : OK - Servicio Web correcto.</li>
                <li> 1 : Error de autenticacion - Usuario y contraseña invalidas.</li>
                <li> 2 : Error de parametros - Algun campo es vacio.</li>
                <li> 3 : Error de conexion - La conexion a la base de datos no se pudo establecer correctamente. </li>
                <li> 4 : Error de procedimiento - Algo salio mal dentro de la funcion. </li>
            </blockquote> 
        </ul>
        <br>
        <ul> Tipos de codigoValidacion : mensajeValidacion:
        <blockquote>
            <li>  0 : OK  </li>
            <li> -1 : La persona no esta registrada en ninguna carrera de la Facultad </li>
            <li> -2 : El alumno no ha realizado la Reinscripción Anual  (string)</li>
            <li> -3 : Usuario o Clave Incorrectos</li>
          
        </blockquote>  </ul>";
?>
