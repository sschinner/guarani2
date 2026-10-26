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
include_once("../detallesComisiones.php");
include_once("../periodosLectivos.php");

/* --------------------------
 Comentarios de servicios
 -------------------------- */
$comentarioComisionCursadas = "El servicio web retorna los horarios, dias y profesores de las materias que se dictan en un determinado periodo lectivo. El retorno es un JSON que contiene el siguiente objeto: stdClass Object
        (
            [codigoWS] => 0
            [mensajeWS] => OK - Servicio Web correcto.
            [codigoRetorno] => 0
            [mensajeRetorno] => OK - Datos comisiones a cursada
            [historia] => Array
                (
                    [0] => stdClass Object
                        (
                            [nombreMateria] => (string)
                            [codigoMateria] => (string)
                            [codigoCarrera] => (string)
                            [nombreCarrera] =>(string)
                            [comision] => (int)
                            [nombreComision] => (string)
                            [apellido] => (string)
                            [nombreProfesor] => (string)
                            [documentoProfesor] => (string)
                            [diaSemana] => (string)
                            [nombreDia] => (string)
                            [tipoClase] => (string)
                            [horaInicio] => (HH:mm)
                            [horaFin] => (HH:mm)
                            [nombreAula] => (string)
                            [nombreEdificio] => (string)
                            [anioCursada] => (int)
                        )
       )";

$comentarioPeriodosLectivos = "El servicio web retorna los periodos lectivos de un año academico. El retorno es un JSON que contiene el siguiente objeto: stdClass Object
        (
            [codigoWS] => 0
            [mensajeWS] => OK - Servicio Web correcto.
            [codigoRetorno] => 0
            [mensajeRetorno] => OK - Datos periodos lectivos
            [periodos_lectivos] => Array
                (
                    [0] => stdClass Object
                        (
                            [periodo_lectivo]	=> (string)
                            [inicio]			=> (date)
                            [fin]				=> (date)
                        )
       )";

