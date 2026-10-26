<?php
/* -----------------------------------------------------------------------------------------
CODIGO DE ERRORES DE WEBSERVICES:
'0': OK - La funcion se ejecuto correctamente.
'1': Error de autenticacion - Credenciales invalidas.
'2': Error de parametros - Algun campo es vacio.
'3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
'4': Error de procedimiento - Algo salio mal dentro de la funcion.
------------------------------------------------------------------------------------------*/

require_once("adodb/adodb.inc.php");
include("/etc/guarani-webservices/atilra/ws_parametros.php");
include_once("/etc/guarani-webservices/credenciales/credenciales.php");
include("../general.php");
include_once("../configServer.php");

/* --------------------------------------------------------
INCLUYO LAS FUNCIONES QUE PUEDE REALIZAR ESTE CLIENTE DE WS
-------------------------------------------------------- */
include("../insertaAlumno.php");
include("../cambiarUsuarioAutogestion.php");
include("../cambiarClaveAutogestion.php");
include("../altaReinscripcion.php");
