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

$bdGuarani['01'] = array( 
	'tipo_conexion' => 'pdo_guarani', 
	'conexion' => 'ol_servidor_medicina', 
	'host' => '192.168.0.1', 
	'service' => '1526', 
	'protocolo' => 'onsoctcp', 
	'bd' => 'ciencias_medicas', 
	'usuario' => 'usuario', 
	'clave' => 'clave123456');


$bdGuarani['02'] = array( 
	'tipo_conexion' => 'pdo_guarani', 
	'conexion' => 'ol_servidor_abogacia', 
	'host' => '192.168.0.2', 
	'service' => '1526', 
	'protocolo' => 'onsoctcp', 
	'bd' => 'abogacia', 
	'usuario' => 'usuario', 
	'clave' => 'clave123456',
        'secundarios' => ['sec02'],
);


$secundarios = array(
    'sec02' => array( 
	'tipo_conexion' => 'pdo_guarani', 
	'conexion' => 'ol_servidor_abogacia', 
	'host' => '192.168.0.2', 
	'service' => '1526', 
	'protocolo' => 'onsoctcp', 
	'bd' => 'abogacia', 
	'usuario' => 'usuario', 
	'clave' => 'clave123456'
    ),
);