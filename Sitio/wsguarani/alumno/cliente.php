<?php

require_once("adodb/adodb.inc.php");
require_once('funciones.php');
require_once('../nusoap/lib/nusoap.php');

//$wsdl = WSDLG."alumno?wsdl"; //el nombre del archivo servidor
$wsdl = 'https://servicios.unl.edu.ar/test/guarani/ws/alumno?wsdl';
$client = new nusoap_client($wsdl, 'wsdl');
//$client->setCredentials("wsAlumno", "Ws_4LUMn5", "basic");//integracion
//$client->setCredentials("wsAlumno", "Ws_4LUMn5T25t", "basic");//test
//#Tel3m1t1_*   telematica
//$client->setCredentials("gea","10G3a#_*","basic");
//$client->setCredentials("telematica","#Tel3m1t1_*","basic");

$client->setCredentials("moodlefich","*m00dl2F3ch#","basic");        
$err = $client->getError();
if ($err) {
    // error if any
    echo 'Constructor error' . $err;
}

//////$param = array('carrera'=>'1045','tipo'=>'0','documento'=>"37569869",'pais'=>"54",'unidadAcademica'=>'EUAA','tipoTitulo'=>'0');
//$param = array('carrera'=>'1021','tipo'=>'0','documento'=>'36406279','pais'=>"54",'unidadAcademica'=>'FIQ','tipoTitulo'=>'0');
//$resultado = $client->call('historiaAcademicaAlumno', $param);
//$resp[]=json_decode($resultado);//39959243*/
////
////$param = array('carrera'=>'1045','tipo'=>'0','documento'=>"37569869",'pais'=>"54",'unidadAcademica'=>'EUAA','tipoTitulo'=>'0');
//////$param = array('carrera'=>'1021','tipo'=>'0','documento'=>"22761917",'pais'=>"54",'unidadAcademica'=>'FIQ','tipoTitulo'=>'7');
////$resultado = $client->call('historiaAcademicaAlumno', $param);
////$resp[]=json_decode($resultado);//39959243*/
////
//$param = array('carrera'=>'03','tipo'=>'0','documento'=>"29686498",'pais'=>"54",'unidadAcademica'=>'fich','tipoTitulo'=>'1');
//$resultado = $client->call('historiaAcademicaAlumno', $param);
//$resp[]=json_decode($resultado);
//
//print_r($resp);die;
//$client->setCredentials("hefesto","**hef3St0","basic");
//
//$param = array('tipo'=>'0','documento'=>"38108720",'pais'=>"54",'unidadacademica'=>'');
//$resultado = $client->call('rendimientoAcademico', $param);
//$resp[]=json_decode($resultado);//39959243

//34650610-2
// $param = array('carrera'=>'03','tipo'=>'0','documento'=>"29686498",'pais'=>"54",'unidadAcademica'=>'fich','tipoTitulo'=>'1');
//$resultado = $client->call('historiaAcademicaAlumno', $param);
//$resp[]=json_decode($resultado);
/*$param = array('carrera'=>'03','tipo'=>'0','documento'=>"29686498",'pais'=>"54",'unidadAcademica'=>'FIch','tipoTitulo'=>'1');
$resultado = $client->call('historiaAcademicaAlumno', $param);
$resp[]=json_decode($resultado); */ //39959243 
//$param = array('tipo'=>'0','documento'=>"31163280",'pais'=>"54",'unidadacademica'=>'');
//$resultado = $client->call('rendimientoAcademico', $param);
//$resp[]=json_decode($resultado);//39959243
////""37232595
// $param = array('tipo'=>'0','documento'=>"31892027",'pais'=>"54",'unidadacademica'=>'FIQ');
//$resultado = $client->call('rendimientoAcademico', $param);
////$resp=json_decode($resultado);//39959243
//$resp[]=json_decode($resultado); //39959243
//$param = array('tipo'=>'0','documento'=>"31849954",'pais'=>"54",'unidadacademica'=>'');
//$resultado = $client->call('rendimientoAcademico', $param);
////$resp=json_decode($resultado);//39959243
//$resp[]=json_decode($resultado);
//////////
//$resp[]=json_decode($resultado);//39959243
//
//$param = array('tipo'=>'0','documento'=>"36001533",'pais'=>"54",'unidadacademica'=>'');
//$resultado = $client->call('rendimientoAcademico', $param);
//$resp[]=json_decode($resultado);
//$param = array('tipo'=>'0','documento'=>"37701552",'pais'=>"54",'unidadacademica'=>'');
//$resultado = $client->call('rendimientoAcademico', $param);
//$resp[]=json_decode($resultado);
//$param = array('tipo'=>'0','documento'=>"37037138",'pais'=>"54",'unidadacademica'=>'');
//$resultado = $client->call('rendimientoAcademico', $param);
//$resp[]=json_decode($resultado);
//$param = array('tipo'=>'0','documento'=>"36814493",'pais'=>"54",'unidadacademica'=>'');
//$resultado = $client->call('rendimientoAcademico', $param);
//$resp[]=json_decode($resultado);
//$param = array('tipo'=>'0','documento'=>"35448093",'pais'=>"54",'unidadacademica'=>'');
//$resultado = $client->call('rendimientoAcademico', $param);
//$resp[]=json_decode($resultado);
//$param = array('tipo'=>'0','documento'=>"32236395",'pais'=>"54",'unidadacademica'=>'');
//$resultado = $client->call('rendimientoAcademico', $param);
//$resp[]=json_decode($resultado);
//$param = array('tipo'=>'0','documento'=>"37774157",'pais'=>"54",'unidadacademica'=>'');
//$resultado = $client->call('rendimientoAcademico', $param);
//$resp[]=json_decode($resultado);
//$param = array('tipo'=>'0','documento'=>"36910191",'pais'=>"54",'unidadacademica'=>'');
//$resultado = $client->call('rendimientoAcademico', $param);
//$resp[]=json_decode($resultado);
//$param = array('tipo'=>'0','documento'=>"35707643",'pais'=>"54",'unidadacademica'=>'');
//$resultado = $client->call('rendimientoAcademico', $param);
//$resp[]=json_decode($resultado);
//$param = array('tipo'=>'0','documento'=>"40618582",'pais'=>"54",'unidadacademica'=>'');
//$resultado = $client->call('rendimientoAcademico', $param);
//$resp[]=json_decode($resultado);
//$param = array('tipo'=>'0','documento'=>"34177546",'pais'=>"54",'unidadacademica'=>'');
//$resultado = $client->call('rendimientoAcademico', $param);
//$resp[]=json_decode($resultado);
//$param = array('tipo'=>'0','documento'=>"37260251",'pais'=>"54",'unidadacademica'=>'');
//$resultado = $client->call('rendimientoAcademico', $param);
//$resp[]=json_decode($resultado);
//$param = array('tipo'=>'0','documento'=>"37545190",'pais'=>"54",'unidadacademica'=>'');
//$resultado = $client->call('rendimientoAcademico', $param);
//$resp[]=json_decode($resultado);
//$resp=json_decode($resultado);//39959243
//39959243
//33317377
//$param = array('tipo'=>'0','documento'=>"38261825",'pais'=>"54",'unidadacademica'=>'FCJS');
//$resultado = $client->call('rendimientoAcademico', $param);
////$resp=json_decode($resultado);//39959243
//$resp[]=json_decode($resultado);//39959243
//
//$param = array('tipo'=>'0','documento'=>"37232595",'pais'=>"54",'unidadacademica'=>'');
//$param = array('tipo'=>'0','documento'=>"24325851",'pais'=>"54",'unidadacademica'=>'');
//$resultado = $client->call('rendimientoAcademico', $param);
////$resp=json_decode($resultado);//39959243
//$resp[]=json_decode($resultado);//39959243
////
$param = array('unidadAcademica'=>'FICH','tipoTitulo'=>6,'filtro'=>'carrera','valor1'=>'0001','valor2'=>'0','valor3'=>'54');
$resultado = $client->call('datosCensalesAlumno', $param);
$resp[] = json_decode($resultado); //38446979(fiq)31892027
//$param = array('unidadAcademica'=>'FIQ','tipoTitulo'=>0,'filtro'=>'documento','valor1'=>'37569869','valor2'=>'0','valor3'=>'54');
//$resultado = $client->call('datosCensalesAlumno', $param);
//$resp[] = json_decode($resultado); 
//$param = array('unidadAcademica'=>'FIQ','tipoTitulo'=>0,'filtro'=>'documento','valor1'=>'31892027','valor2'=>'0','valor3'=>'54');
//$resultado = $client->call('estadoAlumno', $param);
//$resp[] = json_decode($resultado);
$param = array('unidadAcademica'=>'FICH','tipoTitulo'=>6,'filtro'=>'carrare','valor1'=>'0001','valor2'=>'0','valor3'=>'54');
$resultado = $client->call('estadoAlumno', $param);
$resp[] = json_decode($resultado);
//$param = array('unidadAcademica'=>'FADU','tipoTitulo'=>0,'filtro'=>'documento','valor1'=>'32641202','valor2'=>'0','valor3'=>'54');
//$resultado = $client->call('estadoAlumno', $param);
//$resp[] = json_decode($resultado);
//$param = array('unidadAcademica'=>'FCA','tipoTitulo'=>0,'filtro'=>'carrera','valor1'=>'1048','valor2'=>'0','valor3'=>'54');
//$resultado = $client->call('estadoAlumno', $param);
//$resp[] = json_decode($resultado);
//$param = array('unidadAcademica'=>'EUAA','tipoTitulo'=>1,'filtro'=>'documento','valor1'=>'37569869','valor2'=>'0','valor3'=>'54');
//$resultado = $client->call('estadoAlumno', $param);
//$resp[] = json_decode($resultado);
//$param = array('unidadAcademica'=>'FCA','tipoTitulo'=>0,'filtro'=>'ingreso','valor1'=>'2018','valor2'=>'0','valor3'=>'54');
//$resultado = $client->call('datosCensalesAlumno', $param);
//$resp[] = json_decode($resultado);
//$param = array('unidadAcademica'=>'FCV','tipoTitulo'=>1,'filtro'=>'ingreso','valor1'=>'2018','valor2'=>'0','valor3'=>'54');
//$resultado = $client->call('datosCensalesAlumno', $param);
//$resp[] = json_decode($resultado); 

//$resp = json_decode($resultado); 
//foreach ($resp as $value) {
//    echo gettype($value->carreras[0]->fechaIngreso);
//    echo gettype($value->carreras[0]->cantMatPlan);
//}
//$param = array('usuario'=>'DNI38261825','clave'=>'16222085','unidadAcademica'=>'FCJS', 'tipoTitulo'=>'0');
//$param = array('usuario'=>'37569869','clave'=>'Guarani4','unidadAcademica'=>'EUAA', 'tipoTitulo'=>'0');
//$param = array('usuario'=>'29349542','clave'=>'Arnoldt1','unidadAcademica'=>'FICH', 'tipoTitulo'=>'0');
//$param = array('usuario'=>'29349542','clave'=>'Arnoldt1','unidadAcademica'=>'FICH', 'tipoTitulo'=>'0');
//$resultado = $client->call('autenticarAlumno', $param,URI."alumno/index.php?wsdl",URI."alumno/index.php?wsdl/autenticarAlumno");
// $resp[] = json_decode($resultado);
////$resp = ($resultado);
//////DNI38261825
//$param = array('unidadAcademica'=>'FBCB','tipoTitulo'=>1,'filtro'=>'documento','valor1'=>'33931764','valor2'=>'0','valor3'=>'54');
//$resultado = $client->call('datosCensalesAlumno', $param);
//$resp[] = json_decode($resultado); 
//
//
//$param = array('unidadAcademica'=>'FCJS','tipoTitulo'=>0,'filtro'=>'usuario','valor1'=>'DNI38261825','valor2'=>'','valor3'=>'');
//$resultado = $client->call('datosCensalesAlumno', $param);
//$resp[] = json_decode($resultado); 

//$param = array('unidadAcademica'=>'FCJS','tipoTitulo'=>0,'filtro'=>'usuario','valor1'=>'dni24325851','valor2'=>'','valor3'=>'');
//$resultado = $client->call('datosCensalesAlumno', $param);
//$resp[] = json_decode($resultado); 


/**  PRUEBA DE STRESS  **/
//$tiempo_inicio = microtime(true);
//for($i=0;$i<60;$i++){
//
//    $param = array('usuario'=>'dni24325851','clave'=>'74430709','unidadAcademica'=>'FCJS', 'tipoTitulo'=>'0');
//    $resultado = $client->call('autenticarAlumno', $param,URI."alumno/index.php?wsdl",URI."alumno/index.php?wsdl/autenticarAlumno");
//    $resp = json_decode($resultado);
//    print_r($resp);
//
//    $param = array('unidadAcademica'=>'FCJS','tipoTitulo'=>0,'filtro'=>'usuario','valor1'=>'dni24325851','valor2'=>'','valor3'=>'');
//    $resultado = $client->call('datosCensalesAlumno', $param);
//    $resp = json_decode($resultado);
//    print_r($resp);    
//
//    $param = array('tipo'=>'0','documento'=>"33317377",'pais'=>"54",'unidadacademica'=>'');
//    $resultado = $client->call('rendimientoAcademico', $param);
//    $resp=json_decode($resultado);//39959243
//    print_r($resp);
//}
//
//$tiempo_fin = microtime(true);
//$tiempo = bcsub($tiempo_fin, $tiempo_inicio, 4);
//echo "\n"."\n"."Tiempo de ejecucion: " . (($tiempo)/60). " minutos";


print_r($resp);
die;
