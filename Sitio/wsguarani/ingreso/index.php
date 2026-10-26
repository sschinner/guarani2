<?php

ob_start('limpiar');

function limpiar($buffer) {
    return trim($buffer);
}


require_once('../nusoap/lib/nusoap.php');
include("funciones.php");

$server = new soap_server;

$targetNameSpace = 'guarani/ws/ingreso';
$server->configurewsdl('ApplicationServices', $targetNameSpace,false,'rpc', 'http://schemas.xmlsoap.org/soap/http', $targetNameSpace);
$server->wsdl->schematargetnamespace = $targetNameSpace;


//$server->register('altaAspirante',  array('ua' => 'xsd:string', 'tipotitulo' => 'xsd:string',
//		'anio_acad' => 'xsd:string', 'carrera' => 'xsd:string', 'sede' => 'xsd:string',	'tipo_ingreso' => 'xsd:string',
//                'fecha_insc' => 'xsd:string', 'apellido' => 'xsd:string', 'nombres' => 'xsd:string', 'tipo_doc' => 'xsd:string',
//                'nro_doc' => 'xsd:string', 'pais_documento' => 'xsd:string', 'numero_cuil' => 'xsd:string', 'fecha_nacimiento' => 'xsd:string',
//		'sexo' => 'xsd:string', 'loc_nacimiento' => 'xsd:string', 'colegio_secundario' => 'xsd:string',	'colegio_secundario_dependencia' => 'xsd:string', 
//		'anio_egreso_sec' => 'xsd:string', 'grupo_sanguineo' => 'xsd:string', 'factor_sanguineo' => 'xsd:string', 'apellido_padre' => 'xsd:string', 
//		'apellido_madre' => 'xsd:string', 'pais_emisor_pasap' => 'xsd:string', 'nro_pasap' => 'xsd:string', 'estado_civil' => 'xsd:string', 
//		'eMail' => 'xsd:string', 'calle_per_lec' => 'xsd:string', 'numero_per_lect' => 'xsd:string', 'piso_per_lect' => 'xsd:string', 'dpto_per_lect' => 'xsd:string', 
//		'unidad_per_lect' => 'xsd:string', 'loc_per_lect' => 'xsd:string', 'cp_per_lect' => 'xsd:string', 'te_per_lect' => 'xsd:string', 
//		'calle_proc' => 'xsd:string', 'numero_proc' => 'xsd:string', 'piso_proc' => 'xsd:string', 'dpto_proc' => 'xsd:string', 'unidad_proc' => 'xsd:string', 'loc_proc' => 'xsd:string', 'cp_proc' => 'xsd:string', 'te_proc' => 'xsd:string', 
//		'otros_estud_super' => 'xsd:string', 'padre_vive' => 'xsd:string', 'madre_vive' => 'xsd:string', 'sit_laboral_alumno' => 'xsd:string',
//		'categ_ocup_alum' => 'xsd:string', 'act_econom_alum' => 'xsd:string', 'det_rama_act_alum' => 'xsd:string', 
//		'cant_horas_sem_trab_alum'  => 'xsd:string', 'sit_laboral_padre' => 'xsd:string', 'ult_est_padre' => 'xsd:string', 
//		'act_econom_padre' => 'xsd:string', 'det_rama_act_padre' => 'xsd:string', 'sit_laboral_madre' => 'xsd:string', 'ult_est_madre' => 'xsd:string', 
//		'act_econom_madre' => 'xsd:string', 'det_rama_act_madre' => 'xsd:string', 'alu_req_acces_fisica' => 'xsd:string',
//                'alu_req_acces_com' => 'xsd:string','nacionalidad' => 'xsd:string','fecha_ingreso_pais' => 'xsd:string'),
//	array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal','N/A' );
//---------------------------------------------------------------------------------------------------------

//$server->register('altaRequisito',  array('ua' => 'xsd:string', 'tipotitulo' => 'xsd:string',
//		'carrera' => 'xsd:string', 'tipo_doc' => 'xsd:string', 'nro_doc' => 'xsd:string', 
//		'pais_documento' => 'xsd:string', 'nro_inscripcion' => 'xsd:string', 'cod_requisito' => 'xsd:string', 'forma_cumpli' => 'xsd:string', 
//		'fecha_presentacion' => 'xsd:string',
//		'exceptuado' => 'xsd:string', 'validado' => 'xsd:string'),
//	array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal','N/A' );
//---------------------------------------------------------------------------------------------------------

$server->register('altaNotasIngreso',  array('ua' => 'xsd:string', 'tipotitulo' => 'xsd:integer',
		'carrera' => 'xsd:string','pais_documento' => 'xsd:integer', 'tipo_doc' => 'xsd:integer', 'nro_doc' => 'xsd:string', 
		'materia' => 'xsd:string', 'tipo_examen' => 'xsd:string', 'fecha_examen' => 'xsd:string',
                'nota' => 'xsd:string'),
	array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal',$comentarioAltaNotasIngreso );
//---------------------------------------------------------------------------------------------------------

$server->register('estaInscripto',  array('ua' => 'xsd:string', 'tipotitulo' => 'xsd:integer',
            'carrera' => 'xsd:string','pais_documento' => 'xsd:integer',
            'tipo_documento' => 'xsd:integer', 'nro_documento' => 'xsd:string'),
        array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal',$comentarioEstaInscripto );
//---------------------------------------------------------------------------------------------------------

//SE COMENTA -- AHORA ES INVOCADO DIRECTAMENTE DESDE EL ALTA REQUISITO
/*$server->register('generaLegajo',  array('ua' => 'xsd:string', 'tipotitulo' => 'xsd:string', 
                 'carrera' => 'xsd:string','pais_documento' => 'xsd:string',
            'tipo_documento' => 'xsd:string', 'nro_documento' => 'xsd:string', 'validado' => 'xsd:string'),
        array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal','N/A' );*/
 
//---------------------------------------------------------------------------------------------------------

$server->register('bajaRequisito',  array('ua' => 'xsd:string', 'tipotitulo' => 'xsd:integer',
		'carrera' => 'xsd:string', 'tipo_doc' => 'xsd:integer', 'nro_doc' => 'xsd:string', 
		'pais_documento' => 'xsd:integer', 'nro_inscripcion' => 'xsd:string', 
                'cod_requisito' => 'xsd:integer'),
	array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal',$comentarioBajaRequisito );
//---------------------------------------------------------------------------------------------------------

$server->register('becaAlumno',  array('ua' => 'xsd:string', 'tipotitulo' => 'xsd:integer',
		'carrera' => 'xsd:string', 'tipo_doc' => 'xsd:integer', 'nro_doc' => 'xsd:string', 
		'pais_documento' => 'xsd:integer', 'fecha_inicio' => 'xsd:string', 'fecha_fin' => 'xsd:string'),
	array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal',$comentarioBecaAlumno );
//---------------------------------------------------------------------------------------------------------

$server->register('bajaNotasIngreso',  array('ua' => 'xsd:string', 'tipotitulo' => 'xsd:integer',
		'carrera' => 'xsd:string','pais_documento' => 'xsd:integer', 'tipo_doc' => 'xsd:integer', 'nro_doc' => 'xsd:string', 
		'materia' => 'xsd:string'),
	array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal',$comentarioBajaNotasIngreso );

//-----------------------------------------------------------------------------------------------------------

$server->register('rendimientoAcademico',array('tipo' => 'xsd:integer','documento' => 'xsd:string','pais' => 'xsd:integer','unidadacademica' => 'xsd:string'),
		array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal',$comentarioRendiminetoAcademico );

//---------------------------------------------------------------------------------------------------------------

$server->register('estadoAspirante',array('unidad_academica' => 'xsd:string','tipoTitulo' => 'xsd:integer','carrera' => 'xsd:string','tipo_documento' => 'xsd:integer','nro_documento' => 'xsd:string'),
		array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal',$comentarioEstadoAspirante );

//---------------------------------------------------------------------------------------------------------------

$server->register('insertarAspirante',  array(
        'ua'            => 'xsd:string', 'tipotitulo'   => 'xsd:integer',
		'anio_acad'     => 'xsd:integer', 'carrera'      => 'xsd:string', 
        'sede'          => 'xsd:string', 'tipo_ingreso' => 'xsd:string', 
        'fecha_insc'    => 'xsd:string', 'apellido'     => 'xsd:string', 
        'nombres'       => 'xsd:string', 'pais_documento'   => 'xsd:integer', 
        'tipo_doc'      => 'xsd:integer', 'nro_doc'          => 'xsd:string', 
        'numero_cuil'   => 'xsd:string', 'fecha_nacimiento' => 'xsd:string',
		'sexo'          => 'xsd:string', 'nacionalidad'     => 'xsd:string', 
        'pais_origen'   => 'xsd:string', 'email'            => 'xsd:string'),
	array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal', $comentarioInsertarAspirante );

//---------------------------------------------------------------------------------------------------------------

$server->register('insertarRequisito',  array('ua' => 'xsd:string', 'tipotitulo' => 'xsd:integer',
		'carrera' => 'xsd:string', 'tipo_doc' => 'xsd:integer', 'nro_doc' => 'xsd:string', 
		'pais_documento' => 'xsd:integer', 'cod_requisito' => 'xsd:integer', 
		'fecha_presentacion' => 'xsd:string',
		),
	array('return'=>'xsd:string'),$targetNameSpace,false,false,'literal', $comentarioInsertarRequisito );

$HTTP_RAW_POST_DATA = isset($HTTP_RAW_POST_DATA) ? $HTTP_RAW_POST_DATA : '';

$server->service($HTTP_RAW_POST_DATA);
ob_end_flush();
exit;
?>
