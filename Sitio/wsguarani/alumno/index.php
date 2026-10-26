<?php

ob_start('limpiar');

function limpiar($buffer) {
    return trim($buffer);
}

//require_once("adodb/adodb.inc.php"); 


require_once('../nusoap/lib/nusoap.php');
include_once("funciones.php");

$server = new soap_server;

$targetNameSpace = 'guarani/ws/alumno';
$server->configurewsdl('ApplicationServices', $targetNameSpace,false,'rpc', 'http://schemas.xmlsoap.org/soap/http', $targetNameSpace);
$server->wsdl->schematargetnamespace = $targetNameSpace;


$server->register('rendimientoAcademico',array('tipo' => 'xsd:integer','documento' => 'xsd:string','pais' => 'xsd:integer','unidadacademica' => 'xsd:string'),
		array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal', $comentarioRendiminetoAcademico );

/*******************************************************************************/

$server->register('datosCensalesAlumno',array('unidadAcademica' => 'xsd:string','tipoTitulo'=>'xsd:integer','filtro'=>'xsd:string','valor1'=>'xsd:string','valor2'=>'xsd:string','valor3'=>'xsd:string'),
		array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal', $comentarioDatosCensalesAlumno );

/********************************************************************************/

$server->register('autenticarAlumno',array('usuario' => 'xsd:string','clave' => 'xsd:string','unidadAcademica' => 'xsd:string','tipoTitulo'=>'xsd:integer'),
		array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal', $comentarioAutenticarAlumno );

/********************************************************************************/

$server->register('historiaAcademicaAlumno',array('carrera' => 'xsd:string','tipo' => 'xsd:integer','documento' => 'xsd:string','pais' => 'xsd:integer','unidadAcademica' => 'xsd:string','tipoTitulo' => 'xsd:integer'),
		array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal', $comentarioHistoriaAcademica);



/********************************************************************************/

$server->register('estadoAlumno',array('unidadAcademica' => 'xsd:string','tipoTitulo'=>'xsd:integer','filtro'=>'xsd:string','valor1'=>'xsd:string','valor2'=>'xsd:string','valor3'=>'xsd:string'),
		array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal', $comentarioEstadoAlumno );


/********************************************************************************/

$server->register('carrerasAlumno',array('nroDocumento'=>'xsd:string','tipoDocumento'=>'xsd:integer','paisDocumento'=>'xsd:integer','unidadAcademica' => 'xsd:string'),
		array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal', $comentarioCarrerasAlumno );


/********************************************************************************/

/*$server->wsdl->addComplexType(
  'fecha_ingreso_pais',  'complexType', 'struct', 'all', '', array(
   'fecha_ingreso_pais'=> array('name' => 'fecha_ingreso_pais','type'=> 'xsd:string', 'nillable' => 'true'))
 );

$server->wsdl->addComplexType(
  'apellido_padre',  'complexType', 'struct', 'all', '', array(
   'apellido_padre'=> array('name' => 'apellido_padre','type'=> 'xsd:string', 'nillable' => 'true'))
 );

$server->register('insertaDatosCensales',
            array(  //'unidadAcademica' => 'xsd:string',
                    //'tipoTitulo' => 'xsd:string',
                    'nroDocumento'=>'xsd:string',
                    'tipoDocumento'=>'xsd:string',
                    'paisDocumento'=>'xsd:string',
                    'fecha_ingreso_pais'=> 'xsd:string',
                    'apellido_padre' => 'xsd:string', 
                    'apellido_madre' => 'xsd:string', 'pais_emisor_pasap' => 'xsd:string',
                    'nro_pasap' => 'xsd:string', 'estado_civil' => 'xsd:string', 
                    'calle_per_lect' => 'xsd:string', 'numero_per_lect' => 'xsd:string',
                    'piso_per_lect' => 'xsd:string', 'dpto_per_lect' => 'xsd:string', 
                    'unidad_per_lect' => 'xsd:string', 'loc_per_lect' => 'xsd:string',
                    'cp_per_lect' => 'xsd:string', 'te_per_lect' => 'xsd:string', 
                    'calle_proc' => 'xsd:string', 'numero_proc' => 'xsd:string', 'piso_proc' => 'xsd:string',
                    'dpto_proc' => 'xsd:string', 'unidad_proc' => 'xsd:string', 'loc_proc' => 'xsd:string',
                    'cp_proc' => 'xsd:string', 'te_proc' => 'xsd:string', 
                    'otros_estud_super' => 'xsd:string', 'padre_vive' => 'xsd:string',
                    'madre_vive' => 'xsd:string', 'sit_laboral_alumno' => 'xsd:string',
                    'categ_ocup_alum' => 'xsd:string', 'act_econom_alum' => 'xsd:string',
                    'det_rama_act_alum' => 'xsd:string','cant_horas_sem_trab_alum'  => 'xsd:string',
                    'sit_laboral_padre' => 'xsd:string', 'ult_est_padre' => 'xsd:string', 
                    'act_econom_padre' => 'xsd:string', 'det_rama_act_padre' => 'xsd:string',
                    'sit_laboral_madre' => 'xsd:string', 'ult_est_madre' => 'xsd:string', 
                    'act_econom_madre' => 'xsd:string', 'det_rama_act_madre' => 'xsd:string',
                    'alu_req_acces_fisica' => 'xsd:string', 'alu_req_acces_com' => 'xsd:string',
                     'nivel_otros_estud' => 'xsd:string','localidad_nacimiento'=>'xsd:string','nacionalidad' =>'xsd:string' ),
	    array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal', $comentarioInsertaDatosCensales );
        */
//$server->wsdl->addComplexType(
//  'acepta_nulos',  'complexType', 'struct', 'all', '', array(
//   'acepta_nulos'=> array('name' => 'acepta_nulos','type'=> 'xsd:string', 'nillable' => 'true'))
// );

//$server->wsdl->addComplexType(
//  'acepta_nulos_int',  'complexType', 'struct', 'all', '', array(
//   'acepta_nulos'=> array('name' => 'acepta_nulos_int','type'=> 'xsd:integer', 'nillable' => 'true'))
// );


$server->register('insertaDatosCensales',
            array(  'nroDocumento'=>'xsd:string',
                    'tipoDocumento'=>'xsd:integer',
                    'paisDocumento'=>'xsd:integer',
                    'fecha_ingreso_pais'=> 'xsd:string',
                    'apellido_padre' => 'xsd:string', 
                    'apellido_madre' => 'xsd:string', 'pais_emisor_pasap' => 'xsd:integer',
                    'nro_pasap' => 'xsd:string', 'estado_civil' => 'xsd:string', 
                    'calle_per_lect' => 'xsd:string', 'numero_per_lect' => 'xsd:string',
                    'piso_per_lect' => 'xsd:string', 'dpto_per_lect' => 'xsd:string', 
                    'unidad_per_lect' => 'xsd:string', 'loc_per_lect' => 'xsd:string',
                    'cp_per_lect' => 'xsd:string', 'te_per_lect' => 'xsd:string', 
                    'calle_proc' => 'xsd:string', 'numero_proc' => 'xsd:string',
                    'piso_proc' => 'xsd:string',
                    'dpto_proc' => 'xsd:string', 'unidad_proc' => 'xsd:string',
                    'loc_proc' => 'xsd:string',
                    'cp_proc' => 'xsd:string', 'te_proc' => 'xsd:string', 
                    'otros_estud_super' => 'xsd:string', 'padre_vive' => 'xsd:string',
                    'madre_vive' => 'xsd:string', 'sit_laboral_alumno' => 'xsd:string',
                    'categ_ocup_alum' => 'xsd:string', 'act_econom_alum' => 'xsd:string',
                    'det_rama_act_alum' => 'xsd:string','cant_horas_sem_trab_alum'  => 'xsd:string',
                    'sit_laboral_padre' => 'xsd:string', 'ult_est_padre' => 'xsd:string', 
                    'act_econom_padre' => 'xsd:string', 'det_rama_act_padre' => 'xsd:string',
                    'sit_laboral_madre' => 'xsd:string', 'ult_est_madre' => 'xsd:string', 
                    'act_econom_madre' => 'xsd:string', 'det_rama_act_madre' => 'xsd:string',
                    'alu_req_acces_fisica' => 'xsd:string', 'alu_req_acces_com' => 'xsd:string',
                    'nivel_otros_estud' => 'xsd:string','localidad_nacimiento'=>'xsd:string',
                    'nacionalidad' =>'xsd:string','colegio_secundario'=>'xsd:string' ),
	    array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal', $comentarioInsertaDatosCensales );

$server->register('validarRequisitosDiploma',  array('ua' => 'xsd:string',
		'tipo_doc' => 'xsd:integer', 'nro_doc' => 'xsd:string', 
		'pais_documento' => 'xsd:integer', 'solicitud' => 'xsd:string', 'requisitos_validados' => 'xsd:string'),
	array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal','N/A' );

$server->register('solicitudesTitulo',  array('ua' => 'xsd:string', 'pais_documento' => 'xsd:integer', 'tipo_doc' => 'xsd:integer', 'nro_doc' => 'xsd:string'),
	array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal','N/A' );

$server->register('urlSolicitud',  array('ua' => 'xsd:string', 'pais_documento' => 'xsd:integer', 'tipo_doc' => 'xsd:integer', 'nro_doc' => 'xsd:string', 'solicitud' => 'xsd:string'),
	array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal','N/A' );
/*
$server->wsdl->addComplexType(
  'fecha_ingreso_pais',  'complexType', 'struct', 'all', '', array(
   'fecha_ingreso_pais'=> array('name' => 'fecha_ingreso_pais','type'=> 'xsd:string', 'nillable' => 'true'))
 );

$server->wsdl->addComplexType(
  'apellido_padre',  'complexType', 'struct', 'all', '', array(
   'apellido_padre'=> array('name' => 'apellido_padre','type'=> 'xsd:string', 'nillable' => 'true'))
 );
$server->wsdl->addComplexType(
  'apellido_madre',  'complexType', 'struct', 'all', '', array(
   'apellido_madre'=> array('name' => 'apellido_madre','type'=> 'xsd:string', 'nillable' => 'true'))
 );

$server->wsdl->addComplexType(
  'pais_emisor_pasap',  'complexType', 'struct', 'all', '', array(
   'pais_emisor_pasap'=> array('name' => 'pais_emisor_pasap','type'=> 'xsd:string', 'nillable' => 'true'))
 );
$server->wsdl->addComplexType(
  'nro_pasap',  'complexType', 'struct', 'all', '', array(
   'nro_pasap'=> array('name' => 'nro_pasap','type'=> 'xsd:string', 'nillable' => 'true'))
 );

$server->wsdl->addComplexType(
  'estado_civil',  'complexType', 'struct', 'all', '', array(
   'estado_civil'=> array('name' => 'estado_civil','type'=> 'xsd:string', 'nillable' => 'true'))
 );
$server->wsdl->addComplexType(
  'calle_per_lect',  'complexType', 'struct', 'all', '', array(
   'calle_per_lect'=> array('name' => 'calle_per_lect','type'=> 'xsd:string', 'nillable' => 'true'))
 );

$server->wsdl->addComplexType(
  'numero_per_lect',  'complexType', 'struct', 'all', '', array(
   'numero_per_lect'=> array('name' => 'numero_per_lect','type'=> 'xsd:string', 'nillable' => 'true'))
 );
$server->wsdl->addComplexType(
  'piso_per_lect',  'complexType', 'struct', 'all', '', array(
   'piso_per_lect'=> array('name' => 'piso_per_lect','type'=> 'xsd:string', 'nillable' => 'true'))
 );

$server->wsdl->addComplexType(
  'dpto_per_lect',  'complexType', 'struct', 'all', '', array(
   'dpto_per_lect'=> array('name' => 'dpto_per_lect','type'=> 'xsd:string', 'nillable' => 'true'))
 );
$server->wsdl->addComplexType(
  'unidad_per_lect',  'complexType', 'struct', 'all', '', array(
   'unidad_per_lect'=> array('name' => 'unidad_per_lect','type'=> 'xsd:string', 'nillable' => 'true'))
 );

$server->wsdl->addComplexType(
  'loc_per_lect',  'complexType', 'struct', 'all', '', array(
   'loc_per_lect'=> array('name' => 'loc_per_lect','type'=> 'xsd:string', 'nillable' => 'true'))
 );
$server->wsdl->addComplexType(
  'cp_per_lect',  'complexType', 'struct', 'all', '', array(
   'cp_per_lect'=> array('name' => 'cp_per_lect','type'=> 'xsd:string', 'nillable' => 'true'))
 );

$server->wsdl->addComplexType(
  'te_per_lect',  'complexType', 'struct', 'all', '', array(
   'te_per_lect'=> array('name' => 'te_per_lect','type'=> 'xsd:string', 'nillable' => 'true'))
 );
$server->wsdl->addComplexType(
  'calle_proc',  'complexType', 'struct', 'all', '', array(
   'calle_proc'=> array('name' => 'calle_proc','type'=> 'xsd:string', 'nillable' => 'true'))
 );
$server->wsdl->addComplexType(
  'numero_proc',  'complexType', 'struct', 'all', '', array(
   'numero_proc'=> array('name' => 'numero_proc','type'=> 'xsd:string', 'nillable' => 'true'))
 );

$server->wsdl->addComplexType(
  'piso_proc',  'complexType', 'struct', 'all', '', array(
   'piso_proc'=> array('name' => 'piso_proc','type'=> 'xsd:string', 'nillable' => 'true'))
 );
$server->wsdl->addComplexType(
  'dpto_proc',  'complexType', 'struct', 'all', '', array(
   'dpto_proc'=> array('name' => 'dpto_proc','type'=> 'xsd:string', 'nillable' => 'true'))
 );

$server->wsdl->addComplexType(
  'unidad_proc',  'complexType', 'struct', 'all', '', array(
   'unidad_proc'=> array('name' => 'unidad_proc','type'=> 'xsd:string', 'nillable' => 'true'))
 );

$server->wsdl->addComplexType(
  'loc_proc',  'complexType', 'struct', 'all', '', array(
   'loc_proc'=> array('name' => 'loc_proc','type'=> 'xsd:string', 'nillable' => 'true'))
 );
$server->wsdl->addComplexType(
  'cp_proc',  'complexType', 'struct', 'all', '', array(
   'cp_proc'=> array('name' => 'cp_proc','type'=> 'xsd:string', 'nillable' => 'true'))
 );
$server->wsdl->addComplexType(
  'te_proc',  'complexType', 'struct', 'all', '', array(
   'te_proc'=> array('name' => 'te_proc','type'=> 'xsd:string', 'nillable' => 'true'))
 );

$server->wsdl->addComplexType(
  'otros_estud_super',  'complexType', 'struct', 'all', '', array(
   'otros_estud_super'=> array('name' => 'otros_estud_super','type'=> 'xsd:string', 'nillable' => 'true'))
 );
$server->wsdl->addComplexType(
  'padre_vive',  'complexType', 'struct', 'all', '', array(
   'padre_vive'=> array('name' => 'padre_vive','type'=> 'xsd:string', 'nillable' => 'true'))
 );

$server->wsdl->addComplexType(
  'madre_vive',  'complexType', 'struct', 'all', '', array(
   'madre_vive'=> array('name' => 'madre_vive','type'=> 'xsd:string', 'nillable' => 'true'))
 );
$server->wsdl->addComplexType(
  'sit_laboral_alumno',  'complexType', 'struct', 'all', '', array(
   'sit_laboral_alumno'=> array('name' => 'sit_laboral_alumno','type'=> 'xsd:string', 'nillable' => 'true'))
 );

$server->wsdl->addComplexType(
  'categ_ocup_alum',  'complexType', 'struct', 'all', '', array(
   'categ_ocup_alum'=> array('name' => 'categ_ocup_alum','type'=> 'xsd:string', 'nillable' => 'true'))
 );
$server->wsdl->addComplexType(
  'act_econom_alum',  'complexType', 'struct', 'all', '', array(
   'act_econom_alum'=> array('name' => 'act_econom_alum','type'=> 'xsd:string', 'nillable' => 'true'))
 );
$server->wsdl->addComplexType(
  'det_rama_act_alum',  'complexType', 'struct', 'all', '', array(
   'det_rama_act_alum'=> array('name' => 'det_rama_act_alum','type'=> 'xsd:string', 'nillable' => 'true'))
 );

$server->wsdl->addComplexType(
  'cant_horas_sem_trab_alum',  'complexType', 'struct', 'all', '', array(
   'cant_horas_sem_trab_alum'=> array('name' => 'cant_horas_sem_trab_alum','type'=> 'xsd:string', 'nillable' => 'true'))
 );
$server->wsdl->addComplexType(
  'sit_laboral_padre',  'complexType', 'struct', 'all', '', array(
   'sit_laboral_padre'=> array('name' => 'sit_laboral_padre','type'=> 'xsd:string', 'nillable' => 'true'))
 );

$server->wsdl->addComplexType(
  'ult_est_padre',  'complexType', 'struct', 'all', '', array(
   'ult_est_padre'=> array('name' => 'ult_est_padre','type'=> 'xsd:string', 'nillable' => 'true'))
 );
$server->wsdl->addComplexType(
  'act_econom_padre',  'complexType', 'struct', 'all', '', array(
   'act_econom_padre'=> array('name' => 'act_econom_padre','type'=> 'xsd:string', 'nillable' => 'true'))
 );
$server->wsdl->addComplexType(
  'det_rama_act_padre',  'complexType', 'struct', 'all', '', array(
   'det_rama_act_padre'=> array('name' => 'det_rama_act_padre','type'=> 'xsd:string', 'nillable' => 'true'))
 );
$server->wsdl->addComplexType(
  'sit_laboral_madre',  'complexType', 'struct', 'all', '', array(
   'sit_laboral_madre'=> array('name' => 'sit_laboral_madre','type'=> 'xsd:string', 'nillable' => 'true'))
 );

$server->wsdl->addComplexType(
  'ult_est_madre',  'complexType', 'struct', 'all', '', array(
   'ult_est_madre'=> array('name' => 'ult_est_madre','type'=> 'xsd:string', 'nillable' => 'true'))
 );
$server->wsdl->addComplexType(
  'act_econom_madre',  'complexType', 'struct', 'all', '', array(
   'act_econom_madre'=> array('name' => 'act_econom_madre','type'=> 'xsd:string', 'nillable' => 'true'))
 );

$server->wsdl->addComplexType(
  'det_rama_act_madre',  'complexType', 'struct', 'all', '', array(
   'det_rama_act_madre'=> array('name' => 'det_rama_act_madre','type'=> 'xsd:string', 'nillable' => 'true'))
 );

$server->wsdl->addComplexType(
  'alu_req_acces_fisica',  'complexType', 'struct', 'all', '', array(
   'alu_req_acces_fisica'=> array('name' => 'alu_req_acces_fisica','type'=> 'xsd:string', 'nillable' => 'true'))
 );

$server->wsdl->addComplexType(
  'alu_req_acces_com',  'complexType', 'struct', 'all', '', array(
   'alu_req_acces_com'=> array('name' => 'alu_req_acces_com','type'=> 'xsd:string', 'nillable' => 'true'))
 );
$server->wsdl->addComplexType(
  'nivel_otros_estud',  'complexType', 'struct', 'all', '', array(
   'nivel_otros_estud'=> array('name' => 'nivel_otros_estud','type'=> 'xsd:string', 'nillable' => 'true'))
 );

$server->wsdl->addComplexType(
  'localidad_nacimiento',  'complexType', 'struct', 'all', '', array(
   'localidad_nacimiento'=> array('name' => 'localidad_nacimiento','type'=> 'xsd:string', 'nillable' => 'true'))
 );
$server->wsdl->addComplexType(
  'nacionalidad',  'complexType', 'struct', 'all', '', array(
   'nacionalidad'=> array('name' => 'nacionalidad','type'=> 'xsd:string', 'nillable' => 'true'))
 );


$server->register('insertaDatosCensales',
            array(  //'unidadAcademica' => 'xsd:string',
                    //'tipoTitulo' => 'xsd:string',
                    'nroDocumento'=>'xsd:string',
                    'tipoDocumento'=>'xsd:string',
                    'paisDocumento'=>'xsd:string',
                    'fecha_ingreso_pais'=> 'tns:fecha_ingreso_pais',
                    'apellido_padre' => 'tns:apellido_padre', 
                    'apellido_madre' => 'tns:apellido_madre',
                    'pais_emisor_pasap' => 'tns:pais_emisor_pasap',
                    'nro_pasap' => 'tns:nro_pasap',
                    'estado_civil' => 'tns:estado_civil', 
                    'calle_per_lect' => 'tns:calle_per_lect',
                    'numero_per_lect' => 'tns:numero_per_lect',
                    'piso_per_lect' => 'tns:piso_per_lect',
                    'dpto_per_lect' => 'tns:dpto_per_lect', 
                    'unidad_per_lect' => 'tns:unidad_per_lect', 
                    'loc_per_lect' => 'tns:loc_per_lect',
                    'cp_per_lect' => 'tns:cp_per_lect',
                    'te_per_lect' => 'tns:te_per_lect', 
                    'calle_proc' => 'tns:calle_proc',
                    'numero_proc' => 'tns:numero_proc', 
                    'piso_proc' => 'tns:piso_proc',
                    'dpto_proc' => 'tns:dpto_proc', 
                    'unidad_proc' => 'tns:unidad_proc',
                    'loc_proc' => 'tns:loc_proc',
                    'cp_proc' => 'tns:cp_proc',
                    'te_proc' => 'tns:te_proc', 
                    'otros_estud_super' => 'tns:otros_estud_super',
                    'padre_vive' => 'tns:padre_vive',
                    'madre_vive' => 'tns:madre_vive',
                    'sit_laboral_alumno' => 'tns:sit_laboral_alumno',
                    'categ_ocup_alum' => 'tns:categ_ocup_alum',
                    'act_econom_alum' => 'tns:act_econom_alum',
                    'det_rama_act_alum' => 'tns:det_rama_act_alum',
                    'cant_horas_sem_trab_alum'  => 'tns:cant_horas_sem_trab_alum',
                    'sit_laboral_padre' => 'tns:sit_laboral_padre',
                    'ult_est_padre' => 'tns:ult_est_padre', 
                    'act_econom_padre' => 'tns:act_econom_padre',
                    'det_rama_act_padre' => 'tns:det_rama_act_padre',
                    'sit_laboral_madre' => 'tns:sit_laboral_madre',
                    'ult_est_madre' => 'tns:ult_est_madre', 
                    'act_econom_madre' => 'tns:act_econom_madre',
                    'det_rama_act_madre' => 'tns:det_rama_act_madre',
                    'alu_req_acces_fisica' => 'tns:alu_req_acces_fisica',
                    'alu_req_acces_com' => 'tns:alu_req_acces_com',
                    'nivel_otros_estud' => 'tns:nivel_otros_estud',
                    'localidad_nacimiento'=>'tns:localidad_nacimiento',
                    'nacionalidad' =>'tns:nacionalidad' ),
	    array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal', $comentarioInsertaDatosCensales );*/


/********************************************************************************/

//$server->register('catalogo',array('filtro'=>'xsd:string'),array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal', $comentarioInsertaDatosCensales );

$HTTP_RAW_POST_DATA = isset($HTTP_RAW_POST_DATA) ? $HTTP_RAW_POST_DATA : '';

$server->service($HTTP_RAW_POST_DATA);
ob_end_flush();
exit;
?>
