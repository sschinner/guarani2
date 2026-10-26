<?php
ob_start('limpiar');
function limpiar($buffer){
  return trim($buffer);
}
//require_once("adodb/adodb.inc.php");
require_once('../nusoap/lib/nusoap.php');

include("funciones.php");

$server = new soap_server;
$server->soap_defencoding = 'utf-8';
$server->decode_utf8 = false;

$targetNameSpace = 'guarani/ws/gobierno';
$server->configurewsdl('ApplicationServices', $targetNameSpace,false,'rpc', 'http://schemas.xmlsoap.org/soap/http', $targetNameSpace);
$server->wsdl->schematargetnamespace = $targetNameSpace;

// El arreglo de strings
$server->wsdl->addComplexType(
								'ArrayOfString',
								'complexType',
								'array',
								'',
								'SOAP-ENC:Array',
								array(),
								array(array('ref'=>'SOAP-ENC:arrayType','wsdl:arrayType'=>'string[]')),
								'xsd:string'
							);
// El arreglo de arreglos 
$server->wsdl->addComplexType(
								'ArrayOfArray',
								'complexType',
								'array',
								'',
								'SOAP-ENC:Array',
								array(),
								array(array('ref'=>'SOAP-ENC:arrayType','wsdl:arrayType'=>'ArrayOfString[]')),
								'ArrayOfString'
							);

$server->register('esAlumno',
array('TI' => 'xsd:string','UA' => 'xsd:string','apellido' => 'xsd:string','nombre' => 'xsd:string','Tdni' => 'xsd:string','dni' => 'xsd:string','sexo' => 'xsd:string','fecha' => 'xsd:string'),
array('return' => 'tns:ArrayOfArray'),
$ns); 

$HTTP_RAW_POST_DATA = isset($HTTP_RAW_POST_DATA) ? $HTTP_RAW_POST_DATA : '';

$server->service($HTTP_RAW_POST_DATA); 
//$server->service($input);
ob_end_flush();
exit;
?>
