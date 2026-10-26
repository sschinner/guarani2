<?php
require_once("adodb/adodb.inc.php");
require_once('funciones.php');
require_once('../nusoap/lib/nusoap.php');

$tiempo_inicio = microtime(true);

$wsdl=WSDLG."kuntur?wsdl"; //el nombre del archivo servidor

$client=new nusoap_client($wsdl, 'wsdl');
$client->setCredentials("wskuntur","WSk5nT5r","basic");

$err = $client->getError();
if ($err) {
    // error if any
    echo 'Constructor error' . $err; 
} 


//$resp=array();
//$param = array('usuario'=>'39033218','clave'=>'39033','unidadAcademica'=>'FBCB','tipoTitulo'=>'1');
//$resultado = $client->call('autenticarUsuarioGuarani', $param);
//$resp[]=json_decode($resultado);
//$param = array('tipo'=>'0','documento'=>"39033218");
//$resultado = $client->call('datosAcademicosCompletos', $param);
//$resp[]=json_decode($resultado);
$param = array('usuario'=>"29349542",'unidadAcademica'=>'FICH','tipoTitulo'=>'1');
$resultado = $client->call('datosCensales', $param);
$resp[]=json_decode($resultado);
//$param = array('unidadAcademica'=>'FBCB','tipoTitulo'=>'1');
//$resultado = $client->call('promedioHistoricoUA', $param);
//$resp[]=json_decode($resultado);
//
//
//
//$resp[] = 'PRUEBA POSTGRES GUARANI 3';
//
////Casos de Prueba para Guarani3 Postgres
//$param = array('usuario'=>'26781486','clave'=>'Alumno1','unidadAcademica'=>'CU-RA','tipoTitulo'=>'1');
//$resultado = $client->call('autenticarUsuarioGuarani', $param);
//$resp[]=json_decode($resultado);
//$param = array('tipo'=>'0','documento'=>"30788498");
//$resultado = $client->call('datosAcademicosCompletos', $param);
//$resp[]=json_decode($resultado);//39959243
//$param = array('tipo'=>'0','documento'=>"29349542");
//$resultado = $client->call('datosAcademicosCompletos', $param);
//$resp[]=json_decode($resultado);
//$param = array('usuario'=>"39959243",'unidadAcademica'=>'Cu-Ra','tipoTitulo'=>'1');
//$resultado = $client->call('datosCensales', $param);
//$resp[]=json_decode($resultado);
//
//$param = array('unidadAcademica'=>'cu-ra','tipoTitulo'=>'7');
//$resultado = $client->call('promedioHistoricoUA', $param);
//$resp[]=json_decode($resultado);
//


//$unidad=array("FADU", "FBCB", "FCA", "FCE","FCJS", "FCM", "FCV", "FHUC","FIQ","FICH","EUAA","ISM", "ESS","CU-RA");
$unidad=array("CU-RA");

for($i=0;$i<count($unidad);$i++){
    if($unidad[$i]=='CU-RA')
        $titulo = 1;
    else
        $titulo = 0;
    $param = array('unidadAcademica'=>$unidad[$i],'tipoTitulo'=>$titulo);
    $resultado = $client->call('promedioHistoricoUA', $param);
    $resp[]=json_decode($resultado);
}



$tiempo_fin = microtime(true);
$tiempo = bcsub($tiempo_fin, $tiempo_inicio, 4);
 

print_r($resp);

echo "\n"."\n"."Tiempo de ejecucion: " . (($tiempo)). " segundos";

die;

?>
