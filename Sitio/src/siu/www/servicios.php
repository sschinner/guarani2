<?php
require_once(realpath(dirname(__FILE__).'/../bootstrap.php'));
	\siu\bootstrap::cargar();
	//\kernel\nucleo\acceso_web::procesar();
	
function echoFunction($inMessage) {
    $returnMessage = new WSMessage($inMessage->str);
	
	// gde_asignacion, marcar respondido
	
	
    return $returnMessage;
}

$operations = array("eco" => "echoFunction");
$actions = array("http://wso2.org/wsfphp/samples/eco" => "eco");

$service = new WSService(array( "operations" => $operations, 
                                "actions" => $actions)
							);
        
$service->reply();

?>