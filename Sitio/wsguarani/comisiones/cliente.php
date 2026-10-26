<?php
require_once("adodb/adodb.inc.php");
require_once('funciones.php');
require_once('../nusoap/lib/nusoap.php');

$wsdl = WSDLG."comisiones?wsdl"; //el nombre del archivo servidor
//$wsdl = 'https://servicios.unl.edu.ar/test/guarani/ws/comisiones?wsdl';
$client = new nusoap_client($wsdl, 'wsdl');
//$client->setCredentials("wsAlumno", "Ws_4LUMn5", "basic");//integracion
//$client->setCredentials("wsAlumno", "Ws_4LUMn5T25t", "basic");//test
//#Tel3m1t1_*   telematica
//$client->setCredentials("gea","10G3a#_*","basic");
//$client->setCredentials("telematica","#Tel3m1t1_*","basic");

$client->setCredentials('fhuc',"*_Fh5C#*","basic");        
$err = $client->getError();
if ($err) {
    // error if any
    echo 'Constructor error' . $err;
}

//$param = array('tipo'=>'0','documento'=>"36000856",'unidadAcademica'=>'Fce','tipoTitulo'=>'0');
//$param = array('tipo'=>'0','documento'=>"30171912");
//$resultado = $client->call('datosAcademicosFCE', $param,"http://guarani3w-test.intranet/wsguarani/fce/index.php?wsdl","http://guarani3w-test.intranet/wsguarani/datosAcademicosFCE");
//34398709  28331969*/
$param = array('ua' => 'FHUC','anio_academico'=>'2018','periodo_lectivo'=>'1er. Cuatrimestre','tipoTitulo'=>'1');
$resultado = $client->call('detallesComisiones', $param);
print_r($resultado);
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
