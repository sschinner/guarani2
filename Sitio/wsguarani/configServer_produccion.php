<?php
/**
* PRODUCCION 
*/

//config server
define("NS","https://servicios.unl.edu.ar/guarani/ws/");
//config cliente
define("WSDLG","https://servicios.unl.edu.ar/guarani/ws/");
define("URI","uri:https://servicios.unl.edu.ar/guarani/ws/");

//url ws siguv
define("URL_AUTENTICA_SIGUV_REST", "https://www.unlvirtual.edu.ar/campusvirtual/ws/autenticarUsuario?");
define("URL_DNIPAISTIPO_SIGUV_REST", 'https://www.unlvirtual.edu.ar/campusvirtual/ws/validarUsuarioHefesto?');

/*
** INFORMIX 
*/
define("HOST", "guarani.intranet");
define("SERVER","rectorado_csm");
define("USUARIOCONEXION",'internet');
define("PASSWORDCONEXION",'#3nt2rn2t*');
define("PUERTO","9086");

/*
** CEMED
*/
define("HOSTCEMED","guarani.intranet");
define("SERVERCEMED","rectorado_csm");
define("USUARIOCONEXIONCEMED",'internet');
define("PASSWORDCONEXIONCEMED",'#3nt2rn2t*');
define("PUERTOCEMED","9086");

/*
** POSGRES
*/
define("USUARIOCONEXIONPOSGRES",'guarani3_owner');
define("PASSWORDCONEXIONPOSGRES",'R3ow.9raC');
define("PUERTOPOSGRES","5432");
define("HOSTPOSGRES", "guarani3db.intranet");
define("DBPOSGRES", "guarani3_db");

/*
** Auditoria
*/
define("DBAUDITORIA_NAME", "guarani3_auditoriadb");
define("DBAUDITORIA_HOST", "<host_db_auditoria>");
define("DBAUDITORIA_PORT", "5432");
define("DBAUDITORIA_USER", "<rattic_user>");
define("DBAUDITORIA_PASS", "<rattic_user_pass>");

/*
** CONSTANTES DE RETORNO
*/
define("CODIGO_OK",0);
define("CODIGO_ERROR_AUTENTICACION",1);
define("CODIGO_ERROR_PARAMETROS",2);
define("CODIGO_ERROR_CONEXION",3);
define("CODIGO_ERROR_PROCEDIMIENTO",4);

define("MENSAJE_OK", "OK - Servicio Web correcto.");
define("MENSAJE_ERROR_AUTENTICACION", "Error de autenticacion - Usuario y contraseña invalidas.");
define("MENSAJE_ERROR_PARAMETROS", "Error de parametros - Algun campo es vacio.");
define("MENSAJE_ERROR_CONEXION", "Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.");
define("MENSAJE_ERROR_PROCEDIMIENTO", "Error de procedimiento - Algo salio mal dentro de la funcion.");
?>
