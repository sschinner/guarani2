<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Usuario y contrase?a invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */

require_once("../adodb/adodb.inc.php");
include_once("/etc/guarani-webservices/alumno/ws_parametros.php");
include_once("/etc/guarani-webservices/credenciales/credenciales.php");
include_once("../../general.php");
include_once("../../configServer.php");
//include_once("../etc/guarani-webservices/credenciales/credenciales.php");

/* --------------------------------------------------------
  INCLUYO LAS FUNCIONES QUE PUEDE REALIZAR ESTE CLIENTE DE WS
  -------------------------------------------------------- */
include("../../v2/autenticarAlumno.php");

/* --------------------------
  Comentarios de servicios
  -------------------------- */
$comentarioAutenticarAlumno = "<ul>El servicio web determina si una persona es usuario del sistema Guarani. 
            <li>El Input se describe arriba</li>
            <li>El Output es un JSON que contiene el siguiente objeto:</li>    
            <li>stdClass Object(</li>
            <li>[codigoWS] => 0 (integer)</li>
            <li>[mensajeWS] => OK - Servicio Web correcto. (string)</li>
            <li>[codigoRetorno] => true (boolean)</li>
            <li>[mensajeRetorno] => Es usuario Guarani (string)</li>
            <li>[tipoTitulo] => integer </li>
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
         <br/>
        <ul> Tipos de codigoRetorno : mensajeRetorno:
        <blockquote>
            <li>  true : Es usuario Guarani (string)</li>
            <li> false : No es usuario Guarani (string)</li>
        </blockquote>   </ul>
       ";
