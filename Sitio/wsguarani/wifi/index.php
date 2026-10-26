<?php

ob_start('limpiar');

function limpiar($buffer) {
    return trim($buffer);
}

//require_once("adodb/adodb.inc.php");
require_once('../nusoap/lib/nusoap.php');

include("funciones.php");

$server = new soap_server;

$targetNameSpace = 'guarani/ws/wifi';
$server->configurewsdl('ApplicationServices', $targetNameSpace,false,'rpc', 'http://schemas.xmlsoap.org/soap/http', $targetNameSpace);
$server->wsdl->schematargetnamespace = $targetNameSpace;


$server->register('autenticarUsuarioWifi', array('ua' => 'xsd:string', 
                'tipotitulo' => 'xsd:integer', 'tipodoc' => 'xsd:string',
                'nrodoc' => 'xsd:string', 'clave' => 'xsd:string'), array('return' => 'xsd:string'),$targetNameSpace, false, false, 'literal', $comentarioAutenticarUsuarioWifi);

$HTTP_RAW_POST_DATA = isset($HTTP_RAW_POST_DATA) ? $HTTP_RAW_POST_DATA : '';

$server->service($HTTP_RAW_POST_DATA);
ob_end_flush();
exit;
?>
