<?php

/* -----------------------------------------------------------------------------------------
CODIGO DE ERRORES DE WEBSERVICES:
'0': OK - La funcion se ejecuto correctamente.
'1': Error de autenticacion - Usuario y contrase�a invalidas.
'2': Error de parametros - Algun campo es vacio.
'3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
'4': Error de procedimiento - Algo salio mal dentro de la funcion.
------------------------------------------------------------------------------------------*/

require_once("../../../libraries/adodb/adodb.inc.php");
// include("/etc/guarani-webservices/tramites/ws_parametros.php");
include("../../general.php");
include_once("../../configServer.php"); 
/* --------------------------------------------------------
INCLUYO LAS FUNCIONES QUE PUEDE REALIZAR ESTE CLIENTE DE WS
-------------------------------------------------------- */
include("../notificarUrlCertificado.php");
include("../retrocederValidacion.php");