<?php

ob_start('limpiar');

function limpiar($buffer) {
    return trim($buffer);
}

//require_once("adodb/adodb.inc.php");
require_once('../nusoap/lib/nusoap.php');

include("funciones.php");

$server = new soap_server;

$targetNameSpace = 'guarani/ws/kolla';
$server->configurewsdl('ApplicationServices', $targetNameSpace,false,'rpc', 'http://schemas.xmlsoap.org/soap/http', $targetNameSpace);
$server->wsdl->schematargetnamespace = $targetNameSpace;


$server->register('encuestaCompleta', array('ua' => 'xsd:string', 'tipodoc' => 'xsd:string', 'nrodoc' => 'xsd:string', 'codigotit' => 'xsd:string', 'fechafinenc' => 'xsd:string', 'nrotransaccion' => 'xsd:string'), array('return' => 'xsd:string'),$targetNameSpace, false, false, 'literal', 'N/A');

$HTTP_RAW_POST_DATA = isset($HTTP_RAW_POST_DATA) ? $HTTP_RAW_POST_DATA : '';

$server->service($HTTP_RAW_POST_DATA);
ob_end_flush();
exit;
?>
