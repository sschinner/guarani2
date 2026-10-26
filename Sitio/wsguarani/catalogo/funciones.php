<?php

/* -----------------------------------------------------------------------------------------
CODIGO DE ERRORES DE WEBSERVICES:
'0': OK - La funcion se ejecuto correctamente.
'1': Error de autenticacion - Usuario y contrase�a invalidas.
'2': Error de parametros - Algun campo es vacio.
'3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
'4': Error de procedimiento - Algo salio mal dentro de la funcion.
------------------------------------------------------------------------------------------*/

require_once("../alumno/adodb/adodb.inc.php");

include_once("/etc/guarani-webservices/credenciales/credenciales.php");
//include_once("/etc/guarani-webservices/carreraplan/ws_parametros.php");
include_once("../general.php");
include_once("../configServer.php");


/* --------------------------------------------------------
INCLUYO LAS FUNCIONES QUE PUEDE REALIZAR ESTE CLIENTE DE WS
-------------------------------------------------------- */
include_once("../catalogos.php");

$comentarioCatalogos='<ul>El servicio web retorna datos de los catalogos de colegios secundarios, localidades, depto partidos, provincias y paises. 
    <li>El Input se describe arriba, donde tiene la particularidad que la varible filtro acepta valores:
        <ol> <li><b>colegiosSecundarios, localidades, dpto_partidos, provincias y paises</b></li></ol>
    <li>El Output es un JSON que contiene el siguiente objeto:</li>
    <li>stdClass Object(</li>
            <li>[codigoWS] =>  (integer)</li>
            <li>[mensajeWS] =>   (string)</li>
            <li>[codigoRetorno] =>  (integer)</li>
            <li>[mensajeRetorno] => (string)</li>
            <li>[catalogo] =></li>
             <ol><li> Si filtro = colegiosSecundarios</li>
                <blockquote><li>Array([0] => stdClass Object(</li>                 
                      <blockquote><li>  [codigo] => string </li>
                      <li> [nombre] => string </li>
                      <li>[localidad] => string </li></blockquote>)</blockquote>
             </ol>
             <ol><li> Si filtro = localidades</li>           
                        <blockquote><li>Array([0] => stdClass Object(</li>                 
                      <blockquote><li>  [localidad] => string </li>
                      <li>  [nombre] => string </li>
                      <li>[dpto_partido] => string </li></blockquote>)</blockquote>
            </ol>
            <ol><li> Si filtro = dpto_partidos</li>           
                      <blockquote><li>Array([0] => stdClass Object(</li>                 
                      <blockquote><li>  [dpto_partido] => string </li>
                      <li>  [nombre] => string </li>
                      <li>[provincia] => string </li></blockquote>)</blockquote>
            </ol>
            <ol><li> Si filtro = provincias</li>           
                      <blockquote><li>Array([0] => stdClass Object(</li>                 
                      <blockquote><li>  [provincias] => string </li>
                      <li>  [nombre] => string </li>
                      <li>[pais] => string </li></blockquote>)</blockquote>
            </ol>
            <ol><li> Si filtro = paises</li>           
                      <blockquote><li>Array([0] => stdClass Object(</li>                 
                      <blockquote><li>  [pais] => string </li>
                      <li>[nombre] => string </li></blockquote>)</blockquote>
            </ol>

            <li>)</li></ul>
             <br/>
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
            <li>  0 : OK - (Catalogo Colegios Secundarios - Catalogo Localidades - Catalogo Dpto Partidos - Catalogo Provincias - Catalogo Paises)</li>
            <li>-1 : No se encontro el filtro solicitado - Filtros disponibles: "colegiosSecundarios","localidades","dpto_partidos","provincias","paises" </li>
           
        </blockquote>  </ul>';