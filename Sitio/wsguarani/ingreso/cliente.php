<?php

require_once("adodb/adodb.inc.php");
require_once('funciones.php');
require_once('../nusoap/lib/nusoap.php');

$wsdl = WSDLG."ingreso?wsdl"; //el nombre del archivo servidor
//$wsdl = 'https://servicios.unl.edu.ar/integracion/guarani/ws/ingreso?wsdl';
$client = new nusoap_client($wsdl, 'wsdl');
$client->setCredentials("wsingreso", "WS1NGR3S0", "basic");

$err = $client->getError();
if ($err) {
    // error if any
    echo 'Constructor error' . $err;
}

// Completar los datos correspondientes para prueba
//
//'EUA','2017','TSTA', '00000', 1, '2017-01-10', 'SSSTECHINA',
//                'FFFIORELA AAILEN', 54, 0, '9941057023', '27-9941057023-3', '1998-04-03', 'F', null, 1, null,
//                8202947, 4, '2015', null, null, null, null, null, null, 1, 'stechinafiorela@gmail.com', '303',
//                485, null, null, null, 5571, '3561', '3482-610617', '303', 485, null, null, null, 5571,'3561',
//                '3482-480869', null, null, null, 0, 0, null, null, 0, null, 5, '5', null, null, 7, '5', null,
//                null, 'S', '5'


//$param = array('ua' => 'FICH', 'tipotitulo' => '1',
//		'anio_acad' => '2018', 'carrera' => '03', 'sede' => '00000', 'tipo_ingreso' => 1,
//                'fecha_insc' => /*'2018-02-02'*/'01/01/2018', 'apellido' => 'P`alón', 'nombres' => 'Martín Ñandú', 'tipo_doc' => 0,
//                'nro_doc' => '62900513', 'pais_documento' => 54, 'numero_cuil' => '27-62900513-3', 'fecha_nacimiento' => /*'1998-04-03'*/'01/01/1980',
//		'sexo' => 'F', 'loc_nacimiento' => '', 'colegio_secundario' => '2000',
//		'colegio_secundario_dependencia' => '4', 'anio_egreso_sec' => '2014', 'grupo_sanguineo' => 'B', 'factor_sanguineo' => '+', 'apellido_padre' => 'P`alón', 
//		'apellido_madre' => 'Varela', 'pais_emisor_pasap' => '', 'nro_pasap' => '', 'estado_civil' => '1', 'eMail' => 'stechinafiore@gmail.com', 
//		'calle_per_lec' => '303', 'numero_per_lect' => '485', 'piso_per_lect' => '', 'dpto_per_lect' => '', 
//		'unidad_per_lect' => '', 'loc_per_lect' => '5571', 'cp_per_lect' => '3561', 'te_per_lect' => '', 
//		'calle_proc' => '303', 'numero_proc' => '485', 'piso_proc' => '', 'dpto_proc' => '', 'unidad_proc' => '', 'loc_proc' => '5571', 
//		'cp_proc' => '3561', 'te_proc' => '', 'otros_estud_super' => '', 'padre_vive' => '', 'madre_vive' => '', 'sit_laboral_alumno' => '0',
//		'categ_ocup_alum' => '0', 'act_econom_alum' => '', 'det_rama_act_alum' => '', 'cant_horas_sem_trab_alum'  => '0', 
//		'sit_laboral_padre' => '2', 'ult_est_padre' => '5', 'act_econom_padre' => '2', 'det_rama_act_padre' => '2', 'sit_laboral_madre' => '7', 
//		'ult_est_madre' => '2', 'act_econom_madre' => '2', 'det_rama_act_madre' => '2', 'alu_req_acces_fisica' => 'S', 'alu_req_acces_com' => '5');
////////foreach($param as $fila){
////////             $aspirante[] = mb_detect_encoding($fila);
////////        }
////////        
////////        print_r($aspirante);die;      
//$resultado = $client->call('altaAspirante', $param);
//$resp[] = json_decode($resultado);

//
//    echo gettype($resp->codigoWS), "\n";
//     echo gettype($resp->mensajeWS), "\n";
//     print_r($resp);
//
//die;
// Completar los datos correspondientes para prueba
//'EUA','TSTA', 54, 0, '941057023', 'UNL01', 'S', current_date, 'N'
//$param = array('ua' => 'CU-RA', 'tipotitulo' => '1', 'carrera' => '1016', 'tipo_doc' => '0',
//                'nro_doc' => '9900500', 'pais_documento' => '54', 'nro_inscripcion' => '', 'cod_requisito' => '3',
//		'forma_cumpli' => '2', 'fecha_presentacion' => '06/03/2018', 'exceptuado' => 'N','validado'=>'S');
////
////
//$resultado = $client->call('altaRequisito', $param);
//
//////$resultado = $client->call('altaAspirante', $param);
//$resp = json_decode($resultado);
/*----------------------------------------------------------------------------------------*/
//$ua, $tipotitulo, $carrera, $pais_documento, $tipo_doc, $nro_doc, $materia, $tipo_examen, $fecha_examen, $nota
//$param = array('ua' => 'FICH', 'tipotitulo' => '1', 'carrera' => '03',  'pais_documento' => '54','tipo_doc' => '0',
//                'nro_doc' => '22254544','materia'=> '00418','tipo_examen' => '1', 'fecha_examen' => '01/01/2017', 'nota' => null);
//
//
//
//$resultado = $client->call('altaNotasIngreso', $param);

/*------------------------------------------------------------------------------------------*/

//$resp[] =  "CASO AC: \n";// PREVIAMENTE INSCRIBIR A LA ALUMNA 39033218 a la carrera 0302
//$param = array('ua' => 'FBCB', 'tipotitulo' => '1', 'carrera' => '0301', 'pais_documento' => '54','tipo_documento' => '0','nro_documento' => '39033218');
//$resultado = $client->call('estaInscripto', $param);
//$resp[] = json_decode($resultado);
//
//$resp[] = "CASO IL:\n";
//$param = array('ua' => 'FBCB', 'tipotitulo' => '1', 'carrera' => '0303', 'pais_documento' => '54','tipo_documento' => '0','nro_documento' => '39033218');
//$resultado = $client->call('estaInscripto', $param);
//$resp[] = json_decode($resultado);
//
//$resp[] =  "CASO 0:\n";
//$param = array('ua' => 'FBCB', 'tipotitulo' => '1', 'carrera' => '0303', 'pais_documento' => '54','tipo_documento' => '0','nro_documento' => '3903321');
//$resultado = $client->call('estaInscripto', $param);
//$resp[] = json_decode($resultado);
//
//
//$resp[] =  "CASO Generar Legajo :\n";
//$param = array('ua' => 'CU-RA', 'tipotitulo' => '1','carrera' => '1016', 'pais_documento' => '54','tipo_documento' => '0','nro_documento' => '813344','validado'=>'S');
//$resultado = $client->call('generaLegajo', $param);
//$resp[] = json_decode($resultado);
//
////-------------------------*************************--------------------***********************------------------
//$param = array('ua' => 'CU-RA', 'tipotitulo' => '1', 'carrera' => '1016', 'tipo_doc' => '0',
//                'nro_doc' => '8900510', 'pais_documento' => '54', 'nro_inscripcion' => '', 'cod_requisito' => '4',
//		'forma_cumpli' => '4', 'fecha_presentacion' => '03/03/2018', 'exceptuado' => 'N','validado'=>'S');
////
////
//$resultado = $client->call('altaRequisito', $param);
////
////////$resultado = $client->call('altaAspirante', $param);
//$resp = json_decode($resultado);
//
////
//$param = array('ua' => 'CU-RA', 'tipotitulo' => '1', 'carrera' => '1016', 'tipo_doc' => '0',
//                'nro_doc' => '8900510', 'pais_documento' => '54', 'nro_inscripcion' => '', 'cod_requisito' => '7',
//		'forma_cumpli' => '3');
//
//
//$resultado = $client->call('bajaRequisito', $param);
//
//$resp[] = json_decode($resultado);


//$param = array('unidad_academica' => 'FICH', 'tipoTitulo' => '1', 'carrera' => '03', 'tipo_documento' => '0', 'nro_documento' => '29686498');
//
//
//$resultado = $client->call('estadoAspirante', $param);
//$resp[] = json_decode($resultado);

//$param = array('ua' => 'FBCB', 'tipotitulo' => '1', 'carrera' => '0302', 'tipo_doc' => '0',
//                'nro_doc' => '41256461', 'pais_documento' => '54', 'nro_inscripcion' => '', 'cod_requisito' => '3',
//		'forma_cumpli' => '1');
//
//
//$resultado = $client->call('bajaRequisito', $param);
//$resp[] = json_decode($resultado);
//
//$param = array('ua' => 'FBCB', 'tipotitulo' => '1', 'carrera' => '0303', 'tipo_doc' => '0',
//                'nro_doc' => '36002862', 'pais_documento' => '54', 'nro_inscripcion' => 'FBCB-14101', 'cod_requisito' => '7',
//		'forma_cumpli' => '4');
//
//
//$resultado = $client->call('bajaRequisito', $param);
//$resp[] = json_decode($resultado);
//
//$param = array('ua' => 'FBCB', 'tipotitulo' => '1', 'carrera' => '0301', 'tipo_doc' => '0',
//                'nro_doc' => '37798100', 'pais_documento' => '54', 'nro_inscripcion' => '', 'cod_requisito' => '3',
//		'forma_cumpli' => '1');
//
//
//$resultado = $client->call('bajaRequisito', $param);
//$resp[] = json_decode($resultado);

//$param = array('ua' => 'FICH', 'tipotitulo' => '1', 'carrera' => '03', 'tipo_doc' => '0',
//                'nro_doc' => '29349542', 'pais_documento' => '54', 'fecha_inicio' => '01/01/1999'
//    ,  'fecha_fin' => '12/05-2015');
//
//
//$resultado = $client->call('becaAlumno', $param);
//
////$resultado = $client->call('altaAspirante', $param);
//$resp[] = json_decode($resultado);   

//('CU-RA','TSTA','54','0','32979009','01/01/2010','1010/2017');
//'FHUC','17', '54','0','39255571', '01/01/2012', '31/03/2018');
//$param = array('ua' => 'FHUC', 'tipotitulo' => '1', 'carrera' => '04', 'tipo_doc' => '0',
//                'nro_doc' => '29142291', 'pais_documento' => '54', 'fecha_inicio' => '01/01/2012',
//                'fecha_fin' => '03/31/2018');
//
//
//$resultado = $client->call('becaAlumno', $param);


//
//$param = array('tipo'=>'0','documento'=>"28331969",'unidadacademica'=>'fich');
//$resultado = $client->call('rendimientoAcademico', $param);
//$resp[]=json_decode($resultado);//39959243



//$param = array('ua' => 'CU-RA', 'tipotitulo' => '0', 'carrera' => '1016', 'pais_documento' => '54','tipo_documento' => '0','nro_documento' => '32979009');
//$param = array('ua' => 'FICH', 'tipotitulo' => '0', 'carrera' => '03', 'pais_documento' => '54','tipo_documento' => '0','nro_documento' => '29349542');
//$resultado = $client->call('estaInscripto', $param);
//$resp[] = json_decode($resultado);
////$resultado = $client->call('altaAspirante', $param);

//$param = array('ua' => 'FICH', 'tipotitulo' => '1', 'carrera' => '02', 'pais_documento' => '54', 'tipo_doc' => '0',
//    'nro_doc' => '40036260', 'materia' => '1');
//
//
//
$resultado = $client->call('bajaNotasIngreso', $param);
$param = array('tipo'=>'0','documento'=>"32895602",'unidadacademica'=>'FIQ');
$resultado = $client->call('rendimientoAcademico', $param);
$resp[]=json_decode($resultado);

$param = array('tipo'=>'0','documento'=>"36055680",'unidadacademica'=>'');
$resultado = $client->call('rendimientoAcademico', $param);
$resp[]=json_decode($resultado);

$param = array('tipo'=>'0','documento'=>"37232595",'unidadacademica'=>'CU-RA');
$resultado = $client->call('rendimientoAcademico', $param);
$resp[] = json_decode($resultado); 
//
$param = array('tipo'=>'0','documento'=>"39454814",'unidadacademica'=>'FCA');
$resultado = $client->call('rendimientoAcademico', $param);
$resp[] = json_decode($resultado); 

$param = array('tipo'=>'0','documento'=>"39660838",'unidadacademica'=>' FCl ');
$resultado = $client->call('rendimientoAcademico', $param);
$resp[] = json_decode($resultado);

$param = array('tipo'=>'0','documento'=>"39660838",'unidadacademica'=>' FCV ');
$resultado = $client->call('rendimientoAcademico', $param);
$resp[] = json_decode($resultado);

$param = array('tipo'=>'0','documento'=>"33469085",'unidadacademica'=>'ISM');
$resultado = $client->call('rendimientoAcademico', $param);
$resp[] = json_decode($resultado);
//$param = array('ua' => 'FBCB', 'tipotitulo' => '0', 'carrera' => '0303', 'tipo_doc' => '0',
//                'nro_doc' => '39033218', 'pais_documento' => '54', 'fecha_inicio' => '06/03/2001'
//    ,  'fecha_fin' => '06/01/2017');
//
//
//$resultado = $client->call('becaAlumno', $param);

//$resultado = $client->call('altaAspirante', $param);
//$resp[] = json_decode($resultado); 
    
print_r($resp);
die;
?>
