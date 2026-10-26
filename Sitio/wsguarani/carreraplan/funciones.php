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
include_once("/etc/guarani-webservices/credenciales/credenciales.php");
//include_once("/etc/guarani-webservices/carreraplan/ws_parametros.php");
include_once("../general.php");

include_once("../configServer.php");

/* --------------------------------------------------------
INCLUYO LAS FUNCIONES QUE PUEDE REALIZAR ESTE CLIENTE DE WS
-------------------------------------------------------- */
include_once("../materiasCarreraPlan.php");
include_once("../carrerasUA.php");

$comentarioMateriaCarreraPlan = "<ul> El servicio web retorna las materias de una carrera para un determinado plan y versión de la misma. 
<li>El Input se describe arriba</li>
            <li>El Output es un JSON que contiene el siguiente objeto:</li>     
<li>stdClass Object (</li>
            <li>[codigoWS] => 0 (integer)</li>
            <li>[mensajeWS] => OK - Servicio Web correcto. (string)</li>
            <li>[codigoRetorno] => true (boolean) </li>
            <li>[mensajeRetorno] => OK - Datos Materias-Carrera-Plan (string)</li>
            <li>[materias] => </li>
            <blockquote><li>Array([0] => stdClass Object(</li>
                        <blockquote><li>[codigoMateria] => (string)</li>
                        <li>[nombreMateria] = (string)</li>
                        <li>[tipoMateria] = (string) </li>
                        <li>[horasSemanales] = (integer) </li>
                        <li>[cargaHoraria] = (integer) </li>
                        <li>[valorMateria] = (integer) </li>
                        <li>[promediable] = (string) </li>
                        <li>[obligatoria] => (string)</li></blockquote>)</blockquote>
       <li>)</li></ul>
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
            <li>  true : OK - Datos Materias-Carrera-Plan </li>
            <li> false : No existe datos para la carrera-plan-versión solicitado </li>
            <li> false : No posee permisos para consultar datos de la unidad académica</li>
            
        </blockquote>    
        </ul>";

$comentarioCarrerUA = "<ul> El servicio web retorna las carreras que sean gestionadas en una determinada unidad acádemica. 
<li>El Input se describe arriba</li>
            <li>El Output es un JSON que contiene el siguiente objeto:</li>     
<li>stdClass Object (</li>
            <li>[codigoWS] => 0 (integer)</li>
            <li>[mensajeWS] => OK - Servicio Web correcto. (string)</li>
            <li>[codigoRetorno] => true (boolean) </li>
            <li>[mensajeRetorno] => OK - Datos Carreras UA (string)</li>
            <li>[carreras] => </li>
            <blockquote>
                <li>Array([0] => stdClass Object(</li>
                    <blockquote>
                        <li>[codigoCarrera] => (string)</li>
                        <li>[nombreCarrera] = (string) </li>
                        <li>[planCarrera] = (string) </li>
                        <li>[nombrePlan] = (string) </li>
                        <li>[versionPlan] = (string) </li>
                        <li>[estado]  = (string) </li>
                        <li>[tipoTitulo] = (integer)</li>
                        <li>[tipoCarrera] => (string)</li>
                        <li>[alcanceTitulo] => (string)</li>
                            <blockquote>
                                <li>- Grado</li>
                                <li>- Doctorado</li>
                                <li>- Maestr�a</li>
                                <li>- Especializaci�n</li>
                                <li>- Pregrado</li>
                                <li>- Competencias</li>
                                <li>- Terciario no Universitario</li>
                                <li>- Post�tulo</li>
                                <li>- Ciclo cumplido</li>
                            </blockquote>
                    </blockquote>)
            </blockquote>
       <li>)</li></ul>
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
            <li>  true : OK - Datos Carreras UA</li>
            <li> false : No existe datos de carreras para la unidad acádemica solicitada </li>
            <li> false : No posee permisos para consultar datos de la unidad académica</li>
            
        </blockquote>    
        </ul>";
