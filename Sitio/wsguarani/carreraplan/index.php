<?php

ob_start('limpiar');

function limpiar($buffer) {
    return trim($buffer);
}

//require_once("adodb/adodb.inc.php"); 
require_once('../nusoap/lib/nusoap.php');

include("funciones.php");

$server = new soap_server;

$targetNameSpace = 'guarani/ws/carreraplan';
$server->configurewsdl('ApplicationServices', $targetNameSpace,false,'rpc', 'http://schemas.xmlsoap.org/soap/http', $targetNameSpace);
$server->wsdl->schematargetnamespace = $targetNameSpace;



$server->register('materiasCarreraPlan', array('ua' => 'xsd:string',
                    'tipoTitulo' => 'xsd:integer', 'carrera' => 'xsd:string',
                    'plan' => 'xsd:string','version' => 'xsd:string'),
                    array('return' => 'xsd:string'),$targetNameSpace,false,false,'literal',$comentarioMateriaCarreraPlan);
$server->register('carrerasUA', array('ua' => 'xsd:string','tipoTitulo' => 'xsd:integer'),
                    array('return' => 'xsd:string'),$targetNameSpace,false,false,'literal',$comentarioCarrerUA);


$server->service($HTTP_RAW_POST_DATA);
ob_end_flush();
exit;
?>
