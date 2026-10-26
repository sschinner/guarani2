<?php

// USUARIOS: 
/*
 * 
 * $usuarios['<NOMBRE_DE_USUARIO>'] = '<CLAVE>'
 * 
 * Renombrar este archivo a "usuarios.inc.php"
 * 
 * ** Restringir el acceso del usuario solo a ciertas bases:
 * Podrá utilizar todos los servicios a los que tenga permiso, pero solo sobre ciertas bases de datos (las definidas en $usuarios_ua). Si no se define, por defecto, tiene acceso a todas.
 * Para identificar las bases se utiliza el código de unidad académica o id de base, definido en basesDeDatos.inc.php.
 * 
 * $usuarios_ua['<usuario>'] = array('<codigo_de_unidad_academica_1>','<codigo_de_unidad_academica_2>');
 * 
 * Por ejemplo, el usuario 'usuario_1' solo debe poder consultar los datos de la unidad académica 01 (definida en basesDeDatos.inc.php)
 * 
 * $usuarios_ua['usuario_1'] = array('01');
 */ 

$usuarios['ws'] = '123456';
$usuarios['sicer'] = '123456';
$usuarios['sube'] = '123456';


