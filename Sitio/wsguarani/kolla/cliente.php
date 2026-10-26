<?php

require_once("adodb/adodb.inc.php");
require_once('funciones.php');
require_once('../nusoap/lib/nusoap.php');

//$wsdl = "http://guarani3w-dev.intranet/wsguarani/kolla?wsdl"; //el nombre del archivo servidor
$wsdl = WSDLG."kolla?wsdl"; //el nombre del archivo servidor

$client = new nusoap_client($wsdl, 'wsdl');
$client->setCredentials("wskolla", "WSK0ll4", "basic");

$err = $client->getError();
if ($err) {
    // error if any
    echo 'Constructor error' . $err;
}

// Completar los datos correspondientes para prueba

$ua = 'FICH';
$tipodoc = '0';
$nrodoc = '30171912';
$codigotit = '285';
$fechafinenc = '20-02-2014 20:50';
$nrotransaccion = '1500';

$param = array('ua' => $ua, 'tipodoc' => $tipodoc, 'nrodoc' => $nrodoc, 'codigotit' => $codigotit,
    'fechafinenc' => $fechafinenc, 'nrotransaccion' => $nrotransaccion);
$resultado = $client->call('encuestaCompleta', $param, URI."kolla/index.php?wsdl", URI."kolla/index.php?wsdl/encuestaCompleta");

$resp = json_decode($resultado);
print_r($resp);
die;
?>
