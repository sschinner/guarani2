<?php

require_once("adodb/adodb.inc.php");
require_once('funciones.php');
require_once('../nusoap/lib/nusoap.php');

//$wsdl = WSDLG."alumno?wsdl"; //el nombre del archivo servidor
$wsdl = 'http://localhost:8080/295/wsguarani/catalogo?wsdl';
$client = new nusoap_client($wsdl, 'wsdl');
//$client->setCredentials("wsAlumno", "Ws_4LUMn5", "basic");//integracion
//$client->setCredentials("wsAlumno", "Ws_4LUMn5T25t", "basic");//test
//#Tel3m1t1_*   telematica
//$client->setCredentials("gea","10G3a#_*","basic");
//$client->setCredentials("telematica","#Tel3m1t1_*","basic");

$client->setCredentials("gea","1n10G3a#_*GRA","basic");        
$err = $client->getError();
if ($err) {
    // error if any
    echo 'Constructor error' . $err;
}
$param = array('filtro'=>'colegiosSecundarios');
$resultado = $client->call('catalogos', $param);
$resp[] = json_decode($resultado);

print_r($resp);
die;

//$client = new SoapClient('http://localhost:8080/295/wsguarani/catalogo'.'?wsdl',  array('login'=>"gea",'password'=> "1n10G3a#_*GRA"));
//$param = array('filtro' => 'colegiosSecundarios');
//$resultado = $client->__soapCall("catalogos", $param);
////$resultado = $cliente->call('catalogos', $param, URI."catalogo/index.php?wsdl", URI."catalogo/index.php?wsdl/catalogos");
//
//$resp[]=json_decode($resultado);
//
//print_r($resp/*$resultado*/);die; 
