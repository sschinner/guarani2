<?php

define('CONFIG', dirname(__FILE__).'/config.inc.php');
define('INTERFACE_EXCEPCION_HTTP', dirname(__FILE__).'/../lib/Excepciones/HttpExceptionInterface.php');
define('CLASE_EXCEPCION_CONEXION', dirname(__FILE__).'/../lib/Excepciones/PDOConexionException.class.php');
define('CLASE_EXCEPCION_CONSULTA', dirname(__FILE__).'/../lib/Excepciones/PDOConsultaException.class.php');
define('CLASE_EXCEPCION_PERMISO', dirname(__FILE__).'/../lib/Excepciones/PermisoException.class.php');
define('CLASE_BD', dirname(__FILE__).'/../lib/BD.class.php');
define('PEDIDO_HTTP', dirname(__FILE__).'/../lib/PedidoHTTP.class.php');
define('CLASES_CONSULTAS', dirname(__FILE__).'/../clases/');
define('CLASE_USUARIO', dirname(__FILE__).'/../lib/Usuario.class.php');
define('CLASE_RESPUESTA', dirname(__FILE__).'/../lib/Respuestas/AbstractRespuesta.class.php');
define('CLASE_JSON_RESPUESTA', dirname(__FILE__).'/../lib/Respuestas/JSONRespuesta.class.php');
define('CLASE_JSON_DATOS_CRUDOS_RESPUESTA', dirname(__FILE__).'/../lib/Respuestas/JSONDatosCrudosRespuesta.class.php');
define('CLASE_ACCION', dirname(__FILE__).'/../lib/Accion.class.php');
define('INTERFACE_CACHE', dirname(__FILE__).'/../lib/InterfaceCache.php');
define('CLASE_CACHE_APC', dirname(__FILE__).'/../lib/CacheAPC.class.php');
define('CLASE_LOG', dirname(__FILE__).'/../lib/Log.class.php');

function __autoload($class_name) {
    include CLASES_CONSULTAS.$class_name . '.class.php';      
}
