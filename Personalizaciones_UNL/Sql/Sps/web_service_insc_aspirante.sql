CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_ser_insc_asp') THEN
		DROP PROCEDURE web_ser_insc_asp;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- *************** COMIENZO DEL PROCEDURE web_ser_insc_asp ***************
-- ************************************************************************
-- SP que genera una inscripcion a carrera, a partir de datos de INGRESO
-- en un período dado
-- ************************************************************************
-- DROP PROCEDURE "dba".web_ser_insc_asp;
      
CREATE PROCEDURE "dba".web_ser_insc_asp(pUnidadAcademica LIKE sga_unidades_acad.unidad_academica,
	pAnioAcademico LIKE sga_periodo_insc.anio_academico,
	pCarrera LIKE sga_carreras.carrera,
	pSede LIKE sga_carrera_aspira.sede,
	pTipoIngreso INT,-- Nuevo parámetro Tipo Ingreso: 1 - Titulo Secundario;	2 - Proveniente de ciclo básico común; 3 - Mayor de 25 años ; etc... ver combo De inscripcion Tipo ingreso en Guaraní.
	pFechaInscripcion LIKE sga_datos_censales.fecha_relevamiento,
	pApellido LIKE sga_personas.apellido,
	pNombres LIKE sga_personas.nombres,
	pPaisDocumento LIKE sga_personas.pais_documento,
	pTipoDocumento LIKE sga_personas.tipo_documento,
	pNroDocumento LIKE sga_personas.nro_documento,
	pNumeroCuil LIKE sga_personas.numero_cuil,
	pFechaNacimiento LIKE sga_personas.fecha_nacimiento,
	pSexo LIKE sga_personas.sexo,
	pClave LIKE aca_usuarios_ag.clave,
	pNacionalidad LIKE sga_personas.nacionalidad,
	pLoc_nacimiento LIKE sga_personas.loc_nacimiento,
	pColegio_secundario LIKE sga_personas.colegio_secundario,
	pColegio_secundario_dependencia LIKE sga_personas.orient_voc_rec,
	pAnio_egreso_sec LIKE sga_personas.anio_egreso_sec,
	pGrupo_sanguineo LIKE sga_personas.grupo_sanguineo,
	pFactor_sanguineo LIKE sga_personas.factor_sanguineo,
	pApellido_padre LIKE sga_personas.apellido_padre,
	pApellido_madre LIKE sga_personas.apellido_madre,
	pPais_emisor_pasap LIKE sga_personas.pais_emisor_pasap,
	pNro_pasap LIKE sga_personas.nro_pasap,
	pEstadoCivil LIKE sga_datos_censales.estado_civil,
	pEMail LIKE sga_datos_censales.e_mail,
	pcalle_per_lect LIKE sga_datos_censales.calle_per_lect,
	pnumero_per_lect LIKE sga_datos_censales.numero_per_lect,
	ppiso_per_lect LIKE sga_datos_censales.piso_per_lect,
	pdpto_per_lect LIKE sga_datos_censales.dpto_per_lect,
	punidad_per_lect LIKE sga_datos_censales.unidad_per_lect,
	ploc_per_lect LIKE sga_datos_censales.loc_per_lect,
	pcp_per_lect LIKE sga_datos_censales.cp_per_lect,
	pte_per_lect LIKE sga_datos_censales.te_per_lect,
	pcalle_proc LIKE sga_datos_censales.calle_proc,
	pnumero_proc LIKE sga_datos_censales.numero_proc,
	ppiso_proc LIKE sga_datos_censales.piso_proc,
	pdpto_proc LIKE sga_datos_censales.dpto_proc,
	punidad_proc LIKE sga_datos_censales.unidad_proc,
	ploc_proc LIKE sga_datos_censales.loc_proc,
	pcp_proc LIKE sga_datos_censales.cp_proc,
	pte_proc LIKE sga_datos_censales.te_proc,
	potros_estud_super LIKE sga_datos_censales.otros_estud_super,
	pPadre_vive LIKE sga_datos_cen_aux.padre_vive,
	pMadre_vive LIKE sga_datos_cen_aux.madre_vive,
	pSit_laboral_alumno LIKE sga_datos_censales.sit_laboral_alu,
	pCateg_ocup_alum LIKE sga_datos_censales.categ_ocup_alum,
	pAct_econom_alum LIKE sga_datos_censales.act_econom_alum,
	pdet_rama_act_alum LIKE sga_datos_censales.det_rama_act_alum,
	pCant_horas_sem_trab_alum LIKE u820_datos_cen_aux.cant_hora_sem_trab_alum,
	pHora_sem_trab_alum LIKE sga_datos_censales.hora_sem_trab_alum,
	pSit_laboral_padre LIKE sga_datos_censales.sit_laboral_padre,
	pUlt_est_cur_padre LIKE sga_datos_censales.ult_est_cur_padre,
	pAct_econom_padre LIKE sga_datos_censales.act_econom_padre,
	pdet_rama_act_padre LIKE sga_datos_censales.det_rama_act_padre,
	pSit_laboral_madre LIKE sga_datos_censales.sit_laboral_madre,
	pUlt_est_cur_madre LIKE sga_datos_censales.ult_est_cur_madre,
	pAct_econom_madre LIKE sga_datos_censales.act_econom_madre,
	pdet_rama_act_madre LIKE sga_datos_censales.det_rama_act_madre,
	pAlu_req_acces_fisica LIKE u820_datos_cen_aux.alu_req_acces_fisica,
	pAlu_req_acces_com LIKE u820_datos_cen_aux.alu_req_acces_com,
	pfecha_ingreso_pais LIKE sga_personas.fecha_ingreso_pais)
	Returning INT,VARCHAR(255);

-- Descripcion de Parámetros:

-- pAnioAcademico: año academico de la inscripcion a carrera (Integer)
-- pCarrera: carrera a la que se va a inscribir (Varchar(5))
-- pTipoIngreso: (Integer)
-- pFechaInscripcion: fecha de la inscripcion como aspirante a la carrera (mm/dd/yyyy)


-- Descripcion de Return:
-- INT: 	0 - OK
--	-1 - Error
-- VARCHAR(255): string con la descripcion del error
	
DEFINE aunidad_academica LIKE sga_datos_censales.unidad_academica;
DEFINE aanio_academico LIKE sga_periodo_insc.anio_academico;
DEFINE aperiodo_inscripcio LIKE sga_periodo_insc.periodo_inscripcio;
DEFINE afecha_inicio LIKE sga_periodo_insc.fecha_inicio;
DEFINE anro_inscripcion LIKE sga_personas.nro_inscripcion;
DEFINE aux_nro_inscripcion int;
DEFINE aLegajo LIKE sga_alumnos.legajo;
DEFINE cViven_padres LIKE sga_datos_censales.viven_padres;

DEFINE sql_err, isam_err  	int;
DEFINE error_info         	varchar(80);
DEFINE vcUserError		varchar(10);
DEFINE iStatus			int;
DEFINE vcMsg			varchar(100);
DEFINE iExiste_trab_alum	int;


  -- si hay algun error
ON EXCEPTION SET sql_err, isam_err, error_Info                                        

      LET vcUserError  = 'Error de procedimiento.';
      LET iStatus 	  = 4; 
      LET vcMsg 	  =  vcUserError || ', ' || sql_err || ' - ' || error_Info;
      SET TRIGGERS FOR sga_datos_censales enabled;
      ROLLBACK WORK;
      RETURN iStatus, vcMsg;
END EXCEPTION;
--------------------------------------------------


LET aunidad_academica = NULL;
LET aanio_academico = NULL;
LET aperiodo_inscripcio = NULL;
LET afecha_inicio = NULL;
LET anro_inscripcion = NULL;
LET aLegajo = NULL;
LET aux_nro_inscripcion = NULL;
LET error_info = NULL;
LET sql_err = 0;
LET isam_err = 0;
LET iStatus = 0;
LET vcMsg = 'OK';
LET cViven_padres = NULL;
LET iExiste_trab_alum = NULL;

------------------------------------------------------------------------------------ 
-- Obtengo datos generales de inscripcion a la carrera.

-- Obtengo la Unidad Academica.
Select unidad_academica Into aunidad_academica 
from sga_unidades_acad
where unidad_academica = pUnidadAcademica;

-- Obtengo el periodo de Inscripcion. No pueden existir en Guarani Periodos de inscripcion superpuestos.
-- Pero debo asegurarme de que en la fecha de inscripción propuesta, exista un período de inscripción vigente.

IF pSede IS NULL THEN
	LET pSede = '00000';
END IF;

IF pdet_rama_act_alum IS NULL or pdet_rama_act_alum = '' THEN
	LET pdet_rama_act_alum = NULL;
END IF;

LET pNumeroCuil = replace (pNumeroCuil, '-', '');

IF NOT EXISTS (SELECT * FROM sga_carreras WHERE carrera = pCarrera) THEN
	LET vcMsg = 'La carrera  ' || pCarrera || '  es inexistente - Verifique';
			LET iStatus = -4;
                	RETURN iStatus, vcMsg;	
		
	END IF;


-- Se modifica para no restringir inscripciones al período activo
Select max(periodo_inscripcio) Into aperiodo_inscripcio
from sga_periodo_insc 
where anio_academico = pAnioAcademico
	and tipo in ('I', 'A');
	-- and TODAY between fecha_inicio and fecha_fin;
	
IF aperiodo_inscripcio IS NULL THEN

	LET vcMsg = 'No existe un período de inscripción a carreras vigente para el año academico ' || pAnioAcademico;
	LET iStatus = -1;
        RETURN iStatus, vcMsg;
END IF;

------------------------------------------------------------------------------------ 
-- Cálculo de atributos Calculados

IF (pPadre_Vive IS NOT NULL OR pMadre_Vive IS NOT NULL) THEN
	LET cViven_padres = 'S';
END IF;

IF (pSit_laboral_alumno IN (2,3)) THEN
	LET iExiste_trab_alum = 1;
ELSE
	LET iExiste_trab_alum = 3;
END IF;


------------------------------------------------------------------------------------ 
-- Verifico si existe la persona
Select nro_inscripcion Into anro_inscripcion
		from sga_personas
		where tipo_documento = pTipoDocumento 
			and nro_documento = pNroDocumento
			and unidad_academica = aunidad_academica;
			

IF anro_inscripcion is not null THEN
	------------------------------------------------------------------------------------ 
	-- Busco la carrera con carrera aspira rechazada y del mismo período de inscripción.
	------------------------------------------------------------------------------------ 
  	IF EXISTS (SELECT ' ' FROM sga_carrera_aspira, sga_situacion_asp
	              WHERE sga_carrera_aspira.unidad_academica = aunidad_academica
                	AND sga_carrera_aspira.nro_inscripcion = anro_inscripcion
	                AND sga_carrera_aspira.carrera = pCarrera
               		 AND sga_situacion_asp.resultado_asp = 'R'
	                AND sga_carrera_aspira.periodo_inscripcio = aperiodo_inscripcio 
                	AND sga_carrera_aspira.situacion_asp = sga_situacion_asp.situacion_asp) THEN
	                -- Error
			LET vcMsg = 'La persona posee una inscripción rechazada a la carrera en el año académico ' || pAnioAcademico;
			LET iStatus = -2;
                	RETURN iStatus, vcMsg;	
		
	END IF;

	------------------------------------------------------------------------------------ 
	-- Controlo si ya es aspirante en esta carrera en el periodo o ya es alumno
	------------------------------------------------------------------------------------ 
	IF EXISTS (SELECT ' ' FROM sga_carrera_aspira, sga_alumnos, sga_situacion_asp
		     WHERE sga_carrera_aspira.unidad_academica = aunidad_academica
                		AND sga_carrera_aspira.nro_inscripcion = anro_inscripcion
                		AND sga_carrera_aspira.carrera = pCarrera
                		AND sga_situacion_asp.resultado_asp <> 'R'
                		AND sga_carrera_aspira.periodo_inscripcio <> aperiodo_inscripcio 
                		AND sga_carrera_aspira.situacion_asp = sga_situacion_asp.situacion_asp
                		AND sga_alumnos.unidad_academica = sga_carrera_aspira.unidad_academica
                		AND sga_alumnos.carrera = sga_carrera_aspira.carrera
                		AND sga_alumnos.nro_inscripcion = sga_carrera_aspira.nro_inscripcion) THEN

                		-- Error
				LET vcMsg = 'La persona ya es alumno en esta carrera. Ingreso año académico ' || pAnioAcademico;
				LET iStatus = -3;
                		RETURN iStatus, vcMsg;	
	END IF;

	IF EXISTS (SELECT ' ' FROM sga_carrera_aspira, sga_alumnos, sga_situacion_asp
		     WHERE sga_carrera_aspira.unidad_academica = aunidad_academica
                		AND sga_carrera_aspira.nro_inscripcion = anro_inscripcion
                		AND sga_carrera_aspira.carrera = pCarrera
                		AND sga_situacion_asp.resultado_asp <> 'R'
                		AND sga_carrera_aspira.periodo_inscripcio = aperiodo_inscripcio 
                		AND sga_carrera_aspira.situacion_asp = sga_situacion_asp.situacion_asp
                		AND sga_alumnos.unidad_academica = sga_carrera_aspira.unidad_academica
                		AND sga_alumnos.carrera = sga_carrera_aspira.carrera
                		AND sga_alumnos.nro_inscripcion = sga_carrera_aspira.nro_inscripcion) THEN

                		-- Error
				LET vcMsg = 'La persona ya es Alumno en esta Carrera para el año academico de Ingreso ' || pAnioAcademico;
				LET iStatus = -5;
                		RETURN iStatus, vcMsg;	
	END IF;
	
	IF EXISTS (SELECT ' ' FROM sga_carrera_aspira, sga_situacion_asp
	              WHERE sga_carrera_aspira.unidad_academica = aunidad_academica
                	AND sga_carrera_aspira.nro_inscripcion = anro_inscripcion
	                AND sga_carrera_aspira.carrera = pCarrera
               		AND sga_situacion_asp.resultado_asp <> 'R'
	                AND sga_carrera_aspira.periodo_inscripcio <> aperiodo_inscripcio 
                	AND sga_carrera_aspira.situacion_asp = sga_situacion_asp.situacion_asp) THEN
	                -- Error
			LET vcMsg = 'La persona ya es Aspirante en esta Carrera. Ingreso año academico distinto al ' || pAnioAcademico;
			LET iStatus = -3;
                	RETURN iStatus, vcMsg;	
		
	END IF;
	
	IF NOT EXISTS (SELECT ' ' FROM sga_carrera_aspira, sga_situacion_asp
              		WHERE sga_carrera_aspira.unidad_academica = aunidad_academica
	                AND sga_carrera_aspira.nro_inscripcion = anro_inscripcion
                	AND sga_carrera_aspira.carrera = pCarrera
	                AND sga_situacion_asp.resultado_asp <> 'R'
	                AND sga_carrera_aspira.periodo_inscripcio = aperiodo_inscripcio
                	AND sga_carrera_aspira.situacion_asp = sga_situacion_asp.situacion_asp) THEN
		
		BEGIN WORK;
		-- Hacer inscripcion de aspirante	
		Insert Into sga_carrera_aspira 
		values (aunidad_academica, pCarrera, anro_inscripcion, aperiodo_inscripcio, pFechaInscripcion, pSede, null, 'I', pFechaInscripcion, null, 'AC', null, pTipoIngreso, null, null);

		-- Si no esta como aspirante, actualizo solo los datos de CUIL de Ingreso (que es de carga obligatoria)
		
		update sga_personas set numero_cuil = pNumeroCuil
		where nro_inscripcion = anro_inscripcion
			AND unidad_academica = pUnidadAcademica;

	ELSE

	
			BEGIN WORK;
			-- Tengo que desactivar trigger porque hay un error de Origen al actualizar e_mail
			-- SET TRIGGERS FOR sga_datos_censales disabled;
			-- UPDATE DE DATOS CENSALES Y SGA_PERSONAS
			-- Si esta como aspirante, actualizo con los datos de Ingreso

			update sga_personas set numero_cuil = pNumeroCuil --, fecha_ingreso_pais = pfecha_ingreso_pais
			where nro_inscripcion = anro_inscripcion
				AND unidad_academica = pUnidadAcademica;

			IF (pfecha_ingreso_pais IS NOT NULL) THEN
			
					IF (pfecha_ingreso_pais = '')THEN
						UPDATE	mdp_personas SET fecha_ingreso_pais = null
					WHERE 	persona = vpersona ;
					ELSE
						--valorCastFechaIngresoPais := pfecha_ingreso_pais::DATE;
						UPDATE	mdp_personas SET fecha_ingreso_pais = pfecha_ingreso_pais
						WHERE 	persona = vpersona ;	
					END IF;	
					
			END IF;


			update sga_datos_censales set estado_civil = pEstadoCivil, 
				e_mail = pEMail, 
				calle_per_lect = pcalle_per_lect,
				numero_per_lect = pnumero_per_lect,
				piso_per_lect = ppiso_per_lect,
				dpto_per_lect = pdpto_per_lect,
				unidad_per_lect = punidad_per_lect,
				loc_per_lect = ploc_per_lect,
				cp_per_lect = pcp_per_lect,
				te_per_lect = pte_per_lect,
				calle_proc = pcalle_proc,
				numero_proc = pnumero_proc,
				piso_proc = ppiso_proc,
				dpto_proc = pdpto_proc,
				unidad_proc = punidad_proc,
				loc_proc = ploc_proc,
				cp_proc = pcp_proc,
				te_proc = pte_proc,
				otros_estud_super = potros_estud_super,
				viven_padres = cViven_padres,
				sit_laboral_alu = pSit_laboral_alumno,
				categ_ocup_alum = pCateg_ocup_alum,
				act_econom_alum = pAct_econom_alum,
				det_rama_act_alum = pdet_rama_act_alum,
				hora_sem_trab_alum = pHora_sem_trab_alum,
				sit_laboral_padre = pSit_laboral_padre,
				ult_est_cur_padre = pUlt_est_cur_padre,
				act_econom_padre = pAct_econom_padre,
				det_rama_act_padre = pdet_rama_act_padre,
				sit_laboral_madre = pSit_laboral_madre,
				ult_est_cur_madre = pUlt_est_cur_madre,
				act_econom_madre = pAct_econom_madre,
				det_rama_act_madre = pdet_rama_act_madre


			where nro_inscripcion = anro_inscripcion
				and fecha_relevamiento = pFechaInscripcion;

			-- SET TRIGGERS FOR sga_datos_censales enabled;

			-- UPDATE DE DATOS CENSALES AUXILIARES
			update sga_datos_cen_aux set PADRE_VIVE = pPadre_vive where nro_inscripcion = anro_inscripcion and fecha_relevamiento = pFechaInscripcion;
			update sga_datos_cen_aux set MADRE_VIVE = pMadre_vive where nro_inscripcion = anro_inscripcion and fecha_relevamiento = pFechaInscripcion;
			update sga_datos_cen_aux set EXISTE_TRAB_ALUM = iExiste_trab_alum where nro_inscripcion = anro_inscripcion and fecha_relevamiento = pFechaInscripcion;


			update sga_datos_cen_aux set PADRE_VIVE = 'D' where PADRE_VIVE is null and nro_inscripcion = anro_inscripcion;
			update sga_datos_cen_aux set MADRE_VIVE = 'D' where MADRE_VIVE is null  and nro_inscripcion = anro_inscripcion;
			update sga_datos_cen_aux set EXISTE_TRAB_ALUM = 3 where EXISTE_TRAB_ALUM is null  and nro_inscripcion = anro_inscripcion;

			-- UPDATE DE DATOS CENSALES AUXILIARES u820
			update u820_datos_cen_aux Set cant_hora_sem_trab_alum = pCant_horas_sem_trab_alum, 
				alu_req_acces_fisica = palu_req_acces_fisica, 
				alu_req_acces_com =  palu_req_acces_com
			Where nro_inscripcion = anro_inscripcion and fecha_relevamiento = pFechaInscripcion;

			COMMIT WORK;
			LET vcMsg = 'OK' || ' - ' || anro_inscripcion;
			LET iStatus = 1;
			RETURN iStatus, vcMsg;



	END IF;
	
ELSE


	execute procedure sp_nro_inscripcion(aunidad_academica) into anro_inscripcion;

	BEGIN WORK;
	insert into sga_personas (UNIDAD_ACADEMICA,  NRO_INSCRIPCION, FECHA_INSCRIPCION,  APELLIDO, NOMBRES, PAIS_DOCUMENTO, TIPO_DOCUMENTO, NRO_DOCUMENTO, NUMERO_CUIL, SEXO, FECHA_NACIMIENTO, ABORIGEN, GRUPO_SANGUINEO, FACTOR_SANGUINEO, NACIONALIDAD, LOC_NACIMIENTO, APELLIDO_PADRE, APELLIDO_MADRE, PAIS_EMISOR_PASAP, NRO_PASAP, ANIO_EGRESO_SEC, ORIENT_VOC_REC, COLEGIO_SECUNDARIO, FECHA_INGRESO_PAIS) values (
			aunidad_academica, anro_inscripcion, pfechaInscripcion, pApellido, pNombres, pPaisDocumento, pTipoDocumento, pNroDocumento, pNumeroCuil, pSexo, pFechaNacimiento, 'N', pGrupo_sanguineo, pFactor_sanguineo, pNacionalidad, pLoc_nacimiento, pApellido_padre, pApellido_madre, pPais_emisor_pasap, pNro_pasap, pAnio_egreso_sec, pColegio_secundario_dependencia, pColegio_secundario,pfecha_ingreso_pais);

	Insert Into sga_carrera_aspira
		values (aunidad_academica, pCarrera, anro_inscripcion, aperiodo_inscripcio, pFechaInscripcion, pSede, null, 'I', pFechaInscripcion, null, 'AC', null, pTipoIngreso, null, null);

	Insert Into u820_datos_cen_aux (UNIDAD_ACADEMICA,  NRO_INSCRIPCION, FECHA_RELEVAMIENTO)
		values ( aunidad_academica, anro_inscripcion, pFechaInscripcion);

	-- UPDATE DE CLAVE
	UPDATE aca_usuarios_ag set clave = pClave
		WHERE nro_inscripcion = anro_inscripcion
		and identificacion = pNroDocumento;

	-- UPDATE DE DATOS CENSALES
	update sga_datos_censales set estado_civil = pEstadoCivil, 
		e_mail = pEMail, 
		calle_per_lect = pcalle_per_lect,
		numero_per_lect = pnumero_per_lect,
		piso_per_lect = ppiso_per_lect,
		dpto_per_lect = pdpto_per_lect,
		unidad_per_lect = punidad_per_lect,
		loc_per_lect = ploc_per_lect,
		cp_per_lect = pcp_per_lect,
		te_per_lect = pte_per_lect,
		calle_proc = pcalle_proc,
		numero_proc = pnumero_proc,
		piso_proc = ppiso_proc,
		dpto_proc = pdpto_proc,
		unidad_proc = punidad_proc,
		loc_proc = ploc_proc,
		cp_proc = pcp_proc,
		te_proc = pte_proc,
		otros_estud_super = potros_estud_super,
		viven_padres = cViven_padres,
		sit_laboral_alu = pSit_laboral_alumno,
		categ_ocup_alum = pCateg_ocup_alum,
		act_econom_alum = pAct_econom_alum,
		det_rama_act_alum = pdet_rama_act_alum,
		hora_sem_trab_alum = pHora_sem_trab_alum,
		sit_laboral_padre = pSit_laboral_padre,
		ult_est_cur_padre = pUlt_est_cur_padre,
		act_econom_padre = pAct_econom_padre,
		det_rama_act_padre = pdet_rama_act_padre,
		sit_laboral_madre = pSit_laboral_madre,
		ult_est_cur_madre = pUlt_est_cur_madre,
		act_econom_madre = pAct_econom_madre,
		det_rama_act_madre = pdet_rama_act_madre


	where nro_inscripcion = anro_inscripcion
		and fecha_relevamiento = pFechaInscripcion;

	-- UPDATE DE DATOS CENSALES AUXILIARES
	update sga_datos_cen_aux set PADRE_VIVE = pPadre_vive where nro_inscripcion = anro_inscripcion and fecha_relevamiento = pFechaInscripcion;
	update sga_datos_cen_aux set MADRE_VIVE = pMadre_vive where nro_inscripcion = anro_inscripcion and fecha_relevamiento = pFechaInscripcion;
	update sga_datos_cen_aux set EXISTE_TRAB_ALUM = iExiste_trab_alum where nro_inscripcion = anro_inscripcion and fecha_relevamiento = pFechaInscripcion;


	update sga_datos_cen_aux set PADRE_VIVE = 'D' where PADRE_VIVE is null and nro_inscripcion = anro_inscripcion;
	update sga_datos_cen_aux set MADRE_VIVE = 'D' where MADRE_VIVE is null  and nro_inscripcion = anro_inscripcion;
	update sga_datos_cen_aux set EXISTE_TRAB_ALUM = 3 where EXISTE_TRAB_ALUM is null  and nro_inscripcion = anro_inscripcion;

	-- UPDATE DE DATOS CENSALES AUXILIARES u820
	update u820_datos_cen_aux Set cant_hora_sem_trab_alum = pCant_horas_sem_trab_alum, 
		alu_req_acces_fisica = palu_req_acces_fisica, 
		alu_req_acces_com =  palu_req_acces_com
	Where nro_inscripcion = anro_inscripcion and fecha_relevamiento = pFechaInscripcion;



END IF;

COMMIT WORK;

LET vcMsg = 'OK aspirante inscripto correctamente ';
RETURN iStatus, vcMsg;


END PROCEDURE;
-- *************** FIN DEL PROCEDURE "dba".web_ser_insc_asp ***************
revoke execute on "dba".web_ser_insc_asp from public;
grant execute on "dba".web_ser_insc_asp to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_ser_insc_asp to internet; -- Rol de usuario de Internet

