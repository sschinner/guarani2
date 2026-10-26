<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente. Y realiz� la operaci�n deseada por el cliente.
  '1': Error de autenticacion - Credenciales invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion. Implica alguna condici�n de error del lenguaje, que no es gestionada.
  ------------------------------------------------------------------------------------------ */

require_once("adodb/adodb.inc.php");
include("/etc/guarani-webservices/ingreso/ws_parametros.php");
include_once("/etc/guarani-webservices/credenciales/credenciales.php");
include("../general.php");
include_once("../configServer.php");
/* --------------------------------------------------------
  INCLUYO LAS FUNCIONES QUE PUEDE REALIZAR ESTE CLIENTE DE WS
  -------------------------------------------------------- */
//include("../altaAspirante.php");
include("../generaLegajo.php");
//include("../altaRequisito.php");
include("../altaNotasIngreso.php");
include("../estaInscripto.php");
include("../bajaRequisito.php");
include("../becaAlumno.php");
include("../bajaNotasIngreso.php");
include("../rendimientoAcademico.php");
include("../estadoAspirante.php");
include("../insertarAspirante.php");
include("../insertarRequisito.php");






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
                            <li>[fechaIngreso] => (string) (Y-m-d)</li>
                            <li>[fechaEgreso] => (string) (Y-m-d)</li>
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
        </blockquote>  </ul>";


$comentarioAltaNotasIngreso = "<ul>El servicio web realiza la inserción de las notas de los cursos de ingreso.
<li>El Input se describe arriba</li>
            <li>El Output es un JSON que contiene el siguiente objeto:</li> 
<li>stdClass Object(</li>
            <li>[codigoWS] => 0 (integer)</li>
            <li>[mensajeWS] => OK - Servicio Web correcto. (string)</li>
        </ul>  
        <ul> Tipos de codigoWS : mensajeWS:
            <blockquote>
                <li> 0 : OK - Se insertó la nota del curso para el legajo: xxxxxxx </li>
                <li> 0 : OK - Se rectificó la nota del curso para el legajo: xxxxxxx </li>
                <li> 1 : Error de autenticacion - Usuario y contraseña invalidas.</li>
                <li> 2 : Error de parametros - Algun campo es vacio.</li>
                <li> 3 : Error de conexion - La conexion a la base de datos no se pudo establecer correctamente. </li>
                <li> 4 : Error de procedimiento - Algo salio mal dentro de la funcion. </li>
                <li>-1 : La nota del curso de Ingreso no se rectifica por ser igual en fecha y nota a la del legajo: xxxxxxx </li>
                <li>-1 : La nota del curso de Ingreso no se rectifica por encontrarse en acta de exámen/promoción</li>
                <li>-2 : La nota del curso de Ingreso no se migra por ser un reprobado. Legajo: xxxxxxx </li>
                <li>-3 : No existe el curso de Ingreso en la carrera en Guaraní </li>
                <li>-4 : No existe o no tiene generado legajo el aspirante en la carrera </li>
                
            </blockquote> 
        
        </ul>
         <br/>                    
       ";


$comentarioEstaInscripto = "<ul>El servicio web determina si una persona es alumno o esta inscripta para un determinado periodo.
<li>El Input se describe arriba</li>
            <li>El Output es un JSON que contiene el siguiente objeto:</li> 
<li>stdClass Object(</li>
            <li>[codigoWS] => 0 (integer)</li>
            <li>[mensajeWS] => OK - Servicio Web correcto. (string)</li>
            <li>[esAlumno] => (boolean) </li>
            <li>[mensajePr] => (string)</li>
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
       <ul> Tipos de esAlumno : mensajePr
        <blockquote>
            <li> false : La persona no se encuentra inscripta en la carrera</li>
            <li> true : Alumno con legajo ya generado en la carrera. - Periodo de inscripción xxxx</li>
            <li> true : Aspirante a carrera en el período de Inscripción - Periodo de inscripción xxxx</li>
        </blockquote>  </ul>";


$comentarioBajaRequisito = "<ul>El servicio web elimina un requisito previamente ingresado a un determinado aspirante/alumno. En caso de que se elimine un requisito obligatorio para la generación de legajo la condición del alumno puede cambiar a aspirante o legajo condicional según corresponda
<li>El Input se describe arriba</li>
            <li>El Output es un JSON que contiene el siguiente objeto:</li> 
<li>stdClass Object(</li>
            <li>[codigoWS] => 0 (integer)</li>
            <li>[mensajeWS] => OK - Servicio Web correcto. (string)</li>
        </ul>  
        <ul> Tipos de codigoWS : mensajeWS:
            <blockquote>
                <li> 0 : OK - Se dio de baja el requisito: xxxx </li>
                <li> 1 : Error de autenticacion - Usuario y contraseña invalidas.</li>
                <li> 2 : Error de parametros - Algun campo es vacio.</li>
                <li> 3 : Error de conexion - La conexion a la base de datos no se pudo establecer correctamente. </li>
                <li> 4 : Error de procedimiento - Algo salio mal dentro de la funcion. </li>
                <li>-1 : La persona no se encuentra inscripta en esta carrera </li>
                <li>-2 : No existe el requisito xxxx para la persona xxxxxxxx en la carrera xxxxx </li>
                <li>-3 : La persona no tiene el requisito xxxxx presentado. </li>
            </blockquote> 
        </ul>   ";

$comentarioBecaAlumno = "<ul>El servicio web retorna la cantidad de materias aprobadas por exámen y el listado de las mismas para un intervalo de tiempo determinado de un alumno además devuelve el año de ingreso del mismo. En el conteo de materias se cuentan para el caso de optativas/electivas 4 como maximo.
<li>El Input se describe arriba</li>
            <li>El Output es un JSON que contiene el siguiente objeto:</li> 
<li>stdClass Object(</li>
            <li>[codigoWS] => 0 (integer)</li>
            <li>[mensajeWS] => OK - Servicio Web correcto. (string)</li>
            <li>[codigoRetorno] =>  (integer)</li>
            <li>[mensajeRetorno] => (string)</li>
            <li>[cantMaterias] =>  (integer)</li>
            <li>[anioIngreso] => (string)</li>
            <li>[listaMaterias] =></li>
                <blockquote><li>Array([0] => stdClass Object(</li>
                           <blockquote><li> [codigoMateria] => (string)</li>                            
                            <li>[nombreMateria] = (string)</li>
                            <li>[tipoMateria] = (string)</li>
                            <li>[fechaExamen] = (string) d/m/Y </li>                    
                            <li>[formaAprobacion] => (string)</li></blockquote>)</blockquote>
                        <li>)</li></ul>
        <ul> Tipos de codigoWS : mensajeWS:
            <blockquote>
                <li> 0 : OK - Servicio Web correcto.</li>
                <li> 1 : Error de autenticacion - Usuario y contraseña invalidas.</li>
                <li> 2 : Error de parametros - Algun campo es vacio.</li>
                <li> 2 : Error de parametros - Campo fecha inicio/fin incorrecto - Verifique (MM/dd/YYYY)</li>
                <li> 3 : Error de conexion - La conexion a la base de datos no se pudo establecer correctamente. </li>
                <li> 4 : Error de procedimiento - Algo salio mal dentro de la funcion. </li>
            </blockquote> 
        </ul>
         <br/>                    
       <ul> Tipos de codigoRetorno : mensajeRetorno:
        <blockquote>
            <li>  0 : OK - Beca Alumno</li>
            <li>-1 : No hay datos - Nro documento xxxxxxx , Tipo documento xxxx y Pais documento xxxx - Verifique</li>
        </blockquote>  </ul>";



$comentarioBajaNotasIngreso = "<ul>El servicio web elimina la nota de un curso de ingreso a un determinado alumno.
<li>El Input se describe arriba</li>
            <li>El Output es un JSON que contiene el siguiente objeto:</li> 
<li>stdClass Object(</li>
            <li>[codigoWS] => 0 (integer)</li>
            <li>[mensajeWS] => OK - Servicio Web correcto. (string)</li>
        </ul>  
        <ul> Tipos de codigoWS : mensajeWS:
            <blockquote>
                <li> 0 : OK - La nota del curso de Ingreso se elimina por ser un reprobado. Legajo: xxxxxxx </li>
                <li> 1 : Error de autenticacion - Usuario y contraseña invalidas.</li>
                <li> 2 : Error de parametros - Algun campo es vacio.</li>
                <li> 3 : Error de conexion - La conexion a la base de datos no se pudo establecer correctamente. </li>
                <li> 4 : Error de procedimiento - Algo salio mal dentro de la funcion. </li>
                <li>-2 : No existe nota del curso de ingreso cargada. Legajo: xxxxxxx </li>
                <li>-3 : No existe el curso de Ingreso en la carrera en Guaraní </li>
                <li>-4 : No existe o no tiene generado legajo el aspirante en la carrera </li>
            </blockquote> 
        </ul>   ";

$comentarioEstadoAspirante = "<ul>El servicio web retorna los requisitos presentados y los cursos de ingreso migrados de un determinado aspirante/alumno.
<li>El Input se describe arriba</li>
            <li>El Output es un JSON que contiene el siguiente objeto:</li> 
<li>stdClass Object(</li>
            <li>[codigoWS] => 0 (integer)</li>
            <li>[mensajeWS] => OK - Servicio Web correcto. (string)</li>
           
            <li>[requisitos] =></li>
                <blockquote><li>Array([0] => stdClass Object(</li>
                    <blockquote><li> [requisito] => (string)</li>                            
                    <li>[nombre] => (string)</li> 
                    <li>[fecha] => (string) d/m/Y</li> 
                    <li>[exceptuado] => (string)</li></blockquote>)</blockquote>
                   
             <li>[cursosIngreso] =></li>
                <blockquote><li>Array([0] => stdClass Object(</li> 
                    <blockquote><li> [curso] => (string)</li>                            
                    <li>[nombre] => (string)</li> 
                    <li>[fecha] => (string) d/m/Y</li> 
                    <li>[nota] => (float)</li> 
                    <li>[forma_aprobacion] => (float)</li>
                    <li>[id_curso_bienestar] => null</li></blockquote>)</blockquote>
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
       ";

$comentarioInsertarAspirante = "<ul>El servicio web inserta un aspirante con los datos minimos necesarios.

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
        </ul>   
        <ul> Tipos de codigoRetorno : mensajeRetorno
            <blockquote>
                <li> 0 : OK aspirante inscripto correctamente </li>
                <li> -1 : No existe un per�odo de inscripci�n a carreras vigente para el a�o academico [a�o academico] </li>
                <li> -2 : La persona posee una inscripci�n rechazada a la carrera en el a�o acad�mico [a�o academico] </li>
                <li> -3 : La persona ya es alumno en esta carrera. Ingreso a�o acad�mico [a�o ingreso] </li>
                <li> -4 : Carrera [carrera] inexistente - Verifique. </li>
                <li> -5 : La persona ya es Aspirante en esta Carrera. Ingreso a�o academico distinto al [a�o_academico] </li>
            </blockquote> 
        </ul> ";

$comentarioInsertarRequisito = "<ul>El servicio web inserta un requisito de ingreso.

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
        </ul>   
        <ul> Tipos de codigoRetorno : mensajeRetorno
            <blockquote>
                <li> 0 : OK - Requisito insertado correctamente </li>
                <li> -1 : La persona no se encuentra inscripta en esta carrera </li>
                <li> -2 : La persona ya posee cargado el requisito de ingreso </li>
                <li> -3 : El requisito es inexistente </li>
                <li> -4 : La persona se encuentra rechazada en esta carrera </li>
            </blockquote> 
        </ul> ";

?>
