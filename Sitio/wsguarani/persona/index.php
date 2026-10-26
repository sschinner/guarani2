<?php
ob_start('limpiar');
function limpiar($buffer) {
   	return trim($buffer);
}

//require_once("adodb/adodb.inc.php");
require_once('../nusoap/lib/nusoap.php');

include_once("funciones.php");

$server = new soap_server;

$targetNameSpace = 'guarani/ws/persona';
$server->configurewsdl('ApplicationServices', $targetNameSpace,false,'rpc', 'http://schemas.xmlsoap.org/soap/http', $targetNameSpace);
$server->wsdl->schematargetnamespace = $targetNameSpace;

 
$server->register('cambiarUsuarioAutogestion', array('ua' => 'xsd:string', 'tipotitulo' => 'xsd:string',
					'tipo_doc' => 'xsd:string', 'nro_doc' => 'xsd:string','pais_doc' => 'xsd:string','usuario_ag'=>'xsd:string',                     						'usuario_ag' => 'xsd:string'),
                                    array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal','N/A' );
//---------------------------------------------------------------------------------------------------------
$server->register('cambiarClaveAutogestion', array('ua' => 'xsd:string', 'tipotitulo' => 'xsd:string',
						'usuario' => 'xsd:string',
                                                'claveNueva' => 'xsd:string'),
                                            array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal','N/A' );

//---------------------------------------------------------------------------------------------------------
$server->register('consultarUsuarioAutogestion', array('ua' => 'xsd:string', 'tipotitulo' => 'xsd:string',
					'tipo_doc' => 'xsd:string', 'nro_doc' => 'xsd:string','pais_doc' => 'xsd:string'),
                                    array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal','N/A' );
//-------------------------------------------------------------------------------------------------------------

$HTTP_RAW_POST_DATA = isset($HTTP_RAW_POST_DATA) ? $HTTP_RAW_POST_DATA : '';
$server->service($HTTP_RAW_POST_DATA);
ob_end_flush();
exit;
?>
