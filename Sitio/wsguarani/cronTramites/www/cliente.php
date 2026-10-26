<?php

// Includes necesarios para el funcionamiento
include_once(dirname(__DIR__) . '../../../libraries/adodb/adodb.inc.php');
include_once(dirname(__DIR__) . '../../../libraries/nusoap/lib/nusoap.php');

// Seteo parametros de conexion
// $wsdl = 'https://servicios.unl.edu.ar/test/guarani/ws/cronTramites/www/index.php?wsdl';
// $wsdl = 'https://servicios.unl.edu.ar/integracion/guarani/ws/cronTramites/www/index.php?wsdl';
$wsdl = 'http://toba-02:8888/291/wsguarani/cronTramites/www/index.php?wsdl';
$client = new nusoap_client($wsdl, 'wsdl');
// $client->setCredentials("wstramites", "WST4mit3s", "basic");
$client->setCredentials("wstramites", "wstramites", "basic");

$param = array("expediente" => 'FADU-0870408-17',
    "urlCertificado" => 'Otro path chaucha',
	"tipoNotificacion" => 'P');
$salida = $client->call('notificarUrlCertificado', $param);

/*$param = array("expediente" => 'FADU-0870408-17',
    "motivoRechazo" => 'Quiero rechazarlo porque SI');
$salida = $client->call('retrocederValidacion', $param);*/
$err = $client->getError();
if ($err) {
    echo 'Constructor error ' . $err;
}
$resultado = json_decode($salida);
var_dump($resultado);

