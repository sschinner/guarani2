<?php

/* -----------------------------------------------------------------------------------------
CODIGO DE ERRORES DE WEBSERVICES:
'0': OK - La funcion se ejecuto correctamente.
'1': Error de autenticacion - Usuario y contrase?a invalidas.
'2': Error de parametros - Algun campo es vacio.
'3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
'4': Error de procedimiento - Algo salio mal dentro de la funcion.
------------------------------------------------------------------------------------------*/

require_once("adodb/adodb.inc.php");
//include_once("/etc/guarani-webservices/alumno/ws_parametros.php");
include_once("/etc/guarani-webservices/credenciales/credenciales.php");
include_once("../general.php");
include_once("../configServer.php");
//include_once("../etc/guarani-webservices/credenciales/credenciales.php");

/* --------------------------------------------------------
INCLUYO LAS FUNCIONES QUE PUEDE REALIZAR ESTE CLIENTE DE WS
-------------------------------------------------------- */
include_once("../turnosExamen.php");
include_once("../mesasExamen.php");

/* --------------------------
 Comentarios de servicios
 -------------------------- */
$comentarioTurnosExamen = "El servicio web retorna los turnos de examen de un año academico. El retorno es un JSON que contiene el siguiente objeto: stdClass Object
        (
            [codigoWS] => 0
            [mensajeWS] => OK - Servicio Web correcto.
            [codigoRetorno] => 0
            [mensajeRetorno] => OK - Datos Turnos de Examen
            [turnos_Examen] => Array
                (
                    [0] => stdClass Object
                        (
                            [turno_examen]	=> (string)
                            [nombre]		=> (string)
                            [turno_tipo]	=> (string)
                            [fecha_inicio]	=> (date)
                            [fecha_fin]		=> (date)
                            [tipoTitulo]	=> (integer)
                        )
       )";

$comentarioMesasExamen = "El servicio web retorna las mesas de examen de un turno. El retorno es un JSON que contiene el siguiente objeto: stdClass Object
        (
            [codigoWS] => 0
            [mensajeWS] => OK - Servicio Web correcto.
            [codigoRetorno] => 0
            [mensajeRetorno] => OK - Datos Mesas de Examen
            [turnos_Examen] => Array
                (
                    [0] => stdClass Object
                        (
						['mesa_codigo']			= (string)
						['mesa_nombre']			= (string)
						['actividad_codigo']	= (string)
						['actividad_nombre']	= (string)
						['fecha']				= (date);
						['hora_inicio']			= (time)
						['hora_finalizacion']	= (time)
						['llamado']				= (stinrg)
						['llamado_nombre']		= (string)
						['tribunal']			= 
						['propuestas']			= 
						['inscriptos']			= (integer)
                        )
       )";

