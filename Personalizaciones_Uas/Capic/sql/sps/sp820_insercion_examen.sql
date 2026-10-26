-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version Original: 1.03.0
-- Ultima Version de Modificación: 1.11.0, 2.00.1, 2.05.0
-- 
-- SP: sp820_insercion_examen
-- 
-- Recibe: - Tipo y Nro de Documento
--	   - Mesa Examen - LLamado
--	   - Tipo de Inscripcion a Examen
-- 
-- Retorna: Estado del INSERT
-- 
-- Registra una Inscripcion a Examenes
--   * NO puede inscribirse a una materia ya aprobada
--   * NO puede inscribirse mas de n-veces para cursar una materia, donde n lo indica el valor del parametro 
--
-- Versión 1.11 (Modificada para que se adapte a la inscripción de una materia de plan anterior.)
-- *******************************************************************************
-- DROP PROCEDURE sp820_insercion_examen;
CREATE PROCEDURE sp820_insercion_examen(
				pUnidadAcademica	LIKE sga_alumnos.unidad_academica,
				pTipoDoc			LIKE sga_personas.tipo_documento,
				pNroDoc 			LIKE sga_personas.nro_documento,
				pMateria 			LIKE sga_mesas_examen.materia,
				pAnioAcademico 		LIKE sga_mesas_examen.anio_academico,
				pTurnoExamen		LIKE sga_mesas_examen.turno_examen,
				pMesaExamen 		LIKE sga_mesas_examen.mesa_examen,
				pLlamado 			LIKE sga_insc_examen.llamado,
				pTipoInscripcion	LIKE sga_insc_examen.tipo_inscripcion,
				pMatGenerica		LIKE sga_insc_examen.materia_generica, 
				pInterfaz			LIKE sga_insc_examen.interfaz )
		RETURNING    
				smallint,		-- status -1 Error/ 0 OK
				varchar(255),	-- mensaje 
				varchar(20);	-- nro_transacción

   -- vars para el manejo de excepciones
	DEFINE 	ISAMError, SQLErr 							integer;
	DEFINE 	errorInfo 									varchar(76);
	DEFINE	vcUserError									varchar(10);

   -- vars locales
	DEFINE 	iStatusCall, iOK, iStatus 					smallint;
	DEFINE 	vcMsg 										varchar(255);

   -- vars locales	
	DEFINE  cnt_inscunacarrera, cnt_insc_carreras		SMALLINT;
	DEFINE  vcUnidadAcademica							LIKE sga_insc_examen.unidad_academica;
	DEFINE	vcCarrera									LIKE sga_insc_examen.carrera;
	DEFINE	pCarrera									LIKE sga_insc_examen.carrera;
	DEFINE  vcLegajo									LIKE sga_insc_examen.legajo;
	DEFINE  pLegajo										LIKE sga_insc_examen.legajo;
	DEFINE  vcVersion									LIKE sga_versiones_plan.version;
	DEFINE  vdFechaReg  								DATE;
	DEFINE	pEstadoEjCtrls								LIKE sga_insc_examen.estado;   -- est de ejec controles: A-activa/P-Pendiente

   DEFINE insc_unico_llamado, insc_llamado 				LIKE sga_param_sistema.valor;
   DEFINE linsc_un_llamado, vcplan_anterior				LIKE sga_param_sistema.valor;
   DEFINE vcEstado										LIKE sga_insc_examen.estado;
   DEFINE vcNroTransaccion								LIKE sga_insc_examen.nro_transaccion; 
   DEFINE vclistado_examen								LIKE sga_insc_examen.listado_examen; 
   DEFINE iFolio_listado								LIKE sga_insc_examen.folio_listado;
   DEFINE iRenglon_listado								LIKE sga_insc_examen.renglon_listado; 
   DEFINE vcEquiv_parcial								LIKE sga_insc_examen.equiv_parcial; 
   DEFINE vcAdmiteLibres								LIKE sga_mesas_examen.admite_libres; 

   DEFINE vcMatGenerica									LIKE sga_insc_examen.materia_generica;
   DEFINE iCantMaxInscTurno, iCantMaxInscLlam			smallint;
   DEFINE vcRestricciones								LIKE sga_param_sistema.valor;
   DEFINE dFecha_maxima									LIKE sga_prestamos.fecha; 
   DEFINE vcCarreraMesa									LIKE sga_planes.carrera;
   DEFINE vcNombreCarrera								LIKE sga_carreras.nombre;
   DEFINE vcPlan, vcPlanMesa							LIKE sga_planes.plan;
   DEFINE dthora										Datetime hour to second; -- HORA_INICIO

  -- si hay algun error
  ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
      LET vcUserError  = '800401' ;
      LET iStatus 	  = -1; 
      LET vcMsg 	  =  vcUserError || ',' || SQLErr || ' - ' || errorInfo;
      RETURN iStatus, vcMsg, 'null';
   END EXCEPTION;

BEGIN

	LET vcNroTransaccion = null;
	
	-- Busco la carrera de integracion para la Unidad Academica
	SELECT carrera
		INTO pCarrera
		FROM sga_carreras_grupo
		WHERE grupo_carrera = "i0001";
	
	-- Busco los datos del alumno con el tipo y nro de documento pasado como parámetro
	SELECT alu.legajo
		INTO pLegajo
		FROM sga_alumnos alu, sga_personas per
		WHERE 	per.tipo_documento  = pTipoDoc
		AND 	per.nro_documento   = pNroDoc
		AND		per.nro_inscripcion = alu.nro_inscripcion
		AND 	alu.carrera         = pCarrera;
	
	IF pLegajo IS NULL THEN
		LET iStatus	= -1;
		LET vcMsg   = "El tipo y nro. de documento no coincide con ninguna persona de la base de datos";
		RETURN iStatus, vcMsg, vcNroTransaccion;
	END IF;

	LET pEstadoEjCtrls 	= 'A'; -- est de ejec controles: A-activa/P-Pendiente
	LET iOK 			= 0 ;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--	                      ¡¡¡ Controles Obligatorios !!!
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- 1) NO tenga aprobada la materia
BEGIN
	on exception in (-206)
		-- Tabla no existe continuo el proceso	
	end exception with resume;

	DROP TABLE tmp_hist_acad_mat;

	SELECT materia, resultado 
		FROM vw_hist_academica 
		WHERE unidad_academica = pUnidadAcademica 
		AND  carrera		= pCarrera 
		AND  legajo 		= pLegajo
		INTO TEMP  tmp_hist_acad_mat;

	IF DBINFO("sqlca.sqlerrd2") > 0 THEN
		SELECT COUNT(*) INTO iOK
			FROM tmp_hist_acad_mat
			WHERE materia = pMateria
			AND	resultado IN ('A', 'P');

		IF iOK > 0 THEN
			LET vcUserError  	= '800420' ;
			LET iStatus 	  	= -1; 
			LET vcMsg 	  		=  vcUserError || ',' || pMateria ;
			RETURN iStatus, vcMsg, vcNroTransaccion;
		END IF ;
	END IF;

	DROP TABLE tmp_hist_acad_mat;
END;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


  -- 2) Verifico la Cantidad Maxima de Inscripciones por Turno permitidas a una Materia en un Turno de Examen
	EXECUTE PROCEDURE sp_param_sistema ('cant_de_insc_ex_una_materia_por_turno') INTO  iCantMaxInscTurno;

	LET cnt_inscunacarrera = 0;
    LET cnt_insc_carreras  = 0;
    -- Recupero todas las inscricpiones por cada carrera en la que esta inscripta la Persona
	FOREACH EXECUTE PROCEDURE sp_alucarrerasinsc (pUnidadAcademica, pLegajo, pCarrera) INTO vcUnidadAcademica, vcCarrera, vcLegajo, vcPlan, vcVersion, vcNombreCarrera
		SELECT COUNT(*) INTO cnt_inscunacarrera 
			FROM sga_insc_examen
			WHERE unidad_academica 	= vcUnidadAcademica
			AND carrera 			= vcCarrera 
			AND legajo 				= vcLegajo
			AND materia 			= pMateria
			AND anio_academico 		= pAnioAcademico
			AND turno_examen 		= pTurnoExamen
			AND estado       		IN ('A', 'E');

		LET cnt_insc_carreras = cnt_insc_carreras + cnt_inscunacarrera;

	END FOREACH;	
	
	IF cnt_insc_carreras  >=    iCantMaxInscTurno THEN
		LET vcUserError	= '800425' ;
		LET iStatus 	= -1; 
		LET vcMsg 	  	=  vcUserError ;
		RETURN iStatus, vcMsg, vcNroTransaccion;
	END IF;
 
   -- Verifico si las inscripciones son al turno de Examen o a un Llamado
	Execute procedure sp_param_sistema ('inscripcion_examen_por_llamado') INTO insc_llamado;
	IF insc_llamado = 'S' THEN
		IF pLlamado IS NULL THEN
		-- Error
		-- raise exception -746,0,'El  se debe inscribir a un llamado del Turno de Examen.';
			LET vcUserError	= '800421' ;
			LET iStatus 	= -1; 
			LET vcMsg 	  	=  vcUserError || ',' || pMateria ;
			RETURN iStatus, vcMsg, vcNroTransaccion;
		END IF;
	
		-- Verifico si ya no esta inscripto en este llamado
		IF (SELECT COUNT(*) 
				FROM sga_insc_examen 
				WHERE unidad_academica	= pUnidadAcademica
				AND carrera 			= pCarrera 
				AND legajo  			= pLegajo  
				AND materia 			= pMateria
				AND anio_academico 		= pAnioAcademico 
				AND turno_examen   		= pTurnoExamen 
				AND mesa_examen    		= pMesaExamen 
				AND llamado        		= pLlamado
				AND estado <> 'B') > 0 THEN
			-- Error
			-- raise exception -746,0,'Ud. ya esta inscripto en la Materia ' || n_materia || ', Mesa ' || n_mesa_examen || ' y llamado ' || n_llamado ;
			LET vcUserError	= '800422' ;
			LET iStatus 	= -1; 
			LET vcMsg 	  	=  vcUserError || ',' || pMateria || ',' || pMesaExamen || ',' || pLlamado;
			RETURN iStatus, vcMsg, vcNroTransaccion;
		END IF;

		-- Cantidad de Insc A Ex permitidas a una materia en un llamado.
		EXECUTE PROCEDURE sp_param_sistema ('cant_de_insc_ex_una_materia_por_llamado') INTO  iCantMaxInscLlam;

		LET cnt_inscunacarrera = 0;
		LET cnt_insc_carreras  = 0;
		-- Recupero todas las inscricpiones por cada carrera en la que esta inscripta la Persona
		FOREACH EXECUTE PROCEDURE sp_alucarrerasinsc (pUnidadAcademica, pLegajo, pCarrera) INTO vcUnidadAcademica, vcCarrera, vcLegajo, vcPlan, vcVersion, vcNombreCarrera
			-- Controlo si ya esta inscripto en esta materia por otra Carrera, en este llamado.
			IF vcCarrera <> pCarrera OR vcLegajo <> pLegajo THEN
				IF (SELECT COUNT(*) 
						FROM sga_insc_examen 
						WHERE unidad_academica	= vcUnidadAcademica
						AND carrera 			= vcCarrera 
						AND legajo  			= vcLegajo  
						AND materia 			= pMateria
						AND anio_academico 		= pAnioAcademico 
						AND turno_examen   		= pTurnoExamen 
						AND mesa_examen    		= pMesaExamen 
						AND llamado        		= pLlamado
						AND estado <> 'B') > 0 THEN
					-- Error
					LET vcUserError	= '800443' ;
					LET iStatus 	= -1; 
					LET vcMsg 	  	=  vcUserError || ',' || pMateria || ',' || vcCarrera;
					RETURN iStatus, vcMsg, vcNroTransaccion;
				END IF; 
			END IF;

			SELECT COUNT(*) 
				INTO cnt_inscunacarrera
				FROM sga_insc_examen
				WHERE unidad_academica	= vcUnidadAcademica
				AND carrera 			= vcCarrera 
				AND legajo 				= vcLegajo
				AND materia 			= pMateria
				AND anio_academico 		= pAnioAcademico
				AND turno_examen 		= pTurnoExamen
				AND llamado 			= pLlamado;
			LET cnt_insc_carreras = cnt_insc_carreras + cnt_inscunacarrera;

		END FOREACH;

		IF cnt_insc_carreras  >=  iCantMaxInscLlam  THEN
			LET vcUserError	= '800426' ;
			LET iStatus 	= -1; 
			LET vcMsg 	  	=  vcUserError  ;
			RETURN iStatus, vcMsg, vcNroTransaccion;
     	END IF;

		-- 2) Verifico la Cantidad Maxima de Inscripciones por Turno permitidas a una Materia en un Turno de Examen
		EXECUTE PROCEDURE sp_param_sistema ('restricciones_a_multiples_insc_examen') INTO  vcRestricciones;

		-- Los controles son para la materia. No tiene en cuenta la Mesa de Examen.
		IF vcRestricciones = 'L' THEN
			-- No realizo ningun control
		ELIF  vcRestricciones = 'D' THEN
			-- No permito inscribir a un 2do llamado, si se encuentra inscripto en otro llamado y la fecha del examen aun no ha pasado!
			-- No permito inscribir a la misma materia, para cualquir mesa de examen
			LET dFecha_maxima = NULL;

			SELECT MAX(p.fecha)  
				INTO dfecha_maxima
				FROM sga_insc_examen ie, sga_llamados_mesa llm, sga_prestamos  p
				WHERE  ie.unidad_academica 	= pUnidadAcademica
				AND ie.carrera    			= pCarrera
				AND ie.legajo    			= pLegajo
				AND ie.materia    			= pMateria
				AND ie.anio_academico  		= pAnioAcademico
				AND ie.turno_examen  		= pTurnoExamen
				AND llm.unidad_academica 	= ie.unidad_academica    
				AND llm.materia 			= ie.materia  
				AND llm.anio_academico 		= ie.anio_academico  
				AND llm.turno_examen 		= ie.turno_examen   
				AND llm.mesa_examen 		= ie.mesa_examen   
				AND llm.llamado 			= ie.llamado  
				AND p.prestamo 				= llm.prestamo; 

			IF DBINFO("sqlca.sqlerrd2") > 0 THEN
				IF dFecha_maxima IS NULL THEN
					-- no ocurre nada
				ELIF  dFecha_maxima >= TODAY THEN
					LET dthora = NULL;
					IF dFecha_maxima = TODAY THEN
						-- Si la hora de finalizacion del Examen es menor a la hora actual, no hay problema
						SELECT MAX(p.hora_finalizacion)  
							INTO dthora
							FROM sga_insc_examen ie, sga_llamados_mesa llm, sga_prestamos  p
							WHERE  ie.unidad_academica 	= pUnidadAcademica
							AND ie.carrera    			= pCarrera
							AND ie.legajo    			= pLegajo
							AND ie.materia    			= pMateria
							AND ie.anio_academico  		= pAnioAcademico
							AND ie.turno_examen  		= pTurnoExamen
							AND llm.unidad_academica 	= ie.unidad_academica    
							AND llm.materia 			= ie.materia  
							AND llm.anio_academico 		= ie.anio_academico  
							AND llm.turno_examen 		= ie.turno_examen   
							AND llm.mesa_examen 		= ie.mesa_examen   
							AND llm.llamado 			= ie.llamado  
							AND p.prestamo 				= llm.prestamo; 
				  	END IF
					-- Comparo si la hora del examen es mayor a la hora actual o es nula.	
					-- Si es la misma fecha y la hora es menor a la actual, entonces permito la inscripcion.
					IF dtHora IS NULL OR dtHora > CURRENT THEN
						-- Error
						LET vcUserError	= '800427' ;
						LET iStatus 	= -1; 
						LET vcMsg 	  	=  vcUserError;
						RETURN iStatus, vcMsg, vcNroTransaccion;	
					END IF;
				END IF;
			END IF;

		ELIF  vcRestricciones = 'A' THEN
			IF (SELECT COUNT(*)
					FROM  sga_actas_examen  ae, sga_detalle_acta  da
					WHERE  ae.unidad_academica 	= pUnidadAcademica
					AND ae.materia    			= pMateria
					AND ae.anio_academico  		= pAnioAcademico
					AND ae.turno_examen  		= pTurnoExamen
					AND ae.llamado   			< pLlamado 
					AND da.unidad_academica 	= ae.unidad_academica    
					AND da.tipo_acta 			= ae.tipo_acta
					AND da.acta 				= ae.acta
					AND da.carrera 				= pCarrera
					AND da.legajo 				= pLegajo
					AND (ae.estado <> 'C'  or da.resultado <> 'U')  )  > 0 THEN

				-- Error
				LET vcUserError	= '800428' ;
				LET iStatus 	= -1; 
				LET vcMsg 	  	= vcUserError;
				RETURN iStatus, vcMsg, vcNroTransaccion;
			END IF;
		END IF;

		-- Verifico si se puede inscribir a mas de un llamado en el turno
		Execute procedure sp_param_sistema ('inscripcion_examen_unico_llamado') INTO insc_unico_llamado;
		IF insc_unico_llamado = 'S' THEN
			LET cnt_inscunacarrera = 0;
			LET cnt_insc_carreras  = 0;
			-- Recupero todas las inscricpiones por cada carrera en la que esta inscripta la Persona
			FOREACH EXECUTE PROCEDURE sp_alucarrerasinsc (pUnidadAcademica, pLegajo, pCarrera) INTO vcUnidadAcademica, vcCarrera, vcLegajo, vcPlan, vcVersion, vcNombreCarrera
				SELECT COUNT(*) 
					INTO cnt_inscunacarrera
					FROM sga_insc_examen
					WHERE unidad_academica 	= vcUnidadAcademica
					AND carrera 			= vcCarrera 
					AND legajo  			= vcLegajo  
					AND materia 			= pMateria
					AND anio_academico 		= pAnioAcademico 
					AND turno_examen   		= pTurnoExamen 
					AND llamado    			<> pLlamado
					AND estado 				<> 'B';
				LET cnt_insc_carreras = cnt_insc_carreras + cnt_inscunacarrera;
			END FOREACH;
			IF (cnt_insc_carreras) > 0 THEN
				-- Error
				-- raise exception -746,0,'Ud. no puede inscribirse en mas de un llamado. Materia ' || n_materia;
				LET vcUserError	= '800423' ;
				LET iStatus 	= -1; 
				LET vcMsg 	  	= vcUserError || ',' || pMateria;
				RETURN iStatus, vcMsg, vcNroTransaccion;
			END IF;
		END IF;

	ELIF insc_llamado = 'N' THEN
		-- La inscripcion es por TURNO DE EXAMEN
		IF (SELECT COUNT(*) 
				FROM sga_insc_examen
				WHERE unidad_academica 	= pUnidadAcademica
				AND carrera 			= pCarrera 
				AND legajo  			= pLegajo  
				AND materia 			= pMateria
				AND anio_academico 		= pAnioAcademico 
				AND turno_examen   		= pTurnoExamen 
	        	AND mesa_examen    		= pMesaExamen 
				AND estado <> 'B') > 0 THEN
			-- Error
			LET vcUserError = '800424' ;
			LET iStatus   	= -1; 
			LET vcMsg 	  	=  vcUserError || ',' || pMesaExamen || ',' || pTurnoExamen;
			RETURN iStatus, vcMsg, vcNroTransaccion;
		END IF;

		FOREACH EXECUTE PROCEDURE sp_alucarrerasinsc (pUnidadAcademica, pLegajo, pCarrera) INTO vcUnidadAcademica, vcCarrera, vcLegajo, vcPlan, vcVersion, vcNombreCarrera
			IF vcCarrera <> pCarrera OR vcLegajo <> pLegajo THEN
				IF (SELECT COUNT(*) 
						FROM sga_insc_examen 
						WHERE unidad_academica 	= pUnidadAcademica
						AND carrera 			= vcCarrera 
						AND legajo  			= vcLegajo  
						AND materia 			= pMateria
						AND anio_academico 		= pAnioAcademico 
						AND turno_examen   		= pTurnoExamen 
						AND estado <> 'B') > 0 THEN
					-- Error
					LET vcUserError	= '800443' ;
					LET iStatus 	= -1; 
					LET vcMsg 	  	=  vcUserError || ',' || pMateria || ',' || vcCarrera;
					RETURN iStatus, vcMsg, vcNroTransaccion;
				END IF; 
			END IF; 
		END FOREACH;
	END IF;  -- Tipo de Inscripcion: turno o Llamado

	-- (3) Control del Tipo de Mesa (Para libres o Regulares o ambas)
	LET vcCarreraMesa = NULL;
	LET vcPlanMesa    = NULL;

	SELECT admite_libres, carrera, plan 
		INTO vcAdmiteLibres, vcCarreraMesa, vcPlanMesa
		FROM sga_mesas_examen
		WHERE unidad_academica 	= pUnidadAcademica
		AND materia 			= pMateria
		AND anio_academico 		= pAnioAcademico 
		AND turno_examen   		= pTurnoExamen 
		AND mesa_examen  		= pMesaExamen;
  
	IF DBINFO("sqlca.sqlerrd2") <= 0 THEN
		LET vcUserError = '800429' ;
	    LET iStatus     = -1; 
	    LET vcMsg 	    =  vcUserError  || ', ' || pMesaExamen;
	    RETURN iStatus, vcMsg, vcNroTransaccion;
	ELSE
		IF vcAdmiteLibres = 'R' AND NOT (pTipoInscripcion <> 'R' OR pTipoInscripcion <> 'A') THEN
			LET vcUserError = '800430' ;
			LET iStatus     = -1; 
			LET vcMsg 	    =  vcUserError  || ', Regulares';
			RETURN iStatus, vcMsg, vcNroTransaccion;
		END IF;
		IF vcAdmiteLibres = 'L' AND NOT (pTipoInscripcion <> 'L' OR pTipoInscripcion <> 'A') THEN
			LET vcUserError = '800430' ;
			LET iStatus     = -1; 
			LET vcMsg 	    =  vcUserError || ', Libres';
			RETURN iStatus, vcMsg, vcNroTransaccion;
		END IF;
		IF vcAdmiteLibres = 'T' and pTipoInscripcion <> 'T' THEN
			-- Tipo de inscripcion Tesis, debe ser mesa para tesis.			
			LET vcUserError = '800430' ;
			LET iStatus     = -1; 
			LET vcMsg 	    =  vcUserError || ', Tesis';
			RETURN iStatus, vcMsg, vcNroTransaccion;
		END IF;
	END IF;

   -- (4) No permitir inscribir a una mesa con Acta cerrada
   IF (SELECT COUNT(*)
			FROM sga_actas_examen ae
			WHERE  ae.unidad_academica 	= pUnidadAcademica
			AND ae.materia    			= pMateria
			AND ae.anio_academico  		= pAnioAcademico
			AND ae.turno_examen  		= pTurnoExamen
			AND ae.mesa_examen  		= pMesaExamen
			AND ae.llamado   			= pLlamado 
			AND ae.estado =  'C' )  > 0 THEN

		-- Error
		LET vcUserError = '800431' ;
		LET iStatus 	= -1; 
		LET vcMsg 	  	=  vcUserError;
		RETURN iStatus, vcMsg, vcNroTransaccion;
	END IF;

	-- ****************************************rendir_regul_planes_anteriores**************************************
	-- Para reutilizar este sp. para inscripción a materias de planes anteriores agregué el siguiente
	-- código fuente. 
	
	-- Verifico si se puede inscribir a una materia del plan anterior que no este en el plan actual del alumno.
	Execute procedure sp_param_sistema ('rendir_regul_planes_anteriores') INTO vcplan_anterior;

	-- Obtener el plan y versión actual del alumno.
	EXECUTE PROCEDURE sp_plan_de_alumno(pUnidadAcademica,pCarrera,pLegajo) INTO vcPlan,vcVersion;

	-- Si esta habilitado el rendir materia de plan anterior. Me fijo si la materia es del plan anterior, 
	-- y no pertenece al plan - version actual. Colocar el plan y la versión de la materia si es del plan anterior.
	IF vcplan_anterior = 'S' THEN
   	
		-- Si no existe la materia en el plan - versión actual, saco el plan y versión al que pertence, en donde la cursó.
		IF (SELECT count(materia) 
				FROM sga_atrib_mat_plan
				WHERE unidad_academica 	= pUnidadAcademica
				AND	carrera 			= pCarrera
				AND plan 				= vcPlan
				AND	version 			= vcVersion
				AND materia 			= pMateria
				AND tipo_materia 		<> 'G') = 0 THEN

			-- En base a la vista de cursada, saco el plan y versión de la cursada. Sobreescribo la actual para que realize
			-- el insert en sga_insc_examen con el plan y versión anterior.
			LET vcPlan 		= NULL;
			LET vcVersion 	= NULL;

			-- ejecuto un FOREACH, por si tiene mas de una cursada vigente de la misma materia.
			FOREACH SELECT cur.plan, cur.version, cur.fecha_regularidad
						INTO	vcPlan,vcVersion, vdFechaReg
						FROM	sga_cursadas cur
						WHERE cur.unidad_academica 	= pUnidadAcademica
						AND	cur.carrera 			= pCarrera
						AND	cur.legajo 				= pLegajo
						AND	cur.materia 			= pMateria
						AND	cur.resultado 			= 'A'
						AND	(cur.fin_vigencia_regul is null or fin_vigencia_regul >= TODAY)
						ORDER BY cur.fecha_regularidad DESC

				-- Devuelvo la ultima cursada
				EXIT FOREACH;
			END FOREACH;
			IF vcPlan IS NULL OR vcVersion IS NULL THEN
				-- Error. la cursada de la materia se venció o no se encontro alguna cursada.
				LET vcUserError = '800395' ;
				LET iStatus 	= -1; 
				LET vcMsg 	  	=  vcUserError || ',' || pMateria  ;
				RETURN iStatus, vcMsg, vcNroTransaccion;
			END IF;
		END IF;
	END IF;

	-- ****************************************rendir_regul_planes_anteriores*********************************

	-- (5) No permitir inscribir a una mesa de otra carrera o Plan
	-- Controlo solo si esta cargada la Carrera y el Plan 
	-- Éste control obligatorio va a depender del parámetro del sistema 'rendir_regul_planes_anteriores',
	-- ya que el valor de vcPlan este dependiendo si la materia a inscribirse es de un plan anterior y a su vez no 
	-- pertenece al plan - versión actual del alumno.

	IF vcCarreraMesa IS NOT NULL AND vcCarreraMesa <> '' THEN
		SELECT nombre 
			INTO vcNombreCarrera
			FROM sga_carreras
			WHERE unidad_academica 	= pUnidadAcademica
			AND carrera  			=  vcCarrera;

		IF vcCarreraMesa <> pCarrera OR vcPlanMesa <> vcPlan THEN
			-- Error
			LET vcUserError = '800432' ;
			LET iStatus 	= -1; 
			LET vcMsg 	  	=  vcUserError || ', ' || vcCarreraMesa || ', ' ||  vcNombreCarrera || ', ' ||  vcPlanMesa;
			RETURN iStatus, vcMsg, vcNroTransaccion;
		END IF;
	END IF;

-- ++++++++++++++++++++++++++ FIN CONTROLES OBLIGATORIOS +++++++++++++++++++++++++++++++++++
 
	-- Estado en que debe quedar la Inscripcion a Examen (Pendiente o Aceptada).         
	LET vcEstado = pEstadoEjCtrls;
	-- defino el estado de la Inscripcion segun lo que recibio el procedure y lo que indica el parametro del sistema
	IF pEstadoEjCtrls = 'A' THEN	-- si los controles pasaron todos OK
		-- verifico como deberia quedar la finalmente ls inscripcion si paso todos los controles.
		EXECUTE PROCEDURE sp_param_sistema(pInterfaz || '_estado_final_insc_examen') INTO vcEstado;
		-- EXECUTE PROCEDURE sp_param_sistema('si_fallo_ctrl_insc_ex_grabar_pendiente')  INTO cEstado; NO VA MAS
	END IF;

	
	-- Obtengo Nro. de Transaccion segun interfase
	EXECUTE PROCEDURE sp_nroTransaccAG() INTO vcNroTransaccion ;

	LET vclistado_examen 	= null;
	LET vcEquiv_parcial 	= 'N';	-- Esto debe verificarse!
	LET iFolio_listado 		= null;
	LET iRenglon_listado 	= null;
	LET vcEstado 			= 'A';

	-- Agrego la inscripcion de Examen
	INSERT INTO sga_insc_examen (
			unidad_academica, carrera, legajo, materia,
			fecha_inscripcion, anio_academico, turno_examen, mesa_examen, llamado,
			tipo_inscripcion, equiv_parcial, materia_generica,
			listado_examen, folio_listado, renglon_listado,
			nro_transaccion, interfaz, estado, plan, version)
		VALUES (pUnidadacademica, pCarrera, pLegajo, pMateria,
			Current Year to Second, pAnioAcademico, pTurnoExamen, pMesaExamen, pLlamado,
			pTipoInscripcion, vcEquiv_parcial,  pMatGenerica,
			vclistado_examen, iFolio_listado, iRenglon_listado,
			vcNroTransaccion, pInterfaz, vcEstado, vcPlan, vcVersion);

	-- si llego hasta aca, esta todo OK
	LET iStatus = 1; 
	IF 	vcEstado = 'A' THEN
		LET vcUserError  = '800400' ;
	ELSE
		-- Insc Pendiente
		LET vcUserError  = '800410' ;
	END IF;
	LET vcMsg 	=  vcUserError || ',' || vcNroTransaccion ;
	
	-- devuelvo el resultado
	RETURN iStatus, vcMsg, vcNroTransaccion;
END;

END PROCEDURE;
-- ++++++++++++++++++++++++++++++++++++++++++++++ FIN SP sp_i_inscexam +++++++++++++++++++++++++++++++++++++++

