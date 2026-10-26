<?php
ob_start('limpiar');
function limpiar($buffer){
	return trim($buffer);
}
//require_once("adodb/adodb.inc.php"); 
require_once('../nusoap/lib/nusoap.php');

include("funciones.php");

$server = new soap_server;

$targetNameSpace = 'guarani/ws/kuntur';
$server->configurewsdl('ApplicationServices', $targetNameSpace,false,'rpc', 'http://schemas.xmlsoap.org/soap/http', $targetNameSpace);
$server->wsdl->schematargetnamespace = $targetNameSpace;


$server->register('autenticarUsuarioGuarani',array('usuario' => 'xsd:string','clave' => 'xsd:string','unidadAcademica' => 'xsd:string','tipoTitulo'=>'xsd:integer'),
		array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal',$comentariosAutenticarUsuario );
//$server->register('datosCensales',array('usuario' => 'xsd:string','unidadAcademica' => 'xsd:string','tipoTitulo'=>'xsd:string'),
//		array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal','N/A' );
//$server->register('datosAcademicosCompletos',array('tipo' => 'xsd:integer','documento' => 'xsd:string'),
//		array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal','N/A' );
$server->register('promedioHistoricoUA',array('unidadAcademica' => 'xsd:string','tipoTitulo'=>'xsd:integer'),
		array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal',$comentariosPromedioHistoricoUA );
$HTTP_RAW_POST_DATA = isset($HTTP_RAW_POST_DATA) ? $HTTP_RAW_POST_DATA : '';

$server->service($HTTP_RAW_POST_DATA); 
ob_end_flush();
exit;
?>
