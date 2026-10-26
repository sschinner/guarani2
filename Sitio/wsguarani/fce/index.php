<?php

ob_start('limpiar');

function limpiar($buffer) {
    return trim($buffer);
}

//require_once("adodb/adodb.inc.php"); 
require_once('../nusoap/lib/nusoap.php');

include("funciones.php");

$server = new soap_server;

$targetNameSpace = 'guarani/ws/fce';
$server->configurewsdl('ApplicationServices', $targetNameSpace,false,'rpc', 'http://schemas.xmlsoap.org/soap/http', $targetNameSpace);
$server->wsdl->schematargetnamespace = $targetNameSpace;

$server->register('datosAcademicosFCE', array('tipo' => 'xsd:integer', 'documento' => 'xsd:string', 'unidadAcademica' => 'xsd:string', 'tipoTitulo' => 'xsd:string'), array('return' => 'xsd:string'),$targetNameSpace, false, false, 'literal', 'N/A');

$server->register('comisionesCursadas', array('ua' => 'xsd:string', 'anio_academico' => 'xsd:string',
    'periodo_lectivo' => 'xsd:string', 'tipoTitulo' => 'xsd:string'), array('return' => 'xsd:string'), $ns);

$server->register('listadoAlumnos', array('ua' => 'xsd:string', 'fecha' => 'xsd:string', 'tipoTitulo' => 'xsd:string'), array('return' => 'xsd:string'), $ns);

$HTTP_RAW_POST_DATA = isset($HTTP_RAW_POST_DATA) ? $HTTP_RAW_POST_DATA : '';

$server->service($HTTP_RAW_POST_DATA);
ob_end_flush();
exit;
?>
