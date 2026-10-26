<?php

ob_start('limpiar');

function limpiar($buffer) {
    return trim($buffer);
}

require_once('../../../libraries/nusoap/lib/nusoap.php');

include("funciones.php");

$server = new soap_server;

$targetNameSpace = 'guarani/ws/tramites';
$server->configurewsdl('ApplicationServices', $targetNameSpace,false,'rpc', 'http://schemas.xmlsoap.org/soap/http', $targetNameSpace);

$server->register('notificarUrlCertificado', 
                array('expediente' => 'xsd:string', 
                    'urlCertificado' => 'xsd:string', 
                    'tipoNotificacion' => 'xsd:string'), 
                array('return' => 'xsd:string'), 
                $ns, false, false, 'literal', 'N/A');

$server->register('retrocederValidacion', 
                array('expediente' => 'xsd:string', 
                    'motivoRechazo' => 'xsd:string'), 
                array('return' => 'xsd:string'), 
                $ns, false, false, 'literal', 'N/A');

$HTTP_RAW_POST_DATA = isset($HTTP_RAW_POST_DATA) ? $HTTP_RAW_POST_DATA : '';

$server->service($HTTP_RAW_POST_DATA);
ob_end_flush();
exit;
?>


