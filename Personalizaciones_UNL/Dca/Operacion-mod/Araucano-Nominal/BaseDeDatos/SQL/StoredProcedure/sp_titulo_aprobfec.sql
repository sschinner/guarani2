-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Stored Procedure: sp_titulo_aprobfec
-- Version: 2.9.4
-- Ultima version de modificacion: 
--
-- Evalua si el titulo esta aprobado por el Alumno a una fecha dada. Recupera el plan en que se encontraba el alumno  a esa fecha.
-- Devuelve las Orientaciones por las que el alumno aprobo el titulo.
--
-- Si no aprobo el titulo, no devuelve nada.
-- 
-- Idem procedure sp_titulo_aprobfec, con la diferencia que recibe el parametro de la fecha.
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DROP PROCEDURE sp_titulo_aprobfec;
CREATE PROCEDURE sp_titulo_aprobfec ( 
   pUA like sga_alumnos.unidad_academica, 
   pCarrera like sga_alumnos.carrera, 
   pLegajo like sga_alumnos.legajo, 
   pTitulo like sga_titulos_otorg.titulo,
   pFecha varchar(10))
	
  -- Este procedure retorna una lista con las orientaciones que tiene aprobadas el alumno.  Si la carrera no tiene orientaciones, entonces retorna '0', (la
  -- orientacion basica ).
  --
  -- Si no aprobo el titulo, no devuelve nada.

  RETURNING 	varchar(5),		-- Orientacion
  		varchar(5),		-- Plan
		varchar(5);		-- Version

  DEFINE 	vcPlan,vcVersion	varchar(5);

  DEFINE	vcOrientacion, vcOrientAlumno	varchar(5);
  DEFINE	vcMateria	varchar(5);
  DEFINE	vcCiclo		varchar(5);
  DEFINE	fPuntos,fpuntosparcial, fPuntosOrBas, fPuntostotal		float;

  DEFINE	iCantMaterias, iRtn, iTieneOrient,v_cantatreas,v_ptos_extracurr	integer ;
  DEFINE	vcOrientBasica, vcOrientAdicional	varchar(5);

  DEFINE	vEgreso	LIKE sga_titulos_plan.calculo_egreso;
  DEFINE	fCreditosEgreso, fCreditosOriBas,fCreditosOriAdic 	LIKE sga_titulos_plan.total_cred_egreso;
  DEFINE        vcMsg	varchar(255);
  DEFINE        dFecha		DATE;
  DEFINE v_suma_act	varchar(2);
  DEFINE v_nivel LIKE sga_titulos.nivel;

BEGIN

  IF pFecha IS NULL THEN
	LET dFecha = TODAY; -- Este prodria reemplazarse por un parametro.
  ELSE
	LET dFecha = to_date(pFecha, '%d/%m/%Y'); -- viene en formato dd/mm/yyyy
  END IF;
  
  LET iTieneOrient = 0;
  LET vcOrientBasica = 0;
  LET fPuntos        = 0;
  LET fpuntosparcial = 0;
  LET fPuntosOrBas   = 0;
  LET fCreditosEgreso = 0;

  -- Obtengo el modo de egreso, plan y version del alumno
  EXECUTE PROCEDURE sp_plan_de_alumno( pUA, pCarrera, pLegajo, dFecha) INTO vcPlan, vcVersion;

  SELECT sga_titulos.nivel
  INTO v_nivel
  FROM sga_titulos
  WHERE sga_titulos.unidad_academica = pua AND
	 sga_titulos.titulo = ptitulo;

  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- Verifico si hay actividades obligatorias y si es así chequeo si el Alumno cumplio 
  -- con las Actividades curriculares segun el Título del Plan.
  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF v_nivel = 'GRADO' THEN
  LET v_cantatreas = 0;

  SELECT  count(*)
  INTO v_cantatreas
  FROM sga_atri_area_plan
  WHERE  sga_atri_area_plan.unidad_academica = pUA AND
	  sga_atri_area_plan.carrera = pCarrera AND
	  sga_atri_area_plan.plan = vcPlan AND
	  sga_atri_area_plan.version = vcVersion AND
	  sga_atri_area_plan.obligatoria = 'S';

  IF v_cantatreas > 0 THEN
	  EXECUTE PROCEDURE sp_tit_actextracur( pUA, pCarrera, pLegajo, pTitulo, vcPlan, vcVersion) INTO iRtn, vcMsg;
	  IF iRtn = -1 Then
		raise exception -746,0,vcMsg;
		-- Return ; 
	  End If;	
  END IF;

END IF;

 -------------------------------------------------------------------------------------------------
 -- Creo la tabla temporal de materias aprobadas. Este sera usado en sp_ciclo_aprobado
 -------------------------------------------------------------------------------------------------
 BEGIN
   ON EXCEPTION IN (-206)
   END EXCEPTION WITH RESUME;
   DROP TABLE tmp_ha_titulos;
 END;

 CREATE TEMP TABLE tmp_ha_titulos (materia varchar(5)) WITH NO LOG;

 INSERT INTO tmp_ha_titulos (materia) 
   SELECT materia
	FROM vw_hist_academica
	WHERE  unidad_academica = pUA
	AND    carrera = pCarrera  
	AND    legajo  = pLegajo
	AND    resultado = 'A'
	AND    fecha <= dFecha;
 -------------------------------------------------------------------------------------------------

  -- Recupero la forma de Egreso del Titulo, Si suma actividades extracurriculares o no  y los creditos necesarios para aprobar.
  SELECT calculo_egreso, total_cred_egreso, suma_cred_act_ext  
	INTO vEgreso, fCreditosEgreso, v_suma_act
  FROM sga_titulos_plan 
  WHERE unidad_academica = pUA
	AND carrera = pCarrera
	AND plan = vcPlan
	AND titulo = pTitulo;


  -- Egreso por Completitud de materias del Titulo.
  IF vEgreso  = 'AM' THEN
	  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  -- Verifico que tenga las orientaciones aprobadas, primero la orientacion básica y luego las otras.
	  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------  
	  EXECUTE PROCEDURE sp_orient_aprobada ( pUA, pCarrera, pLegajo, pTitulo, vcPlan, vcVersion , vcOrientBasica, vEgreso,  'P') 
	    INTO vcOrientBasica, vcCiclo, vcMateria,  fPuntos ;

	  LET iCantMaterias = DBINFO("sqlca.sqlerrd2") ;

	  IF iCantMaterias > 0 THEN
	    DROP TABLE tmp_ha_titulos;
	    RETURN ;
	  END IF;

	  LET vcOrientBasica = '0';

	  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	  -- Verifico si Tiene Orientaciones el Plan con ese Titulo y si 
	  -- el alumnno debia seleccionar una Orientacion
	  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	  LET vcOrientAlumno = NULL;
	  IF (SELECT COUNT(*) FROM sga_titulos_plan
		  WHERE unidad_academica = pUA  AND
			carrera = pCarrera  AND
			plan = vcPlan   AND
			titulo = pTitulo  AND
			tiene_orient = 'S' AND
			elige_orient = 'S' ) > 0 THEN

		-- Verifico que el Alumno tenga una orientacion seleccionada:
		IF (SELECT COUNT(*) FROM sga_orient_alumno
			  WHERE unidad_academica = pUA  AND
				carrera = pCarrera  AND
				legajo = pLegajo  AND
				plan = vcPlan   AND
				titulo = pTitulo  ) <= 0 THEN

			DROP TABLE tmp_ha_titulos;
			-- Error. El alumno debe tener una Orientacion seleccionada...
			-- No puede egresar.
			raise exception -746,0,'El Alumno (' || pLegajo || ') debe seleccionar una Orientación';
		ELSE
			-- Selecciono Orientacion por la cual debo ver si egreso.
			SELECT orientacion
			INTO vcOrientAlumno
			FROM sga_orient_alumno
			WHERE unidad_academica = pUA  AND
				carrera = pCarrera  AND
				legajo = pLegajo  AND
				plan = vcPlan   AND
				titulo = pTitulo ;
		
		END IF;
	
	  END IF;
	  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
	  -- tiene materias pendientes de la orientacion básica, nunca puede ser un egresado.
	  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  FOREACH SELECT orientacion
		    INTO vcOrientAdicional
		    FROM sga_orientaciones 
	   	 WHERE unidad_academica = pUA  AND
			carrera = pCarrera  AND
			plan = vcPlan   AND
			titulo = pTitulo  AND
			orientacion <> vcOrientBasica 

		   -- Obtengo las materias pendientes para la orientacion, si no tiene ninguna entonces es un egresado.
		   LET iTieneOrient = 1;

		   IF vcOrientAlumno IS NULL or vcOrientAlumno = vcOrientAdicional THEN

			EXECUTE PROCEDURE sp_orient_aprobada ( pUA, pCarrera, pLegajo, pTitulo, vcPlan, vcVersion , vcOrientAdicional, vEgreso , 'P' ) 
			INTO vcOrientacion, vcCiclo, vcMateria, fPuntos;

			LET iCantMaterias = DBINFO("sqlca.sqlerrd2");

			IF iCantMaterias <= 0 THEN
				-- No debe nada de la orientacion, asi que retorno los valores
				RETURN vcOrientAdicional, vcPlan, vcVersion WITH RESUME;
			END IF;

		   END IF; -- Orientacion del Alumno o cualquier orientacion del Plan

	  END FOREACH; -- Orientaciones
	

	  DROP TABLE tmp_ha_titulos;

	  IF iTieneOrient = 0 THEN
	    -- No tiene orientaciones y tampoco materias pendientes para la basica
	    RETURN vcOrientBasica, vcPlan, vcVersion; -- Retorna la orientacion básica
	  END IF;

	  -- Sale sin orientacion aprobada.
	  RETURN ;
  END IF;

  IF vEgreso = 'CT' THEN
	
	IF v_nivel = 'GRADO' THEN
		  ---------------------------------------------------------------------------------------------------
		  -- Si es necesario .... Recupero los puntos de las actividades 
		  ---------------------------------------------------------------------------------------------------
		  IF v_suma_act <> 'N' THEN
			EXECUTE PROCEDURE  sp_suma_actextra(pUA, pCarrera, pLegajo, pTitulo, vcPlan, vcVersion, v_suma_act) INTO v_ptos_extracurr;
		 ELSE
			LET v_ptos_extracurr = 0;	 
		 END IF;	
	ELSE
		LET v_ptos_extracurr = 0;
	END IF;

	  -------------------------------------------------------------------
	  -- Recupero los puntos dela Orientacion basica
	  -------------------------------------------------------------------
	  EXECUTE PROCEDURE sp_orient_aprobada ( pUA, pCarrera, pLegajo, pTitulo, vcPlan, vcVersion , vcOrientBasica, vEgreso,  'T') 
		INTO vcOrientBasica, vcCiclo, vcMateria,  fPuntosOrBas ;

	  LET vcOrientBasica = '0';

	  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	  -- Verifico si Tiene Orientaciones el Plan con ese Titulo y si 
	  -- el alumnno debia seleccionar una Orientacion
	  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	  LET vcOrientAlumno = NULL;
	  IF (SELECT COUNT(*) FROM sga_titulos_plan
		  WHERE unidad_academica = pUA  AND
			carrera = pCarrera  AND
			plan = vcPlan   AND
			titulo = pTitulo  AND
			tiene_orient = 'S' AND
			elige_orient = 'S' ) > 0 THEN

		-- Verifico que el Alumno tenga una orientacion seleccionada:
		IF (SELECT COUNT(*) FROM sga_orient_alumno
			  WHERE unidad_academica = pUA  AND
				carrera = pCarrera  AND
				legajo = pLegajo  AND
				plan = vcPlan   AND
				titulo = pTitulo  ) <= 0 THEN
			DROP TABLE tmp_ha_titulos;
			-- Error. El alumno debe tener una Orientacion seleccionada...
			-- No puede egresar.
			raise exception -746,0,'El Alumno (' || pLegajo || ') debe seleccionar una Orientación';
		ELSE
			-- Selecciono Orientacion por la cual debo ver si egreso.
			SELECT orientacion
			INTO vcOrientAlumno
			FROM sga_orient_alumno
			WHERE unidad_academica = pUA  AND
				carrera = pCarrera  AND
				legajo = pLegajo  AND
				plan = vcPlan   AND
				titulo = pTitulo ;
		
		END IF;
	  END IF;

	  LET fpuntos = fpuntosparcial;

	  FOREACH SELECT orientacion
		    INTO vcOrientAdicional
		    FROM sga_orientaciones 
	   	 WHERE  unidad_academica = pUA  AND
			carrera = pCarrera  AND
			plan = vcPlan   AND
			titulo = pTitulo  AND
			orientacion <> vcOrientBasica 

		   LET iTieneOrient = 1;
		   LET fpuntosparcial = 0;
	
		   IF vcOrientAlumno IS NULL or vcOrientAlumno = vcOrientAdicional THEN

			-- Obtengo los puntos del a orientacion
			EXECUTE PROCEDURE sp_orient_aprobada ( pUA, pCarrera, pLegajo, pTitulo, vcPlan, vcVersion , vcOrientAdicional , vEgreso, 'T' ) 
			INTO vcOrientacion, vcCiclo, vcMateria, fpuntosparcial;

			LET fpuntosparcial = fpuntosparcial + fPuntosOrBas + v_ptos_extracurr;
			
			-- Orientacion Basica + Orientacion x
			IF fPuntosparcial >= fCreditosEgreso  THEN
			    -- Egresa por creditos del titulo por esta orientacion.
			    RETURN vcOrientAdicional, vcPlan, vcVersion WITH RESUME; -- Retorna la orientacion
			END IF
		   END IF; -- Orientacion del Alumno o cualquier orientacion del Plan
	  END FOREACH; -- Orientaciones

	DROP TABLE tmp_ha_titulos;

	-- Si el titulo no tiene orientaciones, verifico que pasa con la basica.
	IF iTieneOrient = 0 THEN
		LET fPuntosTotal = fPuntosOrBas + v_ptos_extracurr;

		IF fPuntosTotal >= fCreditosEgreso  THEN
		    -- Egresa por la Orientacion Basica.	
		    RETURN vcOrientBasica, vcPlan, vcVersion; -- Retorna la orientacion básica
		END IF
	END IF;

	Return; -- sale del sp

  END IF; -- Creditos del Titulo.


  IF vEgreso = 'CO' THEN
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Modo de Egreso por Creditos de la Orientación
	-- Se considera que el alumno aprobo por esta modalidad si:
	-- Hoy se calcula de esta forma:	
	--      Creditos definidos en la Orientación  <=    Creditos obtenidos de la Orientacion Básica 
	--				          + Creditos obtenidos de la Orientación evaluada 
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	-----------------------------------------------------------------------------
	-- Obtengo los creditos de la orientacion basica
	-----------------------------------------------------------------------------
	LET vcOrientBasica = '0';

	SELECT ori.total_cred_egreso
	INTO fCreditosOriBas 
	FROM sga_orientaciones ori
	WHERE ori.unidad_academica = pUA
	            AND ori.carrera = pCarrera
	            AND ori.plan = vcplan
	            AND ori.titulo = pTitulo 
	            AND ori.orientacion = vcOrientBasica;
	IF fCreditosOriBas IS NULL THEN
		LET fCreditosOriBas = 0;
	END IF;

	  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  -- Verifico que tenga las orientaciones aprobadas, primero la orientacion básica y luego las otras.
	  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------  
	  EXECUTE PROCEDURE sp_orient_aprobada ( pUA, pCarrera, pLegajo, pTitulo, vcPlan, vcVersion , vcOrientBasica, vEgreso,  'T') 
	  INTO vcOrientBasica, vcCiclo, vcMateria,  fPuntosOrBas ;

	 -- No cumplio con los creditos de la orientacion basica.
	 IF fpuntosOrBas < fCreditosOriBas THEN
		DROP TABLE tmp_ha_titulos;
		RETURN ;
	 END IF;


		  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		  -- Verifico si Tiene Orientaciones el Plan con ese Titulo y si 
		  -- el alumnno debia seleccionar una Orientacion
		  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		  LET vcOrientAlumno = NULL;
		  IF (SELECT COUNT(*) FROM sga_titulos_plan
			  WHERE unidad_academica = pUA  AND
				carrera = pCarrera  AND
				plan = vcPlan   AND
				titulo = pTitulo  AND
				tiene_orient = 'S' AND
				elige_orient = 'S' ) > 0 THEN

			-- Verifico que el Alumno tenga una orientacion seleccionada:
			IF (SELECT COUNT(*) FROM sga_orient_alumno
				  WHERE unidad_academica = pUA  AND
					carrera = pCarrera  AND
					legajo = pLegajo  AND
					plan = vcPlan   AND
					titulo = pTitulo  ) <= 0 THEN
				DROP TABLE tmp_ha_titulos;
				-- Error. El alumno debe tener una Orientacion seleccionada...
				-- No puede egresar.
				raise exception -746,0,'El Alumno (' || pLegajo || ') debe seleccionar una Orientación';
			ELSE
				-- Selecciono Orientacion por la cual debo ver si egreso.
				SELECT orientacion
				INTO vcOrientAlumno
				FROM sga_orient_alumno
				WHERE unidad_academica = pUA  AND
					carrera = pCarrera  AND
					legajo = pLegajo  AND
					plan = vcPlan   AND
					titulo = pTitulo ;
		
			END IF;
		END IF;

		  LET fpuntos = fpuntosparcial;

		  FOREACH SELECT orientacion, total_cred_egreso
			    INTO vcOrientAdicional, fCreditosOriAdic
			    FROM sga_orientaciones 
		   	 WHERE unidad_academica = pUA  AND
				carrera = pCarrera  AND
				plan = vcPlan   AND
				titulo = pTitulo  AND
				orientacion <> vcOrientBasica 

			   LET iTieneOrient = 1;
			   LET fpuntosparcial = 0;
	
			   IF vcOrientAlumno IS NULL or vcOrientAlumno = vcOrientAdicional THEN

				-- Obtengo los puntos del a orientacion
				EXECUTE PROCEDURE sp_orient_aprobada ( pUA, pCarrera, pLegajo, pTitulo, vcPlan, vcVersion , vcOrientAdicional , vEgreso, 'T' ) 
				INTO vcOrientacion, vcCiclo, vcMateria, fpuntosparcial;

				-- Egresa por la Orientacion y continua buscando en las otras orientaciones.
				-- IF fPuntosparcial >= fCreditosOriAdic THEN

				IF (fPuntosparcial + fpuntosOrBas) >= fCreditosOriAdic THEN
				    RETURN vcOrientAdicional, vcPlan, vcVersion WITH RESUME; -- Retorna la orientacion
				END IF
			   END IF; -- Orientacion del Alumno o cualquier orientacion del Plan
		  END FOREACH; -- Orientaciones

	-- No tiene Orientaciones el Titulo.
	IF iTieneOrient = 0 THEN
	    DROP TABLE tmp_ha_titulos;
	    RETURN vcOrientBasica, vcPlan, vcVersion; -- Retorna la orientacion básica
	END IF;

  END IF; -- Creditos por Orientacion

  IF vEgreso = 'CC' THEN
	
	  ---------------------------------------------------------------------------------------
	  -- Verifico que tenga la orientaciones basica aprobada segun los creditos de sus ciclos
	  ---------------------------------------------------------------------------------------
	  EXECUTE PROCEDURE sp_orient_aprobada ( pUA, pCarrera, pLegajo, pTitulo, vcPlan, vcVersion , vcOrientBasica, vEgreso,  'T') 
	  INTO vcOrientBasica, vcCiclo, vcMateria,  fPuntosOrBas ;

	  -- Si retorna un ciclo, es porque no cumplio con los creditos de ese ciclo. No Egresa hay que estudiar mas....	
	  LET iCantMaterias = DBINFO("sqlca.sqlerrd2") ;
	  IF iCantMaterias > 0 THEN
		DROP TABLE tmp_ha_titulos;
		RETURN ;
	  END IF;

	  LET vcOrientBasica = '0';

	  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	  -- Verifico si Tiene Orientaciones el Plan con ese Titulo y si 
	  -- el alumnno debia seleccionar una Orientacion
	  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	  LET vcOrientAlumno = NULL;
	  IF (SELECT COUNT(*) FROM sga_titulos_plan
		  WHERE unidad_academica = pUA  AND
			carrera = pCarrera  AND
			plan = vcPlan   AND
			titulo = pTitulo  AND
			tiene_orient = 'S' AND
			elige_orient = 'S' ) > 0 THEN

		-- Verifico que el Alumno tenga una orientacion seleccionada:
		IF (SELECT COUNT(*) FROM sga_orient_alumno
			  WHERE unidad_academica = pUA  AND
				carrera = pCarrera  AND
				legajo = pLegajo  AND
				plan = vcPlan   AND
				titulo = pTitulo  ) <= 0 THEN

			DROP TABLE tmp_ha_titulos;
			-- Error. El alumno debe tener una Orientacion seleccionada...
			-- No puede egresar.
			raise exception -746,0,'El Alumno (' || pLegajo || ') debe seleccionar una Orientación';
		ELSE
			-- Selecciono Orientacion por la cual debo ver si egreso.
			SELECT orientacion
			INTO vcOrientAlumno
			FROM sga_orient_alumno
			WHERE unidad_academica = pUA  AND
				carrera = pCarrera  AND
				legajo = pLegajo  AND
				plan = vcPlan   AND
				titulo = pTitulo ;
	
		END IF;
	END IF;

	  -- Recorre las demas orientaciones.
	  FOREACH SELECT orientacion
		    INTO vcOrientAdicional
		    FROM sga_orientaciones 
   		 WHERE unidad_academica = pUA  AND
		       carrera = pCarrera  AND
			plan = vcPlan   AND
			titulo = pTitulo  AND
			orientacion <> vcOrientBasica 

		   LET iTieneOrient = 1;

		   IF vcOrientAlumno IS NULL OR vcOrientAlumno = vcOrientAdicional THEN
			-- Obtengo los puntos del a orientacion
			EXECUTE PROCEDURE sp_orient_aprobada ( pUA, pCarrera, pLegajo, pTitulo, vcPlan, vcVersion , vcOrientAdicional , vEgreso, 'T' ) 
			INTO vcOrientacion, vcCiclo, vcMateria, fpuntosparcial;

			LET iCantMaterias = DBINFO("sqlca.sqlerrd2") ;

			-- Como no devuelve nada, esta todo bien, aprueba por esta orientacion, sigue buscando en las demas.				
			IF iCantMaterias <= 0 THEN
				RETURN vcOrientAdicional, vcPlan, vcVersion WITH RESUME; 
		  	END IF;

		  END IF; -- Orientacion del Alumno o cualquier orientacion del Plan

	  END FOREACH; -- Orientaciones

	  DROP TABLE tmp_ha_titulos;

	  IF iTieneOrient = 0 THEN
	  	-- No tiene orientaciones y tampoco Ciclos pendientes para la orientacion basica
		RETURN vcOrientBasica, vcPlan, vcVersion; -- Retorna la orientacion básica
	  END IF;
  END IF;

  -- Borro la tabla temporal de HA
 BEGIN
   ON EXCEPTION IN (-206)
   END EXCEPTION WITH RESUME;
   DROP TABLE tmp_ha_titulos;
 END;

END;


END PROCEDURE;
-- +++++++++++++++++++++++++++ Fin procedure sp_titulo_aprobfec +++++++++++++++++++++++++++++++++++++++++++

