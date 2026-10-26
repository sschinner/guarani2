<?php

require_once("adodb/adodb.inc.php");
require_once('funciones.php');
require_once('../nusoap/lib/nusoap.php');

//$wsdl="http://guarani3w-dev.intranet/wsguarani/wifi?wsdl"; //el nombre del archivo servidor

$wsdl=WSDLG."wifi?wsdl"; //el nombre del archivo servidor
//$wsdl = 'https://servicios.unl.edu.ar/guarani/ws/wifi?wsdl';
$client = new nusoap_client($wsdl, 'wsdl');
$client->setCredentials("wswifi", "WSW1F1", "basic");

$err = $client->getError();
if ($err) {
    // error if any
    echo 'Constructor error' . $err;
}

// Completar los datos correspondientes para prueba
$resp = array();


//$ua = 'CU-RA';
//$tipotitulo = '1';
//$tipodoc = '0';
//$nrodoc = '37713002';
////$clave = '';
//$clave = md5('37713');
////$clave = 'cualquierclave';
//
//$param = array('ua' => $ua, 'tipotitulo' => $tipotitulo, 'tipodoc' => $tipodoc, 'nrodoc' => $nrodoc, 'clave' => $clave);
//$salida = $client->call('autenticarUsuarioWifi', $param, URI."wifi/index.php?wsdl", URI."wifi/index.php?wsdl/autenticarUsuarioWifi");
//
//$resultado = json_decode($salida);
//
//$resp[]= $resultado;



$ua = 'FIQ';
$tipotitulo = '0';
$tipodoc = '0';
$nrodoc = '32186354';
//$clave = '';
$clave = md5('99336');//'7ed77353770c97546731bc60651b5662';
//$clave = 'cualquierclave';

$param = array('ua' => $ua, 'tipotitulo' => $tipotitulo, 'tipodoc' => $tipodoc, 'nrodoc' => $nrodoc, 'clave' => $clave);
$salida = $client->call('autenticarUsuarioWifi', $param, URI."wifi/index.php?wsdl", URI."wifi/index.php?wsdl/autenticarUsuarioWifi");

$resultado = json_decode($salida);

$resp[]= $resultado;

print_r($resp);
?>
