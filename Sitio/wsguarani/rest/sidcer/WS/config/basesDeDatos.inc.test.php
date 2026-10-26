<?php

// BASES DE DATOS:
/*
 * ConfiguraciÃ³n de conexiÃ³n a las bases de datos: 
 * 
 * Renombrar este archivo a "basesDeDatos.inc.php".
 * Pueden ser varias bases de datos (no se debe repetir el cÃ³digo de unidad acadÃ©mica/identificador de la base como clave del arreglo)
 * El formato es el siguiente (uno debajo del otro):

$bdGuarani['<codigo_de_unidad_academica>'] = array( 
  'tipo_conexion' => 'pdo_guarani', 
  'conexion' => '<nombre del servidor>', 
  'host' => '<ip_del_host>', // Solo PDO
  'service' => '<puerto_del_servicio>', // Solo PDO
  'protocolo' => 'onsoctcp', // Solo PDO
  'bd' => '<nombre de bd>', 
  'usuario' => '<usuario>', 
  'clave' => '<clave>'
);


 *
 * Las bases secundarias son a las que se intentará conectar cuando la BD principal no esté disponible. Para ello se configura el array
 * $secundarios con los datos de conexión (al igual que $bdGuarani). Luego en cada conexión se especifica dentro del índice "secundarios"
 * 'secundarios' => ['sec01', 'sec02'],
 * Ejemplos:
 * 
 */
//'vendor' => 'informix',
//				'database' => 'alumnado_fich',
//				'host' => 'guarani-test',
//				'server' => 'guarani_test',
//				'client_locale' => 'es_es.8859-1',
//				'service' => 9086,
//				'protocol' => 'olsoctcp',
//				'LogonID' => 'jazcoaga',
//				'pwd' => 'gu4r4n1',
//				'EnableScrollableCursors' => 1,
$bdGuarani['FICH'] = array( 
	'tipo_conexion' => 'pdo_guarani', 
	'conexion' => 'guarani_test', 
	'host' => 'guarani-test.intranet', 
	'service' => 9086, 
	'protocolo' => 'olsoctcp', 
	'bd' => 'alumnado_fich', 
	'usuario' => 'jazcoaga', 
	'clave' => 'gu4r4n1');

$bdGuarani['FADU'] = array( 
	'tipo_conexion' => 'pdo_guarani', 
	'conexion' => 'guarani_test', 
	'host' => 'guarani-test.intranet', 
	'service' => 9086, 
	'protocolo' => 'olsoctcp', 
	'bd' => 'alumnado_fadu', 
	'usuario' => 'jazcoaga', 
	'clave' => 'gu4r4n1');

$bdGuarani['FBCB'] = array( 
	'tipo_conexion' => 'pdo_guarani', 
	'conexion' => 'guarani_test', 
	'host' => 'guarani-test.intranet', 
	'service' => 9086, 
	'protocolo' => 'olsoctcp', 
	'bd' => 'alumnado_fbcb', 
	'usuario' => 'jazcoaga', 
	'clave' => 'gu4r4n1');

$bdGuarani['ESS'] = array( 
	'tipo_conexion' => 'pdo_guarani', 
	'conexion' => 'guarani_test', 
	'host' => 'guarani-test.intranet', 
	'service' => 9086, 
	'protocolo' => 'olsoctcp', 
	'bd' => 'alumnado_ess', 
	'usuario' => 'jazcoaga', 
	'clave' => 'gu4r4n1');

$bdGuarani['FCA'] = array( 
	'tipo_conexion' => 'pdo_guarani', 
	'conexion' => 'guarani_test', 
	'host' => 'guarani-test.intranet', 
	'service' => 9086, 
	'protocolo' => 'olsoctcp', 
	'bd' => 'alumnado_fca', 
	'usuario' => 'jazcoaga', 
	'clave' => 'gu4r4n1');

$bdGuarani['FCE'] = array( 
	'tipo_conexion' => 'pdo_guarani', 
	'conexion' => 'guarani_test', 
	'host' => 'guarani-test.intranet', 
	'service' => 9086, 
	'protocolo' => 'olsoctcp', 
	'bd' => 'alumnado_fceb', 
	'usuario' => 'jazcoaga', 
	'clave' => 'gu4r4n1');

$bdGuarani['FCM'] = array( 
	'tipo_conexion' => 'pdo_guarani', 
	'conexion' => 'guarani_test', 
	'host' => 'guarani-test.intranet', 
	'service' => 9086, 
	'protocolo' => 'olsoctcp', 
	'bd' => 'alumnado_fcm', 
	'usuario' => 'jazcoaga', 
	'clave' => 'gu4r4n1');
/*
$bdGuarani['FCJS'] = array( 
	'tipo_conexion' => 'pdo_guarani', 
	'conexion' => 'guarani_test', 
	'host' => 'guarani-test.intranet', 
	'service' => 9086, 
	'protocolo' => 'olsoctcp', 
	'bd' => 'alumnado_fcjs', 
	'usuario' => 'jazcoaga', 
	'clave' => 'gu4r4n1');
*/
$bdGuarani['FHUC'] = array( 
	'tipo_conexion' => 'pdo_guarani', 
	'conexion' => 'guarani_test', 
	'host' => 'guarani-test.intranet', 
	'service' => 9086, 
	'protocolo' => 'olsoctcp', 
	'bd' => 'alumnado_fhuc', 
	'usuario' => 'jazcoaga', 
	'clave' => 'gu4r4n1');

$bdGuarani['FCV'] = array( 
	'tipo_conexion' => 'pdo_guarani', 
	'conexion' => 'guarani_test', 
	'host' => 'guarani-test.intranet', 
	'service' => 9086, 
	'protocolo' => 'olsoctcp', 
	'bd' => 'alumnado_fcv', 
	'usuario' => 'jazcoaga', 
	'clave' => 'gu4r4n1');

$bdGuarani['FIQ'] = array( 
	'tipo_conexion' => 'pdo_guarani', 
	'conexion' => 'guarani_test', 
	'host' => 'guarani-test.intranet', 
	'service' => 9086, 
	'protocolo' => 'olsoctcp', 
	'bd' => 'alumnado_fiq', 
	'usuario' => 'jazcoaga', 
	'clave' => 'gu4r4n1');

$bdGuarani['ISM'] = array( 
	'tipo_conexion' => 'pdo_guarani', 
	'conexion' => 'guarani_test', 
	'host' => 'guarani-test.intranet', 
	'service' => 9086, 
	'protocolo' => 'olsoctcp', 
	'bd' => 'alumnado_ism', 
	'usuario' => 'jazcoaga', 
	'clave' => 'gu4r4n1');


//$bdGuarani['02'] = array( 
//	'tipo_conexion' => 'pdo_guarani', 
//	'conexion' => 'ol_servidor_abogacia', 
//	'host' => '192.168.0.2', 
//	'service' => '1526', 
//	'protocolo' => 'onsoctcp', 
//	'bd' => 'abogacia', 
//	'usuario' => 'usuario', 
//	'clave' => 'clave123456',
//        'secundarios' => ['sec02'],
//);
//
//
//$secundarios = array(
//    'sec02' => array( 
//	'tipo_conexion' => 'pdo_guarani', 
//	'conexion' => 'ol_servidor_abogacia', 
//	'host' => '192.168.0.2', 
//	'service' => '1526', 
//	'protocolo' => 'onsoctcp', 
//	'bd' => 'abogacia', 
//	'usuario' => 'usuario', 
//	'clave' => 'clave123456'
//    ),
//);
