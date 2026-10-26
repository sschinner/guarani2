<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Usuario y contrase?a invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */

require_once("adodb/adodb.inc.php");
include_once("/etc/guarani-webservices/alumno/ws_parametros.php");
include_once("/etc/guarani-webservices/credenciales/credenciales.php");
include_once("../general.php");
include_once("../configServer.php");
//include_once("../etc/guarani-webservices/credenciales/credenciales.php");

/* --------------------------------------------------------
  INCLUYO LAS FUNCIONES QUE PUEDE REALIZAR ESTE CLIENTE DE WS
  -------------------------------------------------------- */
include("../rendimientoAcademico.php");
include("../datosCensalesAlumno.php");
include("../autenticarAlumno.php");
include("../historiaAcademicaAlumno.php");
include("../estadoAlumno.php");
include("../carrerasAlumno.php");
include("../insertaDatosCensales.php");
include("../validarRequisitosDiploma.php");
include("../solicitudesTitulo.php");
include("../urlSolicitud.php");
//include("../catalogo.php");




/* --------------------------
  Comentarios de servicios
  -------------------------- */
$comentarioHistoriaAcademica = "<ul> El servicio web retorna la historia academica de un determinado alumno. 
<li>El Input se describe arriba</li>
            <li>El Output es un JSON que contiene el siguiente objeto:</li>     
<li>stdClass Object (</li>
            <li>[codigoWS] => 0 (integer)</li>
            <li>[mensajeWS] => OK - Servicio Web correcto. (string)</li>
            <li>[codigoRetorno] => 0 (integer)</li>
            <li>[mensajeRetorno] => OK - Datos Historia Academica Alumno (string)</li>
            <li>[historia] => </li>
            <blockquote><li>Array([0] => stdClass Object(</li>
                            <blockquote><li>[materia] => (string)</li>
                            <li>[nombreMateria] => (string)</li>
                            <li>[fecha] => (string )(Y-m-d)</li>
                            <li>[nota] => (float)</li>
                            <li>[resultado] => (string)</li>
                            <li>[acta] => (string)</li>
                            <li>[tipoActa] => (string)</li>
                            <li>[tipoExamen] => (string)</li>
                            <li>[nroResolucion] => (string)</li></blockquote>)</blockquote>
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
            <li>  0 : OK - Historia Académica</li>
            <li>  0 : El alumno no posee historia académica en la carrera xxxxx</li>
            <li>-1 : No hay datos para Tipo xx  Documento xxxxxxxx , Pais xx y Carrera xxxxx - Verifique</li>
            <li>-5 : No posee permisos para consultar datos de la unidad académica</li>
        </blockquote>    
        </ul>";

$comentarioRendiminetoAcademico = "<ul>El servicio web retorna el rendimiento academico de un determinado alumno.
<li>El Input se describe arriba</li>
            <li>El Output es un JSON que contiene el siguiente objeto:</li> 
<li>stdClass Object(</li>
            <li>[codigoWS] => 0 (integer)</li>
            <li>[mensajeWS] => OK - Servicio Web correcto. (string)</li>
            <li>[codigoRetorno] => 0 (integer)</li>
            <li>[mensajeRetorno] => OK - Datos Rendimiento Academico (string)</li>
            <li>[carreras] =></li>
                <blockquote><li>Array([0] => stdClass Object(</li>
                           <blockquote><li> [unidadAcademica] => (string)</li>
                            <li>[carrera] => (string)</li>
                            <li>[calidadAlu] => (string)</li>
                            <li>[fechaIngreso] => (string )(Y-m-d)</li>
                            <li>[fechaEgreso] => (string )(Y-m-d)</li>
                            <li>[cantMatAprob] => integer</li>
                            <li>[cantMatReprob] => integer</li>
                            <li>[cantMatPlan] => integer</li>
                            <li>[promedioAplazo] => float</li>
                           <li> [promedioSinAplazo] => float</li>
                            <li>[nombreCarrera] => (string)</li>
                           <li> [regular] => (string)</li>
                            <li>[descripcionCalidad] => (string)</li>
                            <li>[nombreTitulo] => (string)</li>
                            <li>[egresado] => (string)</li>
                            <li>[tipoTitulo] => (integer)</li></blockquote>)</blockquote>
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
            <li>  0 : OK - Datos Rendimiento Academico</li>
            <li>-1 : No hay datos para Tipo xx  Documento xxxxxxxx , Pais xx y Carrera xxxxx</li>
            <li>-5 : No posee permisos para consultar datos de la unidad académica</li>
            <li>  4 : Erorr de procedimiento </li>
        </blockquote>   </ul>";

$comentarioDatosCensalesAlumno = '<ul>El servicio web retorna los datos censales de los alumnos. 
    <li>El Input se describe arriba, donde tiene la particularidad que la varible filtro acepta valores:
        <ol> <li><b>carrera, usuario, documento, ingreso y reinscripcion</b></li>
        <li>Solo si filtro es <b>documento</b>, valor2 y valor3 deben completarse con tipo documento y pais documento respectivamente caso contrario van vacios</li></ol>
    <li>El Output es un JSON que contiene el siguiente objeto:</li>
    <li>stdClass Object(</li>
            <li>[codigoWS] => 0 (integer)</li>
            <li>[mensajeWS] => OK - Servicio Web correcto. (string)</li>
            <li>[codigoRetorno] => 0 (integer)</li>
            <li>[mensajeRetorno] => OK - Datos Censales Alumno (string)</li>
            <li>[datos] =></li>
                <blockquote><li>Array([0] => stdClass Object(</li>                 
                      <blockquote><li>  [tipoDocumento] => integer </li>
                        <li>[nroDocumento] => string </li>
                        <li>[fechaNacimiento] => date </li>
                        <li>[apellido] => string </li>
                        <li>[nombre] => string </li>
                        <li>[sexo] => integer </li>
                        <li>[localidadProc] => string </li>
                        <li>[cpProc] => integer </li>
                        <li>[localidadRes] => string </li>
                        <li>[cpRes] => integer </li>
                        <li>[direccionRes] => string </li>
                        <li>[nroRes] => integer </li>
                        <li>[pisoRes] => integer </li>
                        <li>[deptoRes] => string </li>
                        <li>[unidad] => string </li>
                        <li>[telefono] => string </li>
                        <li>[email] => string </li>
                        <li>[nroCelular] => string </li>
                        <li>[compCelular] =>  string </li>
                        <li>[paisDocumento] => string </li>
                        <li>[provincia_lectivo] = integer  </li>
                        <li>[pais_lectivo] = integer  </li>
                        <li>[provincia_proc] = integer  </li>
                        <li>[pais_proc] = integer  </li>
                        <li>[telefono_familiar] = string  </li>
                        <li>[procedencia_calle] = string  </li>
                        <li>[procedencia_numero] = string </li>
                        <li>[tipoTitulo] => integer </li></blockquote>)</blockquote>
                        <li>)</li>
            </li></ul>
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
            <li>  0 : OK - Datos Rendimiento Academico</li>
            <li>-1 : No hay datos para Tipo xx  Documento xxxxxxxx , Pais xx y Carrera xxxxx</li>
            <li>-2 : El filtro indicado xxxxxx no se reconoce - Valores posibles: carrera, usuario, documento, ingreso y reinscripcion </li>
            <li>-5 : No posee permisos para consultar datos de la unidad académica</li>
            <li>  4 : Error de procedimiento </li>
        </blockquote>   </ul>
      ';





$comentarioAutenticarAlumno = "<br>
	<b>DEPRECADO - Utilizar alumno/v2/autenticarAlumno</b>
	<ul>El servicio web determina si una persona es usuario del sistema Guarani. 
            <li>El Input se describe arriba</li>
            <li>El Output es un JSON que contiene el siguiente objeto:</li>    
            <li>stdClass Object(</li>
            <li>[codigoWS] => 0 (integer)</li>
            <li>[mensajeWS] => OK - Servicio Web correcto. (string)</li>
            <li>[codigoRetorno] => true (boolean)</li>
            <li>[mensajeRetorno] => Es usuario guarani  (string)</li>
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
            <li>  true : Es usuario guarani  (string)</li>
            <li> false : No es usuario guarani  (string)</li>
          
        </blockquote>   </ul>
       ";

$comentarioEstadoAlumno = "<ul>El servicio web retorna el estado de los alumnos.
    <li>El Input se describe arriba, donde tiene la particularidad que la varible filtro acepta valores:
        <ol> <li><b>carrera, documento, ingreso y reinscripcion</b></li>
        <li>Solo si filtro es <b>documento</b>, valor2 y valor3 deben completarse con tipo documento y pais documento respectivamente caso contrario van vacios</li></ol>
    <li>El Output es un JSON que contiene el siguiente objeto:</li>
    <li>stdClass Object(</li>
    
         <li>[codigoWS] => 0 (integer)</li>
            <li>[mensajeWS] => OK - Servicio Web correcto. (string)</li>
            <li>[codigoRetorno] => 0 (integer)</li>
            <li>[mensajeRetorno] => OK - Estado Alumno (string)</li>
            <li>[datos] =></li>
                <blockquote><li>Array([0] => stdClass Object(</li>               
                       <blockquote> <li>['carrera'] = (string)</li> 
                        <li>['nombreCarrera'] => (string)</li>
                        <li>['tipoDocumento'] =>(int)</li> 
                        <li>['nroDocumento'] => (string)</li>
                        <li>['fechaIngreso'] => (string)</li> 
                        <li>['calidad'] => (string)</li> 
                        <li>['situacionAlumno'] => (string)</li> 
                        <li>['sancionesActuales'] => (int)</li> 
                        <li>['alumnoRegular'] => (boolean)</li> 
                        <li>['egresado'] => (boolean)</li> 
                        <li>['ua'] => (string)</li> 
                        <li>['tipoTitulo'] => (int)</li>
                        <li>['planCarrera'] => (string)</li>
                        <li>['nombrePlan'] => (string)</li>
                        </blockquote>)
                </blockquote>
                        <li>)</li>
        </li></ul>
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
            <li>  0 : OK - Estado Alumno</li>
            <li>-1 : No hay datos para Tipo xx  Documento xxxxxxxx , Pais xx y Carrera xxxxx</li>
            <li>-2 : El filtro indicado xxxxxx no se reconoce - Valores posibles: carrera, documento, ingreso y reinscripcion </li>
            <li>-5 : No posee permisos para consultar datos de la unidad académica</li>
            <li>  4 : Erorr de procedimiento </li>
        </blockquote>   </ul>";


$comentarioCarrerasAlumno = "<ul>El servicio web retorna las carreras en las cuales se encuentra un determinado alumno, sean de grado, posgrado, integracion, externos, etc. 
    <li>El Input se describe arriba</li>
            <li>El Output es un JSON que contiene el siguiente objeto:</li> 
<li>stdClass Object(</li>
            <li>[codigoWS] => 0 (integer)</li>
            <li>[mensajeWS] => OK - Servicio Web correcto. (string)</li>
            <li>[codigoRetorno] => 0 (integer)</li>
            <li>[mensajeRetorno] => OK - Datos Carrera Alumno (string)</li>
            <li>[carreras] =></li>
               <blockquote><li>Array([0] => stdClass Object(</li>
                             <blockquote><li>[unidadAcademica] => (string)</li>
                            <li>[carrera] => (string)</li>
                            <li>[nombreCarrera] => (string)</li>
                            <li>[calidadAlu] => (string)</li>
                            <li>[tipoIngreso] => (string)</li>
                            <li>[descrcipcionTipoIngreso] => (string)</li>
                            <li>[tipoTitulo] => (integer)</li></blockquote>)</blockquote>
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
            <li>  0 : OK - Carreras Alumno</li>
            <li>-1 : No hay datos para Tipo xx  Documento xxxxxxxx , Pais xx y Carrera xxxxx</li>
            
        </blockquote>   </ul>";

$comentarioInsertaDatosCensales = "<ul>El servicio web inserta o actualiza los datos censales.

            <li>El Output es un JSON que contiene el siguiente objeto:</li> 
<li>stdClass Object(</li>
            <li>[codigoWS] => 0 (integer)</li>
            <li>[mensajeWS] => OK - Servicio Web correcto. (string)</li>
        </ul>  
        <ul> Tipos de codigoWS : mensajeWS
            <blockquote>
                <li> 0 : OK - Servicio Web correcto.</li>
                <li> 1 : Error de autenticacion - Usuario y contraseña invalidas.</li>
                <li> 2 : Error de parametros - Algun campo es vacio.</li>
                <li> 3 : Error de conexion - La conexion a la base de datos no se pudo establecer correctamente. </li>
                <li> 4 : Error de procedimiento - Algo salio mal dentro de la funcion. </li>
            </blockquote> 
        </ul>  ";
