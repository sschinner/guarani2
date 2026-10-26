<?php
ob_start('limpiar');
function limpiar($buffer){
	return trim($buffer);
}

//require_once("adodb/adodb.inc.php");
require_once('../nusoap/lib/nusoap.php');

include_once("funciones.php");

$server = new soap_server;

$targetNameSpace = 'guarani/ws/fhuc';
$server->configurewsdl('ApplicationServices', $targetNameSpace,false,'rpc', 'http://schemas.xmlsoap.org/soap/http', $targetNameSpace);
$server->wsdl->schematargetnamespace = $targetNameSpace;


$server->register('cursadasFhuc',array('tipoTitulo' => 'xsd:string','anio_academico' => 'xsd:string',
                                'periodo_lectivo' => 'xsd:string'),
                                array('return' => 'xsd:string'),$ns);

$server->register('carrerasFhuc',array('tipoTitulo' => 'xsd:string','plan' => 'xsd:string',
                                'carrera' => 'xsd:string'),
                                array('return' => 'xsd:string'),$ns);

$server->register('alumnoReg5aniosFhuc',array('nroDocumento' => 'xsd:string','tipoTitulo' => 'xsd:string'),
                                        array('return' => 'xsd:string'),$ns);

$HTTP_RAW_POST_DATA = isset($HTTP_RAW_POST_DATA) ? $HTTP_RAW_POST_DATA : '';

$server->service($HTTP_RAW_POST_DATA); 
ob_end_flush();
exit;
?>
