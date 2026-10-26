<?php
require_once("adodb/adodb.inc.php");
require_once('funciones.php');
require_once('../nusoap/lib/nusoap.php');
//print_r($_SERVER['SERVER_ADDR']);die;
 //el nombre del archivo servidor

if ($_SERVER['SERVER_ADDR'] == '127.0.0.1') {
    
    $wsdl = "http://localhost/wsguarani/bedeliaunl?wsdl";
} else {
    $wsdl = WSDLG . "bedeliaunl?wsdl";
}

//$wsdl=WSDLG."fce?wsdl";

$client=new nusoap_client($wsdl, 'wsdl');
$client->setCredentials("wsbedeliaunl","WsB2D2l315nL","basic");

$err = $client->getError();
if ($err) {
    // error if any
    echo 'Constructor error' . $err; 
} 

//$param = array('tipo'=>'0','documento'=>"36000856",'unidadAcademica'=>'Fce','tipoTitulo'=>'0');
//$param = array('tipo'=>'0','documento'=>"30171912");
//$resultado = $client->call('datosAcademicosFCE', $param,"http://guarani3w-test.intranet/wsguarani/fce/index.php?wsdl","http://guarani3w-test.intranet/wsguarani/datosAcademicosFCE");
//34398709  28331969*/
$param = array('ua' => 'FICH','anio_academico'=>'2018','periodo_lectivo'=>'1er. Cuatrimestre','tipoTitulo'=>'1');
$resultado = $client->call('comisionesCursadas', $param,URI."bedeliaunl/index.php?wsdl",URI."bedeliaunl/index.php?wsdl/comisionesCursadas");

/*$param = array('usuario'=>'28331969','unidadAcademica'=>'FICh','tipoTitulo'=>'0');
$resultado = $client->call('datosCensalesHefesto', $param,"uri:http://guarani3w-dev.intranet/wsguarani/hefesto/index.php?wsdl",
"uri:http://guarani3w-dev.intranet/wsguarani/hefesto/index.php?wsdl/datosCensalesHefesto");*/

/*$param = array('usuario'=>'29349542','clave'=>'29349','unidadAcademica'=>'Fich', 'tipoTitulo'=>'1');
$resultado = $client->call('autenticarUsuarioGuarani', $param,"uri:http://guarani3w-dev.intranet/wsguarani/hefesto/index.php?wsdl",
"uri:http://guarani3w-dev.intranet/wsguarani/hefesto/index.php?wsdl/datosCensalesHefesto");*/

//phpinfo();
$resp=json_decode($resultado);
print_r($resp/*$resultado*/);die; 

?>
