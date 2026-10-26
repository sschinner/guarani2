-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version Original: 1.2.0
-- Version Modificada 1.11.0, 2.01.0, 2.03.0, 2.04.0, 2.5.0
-- Procedure sp_crear_alumno
--
-- Genera un registro en la tabla sga_alumnos.
-- Según lo que indique el parámetro del sistema 'insc_carrera_equiv_auto', llama
-- al proceso que otorga las equivalencias automáticas para materias comunes.
-- Desbloquea el Usuario de AutoGestión que genero el alta de la persona!!!
-- La fecha de ingreso es la actual y no la que figura en "sga_carrera_aspira"
-- Para los alumnos que tienen legajo previo, no se le genera legajo, pero se 
-- le otorga calidad de alumno activo si cumplió con todos los requisitos obligatorios.
-- Valida materias comunes no esten aprobadas mas de una vez en otras carreras.
--
-- El codigo de plan puede venir en NULL o pasado como parametro.  Esto se debe a que 
-- puede generarse un legajo con un plan activo pero no vigente.
-- *****************************************************************************
-- DROP PROCEDURE sp820_crear_alumno;
CREATE PROCEDURE sp820_crear_alumno(
  	aunidad_academica LIKE sga_alumnos.unidad_academica,
  	anro_inscripcion LIKE sga_alumnos.nro_inscripcion,
  	acarrera LIKE sga_alumnos.carrera,
	pfechainscripcion LIKE sga_alumnos.fecha_ingreso,
  	alegajo LIKE sga_alumnos.legajo,
  	aPlan LIKE sga_alumnos.plan)
	RETURNING varchar(15), INT,INT,VARCHAR(255);

BEGIN

DEFINE sql_err, isam_err  	int;
DEFINE error_info         	varchar(255);
DEFINE vc_carrera_ant     	LIKE sga_alumnos.carrera;
DEFINE vc_plan_ant        	LIKE sga_alumnos.plan;
DEFINE leg                	LIKE sga_alumnos.legajo;
DEFINE l_plan             	LIKE sga_planes.plan;
DEFINE l_vig_minima       	LIKE sga_planes.vigencia_minima;
DEFINE l_fin_vig          	Date;
DEFINE l_fecha_inscrip    	Date;
DEFINE l_periodo_insc     	LIKE sga_carrera_aspira.periodo_inscripcio;
DEFINE v_retornoEquiv     	integer;
DEFINE v_equivAuto, v_pasamatcomun        	char(1);
DEFINE vcFormaGeneracion  	LIKE sga_param_sistema.valor;
DEFINE v_retorno_situasp  	LIKE sga_situacion_asp.situacion_asp;
DEFINE iStatus            	smallint;
DEFINE vcMsg              	varchar(255);
DEFINE vcMensajeNoGen	  	varchar(255);
DEFINE vc_Identificacion  	LIKE aca_usuarios_ag.identificacion;
DEFINE ls_yatieneLeg 	    	char(1);
DEFINE vcCalidad		LIKE sga_alumnos.calidad;
DEFINE vdFechaMod	LIKE sga_cambioscalidad.fecha;
DEFINE  l_estado_plan	LIKE sga_planes.estado;

-- Variables de retorno de sp. ejecutados localmente.
DEFINE ll_result, ll_result2		Integer;
DEFINE ls_mensaje_result 	varchar(255); 
DEFINE viModificacion	INTEGER;
DEFINE l_sede LIKE sga_sedes.sede;


ON EXCEPTION SET sql_err, isam_err, error_info
	  RETURN leg, sql_err, isam_err, 'Error: ' || error_info;
END EXCEPTION;

LET ls_yatieneLeg = 'N';
LET leg = NULL;
LET vcFormaGeneracion = 'A';

-- Materias Comunes. Equivalentes.
EXECUTE PROCEDURE sp_param_sistema ('insc_carrera_equiv_auto') INTO v_pasamatcomun;


-- Buscar el código de situacion de aspirante por default establecido, para resultado inscripto('I').
EXECUTE PROCEDURE sp_default_sit_res('I') into v_retorno_situasp;

-- Si ya posee legajo el alumno, cambio la variable para identifique al alumno con legajo previo.
IF (SELECT COUNT(legajo) 
	FROM 	sga_alumnos
	WHERE	unidad_academica = aunidad_academica
	AND 	carrera = acarrera
	AND	legajo = alegajo)     > 0 THEN
		
	LET ls_yatieneLeg = 'S';
END IF; 

--**********************************************************************
-- Recupera el Plan Vigente de la Carrera, y la Fecha de Fin de vigencia
-- del Plan en la carrera
--**********************************************************************
IF aPlan IS NOT NULL THEN
	LET l_plan = aPlan;
	LET l_estado_plan = NULL;

	-- Recupero la vigencia minima del Plan y verifico el estado del mismo
	SELECT 	vigencia_minima, estado  
		INTO l_vig_minima, l_estado_plan	
	FROM 	sga_planes  
	WHERE 	unidad_academica = aunidad_academica
	AND	carrera = acarrera
	AND	plan = aPlan;     

	IF l_estado_plan IS NULL OR (l_estado_plan <> 'A' and l_estado_plan <> 'V') THEN
		-- Estado del Plan: V - Activo Vigente, A - Activo no Vigente
		RETURN NULL,-1,0,'El Plan ' || l_plan || ' no es un Plan Vigente de la Carrera ' || acarrera;
	END IF;

ELSE
	-- Recupero el Plan Actual Vigente de la carrera
	SELECT 	sga_planes.plan, sga_planes.vigencia_minima  
		INTO l_plan, l_vig_minima	
	FROM 	sga_carreras,   
		sga_planes  
	WHERE 	sga_planes.unidad_academica = sga_carreras.unidad_academica
	AND	sga_planes.carrera = sga_carreras.carrera
	AND	sga_carreras.plan_vigente = sga_planes.plan 
	AND	sga_carreras.unidad_academica = aunidad_academica
	AND	sga_carreras.carrera = acarrera;     
END IF;

IF  l_plan IS NULL THEN
	RETURN NULL,-1,0,'La Carrera ' || acarrera || ' no tiene un Plan Vigente';
END IF;

IF  l_vig_minima IS NULL THEN
	RETURN NULL,-1,0,'El Plan ' || l_plan || ' de la Carrera ' || acarrera || ' no tiene definido la Vigencia Mínima';
END IF;

   
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Solo proceso la generación de legajo nuevo si no posee legajo previo.
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
IF ls_yatieneLeg = 'N' THEN

	-- Valido las materias comunes en otras carreras de la persona.
	IF Upper(v_pasamatcomun) = 'S' THEN
		EXECUTE PROCEDURE sp_verificarmatdup(aunidad_academica, anro_inscripcion, acarrera, l_plan) INTO iStatus, vcMsg;
		IF iStatus = -1 THEN
			-- La persona esta en dos o mas carreras y tiene la misma comun aprobadas en 2 o mas carreras
	  		RETURN NULL,-1,0, vcMsg;
		END IF;
	END IF;

	-- Generacion de legajo unico por persona o por carrera.
	EXECUTE PROCEDURE sp_param_sistema('generacion_nro_legajo_alumno') INTO vcFormaGeneracion;
   	IF vcFormaGeneracion = 'M' THEN
		IF alegajo IS NULL or alegajo = '' THEN
		  	RETURN NULL,-1,0,'Debe asignar el Nro de Legajo para la Inscripción: ' || anro_inscripcion ;
		END IF;
		LET leg = alegajo;
   	ELSE
		-- Genero el Legajo del Alumno
		EXECUTE PROCEDURE sp_crear_legajo(aunidad_academica, anro_inscripcion, acarrera) INTO leg;
		IF leg IS NULL THEN
	  		RETURN NULL,-1,0,'Error al Generar el Legajo para la Inscripción: ' || anro_inscripcion || ' en la Carrera  ' || acarrera;
		END IF;
	END IF;
ELSE
   -- Tiene el Legajo Generado	
   LET leg = alegajo;
END IF;



--***************************************************************
-- Recupera la Fecha de Inscripcion en la Carrera
-- Saco la maxima fecha, por si esta inscripto mas de una vez en la
-- carrera (en distintos períodos de inscripcion. No debería pasar)
--***************************************************************
LET l_fecha_inscrip = NULL;
LET l_periodo_insc = NULL;

SELECT	sga_carrera_aspira.fecha_inscripcion, sga_carrera_aspira.periodo_inscripcio, sga_carrera_aspira.sede
	INTO    l_fecha_inscrip, l_periodo_insc, l_sede
FROM   	sga_carrera_aspira,
	sga_situacion_asp
WHERE 	sga_carrera_aspira.unidad_academica = aunidad_academica
AND  	sga_carrera_aspira.carrera = acarrera 
AND	sga_carrera_aspira.nro_inscripcion = anro_inscripcion 
AND	sga_carrera_aspira.situacion_asp = sga_situacion_asp.situacion_asp 
AND	sga_situacion_asp.resultado_asp = 'A';
  
IF  l_fecha_inscrip IS NULL THEN
	RETURN NULL,-1,0,'La Persona  ' || anro_inscripcion || ' en la Carrera ' || acarrera || ' no tiene definida la Fecha de Inscripción.';
END IF;

-- Fecha de fin de vigencia en el Plan. Al año le sumo la cantidad de años de Vigencia
-- del Plan en la Carrera.
LET l_fin_vig = MDY( MONTH(l_fecha_inscrip), DAY(l_fecha_inscrip), YEAR(l_fecha_inscrip) + l_vig_minima);


-- **********************************************************************************
-- Si tiene legajo previo generado.
-- **********************************************************************************
IF ls_yatieneLeg = 'S' THEN
      	
      	-- Si tiene la calidad pasivo.
	LET vcCalidad = NULL;
      	SELECT calidad
		INTO vcCalidad
      		FROM 	sga_alumnos
      		WHERE 	unidad_academica = aunidad_academica
      		AND	carrera = acarrera
      		AND	legajo = alegajo;

	-- Si abandono o estaba Pasivo
	IF vcCalidad  = 'P' or vcCalidad = 'N' THEN
      	
      		-- Ejecutar el Sp. para saber si cumplió con todos los requisitos obligatorios para la generación de legajo.
      		EXECUTE PROCEDURE sp_cumplio_req_leg(aunidad_academica,anro_inscripcion,acarrera,l_periodo_insc) INTO ll_result,ll_result2,ls_mensaje_result;
      		
      		-- Si cumplió con los requisitos obligatorios para la generación de legajos.
      		IF ll_result = 1 THEN
				
			-- -- Insertar el motivo de cambio de calidad del alumno a activo.
			-- INSERT INTO sga_cambioscalidad
			-- (unidad_academica,carrera,legajo,fecha,calidad,motivo,responsable)
			-- VALUES(aunidad_academica,acarrera,alegajo,CURRENT,'A',6,USER);
			
			-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
			-- Cambiar la calidad del alumno a activo.
			-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
			UPDATE	sga_alumnos
				SET 	calidad = 'A',
					fecha_ingreso = pfechainscripcion
			WHERE	unidad_academica = aunidad_academica
			AND	carrera = acarrera
			AND	legajo = alegajo;

			-- Busco el ultimo registro insertado, ya que el UPDATE de calidad del Alumno
			-- inserta un registro en la tabla sga_cambios_calidad

			LET viModificacion = NULL;					

			FOREACH SELECT modificacion, fecha INTO viModificacion, vdFechaMod
					FROM sga_cambioscalidad
					WHERE	unidad_academica = aunidad_academica
					AND	carrera = acarrera
					AND	legajo = alegajo
					ORDER BY fecha  DESC
					EXIT FOREACH;
			END FOREACH;

			-- El registro ya fue insertado, asi que actualizo el motivo y las observaciones
			UPDATE 	sga_cambioscalidad
				SET motivo = 6,   --  Activacion
			        observaciones = 'Inscripción a Carrera'
				WHERE	unidad_academica = aunidad_academica
				AND carrera = acarrera
				AND legajo = alegajo
				AND modificacion = viModificacion;

			-- ++++++++++++++++++++++++++++++++++++++++++++++++++++

			
			-- Si presentó todos los requisitos obligatorios.
			IF (SELECT 	Count(rc.requisito)
				FROM	sga_req_cumplidos rc
				WHERE	rc.unidad_academica = aunidad_academica
				AND	rc.nro_inscripcion = anro_inscripcion
				AND	rc.carrera = acarrera 
				AND	rc.fecha_presentacion is null) = 0 THEN
				
				-- Se pasa la situación de aspirante a 'IL'(Ingresante con Legajo).		
				UPDATE 	sga_carrera_aspira
				SET 	situacion_asp = v_retorno_situasp
				WHERE 	unidad_academica = aunidad_academica
				AND	carrera = aCarrera
				AND	nro_inscripcion = anro_inscripcion
				AND	periodo_inscripcio = l_periodo_insc; 
				
			-- Si no presentó todos los requisitos obligatorios.
			ELSE
			
				-- Se pasa la situación de aspirante a 'IC'(Ingresante Condicional).		
				UPDATE 	sga_carrera_aspira
				SET 	situacion_asp = 'IC'
				WHERE 	unidad_academica = aunidad_academica
				AND	carrera = aCarrera
				AND	nro_inscripcion = anro_inscripcion
				AND	periodo_inscripcio = l_periodo_insc; 					
				
			END IF;
		
		ELSE		
			-- Si no cumplió con la presentación de los requisitos obligatorios.
			IF ll_result = -1 THEN
				-- Cargar el mensaje del porque no se genera el legajo al alumno pasivo.
				LET vcMensajeNoGen = 'No puede ser alumno Activo por no presentar todos los requisitos obligatorios de legajo';
			ELSE
				-- Cargar el mensaje del porque no se genera el legajo al alumno pasivo.
				LET vcMensajeNoGen = 'No puede ser alumno Activo por no presentar en fecha los requisitos obligatorios de legajo.';
			END IF;
		
      		END IF;
      	
  	END IF;
      	

-- **********************************************************************************
-- Si no tiene legajo previo generado
-- **********************************************************************************
ELSE
	
      	-- Ejecutar el Sp. para saber si cumplió con todos los requisitos obligatorios para la generación de legajo.
      	EXECUTE PROCEDURE sp_cumplio_req_leg(aunidad_academica,anro_inscripcion,acarrera,l_periodo_insc) INTO ll_result,ll_result2,ls_mensaje_result;

	-- Controlar que haya cumplido con todos los requisitos obligatorios para la generación de legajo y 
	-- que hayan sido presentados en fecha.
	IF ll_result = 1 THEN
	
		--*************************************************************************
		-- Generar un registro en la tabla sga_alumnos.
		--*************************************************************************

		-- Crea un Registro en la Tabla de Alumnos.
  		INSERT INTO sga_alumnos ( 
	         	unidad_academica,   
         		carrera,   
         		legajo,   
         		plan,   
         		nro_inscripcion,   
	        	fecha_ingreso,   
         		fin_vigencia_plan,   
         		regular,   
         		cnt_readmisiones,   
         		calidad,
		sede ) 
    		VALUES(aunidad_academica,
			acarrera,
			leg,
			l_plan,
			anro_inscripcion,
			pfechainscripcion,
			l_fin_vig,
			'S',
			0,
			'A',
			l_sede);	
				
		-- Ahora el alumno posee legajo generado y con registro en sga_alumnos.
		LET 	ls_yatieneLeg = 'S';			
			
      		-- Ejecutar el Sp. para saber si cumplió con todos los requisitos obligatorios.
      		EXECUTE PROCEDURE sp_cumplio_req(aunidad_academica,anro_inscripcion,acarrera,l_periodo_insc) INTO ll_result,ll_result2,ls_mensaje_result;			
			
		IF ll_result = 1 THEN
			
			-- Se pasa la situación de aspirante a 'IL'(Ingresante con Legajo).		
			UPDATE 	sga_carrera_aspira
			SET 	situacion_asp = v_retorno_situasp
			WHERE 	unidad_academica = aunidad_academica
			AND	carrera = aCarrera
			AND	nro_inscripcion = anro_inscripcion
			AND	periodo_inscripcio = l_periodo_insc; 	
			
		ELSE
			
			-- Se pasa la situación de aspirante a 'IC'(Ingresante Condicional).		
			UPDATE 	sga_carrera_aspira
			SET 	situacion_asp = 'IC'
			WHERE 	unidad_academica = aunidad_academica
			AND	carrera = aCarrera
			AND	nro_inscripcion = anro_inscripcion
			AND	periodo_inscripcio = l_periodo_insc; 	
			
		END IF;
		
	ELSE
		-- Si no cumplió con la presentación de los requisitos obligatorios.
		IF ll_result = -1 THEN
			-- Cargar el mensaje del porque no se genera el legajo al alumno pasivo.
			LET vcMensajeNoGen = 'No presentó todos los requisitos obligatorios para la generación de legajo';
		ELSE
			-- Cargar el mensaje del porque no se genera el legajo al alumno pasivo.
			LET vcMensajeNoGen = 'No presentó en fecha los requisitos obligatorios para la generación de legajo.';
		END IF;
	
	END IF;

END IF;

-- Si ya se le generó registro en sga_alumnos (o sea tiene legajo generado).
IF ls_yatieneLeg = 'S' THEN

	-- **************************************************************************
	-- Llama al proceso que genera las equivalecias automáticas para
	-- materias que tenía aprobadas en otras carreras
	-- **************************************************************************
	IF upper(v_pasamatcomun) = 'S' THEN
      		EXECUTE PROCEDURE sp_pasa_mat_comun ( aunidad_academica, acarrera, leg, l_fecha_inscrip );
	END IF;
   
	-- **************************************************************************
	-- Llama al proceso que pasa las equivalecias de la matriz.
	-- **************************************************************************
	EXECUTE PROCEDURE sp_param_sistema('equiv_automaticas') INTO v_equivAuto;
	
	IF UPPER(v_equivAuto) = 'S' THEN

		FOREACH SELECT sga_alumnos.carrera, sga_alumnos.plan
	                INTO vc_carrera_ant, vc_plan_ant
        	        FROM sga_alumnos
               		WHERE sga_alumnos.unidad_academica = aunidad_academica
                 	AND sga_alumnos.nro_inscripcion  = anro_inscripcion
                 	AND sga_alumnos.carrera  <> acarrera

		EXECUTE PROCEDURE sp_evalua_equiv( aunidad_academica, acarrera, leg, vc_carrera_ant, vc_plan_ant) into v_retornoEquiv;
	
        	IF v_retornoEquiv < 0 THEN
			RETURN NULL, -1, 0, 'Error generando equivalencias automáticas de otras carreras.';
        	END IF;
        
		END FOREACH;
	END IF;
   
	-- **************************************************************************
	-- Llama al proceso para desbloquear el usuario de autogestion de la persona 
	-- **************************************************************************
	LET vc_Identificacion = NULL;
	SELECT 	aca_usuarios_ag.identificacion	INTO 	vc_Identificacion
		FROM 	aca_usuarios_ag
		WHERE 	aca_usuarios_ag.unidad_academica = aunidad_academica
		AND 	aca_usuarios_ag.nro_inscripcion  = anro_inscripcion
		AND 	aca_usuarios_ag.tipo_usuario  = 'ALU';

	-- Puede que no exista el registro de la persona para Autogestion.
	IF DBINFO("sqlca.sqlerrd2") <= 0 THEN
		-- No existe el usuario de Autogestion.
	ELSE
		-- Desbloqueo el usuario, si esta bloqueado.
		EXECUTE PROCEDURE sp_desbloqusuario (aunidad_academica, vc_Identificacion) INTO iStatus, vcMsg ;
		IF iStatus < 0 THEN
			RETURN NULL, -1, 0, 'Error al desbloquear el Usuario de AutoGestión de la Persona  ' || anro_inscripcion ;
		END IF;
	END IF;


	-- Proceso personalizable por la UA.
	EXECUTE PROCEDURE pu_crear_alumno ( aunidad_academica, anro_inscripcion, acarrera, leg ) INTO leg, sql_err, isam_err, vcMsg ;
	IF sql_err < 0 THEN
		RETURN NULL, -1, 0, 'Error en el Proceso Personalizable para la Persona  ' || anro_inscripcion ;
	END IF;

	-- OK. Se generó legajo.   
	RETURN leg,0,0,'Generado';

ELSE
	-- Legajo no generado.
	RETURN NULL, -1, 0, vcMensajeNoGen;
END IF;

END;
END PROCEDURE;
-- ********************** Fin del procedure sp820_crear_alumno **********************

