<?php

require_once ('Redecode.php');
include_once (dirname(__DIR__) . "/configServer.php");

class RepositorioWS {

    public function obtenerDatosCensales($usuario, $objCC) {

        if (isset($usuario) && !empty($usuario)) {
            $resultado = $this->getDatosCensales($usuario, $objCC);
            return $resultado;
        }
    }

    public function obtenerHistoriaAcademicaAlumno($carrera, $tipo, $documento, $pais, $unidadAcademica, $objCC) {

        if (!empty($carrera) && ($tipo !== '') && !empty($documento) && !empty($pais)) {
            $parametros = array($carrera, $tipo, $documento, $pais, $unidadAcademica);
            return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_historia_academica', $objCC);
        }
    }

    public function obtenerDatosCensalesAlumno($filtro, $valor1, $valor2, $valor3, $ua, $objCC) {

        if (!empty($filtro) && !empty($valor1)) {
            $parametros = array($filtro, $valor1, $valor2, $valor3, $ua);
            return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_datos_censales_alumno', $objCC);
        }
    }

    public function regularidadMedioBoleto($valor1, $valor2, $objCC) {

        $parametros = array($valor1, $valor2);
        return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_medio_boleto', $objCC);
    }

    public function obtenerEstadoAlumno($filtro, $valor1, $valor2, $valor3, $ua, $objCC) {

        if (!empty($filtro) && !empty($valor1)) {
            $parametros = array($filtro, $valor1, $valor2, $valor3, $ua);
            return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_estado_alumno', $objCC);
        }
    }
    
    public function actualizaDatosCensales($nroDocumento, $tipoDoc, $paisDoc,
                                       $set_mdp_datos_personales,$set_mdp_datos_economicos,
                                       $set_mdp_personas_allegados_padre,$set_mdp_personas_allegados_madre,
                                       $insert_mdp_datos_economicos, $values_mdp_datos_economicos,
                                       $insert_personas_allegados_padre, $values_personas_allegados_padre,
                                       $insert_personas_allegados_madre, $values_personas_allegados_madre,
                                       $te_per_lect, $te_proc, $alu_req_acces_fisica,
                                       $alu_req_acces_com,$otros_estud_super,$nivel_otros_estud,$fecha_ingreso_pais,
                                       $set_mdp_personas,$colegio_secundario, $objCC){
        
        $parametros = array($nroDocumento, (int)$tipoDoc, (int)$paisDoc,
                                       $set_mdp_datos_personales,$set_mdp_datos_economicos,
                                       $set_mdp_personas_allegados_padre,$set_mdp_personas_allegados_madre,
                                       $insert_mdp_datos_economicos, $values_mdp_datos_economicos,
                                       $insert_personas_allegados_padre, $values_personas_allegados_padre,
                                       $insert_personas_allegados_madre, $values_personas_allegados_madre,
                                       $te_per_lect, $te_proc, $alu_req_acces_fisica,
                                       $alu_req_acces_com,$otros_estud_super,$nivel_otros_estud,
                                       $fecha_ingreso_pais, $set_mdp_personas,$colegio_secundario);
      
        return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_ui_datos_censales', $objCC);                                
        
    }

    public function getHorariosComisiones($anio_academico, $periodo_lectivo, $ua, $objCC) {

        if (!empty($anio_academico) && !empty($periodo_lectivo)) {
            $parametros = array($anio_academico, $periodo_lectivo, $ua);
            return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_horarios_comisiones', $objCC);
        }
    }

    public function getDatosPropuestasUA($unidadAcademica, $objCC) {

        if (!empty($unidadAcademica)) {
            $parametros = array($unidadAcademica);
            return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_propuestas_ua', $objCC);
        }
    }

    public function obtenerDatosAcademicos($tipoDocumento, $nroDocumento, $objCC) {

        if ($tipoDocumento != "" && !empty($nroDocumento)) {
            $resultado = $this->getDatosAcademicos($tipoDocumento, $nroDocumento, $objCC);
            return $resultado;
        }
    }

    public function obtenerRendimientoAcademico($tipoDocumento, $nroDocumento, $pais, $objCC) {

        if ($tipoDocumento != "" && !empty($nroDocumento) && $pais != "") {
            $resultado = $this->getRendimientoAcademico($tipoDocumento, $nroDocumento, $pais, $objCC);
            return $resultado;
        }
    }

    public function obtenerPromedioPorCarrera($objCC) {

        $resultado = $this->getPromedioPorCarrera($objCC);
        return $resultado;
    }

    public function validarUsuarioGuarani($usuario, $objCC) {

        if (isset($usuario) && !empty($usuario)) {
            $resultado = $this->autenticaUsuario($usuario, $objCC);
            return $resultado;
        }
    }

    public function obtenerCondicionAspirante($tipo, $documento, $carrera, $objCC) {

        if ($tipo != "" && !empty($documento) && !empty($carrera)) {

            $parametros = array($tipo, $documento, $carrera);
            return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_condicion_aspirante', $objCC);
        }
    }

    public function becaAlumno($carrera, $pais_documento, $tipo_documento, $nro_documento, $fechaInicio1, $fechaFin1, $objCC) {

        if ($pais_documento != "" && $tipo_documento != '' && $nro_documento != '' && $fechaInicio1 != '' && $fechaFin1 != '') {

            $parametros = array($carrera, $pais_documento, $tipo_documento, $nro_documento, $fechaInicio1, $fechaFin1);
            return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_beca_alumno', $objCC);
        }
    }

    public function obtenerRequisitosAspirante($tipo, $documento, $carrera, $objCC) {

        if ($tipo != "" && !empty($documento) && !empty($carrera)) {

            $parametros = array($tipo, $documento, $carrera);
            return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_requisitos_ingreso', $objCC);
        }
    }

    public function obtenerPeriodosLectivos($anio_academico, $unidadAcademica, $objCC) {

		if ($anio_academico != "" && $unidadAcademica != "") {

            $parametros = array($anio_academico, $unidadAcademica);
            return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_periodos_lectivos', $objCC);
        }
    }

    public function obtenerTurnosExamen($anio_academico, $unidadAcademica, $objCC) {

		if ($anio_academico != "" && $unidadAcademica != "") {

            $parametros = array($anio_academico, $unidadAcademica);
            return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_turnos_examen', $objCC);
        }
    }

    public function obtenerMesasExamen($ua, $turno_examen, $objCC)
	{
		if (isset($turno_examen)) {

            $parametros = [$ua, $turno_examen];
            return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_mesas_examen', $objCC);
        }
    }
	
	public function obtenerPropuestasHabilitadas($mesa_examen, $objCC)
	{
        $sth = $objCC->prepare('
			SELECT DISTINCT nombre as propuesta_nombre
			FROM sga_mesas_examen_propuestas 
			JOIN sga_propuestas USING (propuesta)
			WHERE mesa_examen = :pmesa_examen;
		');
        $sth->execute(array(':pmesa_examen' => $mesa_examen));
        $resul = $sth->fetchAll(PDO::FETCH_NAMED);
        return $resul;
	}
	
	public function obtenerTribunalMesa($mesa_examen, $objCC)
	{
        $sth = $objCC->prepare('
			SELECT	DISTINCT P.apellido, P.nombres 
			FROM	sga_docentes_mesa_llamado DL
			JOIN	sga_llamados_mesa LM USING (llamado_mesa)
			JOIN	sga_docentes D USING (docente)
			JOIN	mdp_personas P USING (persona)
			WHERE	LM.mesa_examen = :pmesa_examen
		');
        $sth->execute(array(':pmesa_examen' => $mesa_examen));
        $resul = $sth->fetchAll(PDO::FETCH_NAMED);
        return $resul;
	}
	
	public function obtenerInscriptosMesa($mesa_examen, $objCC)
	{
        $sth = $objCC->prepare('
			SELECT 	count(1)
			FROM 	vw_insc_examen
			JOIN 	sga_llamados_mesa USING (llamado_mesa)
			WHERE	mesa_examen = :pmesa_examen
		');
        $sth->execute(array(':pmesa_examen' => $mesa_examen));
        $resul = $sth->fetchAll(PDO::FETCH_COLUMN);
        return (string) array_pop($resul);
	}
	
	public function obtenerLlamadosMesa($mesa_examen, $objCC)
	{
        $sth = $objCC->prepare('
			SELECT LM.llamado, P.nombre as llamado_nombre, fecha, hora_inicio, hora_finalizacion 
			FROM sga_llamados_mesa LM
			JOIN sga_llamados_turno USING (llamado)
			JOIN sga_periodos P USING (periodo)
			WHERE mesa_examen = :pmesa_examen
		');
        $sth->execute([':pmesa_examen' => $mesa_examen]);
        $resul = $sth->fetchAll(PDO::FETCH_NAMED);
        return $resul;
	}

    public function obtenerCursosIngreso($tipo, $documento, $carrera, $objCC) {

        if ($tipo != "" && !empty($documento) && !empty($carrera)) {

            $parametros = array($tipo, $documento, $carrera);
            return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_cursos_ingreso', $objCC);
        }
    }

    public function validarUsuarioWifi($tipodoc, $nrodoc, $objCC) {

        if ($tipodoc != '' && $nrodoc != '') {
            $resultado = $this->autenticaUsuarioWifi($tipodoc, $nrodoc, $objCC);
            return $resultado;
        }
    }

    public function estaInscripto($carrera, $paisDocumento, $tipoDocumento, $nroDocumento, $objCC) {

        if ($tipoDocumento != "" && !empty($nroDocumento) && !empty($paisDocumento) && !empty($carrera)) {

            $parametros = array($carrera, $paisDocumento, $tipoDocumento, $nroDocumento);
            return $this->ejecutaFuncionPostgre($parametros, 'funl_esta_inscripto', $objCC);
        }
    }

    public function solicitudesTitulo($paisDocumento, $tipoDocumento, $nroDocumento, $objCC) {

        if ($tipoDocumento != "" && !empty($nroDocumento) && !empty($paisDocumento)) {

            $parametros = array($paisDocumento, $tipoDocumento, $nroDocumento);
            return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_solicitudes_titulo', $objCC);
        }
    }

    public function urlSolicitud($paisDocumento, $tipoDocumento, $nroDocumento, $solicitud, $objCC) {

        if ($tipoDocumento != "" && !empty($nroDocumento) && !empty($paisDocumento) && !empty($solicitud)) {

            $parametros = array($paisDocumento, $tipoDocumento, $nroDocumento, $solicitud);
            return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_url_solicitud', $objCC);
        }
    }

    public function autenticarWifi($tipodoc, $nrodoc, $objCC) {

        if ($tipodoc != '' && $nrodoc != '') {
            $parametros = array($tipodoc, $nrodoc);

            return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_autenticar_wifi', $objCC);
        }
    }

    public function insertarAspirante($ua, $anio_acad, $carrera, $sede, $tipo_ingreso, $fecha_insc, $apellido, $nombres, $tipo_doc, $nro_doc, $pais_documento, $numero_cuil, $fecha_nacimiento, $sexo, $loc_nacimiento, $colegio_secundario, $colegio_secundario_dependencia, $anio_egreso_sec, $grupo_sanguineo, $factor_sanguineo, $apellido_padre, $apellido_madre, $pais_emisor_pasap, $nro_pasap, $estado_civil, $eMail, $calle_per_lec, $numero_per_lect, $piso_per_lect, $dpto_per_lect, $unidad_per_lect, $loc_per_lect, $cp_per_lect, $te_per_lect, $calle_proc, $numero_proc, $piso_proc, $dpto_proc, $unidad_proc, $loc_proc, $cp_proc, $te_proc, $otros_estud_super, $padre_vive, $madre_vive, $sit_laboral_alumno, $categ_ocup_alum, $act_econom_alum, $det_rama_act_alum, $cant_horas_sem_trab_alum, $sit_laboral_padre, $ult_est_padre, $act_econom_padre, $det_rama_act_padre, $sit_laboral_madre, $ult_est_madre, $act_econom_madre, $det_rama_act_madre, $alu_req_acces_fisica, $alu_req_acces_com, $objCC, $claveNueva, $nacionalidad,$fecha_ingreso_pais) {
        $deco = new Redecode();

        $resultado = $this->setAspirante($ua, $anio_acad, $carrera, $sede, $tipo_ingreso, $fecha_insc, $apellido, $nombres, $tipo_doc, $nro_doc, $pais_documento, $deco->recodeCUILExt($nro_doc, $pais_documento, $numero_cuil), $fecha_nacimiento, $sexo, $claveNueva,$nacionalidad, $loc_nacimiento, $deco->recodeColeSecundario($colegio_secundario), $colegio_secundario_dependencia, $anio_egreso_sec, $grupo_sanguineo, $factor_sanguineo, $apellido_padre, $apellido_madre, $pais_emisor_pasap, $nro_pasap, $deco->recodeEstadoCivil($estado_civil), $eMail, $calle_per_lec, $numero_per_lect, $piso_per_lect, $dpto_per_lect, $unidad_per_lect, $loc_per_lect, $cp_per_lect, $te_per_lect, $calle_proc, $numero_proc, $piso_proc, $dpto_proc, $unidad_proc, $loc_proc, $cp_proc, $te_proc, $otros_estud_super, $deco->recodePadresViven($padre_vive), $deco->recodePadresViven($madre_vive), $deco->recodeSit_laboral($sit_laboral_alumno), $deco->recodeCateg_ocup($categ_ocup_alum), $deco->recodeAct_econom($act_econom_alum), $deco->recodedet_rama_act($det_rama_act_alum), $cant_horas_sem_trab_alum, $deco->recodeHora_sem_trab($cant_horas_sem_trab_alum), $deco->recodeSit_laboral($sit_laboral_padre), $deco->recodeUlt_est($ult_est_padre), $deco->recodeAct_econom($act_econom_padre), $deco->recodedet_rama_act($det_rama_act_padre), $deco->recodeSit_laboral($sit_laboral_madre), $deco->recodeUlt_est($ult_est_madre), $deco->recodeAct_econom($act_econom_madre), $deco->recodedet_rama_act($det_rama_act_madre), $deco->recodeDis_acc($alu_req_acces_fisica), $deco->recodeDis_com($alu_req_acces_com),$fecha_ingreso_pais, $objCC);
        return $resultado;
    }
    
    public function insertarAspiranteNuevo($anio_acad, $carrera, $ubicacion, $tipo_ingreso, $fecha_insc, $apellido, $nombres, $pais_documento, $tipo_doc, $nro_doc, $numero_cuil, $fecha_nacimiento, $sexo, $nacionalidad, $pais_origen, $eMail, $objCC) {
        $deco = new Redecode();

        $resultado = $this->setAspiranteNuevo($anio_acad, $carrera, $ubicacion, $tipo_ingreso, $fecha_insc, $apellido, $nombres, $pais_documento, $tipo_doc, $nro_doc, $numero_cuil, $fecha_nacimiento, $sexo, $nacionalidad, $pais_origen, $eMail, $objCC);
        return $resultado;
    }

    public function insertarRequisito($ua, $carrera, $tipo_doc, $nro_doc, $pais_documento, $cod_requisito, $obligatorio, $fecha_presentacion, $exceptuado, $objCC) {

        $resultado = $this->setRequisito($ua, $carrera, $tipo_doc, $nro_doc, $pais_documento, $cod_requisito, $obligatorio, $fecha_presentacion, $exceptuado, $objCC);
        return $resultado;
    }

    public function insertarRequisitoNuevo($carrera, $pais_documento, $tipo_doc, $nro_doc, $codigoRequisito, $fecha_presentacion, $objCC) {

        $resultado = $this->setRequisitoNuevo($carrera, $pais_documento, $tipo_doc, $nro_doc, $codigoRequisito, $fecha_presentacion, $objCC);
        return $resultado;
    }

    public function validarRequisitosDiploma($pais_documento, $tipo_doc, $nro_doc, $solicitud, $requisitos_validados, $objCC) {

        $resultado = $this->setValidarRequisitosDiploma($pais_documento, $tipo_doc, $nro_doc, $solicitud, $requisitos_validados, $objCC);
        return $resultado;
    }

    public function eliminarRequisito($carrera, $tipo_doc, $nro_doc, $pais_documento,$codigoRequisito,$objCC) {

        $parametros = array($carrera, $pais_documento, $tipo_doc, $nro_doc, $codigoRequisito);

        return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_baja_requisito', $objCC);
    }

    public function obtenerCarrerasAlumno($nroDocumento, $tipoDocumento, $paisDocumento, $objCC) {

        $parametros = array($nroDocumento, $tipoDocumento, $paisDocumento);

        return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_carreras_alumno', $objCC);
    }

    public function generaLegajoPostgres($carrera, $pais_documento, $tipo_documento, $nro_documento, $objCC) {
        $resultado = $this->newLegajo($carrera, $pais_documento, $tipo_documento, $nro_documento, $objCC);
        return $resultado;
    }

    public function obtenerMateriasAprobadas($ua, $carrera, $tipo_documento, $nro_documento, $pais_documento, $fechaInicio, $fechaFin, $objCC) {
        $resultado = $this->materiasAprobadas($ua, $carrera, $tipo_documento, $nro_documento, $pais_documento, $fechaInicio, $fechaFin, $objCC);
        return $resultado;
    }

    public function setNotasIngreso($carrera, $pais_documento, $tipo_doc, $nro_doc, $materia, $tipo_examen, $fecha_examen, $nota, $objCC) {
        $resultado = $this->migrarNotasIngreso($carrera, $pais_documento, $tipo_doc, $nro_doc, $materia, $tipo_examen, $fecha_examen, $nota, $objCC);
        return $resultado;
    }

    public function dropNotasIngreso($ua, $carrera, $pais_documento, $tipo_doc, $nro_doc, $materia, $objCC) {
        $resultado = $this->bajaNotasIngreso($ua, $carrera, $pais_documento, $tipo_doc, $nro_doc, $materia, $objCC);
        return $resultado;
    }

    public function setReinscripcion($ua, $carrera, $tipo_doc, $nro_doc, $pais_documento, $anio_academico, $fecha_reinscrip, $nro_transaccion, $objCC) {
        $resultado = $this->ingresarReinscripcion($ua, $carrera, $tipo_doc, $nro_doc, $pais_documento, $anio_academico, $fecha_reinscrip, $nro_transaccion, $objCC);
        return $resultado;
    }

    public function obtenerDatosMateriaCarreraPlan($carrera,$plan,$version, $objCC) {

        $parametros = array($carrera,(string)$plan,(string)$version);

        return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_materias_carrera', $objCC);
    }

    private function autenticaUsuarioWifi($tipodoc, $nrodoc, $objCC) {

        $sth = $objCC->prepare('SELECT  clave  FROM mdp_personas 
                                                join mdp_personas_documentos using (persona)
                                                WHERE    mdp_personas_documentos.tipo_documento = :ptipodoc
                                                and mdp_personas_documentos.nro_documento = :pnrodoc
                                                and mdp_personas.documento_principal = mdp_personas_documentos.documento;');
        $sth->execute(array(':ptipodoc' => "$tipodoc", ':pnrodoc' => "$nrodoc"));
        $resul = $sth->fetchAll();
        return $resul;
    }

    private function autenticaUsuario($usuario, $objCC) {

        $sth = $objCC->prepare('SELECT	clave   FROM mdp_personas 
                WHERE	usuario = :pusuario; ');
        $sth->execute(array(':pusuario' => "$usuario"));
        $resul = $sth->fetchAll();
        return $resul;
    }

    private function getDatosCensales($usuario, $objCC) {

        $sth = $objCC->prepare("SELECT
		1,
		mdp_tipo_documento.tipo_documento,
		mdp_personas_documentos.nro_documento,
		mdp_personas.fecha_nacimiento,
		mdp_personas.apellido,
		mdp_personas.nombres,
		mdp_personas.sexo,
		
		localidad_proc.localidad as localidad_proc,
		localidad_proc.localidad_codigo_postal as codigo_postal_proc,
		localidad_per_lect.localidad as localidad_per_lect,
		localidad_per_lect.localidad_codigo_postal as codigo_postal_per_lect,

		mdp_datos_personales.periodo_lectivo_calle,
		mdp_datos_personales.periodo_lectivo_numero,
		mdp_datos_personales.periodo_lectivo_piso,
		mdp_datos_personales.periodo_lectivo_departamento,
		mdp_datos_personales.periodo_lectivo_unidad,

		COALESCE(contacto_telefono.telefono_codigo_area, '(-)') || '-' || contacto_telefono.telefono_numero AS telefono_principal,
		contacto_mail.email,

		mdp_personas.persona
		
		
	FROM
		mdp_personas
		LEFT JOIN mdp_datos_censales ON mdp_personas.persona = mdp_datos_censales.persona
		LEFT JOIN mdp_datos_personales ON mdp_datos_censales.dato_censal = mdp_datos_personales.dato_censal
		LEFT JOIN mdp_personas_contactos AS contacto_mail ON mdp_personas.persona = contacto_mail.persona
		LEFT JOIN mdp_personas_contactos AS contacto_telefono ON mdp_personas.persona = contacto_telefono.persona
		LEFT JOIN mdp_personas_documentos ON mdp_personas_documentos.documento = mdp_personas.documento_principal
		LEFT JOIN mdp_tipo_documento ON mdp_personas_documentos.tipo_documento = mdp_tipo_documento.tipo_documento 
		LEFT JOIN vw_localidades AS localidad_proc ON mdp_datos_personales.procedencia_localidad = localidad_proc.localidad
		LEFT JOIN vw_localidades AS localidad_per_lect ON mdp_datos_personales.periodo_lectivo_localidad = localidad_per_lect.localidad
		
	WHERE
		mdp_personas.usuario = :pusuario
		AND contacto_mail.contacto_tipo = 'MP'
		AND contacto_telefono.contacto_tipo = 'T'
		AND mdp_datos_censales.fecha_relevamiento = (SELECT max(fecha_relevamiento) 
								FROM mdp_datos_censales 
								WHERE persona = mdp_personas.persona)");
        $sth->execute(array(':pusuario' => "$usuario"));
        $resul = $sth->fetchAll();
        return $resul;
    }

    private function getPromedioPorCarrera($objCC) {
        $sth = $objCC->prepare("SELECT car.propuesta, car.nombre, avg(tit.promedio) as prom_con_aplazos,
                                                avg(tit.promedio_sin_aplazos) as prom_sin_aplazos 
                                                FROM sga_certificados_otorg as tit
                                                INNER JOIN sga_alumnos as a
                                                        ON(a.alumno = tit.alumno)
                                                INNER JOIN sga_propuestas as car
                                                        ON (a.propuesta = car.propuesta)
                                                WHERE date_part('year',tit.fecha_egreso) between (date_part('year',now())-5) and date_part('year',now())
                                            GROUP BY 1, 2; ");
        $sth->execute();
        $resul = $sth->fetchAll();
        return $resul;
    }

//    public function getCatalogoColegios($objCC) {
//
//        $sth = $objCC->prepare("SELECT  colegio, nombre FROM sga_colegios_secundarios  LIMIT 50 ;");
//
//        $sth->execute(array());
//        $resul = $sth->fetchAll();
//        return $resul;
//    }

    private function getRendimientoAcademico($tipoDocumento, $nroDocumento, $pais, $objCC) {

        $sth = $objCC->prepare("SELECT  alu.alumno,
								rra.codigo as ubicacion,
								pp.propuesta as propuesta,
								alca.nombre,
								asp.fecha_inscripcion,
								--egre.fecha_egreso,
								--CASE WHEN (sga_certificados_tipos.es_titulo = 'S' AND certi.titulo_nivel = 'FINAL') THEN egre.fecha_egreso ELSE NULL END as egresado,
								

								(Select fecha_egreso 
							 	FROM sga_certificados_otorg  
								JOIN sga_certificados USING (certificado)
								JOIN sga_certificados_tipos USING (certificado_tipo)
								WHERE sga_certificados_tipos.es_titulo = 'S' AND sga_certificados.titulo_nivel = 'FINAL'
									AND sga_certificados_otorg.alumno = alu.alumno AND sga_certificados_otorg.anulado = 0) as fecha_egreso,

								(select count(*) from
								vw_hist_academica as h
								join sga_elementos using
								(elemento)					
								where h.alumno = alu.alumno
									and h.resultado = 'A'
									and sga_elementos.entidad_subtipo not in(56)
			   -- Filtro las materias que estan aprobadas y asignadas a genericas
				and h.elemento not in (Select optativa from sga_alumnos_optativas where plan_version = h.plan_version and alumno = alu.alumno)
			and h.elemento in (select elemento from vw_actividades_plan where plan_version = h.plan_version)					   
								) + funl_modulos_aprobados(alu.alumno) as cant_aprob, --cant_aprob sin contar cursos (codigo 56)

								plan.cnt_materias, --cant_plan,
								f_promedio(alu.alumno, CURRENT_DATE, NULL, 'S') as promedio_con_aplazos,
								f_promedio(alu.alumno, CURRENT_DATE, NULL, 'N') as promedio_sin_aplazos,
								(select count(*) from
								vw_hist_academica
								join sga_elementos using
								(elemento)
								where alumno = alu.alumno
									and resultado = 'R'
									and entidad_subtipo <>
								56) as cant_reprob, --cant_reprob sin contar cursos (cÃ³digo 56)
								pp.nombre as nombre_propuesta,
								sa.nombre,
								CASE WHEN funl_es_alumno_regular(alu.alumno) = 1 THEN 'S' ELSE 'N' END as regular,
								(CASE WHEN per.sexo = 'F' THEN certi.nombre_femenino ELSE certi.nombre END) AS nombre_titulo,
								--(CASE WHEN (egre.alumno is not null) THEN 1 ELSE 0 END) AS egresado,
								CASE WHEN (Select Fecha_egreso 
								 	FROM sga_certificados_otorg  
									JOIN sga_certificados USING (certificado)
									JOIN sga_certificados_tipos USING (certificado_tipo)
									WHERE sga_certificados_tipos.es_titulo = 'S' AND sga_certificados.titulo_nivel = 'FINAL'
										AND sga_certificados_otorg.alumno = alu.alumno AND sga_certificados_otorg.anulado = 0)
										IS NULL THEN 0 ELSE 1 END as egresado,
								(CASE WHEN (pp.propuesta_tipo = 202) THEN 2 ELSE 1 END) AS tipo_titulo
							 FROM mdp_personas as per
								join sga_propuestas_aspira asp using (persona)
								join sga_propuestas pp using (propuesta)
								join sga_propuestas_ra pra using (propuesta)
								join sga_responsables_academicas rra using (responsable_academica)
								join sga_alumnos alu using (persona, propuesta)
								join sga_planes_versiones plan ON (alu.plan_version = plan.plan_version)
								join sga_ubicaciones as su ON alu.ubicacion = su.ubicacion
								join sga_situacion_aspirante sa ON (asp.situacion_asp = sa.situacion_asp)
								join sga_alumnos_calidad alca ON (alu.calidad = alca.calidad)
								join mdp_personas_documentos as pd using(persona)
								join sga_planes_certificados as plcert ON (plcert.plan_version = alu.plan_version)
								join sga_certificados as certi USING (certificado)
								JOIN sga_certificados_tipos USING (certificado_tipo)
							WHERE  pd.nro_documento = :nro 
							AND pd.tipo_documento = :tipo
							AND pd.pais_documento = :pais
							AND su.institucion_araucano = rra.institucion_araucano
							AND pp.propuesta_tipo not in ('208','207','204')  
							AND asp.situacion_asp in ('1','2')
							AND (
									(sga_certificados_tipos.es_titulo = 'S' AND certi.titulo_nivel = 'FINAL')
									OR 
									pp.propuesta = 1097
								)
							");

        $sth->execute(array(':nro' => "$nroDocumento", ':tipo' => "$tipoDocumento", ':pais' => "$pais"));
        $resul = $sth->fetchAll();
        return $resul;
    }

    private function getDatosAcademicos($tipoDocumento, $nroDocumento, $objCC) {
        $sth = $objCC->prepare(" SELECT  alu.alumno,
                                        rra.codigo as ubicacion,
                                        pp.codigo as propuesta,
                                        alu.calidad,
                                        asp.fecha_inscripcion,
                                        --egre.fecha_egreso,
					--CASE WHEN (sga_certificados_tipos.es_titulo = 'S' AND certi.titulo_nivel = 'FINAL') THEN egre.fecha_egreso ELSE NULL END as egresado,
					

					(Select fecha_egreso 
				 	FROM sga_certificados_otorg  
					JOIN sga_certificados USING (certificado)
					JOIN sga_certificados_tipos USING (certificado_tipo)
					WHERE sga_certificados_tipos.es_titulo = 'S' AND sga_certificados.titulo_nivel = 'FINAL'
						AND sga_certificados_otorg.alumno = alu.alumno) as fecha_egreso,

                                        (select count(*) from
                                        vw_hist_academica
                                        join sga_elementos using
                                        (elemento)
                                        where alumno = alu.alumno
                                            and resultado = 'A'
                                            and entidad_subtipo <>
                                        56) as cant_aprob, --cant_aprob son contar cursos (cÃ³digo 56)
                                        
                                        plan.cnt_materias, --cant_plan,
                                        f_promedio(alu.alumno, CURRENT_DATE, NULL, 'S') as promedio_con_aplazos,
                                        f_promedio(alu.alumno, CURRENT_DATE, NULL, 'N') as promedio_sin_aplazos,
                                        (select count(*) from
                                        vw_hist_academica
                                        join sga_elementos using
                                        (elemento)
                                        where alumno = alu.alumno
                                            and resultado = 'R'
                                            and entidad_subtipo <>
                                        56) as cant_reprob, --cant_reprob son contar cursos (cÃ³digo 56)
                                        pp.nombre as nombre_propuesta,
                                        alca.nombre,
                                                                         FROM mdp_personas as per
                                        join sga_propuestas_aspira asp using (persona)
                                        join sga_propuestas pp using (propuesta)
                                        join sga_propuestas_ra pra using (propuesta)
                                        join sga_responsables_academicas rra using (responsable_academica)
                                        join sga_planes_versiones as plan using (plan_version)
                                        join sga_alumnos alu using (persona, propuesta)
                                        join sga_alumnos_calidad alca ON (alu.calidad = alca.calidad)
                                        join mdp_personas_documentos as pd using(persona)
					join sga_planes_certificados as plcert ON (plcert.plan_version = alu.plan_version)
					join sga_certificados as certi USING (certificado)
					JOIN sga_certificados_tipos USING (certificado_tipo)
                                    WHERE  pd.nro_documento = :nro 
                                    AND pd.tipo_documento = :tipo
				    AND sga_certificados_tipos.es_titulo = 'S' AND certi.titulo_nivel = 'FINAL'; ");

        $sth->execute(array(':nro' => "$nroDocumento", ':tipo' => "$tipoDocumento"));
        $resul = $sth->fetchAll();
        return $resul;
    }

    private function setAspirante($ua, $anio_acad, $carrera, $sede, $tipo_ingreso, $fecha_insc, $apellido, $nombres, $tipo_doc, $nro_doc, $pais_documento, $numero_cuil, $fecha_nacimiento, $sexo, $claveNueva, $nacionalidad, $loc_nacimiento, $colegio_secundario, $colegio_secundario_dependencia, $anio_egreso_sec, $grupo_sanguineo, $factor_sanguineo, $apellido_padre, $apellido_madre, $pais_emisor_pasap, $nro_pasap, $estado_civil, $eMail, $calle_per_lec, $numero_per_lect, $piso_per_lect, $dpto_per_lect, $unidad_per_lect, $loc_per_lect, $cp_per_lect, $te_per_lect, $calle_proc, $numero_proc, $piso_proc, $dpto_proc, $unidad_proc, $loc_proc, $cp_proc, $te_proc, $otros_estud_super, $padre_vive, $madre_vive, $sit_laboral_alumno, $categ_ocup_alum, $act_econom_alum, $det_rama_act_alum, $cant_horas_sem_trab_alum, $horas_sem_trab_alum, $sit_laboral_padre, $ult_est_padre, $act_econom_padre, $det_rama_act_padre, $sit_laboral_madre, $ult_est_madre, $act_econom_madre, $det_rama_act_madre, $alu_req_acces_fisica, $alu_req_acces_com, $fecha_ingreso_pais, $objCC) {


        $parametros = array($ua, $anio_acad, $carrera, $sede, $tipo_ingreso,
            $fecha_insc, $apellido, $nombres, $pais_documento, $tipo_doc, $nro_doc,
            $numero_cuil, $fecha_nacimiento, $sexo, $claveNueva, $nacionalidad,
            $loc_nacimiento, $colegio_secundario,
            $colegio_secundario_dependencia, $anio_egreso_sec, $grupo_sanguineo,
            $factor_sanguineo, $apellido_padre, $apellido_madre, $pais_emisor_pasap,
            $nro_pasap, $estado_civil, $eMail, $calle_per_lec, $numero_per_lect,
            $piso_per_lect, $dpto_per_lect, $unidad_per_lect, $loc_per_lect, $cp_per_lect,
            $te_per_lect, $calle_proc, $numero_proc, $piso_proc, $dpto_proc, $unidad_proc,
            $loc_proc, $cp_proc, $te_proc, $otros_estud_super, $padre_vive, $madre_vive,
            $sit_laboral_alumno, $categ_ocup_alum, $act_econom_alum, $det_rama_act_alum,
            $cant_horas_sem_trab_alum, $horas_sem_trab_alum, $sit_laboral_padre, $ult_est_padre,
            $act_econom_padre, $det_rama_act_padre, $sit_laboral_madre, $ult_est_madre,
            $act_econom_madre, $det_rama_act_madre, $alu_req_acces_fisica, $alu_req_acces_com, $fecha_ingreso_pais);

    
        return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_alta_aspirante', $objCC);
    }
    
    private function setAspiranteNuevo($anio_acad, $carrera, $ubicacion, $tipo_ingreso, $fecha_insc, $apellido, $nombres, $pais_documento, $tipo_doc, $nro_doc, $numero_cuil, $fecha_nacimiento, $sexo, $nacionalidad, $pais_origen, $eMail, $objCC) {

		$ubicacion = empty($ubicacion) ? null : (integer) $ubicacion;
        $parametros = array($anio_acad, $carrera, $ubicacion, $tipo_ingreso, $fecha_insc, $apellido, $nombres, $pais_documento, $tipo_doc, $nro_doc,
            $numero_cuil, $fecha_nacimiento, $sexo, $nacionalidad, $pais_origen, $eMail);

        return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_insertar_aspirante', $objCC);
    }

    private function setRequisito($ua, $carrera, $tipo_doc, $nro_doc, $pais_documento, $cod_requisito, $obligatorio, $fecha_presentacion, $exceptuado, $objCC) {

        $parametros = array($ua, $carrera, $pais_documento, $tipo_doc, $nro_doc,
            $cod_requisito, $obligatorio, $fecha_presentacion, $exceptuado);

        return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_alta_requisito', $objCC);
    }
    
    private function setRequisitoNuevo($carrera, $pais_documento, $tipo_doc, $nro_doc, $codigoRequisito, $fecha_presentacion, $objCC) {

        $parametros = array($carrera, $pais_documento, $tipo_doc, $nro_doc, $codigoRequisito, $fecha_presentacion);

        return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_insertar_requisito', $objCC);
    }
    
    private function setValidarRequisitosDiploma($pais_documento, $tipo_doc, $nro_doc, $solicitud, $requisitos_validados, $objCC) {

        $parametros = array($pais_documento, $tipo_doc, $nro_doc, $solicitud, $requisitos_validados);
        
        return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_validar_requisitos_diploma', $objCC);
    }

    private function newLegajo($carrera, $pais_documento, $tipo_documento, $nro_documento, $objCC) {

        $parametros = array($carrera, $pais_documento, $tipo_documento, $nro_documento);

        return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_genera_legajo', $objCC);
    }

    private function materiasAprobadas($ua, $carrera, $tipo_documento, $nro_documento, $pais_documento, $fechaInicio, $fechaFin, $objCC) {

        $parametros = array($ua, $carrera, $pais_documento, $tipo_documento, $nro_documento, $fechaInicio, $fechaFin);

        return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_materias_aprobadas', $objCC);
    }

    private function migrarNotasIngreso($carrera, $pais_documento, $tipo_doc, $nro_doc, $materia, $tipo_examen, $fecha_examen, $nota, $objCC) {

        $parametros = array($carrera, $pais_documento, $tipo_doc, $nro_doc, $materia, $tipo_examen, $fecha_examen, $nota);

        return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_alta_nota_ingreso', $objCC);
    }

    private function bajaNotasIngreso($ua, $carrera, $pais_documento, $tipo_doc, $nro_doc, $materia, $objCC) {

        $parametros = array($carrera, $pais_documento, $tipo_doc, $nro_doc, $materia);

        return $this->ejecutaFuncionPostgre($parametros, 'funl_ws_baja_nota_ingreso', $objCC);
    }

    private function ingresarReinscripcion($ua, $carrera, $tipo_doc, $nro_doc, $pais_documento, $anio_academico, $fecha_reinscrip, $nro_transaccion, $objCC) {

        $parametros = array($ua, $carrera, $tipo_doc, $nro_doc, $pais_documento, $anio_academico, $fecha_reinscrip, $nro_transaccion);

        return "TODO: FUNCION POSTGRES ";
        return $this->ejecutaFuncionPostgre($parametros, '', $objCC);
    }

    public function ejecutaFuncionPostgre($parametros, $nombreFuncion, $objCC) {

        /* Crear una cadena para los parámetros de sustitución rellenados con el número de parámetros */
        if (!empty($parametros)) {
            $place_holders = implode(',', array_fill(0, count($parametros), '?'));
        } else {
            $place_holders = null;
        }
         
        // Prepara y ejecuta la funcion postgre
        $gsent = $objCC->prepare("SELECT * FROM $nombreFuncion ($place_holders)");
            
        $objCC->beginTransaction();

        $gsent->execute($parametros);
         
        $resul = $gsent->fetchAll();
     // return $gsent->errorInfo();
        if ($gsent->errorCode() == 0) {
            //$resul = $gsent->fetchAll();
            $objCC->commit();
        } else {
            //$resul = $gsent;
            $objCC->rollBack();
        }
        //retorna los datos codigo->valor ó el objeto de conexión para evaluar el error
        
        return $resul;
    }
    
    function registrarAuditoria($comunicacion, $respuesta, $wsnombre, $usuario) {
        $objCC = $this->conectar_auditoria();
        
        $respuesta_json = $this->safe_json_encode($respuesta);
        $comunicacion_json = $this->safe_json_encode($comunicacion);
        
        $parametros = array($comunicacion_json, $respuesta_json, $wsnombre, $usuario); 
        return $this->ejecutaFuncionPostgre($parametros, 'funl_registrar_auditoria', $objCC);
    }
    
    function conectar_auditoria() {

        try {
            $dbConnect = new PDO("pgsql:host=" . DBAUDITORIA_HOST . ";port=" . DBAUDITORIA_PORT . ";dbname=" . DBAUDITORIA_NAME, DBAUDITORIA_USER, DBAUDITORIA_PASS);
            $dbConnect->exec('SET SEARCH_PATH TO public');
            return $dbConnect;
        } 
        catch (PDOException $e) {
            return CODIGO_ERROR_CONEXION;
        }
    }
    
    // json_encode para casos en que $value posea caracteres UTF8 malformados
    function safe_json_encode($value) {
        $encoded = json_encode($value, JSON_PRETTY_PRINT);
        if ($encoded === false && $value && json_last_error() == JSON_ERROR_UTF8) {
            $encoded = json_encode($this->utf8ize($value), JSON_PRETTY_PRINT);
        }
        return $encoded;
    }
    
    function utf8ize($mixed) {
        if (is_array($mixed)) {
            foreach ($mixed as $key => $value) {
                $mixed[$key] = $this->utf8ize($value);
            }
        } elseif (is_string($mixed)) {
            return mb_convert_encoding($mixed, "UTF-8", "UTF-8");
        }
        return $mixed;
    }

    public function propuesta_requiere_cuil($carrera, $objCC) {
        $parametros = array($carrera);
        return $this->ejecutaFuncionPostgre($parametros, 'funl_propuesta_requiere_cuil', $objCC);
    }
	
	public function get_tesis($alumno, $objCC)
	{
        $sth = $objCC->prepare("
				SELECT
					titulo,
					fecha_defensa AS fecha_aprobacion,
					COALESCE(sga_documentos_tipos.nombre || ' ' || sga_documentos.documento_numero, ' ') as resolucion_tesis
				FROM sga_tesis
				JOIN sga_tesis_alumnos			USING (tesis)
				JOIN mce_estados				ON sga_tesis.estado_actual = mce_estados.estado
				LEFT JOIN sga_documentos		ON sga_documentos.documento = sga_tesis.resolucion_tesis
				LEFT JOIN sga_documentos_tipos	USING (documento_tipo)
				JOIN sga_alumnos				USING (alumno)
				JOIN sga_propuestas				USING (propuesta)
				WHERE
					fecha_aprobacion IS NOT NULL
					AND mce_estados.estado = 26						--tesis::estado_tesis_aprobada
					AND sga_tesis_alumnos.alumno = :alumno
					AND sga_propuestas.propuesta_tipo IN (200, 201) --grado y pregrado
		;");
        $sth->execute([':alumno' => $alumno]);
        $resul = $sth->fetchAll(PDO::FETCH_NAMED);
        return $resul;
	}	
	
	public function get_suplemento_reconocimiento_con_fecha($alumno, $fecha_egreso, $objCC)
	{
        $sth = $objCC->prepare("
			SELECT		
				sga_bitacora.titulo,
				sga_bitacora.observaciones,
				to_char(sga_bitacora.fecha, 'DD/MM/YYYY') as fecha
			FROM sga_bitacora
			JOIN sga_alumnos ON sga_alumnos.persona = sga_bitacora.persona
			JOIN sga_propuestas ON sga_propuestas.propuesta = sga_alumnos.propuesta
			WHERE
				sga_bitacora.id_seguimiento = 3					--persona::bitacora_seguimiento_actividades
				AND sga_alumnos.alumno = :alumno
				AND sga_propuestas.propuesta_tipo IN (200, 201) --grado y pregrado
				AND sga_bitacora.fecha <= :fecha_egreso
			ORDER BY sga_bitacora.fecha DESC
		");
        $sth->execute([':alumno' => $alumno, ':fecha_egreso' => $fecha_egreso]);
        $resul = $sth->fetchAll(PDO::FETCH_NAMED);
        return $resul;
	}	
	
	}
