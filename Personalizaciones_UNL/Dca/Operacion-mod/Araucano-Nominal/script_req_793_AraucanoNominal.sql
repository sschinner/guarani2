-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Ventana w_int_arau_nominal_alumnos
-- Version 2.9.2
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
INSERT INTO acc_ventanas (ventana) values ('w_int_arau_nominal_alumnos');
-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Operacion: pes00005
-- Version: 2.9.2
-- *******************************************************************************

Execute procedure dba.sui_operaciones( 'pes00005', 'Información Nominal de alumnos SIU-ARAUCANO', 'Alumnos Nominal Araucano 2016', null );
INSERT INTO dba.acc_parametros ( operacion, orden, ventana, parametros, cierra_anterior ) VALUES ( 'pes00005', 1, 'w_int_arau_nominal_alumnos', 'd_int_arau_nominal_archivo0, d_int_arau_nominal_archivo1, d_int_arau_nominal_archivo2', 'N' );

INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( 'pes00005', 'C' );
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Operacion: pes00005
-- Módulo: 00000070 - Interfaces
-- Version: 2.9.2
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
INSERT INTO dba.acc_operacion_mod ( modulo, operacion, submodulo, orden ) VALUES ( '00000070', 'pes00005', 'Guar_Ara', 87);
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SIU-GUARANI 2 - Sistema de Gestión Académica
-- Versión 2.9.3
-- Araucano Nominal - Archivo 0 - Alumnos a informar
-- Tabla: int_araunom_alu
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- DROP TABLE int_araunom_alu;
CREATE TABLE int_araunom_alu
(
	id_alumno SERIAL NOT NULL,
	anio_academico integer NOT NULL,
	tipo_documento smallint NOT NULL,
	nro_documento varchar(15) NOT NULL,
	cuil_cuit varchar(15),
	genero smallint NOT NULL,
	fecha_nacimiento varchar(8),
	horas_trabajo varchar(4),
	nivel_inst_padre integer,
	nivel_inst_madre integer,
	nacimiento_pais integer,
	nacimiento_loc integer
);

-- ALTER TABLE int_araunom_alu DROP CONSTRAINT pk_int_araunom_alu;
ALTER TABLE int_araunom_alu ADD CONSTRAINT PRIMARY KEY (id_alumno) CONSTRAINT pk_int_araunom_alu;

-- ++++++++++++++++++++++++++ Fin tabla int_araunom_alu +++++++++++++++++++++++++++++-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SIU-GUARANI 2 - Sistema de Gestión Académica
-- Versión 2.9.3
-- Araucano Nominal - Archivo temporal de alumnos egresados o posibles egresados
-- Tabla: int_araunom_egres
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- DROP TABLE int_araunom_egres;
CREATE TABLE int_araunom_egres
(
	anio_academico integer NOT NULL,
	unidad_academica varchar(5) NOT NULL,
	carrera varchar(5) NOT NULL,
	legajo varchar(15) NOT NULL,
	titulo varchar(5) NOT NULL,
	titulo_araucano integer NOT NULL,
	fecha_egreso date,
	solicito_titulo char(1) DEFAULT 'N' NOT NULL
);

-- ALTER TABLE int_araunom_egres DROP CONSTRAINT pk_int_araunom_egres;
ALTER TABLE int_araunom_egres ADD CONSTRAINT PRIMARY KEY (anio_academico,unidad_academica, carrera, legajo, titulo) CONSTRAINT pk_int_araunom_egres;

-- ++++++++++++++++++++++++++ Fin tabla int_araunom_egres +++++++++++++++++++++++++++++-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SIU-GUARANI 2 - Sistema de Gestión Académica
-- Versión 2.9.3
-- Araucano Nominal - Archivo 1 - Oferta académica
-- Tabla: int_araunom_oferta
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- DROP TABLE int_araunom_oferta;
CREATE TABLE int_araunom_oferta
(
	id_oferta SERIAL NOT NULL,
	anio_academico integer NOT NULL,
	tipo_documento smallint NOT NULL,
	nro_documento varchar(15) NOT NULL,
	cuil_cuit varchar(15),
	instituc_araucano integer NOT NULL,
	titulo_araucano integer NOT NULL,
	anio_ingreso integer NOT NULL,
	forma_ingreso smallint NOT NULL,
	fecha_egreso varchar(8),
	procedencia smallint,
	unidad_academica varchar(5) NOT NULL,
	carrera varchar(5) NOT NULL,
	legajo varchar(15) NOT NULL,
	plan varchar(5) NOT NULL
);

-- ALTER TABLE int_araunom_oferta DROP CONSTRAINT pk_int_araunom_ofe;
ALTER TABLE int_araunom_oferta ADD CONSTRAINT PRIMARY KEY (id_oferta) CONSTRAINT pk_int_araunom_ofe;

-- ++++++++++++++++++++++++++ Fin tabla int_araunom_oferta +++++++++++++++++++++++++++++-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SIU-GUARANI 2 - Sistema de Gestión Académica
-- Versión 2.9.3
-- Araucano Nominal - Archivo 2 - Rendimiento Académico
-- Tabla: int_araunom_rend
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- DROP TABLE int_araunom_rend;
CREATE TABLE int_araunom_rend
(
	id_rendimiento SERIAL NOT NULL,
	anio_academico integer NOT NULL,
	tipo_documento integer NOT NULL,
	nro_documento varchar(15) NOT NULL,
	cuil_cuit varchar(15),
	instituc_araucano integer,
	titulo_araucano integer NOT NULL,
	fecha varchar(8) NOT NULL,
	resultado smallint NOT NULL,
	materia varchar(5) NOT NULL,
	materia_nombre varchar(255) NOT NULL,
	carga_horaria integer,
	obligatoriedad char(1) NOT NULL,
	forma_aprobacion smallint NOT NULL,
	nro_libro varchar(30),
	nro_acta varchar(30),
	folio_fisico integer,
	expediente varchar(30),
	unidad_academica varchar(5) NOT NULL,
	carrera varchar(5) NOT NULL,
	legajo varchar(15) NOT NULL,
	plan varchar(5) NOT NULL
);

-- ALTER TABLE int_araunom_rend DROP CONSTRAINT pk_int_araunom_ren;
ALTER TABLE int_araunom_rend ADD CONSTRAINT PRIMARY KEY (id_rendimiento) CONSTRAINT  pk_int_araunom_ren;

-- ++++++++++++++++++++++++++ Fin tabla int_araunom_rend +++++++++++++++++++++++++++++

CREATE INDEX idx_intaraunomegr_1 ON int_araunom_egres (anio_academico, unidad_academica, carrera, legajo, titulo_araucano);
CREATE INDEX idx_intaraunomalu_1 ON int_araunom_alu (anio_academico);
CREATE INDEX idx_intaraunomalu_2 ON int_araunom_alu (tipo_documento, nro_documento);
CREATE INDEX idx_intaraunomofe_1 ON int_araunom_oferta (anio_academico);

CREATE INDEX idx_intaraunomofe_2 ON int_araunom_oferta (tipo_documento, nro_documento);
CREATE INDEX idx_intaraunomofe_3 ON int_araunom_oferta (anio_academico, unidad_academica, carrera, legajo, plan);
CREATE INDEX idx_intaraunomofe_4 ON int_araunom_oferta (anio_academico, unidad_academica, carrera, legajo, titulo_araucano);
CREATE INDEX idx_intaraunomofe_5 ON int_araunom_oferta (anio_academico, tipo_documento, nro_documento);
CREATE INDEX idx_intaraunomren_1 ON int_araunom_rend (anio_academico);
CREATE INDEX idx_intaraunomren_2 ON int_araunom_rend (tipo_documento, nro_documento);
CREATE INDEX idx_intaraunomren_3 ON int_araunom_rend (anio_academico, tipo_documento, nro_documento, titulo_araucano);

CREATE INDEX idx_intaraunomren_4 ON int_araunom_rend (anio_academico, unidad_academica, carrera, legajo, titulo_araucano);


-- *************************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.3
-- Procedure sp_int_araunom_egr
-- Basado en el procedure "sp_int_arau_actegr"
-- 
-- Actualiza la tabla "int_araunom_egres" que contiene a los egresados de los distintos años académicos.
-- Considera como egresado del año académico al alumno que tiene el tramite iniciado
-- ya sea para un titulo de nivel intermedio o final.
-- 
-- Recibe: Año Académico
-- Retorna: Nada. Carga la tabla int_araunomegr
-- *************************************************************************************
 DROP PROCEDURE sp_int_araunom_egr;
CREATE PROCEDURE sp_int_araunom_egr( 
   pAnioAcademico LIKE sga_anio_academico.anio_academico,
   pFechaInicioAnio  varchar(10),
   pFechaFinAnio varchar(10)
 )

-- Variables Internas.
DEFINE ls_Ua              LIKE sga_alumnos.unidad_academica;
DEFINE ls_Carrera         LIKE sga_alumnos.carrera;
DEFINE ls_Legajo          LIKE sga_alumnos.legajo;
DEFINE ls_Titulo          LIKE sga_titulos.titulo;
DEFINE ls_TituloAraucano  LIKE sga_titulos.titulo_araucano;
DEFINE ls_Plan            LIKE sga_planes.plan;
DEFINE ls_Version         LIKE sga_planes.version_actual;
DEFINE ls_Orientacion     LIKE sga_orientaciones.orientacion;
DEFINE vd_FechaIngreso    LIKE sga_alumnos.fecha_ingreso;

DEFINE vd_FechaEgreso     DATE;
DEFINE ld_FechaIni        LIKE sga_anio_academico.fecha_inicio;
DEFINE ld_FechaFin        LIKE sga_anio_academico.fecha_fin;

-- VARIABLES PARA EL MANEJO DE EXCEPCIONES.
DEFINE SQLErr               INTEGER;
DEFINE ISAMError            INTEGER;
DEFINE errorInfo            VARCHAR(76);


-- SI HAY ALGÚN ERROR.
ON EXCEPTION SET SQLErr, ISAMError, errorInfo
   RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;


BEGIN
   
   LET ld_FechaIni = to_date(pFechaInicioAnio, '%d/%m/%Y');
   LET ld_FechaFin = to_date(pFechaFinAnio, '%d/%m/%Y');
   
   -- Borro egresados de la tabla
   DELETE FROM int_araunom_egres WHERE anio_academico = pAnioAcademico;

   -- Ingreso los Egresados que iniciaron el tramite entre las fechas del año.
   INSERT INTO int_araunom_egres ( anio_academico, unidad_academica, carrera, legajo, titulo, titulo_araucano, fecha_egreso, solicito_titulo)
        SELECT pAnioAcademico,
               sga_titulos_otorg.unidad_academica,
               sga_titulos_otorg.carrera,
               sga_titulos_otorg.legajo,
               sga_titulos.titulo,
               sga_titulos.titulo_araucano,
               sga_titulos_otorg.fecha_egreso,
               'S'
          FROM sga_titulos_otorg,
               sga_titulos
         WHERE sga_titulos_otorg.fecha_egreso BETWEEN ld_FechaIni AND ld_FechaFin
           AND sga_titulos_otorg.titulo = sga_titulos.titulo
           AND sga_titulos.titulo_araucano IS NOT NULL;
           -- AND sga_titulos_otorg.carrera NOT IN (SELECT carrera_ciclocomun FROM int_arau_car_cc);
   
   -- Ingreso los Egresados que NO iniciaron el tramite entre las fechas del año.
   FOREACH
    SELECT sga_alumnos.unidad_academica,
           sga_alumnos.carrera,
           sga_alumnos.legajo,
           sga_alumnos.fecha_ingreso,
           sga_titulos_plan.titulo,
           sga_titulos.titulo_araucano
      INTO ls_Ua, ls_Carrera, ls_Legajo, vd_FechaIngreso, ls_Titulo, ls_TituloAraucano
      FROM sga_alumnos,
           sga_titulos_plan,
           sga_titulos
     WHERE sga_alumnos.calidad IN ('A','P','N')
       AND sga_alumnos.fecha_ingreso < ld_FechaFin
       AND sga_titulos_plan.unidad_academica = sga_alumnos.unidad_academica
       AND sga_titulos_plan.carrera = sga_alumnos.carrera
       AND sga_titulos_plan.plan = sga_alumnos.plan
       AND sga_titulos.unidad_academica = sga_titulos_plan.unidad_academica
       AND sga_titulos.titulo = sga_titulos_plan.titulo
       AND sga_titulos.titulo_araucano IS NOT NULL
       AND NOT EXISTS ( SELECT 1 FROM sga_titulos_otorg
                         WHERE unidad_academica = sga_alumnos.unidad_academica
                           AND nro_inscripcion = sga_alumnos.nro_inscripcion
                           AND titulo =  sga_titulos_plan.titulo 
						   -- AND fecha_egreso BETWEEN ld_FechaIni AND ld_FechaFin
					   )
       -- AND sga_alumnos.carrera NOT IN (SELECT carrera_ciclocomun FROM int_arau_car_cc)
     ORDER BY sga_alumnos.unidad_academica, sga_alumnos.carrera
      
      BEGIN
         ON EXCEPTION SET sqlerr, isamerror, errorinfo
            -- error
            -- Se agrego esta excepcion para que continue si encontro algun problema!!!	
            -- Poruqe si da error el titulo por orientacion no seleccionada, devuelve un -746	
         END EXCEPTION WITH RESUME;   
         
         -- FOREACH EXECUTE PROCEDURE sp_titulo_aprobado(ls_Ua, ls_Carrera, ls_Legajo, ls_Titulo ) INTO ls_Orientacion, ls_Plan, ls_Version 
         FOREACH EXECUTE PROCEDURE sp_titulo_aprobfec(ls_Ua, ls_Carrera, ls_Legajo, ls_Titulo, pFechaFinAnio ) INTO ls_Orientacion, ls_Plan, ls_Version 
            
            -- Verifico la fecha de Egreso si se encuentra entre la del año academico.
            EXECUTE PROCEDURE sp_fecha_egreso ( ls_Ua, ls_Carrera, ls_Legajo, ls_Titulo, ls_Plan, ls_Version, ls_Orientacion ) INTO vd_FechaEgreso;
            IF (vd_FechaEgreso <= ld_FechaFin ) AND (vd_FechaEgreso >= ld_FechaIni ) THEN
               
               -- Verifico que ya no se haya ingresado ese titulo, ya que pudo haber egresado por mas de una orientación.
               IF ( SELECT COUNT(*)
                      FROM int_araunom_egres 
                     WHERE anio_academico   = pAnioAcademico
                       AND unidad_academica = ls_UA
                       AND carrera          = ls_Carrera
                       AND legajo           = ls_Legajo
                       AND titulo_araucano  = ls_TituloAraucano ) = 0 THEN
                  
                  INSERT INTO int_araunom_egres (anio_academico, unidad_academica, carrera, legajo, titulo, titulo_araucano, fecha_egreso, solicito_titulo)
                       VALUES ( pAnioAcademico, ls_UA, ls_Carrera, ls_Legajo, ls_titulo, ls_TituloAraucano, vd_FechaEgreso, 'N' );
               END IF;
            END IF;
            
         END FOREACH;  -- titulo aprobado (orientaciones)
      END;
   END FOREACH; -- Alumnos
   
END;
END PROCEDURE;
-- ************************** fin procedure sp_int_araunom_egr **************************

GRANT EXECUTE ON sp_int_araunom_egr TO public;

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

-- ***************************************************************
-- SIU-Guarani 2.9.3
-- Procedure: sp_ult_dato_censal
-- Retorna: Fecha de relevamiento de ultimo dato censal
-- ***************************************************************

-- DROP PROCEDURE sp_ult_dato_censal;
CREATE PROCEDURE sp_ult_dato_censal (
   pUnidad_academica like sga_personas.unidad_academica, 
   pNro_inscripcion  like sga_personas.nro_inscripcion )
 
  RETURNING date;

DEFINE vd_Fecha                DATE;

BEGIN
   LET vd_Fecha = NULL;
   SELECT MAX(fecha_relevamiento)
     INTO vd_Fecha
     FROM sga_datos_censales
    WHERE unidad_academica = pUnidad_academica
      AND nro_inscripcion = pNro_inscripcion;

  RETURN vd_Fecha;
END;
END PROCEDURE;
-- +++++++++++++++++++++++++++++ Fin procedure sp_ult_dato_censal +++++++++++++++++++++

GRANT EXECUTE ON sp_ult_dato_censal TO public;
-- ******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.07.0, 2.9.3
-- Procedure sp_int_arau_datsed
-- 
-- Proceso que recupera la sede de los alumnos para el proceso de Araucano.
-- Recupera la sede que estaba el alumno al inicio del año acadèmico a informar.
-- Si no lo encuentra devuelve la sede actual.
-- 
-- Recibe: UA, Carrera, Legajo, Anio Académico informado
-- Retorna: sede.
-- ******************************************************************************

DROP PROCEDURE sp_int_arau_datsed;
CREATE PROCEDURE sp_int_arau_datsed( 
   pUA      LIKE dba.sga_alumnos.unidad_academica,
   pCarrera LIKE dba.sga_alumnos.carrera,
   pLegajo  LIKE dba.sga_alumnos.legajo,
   pAnio    LIKE dba.sga_anio_academico.anio_academico )

 RETURNING VARCHAR(5);


-- Variables Internas.
DEFINE vc_Sede        VARCHAR(5);
DEFINE vd_Fecha, vd_FechaFinAcad      DATE;
DEFINE l_cmb_sede, l_cmb_sede2 INTEGER;


-- VARIABLES PARA EL MANEJO DE EXCEPCIONES.
DEFINE SQLErr               INTEGER;
DEFINE ISAMError            INTEGER;
DEFINE errorInfo            VARCHAR(76);


-- SI HAY ALGÚN ERROR.
ON EXCEPTION SET SQLErr, ISAMError, errorInfo
   RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;

BEGIN

LET vc_sede = NULL;
LET l_cmb_sede = NULL;
LET vd_FechaFinAcad = NULL;
LET vd_Fecha = NULL;

  -- -- tomo la fecha final del año academico
  -- SELECT fecha_fin INTO vd_FechaFinAcad FROM sga_anio_academico	WHERE anio_academico = pAnio;

  -- Se recupera la sede del alumno en la fecha de inicio del año academico a informar.
  LET vd_Fecha = to_date('0104'|| pAnio, '%d%m%Y');
   


  -- busco la sede en la tabla de cambios de sede

	SELECT MAX(cambio_sede)
	INTO  l_cmb_sede
	FROM sga_sedes_hist_cmb
	WHERE unidad_academica = pUA
	AND carrera = pCarrera
	AND legajo = pLegajo
	AND vd_Fecha BETWEEN fecha_desde and fecha_hasta;
	--   AND vd_FechaFinAcad between fecha_desde and fecha_hasta;


	-- si es no existe busco la que tenga fecha en null (ultimo cambio de sede)
	IF l_cmb_sede IS NULL then

		SELECT MAX(cambio_sede)
		INTO  l_cmb_sede
		FROM sga_sedes_hist_cmb
		WHERE unidad_academica = pUA
		AND carrera = pCarrera
		AND legajo = pLegajo
		AND fecha_desde <= vd_Fecha and fecha_hasta is null;
		-- AND fecha_desde <= vd_FechaFinAcad and fecha_hasta is null;

	END IF;

	IF l_cmb_sede IS NOT NULL then
		SELECT sede
		INTO vc_sede
		FROM sga_sedes_hist_cmb
		WHERE cambio_sede = l_cmb_sede;
	END IF

	IF vc_sede IS NULL THEN
		-- Sede Actual del Alumno
		SELECT sede
		INTO vc_sede
		FROM sga_alumnos
		WHERE unidad_academica = pUA
		AND carrera = pCarrera
		AND legajo = pLegajo;

	END IF;

	RETURN vc_sede;

END;
END PROCEDURE;
-- ********************* FIN DEL PROCESO sp_int_arau_datsed *********************

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SIU-GUARANI 
-- Version: 2.9.3, 2.9.4
-- Stored Procedure: sp_arau_nominal
-- Fecha: Abril 2016
-- Año academico: Se considera del 01/04/(Año a informar)  al 31/03/(Año a informar +1)
-- Recupera alumnos inscriptos con/sin legajo generado a carrera en un año academico  igual o anterior al año a informar y que tengan asignado un titulo araucano.
-- Informa por cada titulo del plan que tenga definido un código de titulo araucano.
-- Si el alumno egresó en un año acadèmico anterior al que se informa (fecha de egreso < al 01/04/Año a informar), entonces no se informa al alumno por ese titulo araucano.
-- El codigo de institucion araucano lo saca de la sede a la fecha de inicio del año academico a informar (si no esta cargado lo saca de la unidad academica del alumno.)
--
-- En el archivo 1 de oferta academica se informan los titulos del plan de estudios que tengan asociado un titulo araucano.
-- Se informa solo si aun no egresó de ese titulo y realizò actividades en el año o si egreso en el año a informar. Si egresò antes no se informa.
-- En el archivo 2 de rendimiento academico se informan las materias realizadas en el año academico a informar y las que peretenecen a cada titulo por la cual se informan.
--
-- No se informan los alumnos de las carreras que tengan asociado un ciclo básico comun, ya que los alumnos de estas carreras
-- seran informados como ingresantes en el ciclo básico comun (si ingresaron en el año a informar).
--
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- DROP PROCEDURE dba.sp_arau_nominal (integer);

CREATE PROCEDURE dba.sp_arau_nominal (pAnioAcademico integer)
   RETURNING Integer, varchar(255); -- Cantidad de alumnos a informar


DEFINE iCantAlumnos,iAnioIngreso, iProcedencia integer;
DEFINE ld_FechaIni, ld_FechaIniAA LIKE sga_anio_academico.fecha_inicio;
DEFINE ld_FechaFin, ld_FechaFinAA LIKE sga_anio_academico.fecha_fin;
DEFINE ls_FechaIni, ls_FechaFin varchar(10);
DEFINE li_AnioSig  INTEGER;
DEFINE vcFormaIngreso char(1);
DEFINE vcUA, vcCarrera, vcPlan, vcSedeActual, vcSede, vcVersion varchar(5);
DEFINE vcLegajo varchar(15);
DEFINE vcNroInscripcion varchar(10);
DEFINE viTipodocumento LIKE sga_personas.tipo_documento;
DEFINE vcNroDocumento  LIKE sga_personas.nro_documento;
DEFINE vcCuit LIKE sga_personas.numero_cuil;


-- VARIABLES PARA EL MANEJO DE EXCEPCIONES.
DEFINE iStatus, sql_error, isam_error   integer;
DEFINE error_info   varchar(76);


-- blk de excepciones
ON EXCEPTION SET sql_error, isam_error, error_info
   -- LET iStatus = sql_err;
   -- LET vcMsg = error_info;
   -- RETURN iStatus, vcMsg;
   RETURN -1, 'Error: ' || sql_error || ' - ' || error_info;
END EXCEPTION; 


BEGIN

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FECHAS DEL AÑO ACADEMICO
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
LET ls_FechaIni = '01/04/' || pAnioAcademico;
LET ls_FechaFin = '31/03/' || pAnioAcademico + 1;
LET ld_FechaIniAA = to_date(ls_FechaIni, '%d/%m/%Y');
LET ld_FechaFinAA = to_date(ls_FechaFin, '%d/%m/%Y');



BEGIN
  -- Creacion de tablas temporales
  ON EXCEPTION IN  (-206)
   -- Tabla temporal ya existe
  END EXCEPTION with resume;

  -- Borro tablas temporales
  DROP TABLE _temp_titulos;
  DROP TABLE _temp_alumnos;
  DROP TABLE _temp_personas;  
  DROP TABLE _temp_materias;  
  DROP TABLE _temp_materias_tit;
  DROP TABLE _temp_alu_sin_act;
  DROP TABLE _temp_alu_con_act;
 
 -- Alumnos que no realizaron ningnua actividad (inscripciones a examen, materias, reinscripcion, equivalencias..) en el año a informar.
 -- Utilizado para ver si se informa estos en el archivo 1.
 CREATE TEMP TABLE _temp_alu_sin_act (unidad_academica varchar(5), carrera varchar(5), legajo varchar(15), titulo_araucano integer) WITH NO LOG;
 CREATE INDEX _idx_tempalusinact ON _temp_alu_sin_act (unidad_academica, carrera, legajo);

 CREATE TEMP TABLE _temp_alu_con_act (unidad_academica varchar(5), carrera varchar(5), legajo varchar(15), titulo_araucano integer) WITH NO LOG;
 CREATE INDEX _idx_tempaluconact ON _temp_alu_con_act (unidad_academica, carrera, legajo);

 -- Titulos a informar
 CREATE TEMP TABLE _temp_titulos (unidad_academica varchar(5), carrera varchar(5), plan varchar(5), titulo varchar(5), titulo_araucano integer) WITH NO LOG;

 INSERT INTO _temp_titulos (unidad_academica, carrera, plan, titulo, titulo_araucano)
  SELECT sga_titulos_plan.unidad_academica, sga_titulos_plan.carrera, sga_titulos_plan.plan, sga_titulos_plan.titulo, sga_titulos.titulo_araucano
    FROM sga_titulos_plan, sga_titulos
 WHERE sga_titulos.unidad_academica = sga_titulos_plan.unidad_academica
     AND sga_titulos.titulo  =  sga_titulos_plan.titulo
     AND sga_titulos.titulo_araucano IS NOT NULL;

  -- AND sga_titulos.nivel = 'GRADO'
  -- AND sga_titulos.tipo_de_titulo IN ('G', 'P', 'S')

 CREATE INDEX _idx_temp_titulos ON _temp_alumnos (unidad_academica, carrera, plan, titulo);


-- Alumnos a Informar
CREATE TEMP TABLE _temp_alumnos (unidad_academica varchar(5), carrera varchar(5), legajo varchar(15), plan varchar(5), nro_inscripcion varchar(10), tipo_documento integer, nro_documento varchar(15), cuil_cuit varchar(15), sede_actual varchar(5))   WITH NO LOG;

-- Personas a informar 
CREATE TEMP TABLE _temp_personas (unidad_academica varchar(5), nro_inscripcion varchar(10)) WITH NO LOG;

-- Materias aprobadas por el alumno
CREATE TEMP TABLE _temp_materias
	( forma_aprobacion   integer NOT NULL,
	  unidad_academica varchar(5),
	  carrera      varchar(5),
	  legajo       varchar(15),
	  materia      varchar(5),
	  materia_nombre varchar(255),
	  fecha        varchar(10),
	  plan         varchar(5),
	  version      varchar(5),
	  resultado  char(1),
	  obligatoria  Integer,
	  carga_horaria Integer,
	  acta         varchar(30),
	  libro        varchar(100),
	  folio_fisico Integer,
	  expediente   varchar(30)
	) WITH NO LOG;

-- Materias que componen un titulo (solo hasta plan. no se considera la version del plan)
CREATE TEMP TABLE _temp_materias_tit
	( unidad_academica varchar(5),
	  carrera varchar(5),
	  plan    varchar(5),
	  -- version   varchar(5),
	  titulo varchar(5),
	  titulo_araucano integer,
	  materia    varchar(5)
	) WITH NO LOG;

END; -- Creacion de tablas temporales

-- Borro datos de la tabla donde se guardan los datos de alumnos para el año academico a procesar
DELETE FROM int_araunom_alu WHERE anio_academico = pAnioAcademico;
DELETE FROM int_araunom_rend WHERE anio_academico = pAnioAcademico;
DELETE FROM int_araunom_oferta WHERE anio_academico = pAnioAcademico;


-- Recupero las materias de cada título de la institucion. Solo titulos con codigo de titulo araucano.
-- INSERT INTO _temp_materias_tit (unidad_academica, carrera, plan, version, titulo, titulo_araucano, materia)
--   SELECT DISTINCT mp.unidad_academica, mp.carrera, mp.plan, mp.version, mp.titulo, t.titulo_araucano, mp.materia

INSERT INTO _temp_materias_tit (unidad_academica, carrera, plan, titulo, titulo_araucano, materia)
  SELECT DISTINCT mp.unidad_academica, mp.carrera, mp.plan, mp.titulo, t.titulo_araucano, mp.materia
    FROM vw_materias_plan as mp , sga_titulos as t
   WHERE mp.unidad_academica = t.unidad_academica
     AND mp.titulo = t.titulo
     AND t.titulo_araucano IS NOT NULL;

CREATE INDEX _idx_temp_mat_tit1 ON _temp_materias_tit (unidad_academica, carrera, plan, titulo);
CREATE INDEX _idx_temp_mat_tit2 ON _temp_materias_tit (unidad_academica, carrera, plan, titulo_araucano, materia);

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Archivo 0 = Alumnos 
-- Alumnos: Activos / Pasivos / Abandono / Egresados inscriptos en años academicos menores o igual al que se informa.
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/*
Horas Trabajo:
20	Menos de 20 horas
2035	De 20 a 35 horas
+35	Más de 35 horas
NDI	No Contesta
NT	No Trabaja

Nivel de instrucion del padre/ de la madre:
1	No hizo estudios
2	Escuela Primaria Incompleta
3	Escuela Primaria Completa
4	Secundario Incompleto
5	Secundario Completo
6	Universitario o Superior Incompleto
7	Universitario o Superior Completo
8	Posgrado
9	No sabe

*/


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Alumnos a informar.
-- * De cualquier calidad hoy (Activo, Pasivo, Egresado, Abandono de Carrera) 
-- * De carreras que tienen titulo araucano a informar 
-- * Que no hayan ingresado en años posteriores al que se informa
-- * Recupera el plan del alumno en el que estaba al comienzo del año academico a informar. 
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++
FOREACH 
  SELECT
       a.unidad_academica,
       a.carrera,
       a.legajo,
       -- a.plan, 
       a.nro_inscripcion,
       p.tipo_documento,
       p.nro_documento,
       p.numero_cuil,
       a.sede
   INTO vcUa, vcCarrera, vcLegajo, vcNroInscripcion, viTipoDocumento, vcNroDocumento, vcCuit, vcSede
FROM 
   sga_alumnos as a, 
   sga_carrera_aspira as ca, 
   sga_periodo_insc as pi,
   sga_personas as p,
   sga_situacion_asp as sa

WHERE a.calidad IN ('A','P','E','N')

  AND ca.unidad_academica = a.unidad_academica
  AND ca.nro_inscripcion = a.nro_inscripcion
  AND ca.carrera = a.carrera

  AND sa.situacion_asp = ca.situacion_asp
  AND sa.resultado_asp IN ('I', 'A')
  -- AND sa.situacion_asp IN ('IL', 'IC','AC') 

  AND pi.periodo_inscripcio = ca.periodo_inscripcio
  AND pi.anio_academico <= pAnioAcademico

  AND p.unidad_academica = a.unidad_academica
  AND p.nro_inscripcion = a.nro_inscripcion

  -- Recupero el plan a la fecha de inicio del periodo lectivo
  EXECUTE PROCEDURE sp_plan_de_alumno( vcUa, vcCarrera, vcLegajo, ld_FechaIniAA) INTO vcPlan, vcVersion;

  -- Inserto en la temporal
  INSERT INTO _temp_alumnos (unidad_academica, carrera, legajo, plan, nro_inscripcion, tipo_documento, nro_documento, cuil_cuit, sede_actual)
     VALUES (vcUa, vcCarrera, vcLegajo, vcPlan, vcNroInscripcion, viTipoDocumento, vcNroDocumento, vcCuit, vcSede);
  
END FOREACH;
  
-- Creo un indice por datos del alumno
CREATE INDEX _idx_temp_alumnos ON _temp_alumnos (unidad_academica, carrera, legajo);

-- Borro ofertas que no existen para informar
DELETE FROM _temp_alumnos
  WHERE unidad_academica || '|' || carrera || '|' ||  plan NOT IN (SELECT unidad_academica || '|' || carrera || '|' ||  plan FROM _temp_titulos);




-- +++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Recupero las personas...
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++
INSERT INTO _temp_personas (unidad_academica, nro_inscripcion)
   SELECT DISTINCT unidad_academica, nro_inscripcion FROM _temp_alumnos;

CREATE INDEX _idx_temp_personas  ON _temp_personas (unidad_academica, nro_inscripcion);


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ARCHIVO 0: Tabla de personas
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
INSERT INTO int_araunom_alu (
	anio_academico,
	tipo_documento,
	nro_documento,
	cuil_cuit,
	genero,
	fecha_nacimiento,
	horas_trabajo,
	nivel_inst_padre,
	nivel_inst_madre,
	nacimiento_pais,
	nacimiento_loc)

  SELECT
       pAnioAcademico,
       p.tipo_documento,
       p.nro_documento, 
       p.numero_cuil,
       cast(p.sexo as integer), 
       to_char(p.fecha_nacimiento, "%Y%m%d"),
       CASE 
          WHEN dca.existe_trab_alum IS NULL THEN 'NDI' -- No contesta
          WHEN dca.existe_trab_alum = 1 THEN  -- Trabaja
             (CASE 
               WHEN dc.hora_sem_trab_alum = 1 THEN '20'
               WHEN dc.hora_sem_trab_alum = 2 THEN '20'
               WHEN dc.hora_sem_trab_alum = 3 THEN '2035'
               WHEN dc.hora_sem_trab_alum = 4 THEN '+35'
               ELSE 'NDI'  -- No contesta
              END)
          WHEN dca.existe_trab_alum = 2 THEN 'NT' 
          WHEN dca.existe_trab_alum = 3 THEN 'NT' 
          ELSE 'NDI' -- No Contesta
       END as horas_trabajo,  
       CASE 
           WHEN dca.padre_vive IS NULL THEN 9  -- No Sabe
           WHEN dca.padre_vive = 'D' THEN 9  -- No Sabe
           WHEN (dca.padre_vive = 'S' OR dca.padre_vive = 'N') THEN
              (CASE
                WHEN dc.ult_est_cur_padre IN (1,2,3,4,5) THEN dc.ult_est_cur_padre
                WHEN dc.ult_est_cur_padre IN (8,10) THEN 6
                WHEN dc.ult_est_cur_padre IN (9,11) THEN 7
                WHEN dc.ult_est_cur_padre = 12 THEN 8
                WHEN dc.ult_est_cur_padre = 13 THEN 9
                ELSE 9
               END)
           ELSE 9
       END as nivel_inst_padre,
       CASE 
           WHEN dca.madre_vive IS NULL THEN 9  -- No Sabe
           WHEN dca.madre_vive = 'D' THEN 9  -- No Sabe
           WHEN (dca.madre_vive = 'S' OR dca.madre_vive = 'N') THEN
              (CASE
                WHEN dc.ult_est_cur_madre IN (1,2,3,4,5) THEN dc.ult_est_cur_madre
                WHEN dc.ult_est_cur_madre IN (8,10) THEN 6
                WHEN dc.ult_est_cur_madre IN (9,11) THEN 7
                WHEN dc.ult_est_cur_madre = 12 THEN 8
                WHEN dc.ult_est_cur_madre = 13 THEN 9
                ELSE 9
             END)
           ELSE 9
       END as nivel_inst_madre,
       CASE 
          WHEN p.loc_nacimiento IS NULL THEN p.pais_documento   -- Recupera el pais del documento que es un dato que siempre existe
          ELSE  
            (SELECT prov.pais FROM mug_localidades as loc, mug_dptos_partidos as dp, mug_provincias as prov
              WHERE loc.localidad = p.loc_nacimiento
                AND dp.dpto_partido = loc.dpto_partido
                AND prov.provincia = dp.provincia)
       END as pais_nacimiento,
       CASE 
          WHEN p.loc_nacimiento IS NULL THEN 
            -- Dpto/Partido, Localidad y Provincia Indeterminada del pais del documento 
            (SELECT loc.localidad
               FROM mug_provincias as prov, mug_dptos_partidos as dp, mug_localidades as loc
              WHERE prov.pais = p.pais_documento
                AND prov.nombre = 'Indeterminada'
                AND dp.provincia = prov.provincia
                AND dp.nombre = 'Indeterminado'
                AND loc.dpto_partido = dp.dpto_partido
                AND loc.nombre = 'Indeterminada'
            )
          ELSE p.loc_nacimiento 
       END as loc_nacimiento
  
FROM 
   _temp_personas as tp, 
   sga_personas as p,
   sga_datos_censales as dc,
   sga_datos_cen_aux as dca

WHERE p.unidad_academica = tp.unidad_academica
  AND p.nro_inscripcion  = tp.nro_inscripcion

  AND dc.unidad_academica   = p.unidad_academica
  AND dc.nro_inscripcion    = p.nro_inscripcion
  AND dc.fecha_relevamiento = sp_ult_dato_censal(p.unidad_academica, p.nro_inscripcion)

  AND dca.unidad_academica   = dc.unidad_academica
  AND dca.nro_inscripcion    = dc.nro_inscripcion
  AND dca.fecha_relevamiento = dc.fecha_relevamiento;
 

-- Recupero cantidad de alumnos
SELECT COUNT(*) INTO iCantAlumnos FROM int_araunom_alu WHERE anio_academico = pAnioAcademico;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Archivo 1 = 
-- * Recupera alumnos relacionado con el archivo 0 de nominales.
-- * Institución Araucano: se la institución definida en la sede del alumno y sino de la unidad academica.
-- * Sede: la sede que se informa es en la que estaba el alumno en la fecha de inicio del año academico a informar.
-- * Se informa un registro por cada carrera en que se encuentra la persona y que tenga un 
--   titulo asociado con las siguientes caracteristicas:
--     - Que el titulo tenga definido un còdigo de título araucano
--     - Que el titulo sea de nivel INTERMEDIO O FINAL (GRADO).
--       Se informa al alumno por cada titulo que obtuvo.
--     - ESTO NO: El tipo de titulo sea uno de estos:  G - Título de Grado Universitario  P - Pre-Grado    S - Postítulo
-- * Fecha de egreso: 
-- * Forma de ingreso:
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Recupero los egresados o alumnos en condicion de egresar en el año academico (01/04 al 31/03). Carga la tabla int_arau_egres
-- Los que egresaron en ese año academico o los que estn en condiciones de egresar)
EXECUTE PROCEDURE sp_int_araunom_egr(pAnioAcademico, ls_FechaIni, ls_FechaFin); 

-- Archivo 1
FOREACH SELECT t.unidad_academica, int_araunom_alu.tipo_documento, int_araunom_alu.nro_documento, int_araunom_alu.cuil_cuit, t.carrera, t.legajo, t.plan, t.sede_actual
          INTO vcUa, viTipoDocumento, vcNroDocumento, vcCuit, vcCarrera, vcLegajo, vcPlan, vcSedeActual 
          FROM int_araunom_alu, _temp_alumnos as t
         WHERE int_araunom_alu.anio_academico = pAnioAcademico
           AND t.tipo_documento   = int_araunom_alu.tipo_documento
           AND t.nro_documento    = int_araunom_alu.nro_documento
 
        -- Cargo la tabla temporal de historia academica "sga_hist_acade_aux" usada por el proceso "sp_int_arau_datequ"
        EXECUTE PROCEDURE sp_ac_up_hacad_alu (vcUA, vcCarrera, vcLegajo, NULL);

        -- Año de ingreso
        EXECUTE PROCEDURE sp_int_arau_dating (vcUA, vcCarrera, vcLegajo) INTO iAnioIngreso;

        -- Forma de ingreso en la carrera. S = por Equivalencia / N = Ingreso normal
        EXECUTE PROCEDURE sp_int_arau_datequ(vcUA, vcCarrera, vcLegajo, iAnioIngreso) INTO vcFormaIngreso;

        -- Recupero la informacion de procedencia
        EXECUTE PROCEDURE sp_int_arau_datpro (vcUA, vcCarrera, vcLegajo, iAnioIngreso) INTO iProcedencia;

        -- Sede en la que se encontraba el alumno en el año academico a inforamr
        EXECUTE PROCEDURE sp_int_arau_datsed (vcUA, vcCarrera, vcLegajo, pAnioAcademico) INTO vcSede;


        -- Inserto los titulos por cada alumno segun el plan actual en el que se encuentra
        INSERT INTO int_araunom_oferta (
        	anio_academico, 
        	tipo_documento, 
        	nro_documento, 
        	cuil_cuit, 
        	instituc_araucano, 
        	titulo_araucano, 
        	anio_ingreso, 
        	forma_ingreso, 
        	fecha_egreso, 
        	procedencia,
        	unidad_academica,
        	carrera,
        	legajo,
        	plan)
        SELECT
        	pAnioAcademico,
        	viTipoDocumento,
        	vcNroDocumento,
        	vcCuit,
        	NVL(sga_sedes.instituc_araucano, sga_unidades_acad.instituc_araucano) as instituc_araucano,
        	CAST(tit.titulo_araucano as integer) as titulo_araucano, 
        	iAnioIngreso,
        
        	CASE vcFormaIngreso
        	  WHEN 'S' THEN 2 -- Por Equivalencia
        	  WHEN 'N' THEN 1 -- Normal
        	  ELSE 1 -- Normal
        	END,
        
        	CASE
        	   WHEN int_araunom_egres.fecha_egreso IS NOT NULL THEN to_char(int_araunom_egres.fecha_egreso, "%Y%m%d")
        	   ELSE CAST(NULL as varchar(10))  -- No obtuvo el titulo en este año academico.
        	END as fecha_egreso,
        	iProcedencia,
        	sga_alumnos.unidad_academica,
        	sga_alumnos.carrera,
        	sga_alumnos.legajo,
        	vcPlan -- sga_alumnos.plan
  
        FROM 
            sga_alumnos, 
            _temp_titulos as tit,
            sga_unidades_acad, 
            sga_sedes,
            OUTER int_araunom_egres
            -- OUTER sga_titulos_otorg
        
        WHERE sga_alumnos.unidad_academica = vcUA
          AND sga_alumnos.carrera = vcCarrera
          AND sga_alumnos.legajo = vcLegajo
          AND sga_sedes.sede = vcSede
          AND sga_unidades_acad.unidad_academica = sga_alumnos.unidad_academica
          AND tit.unidad_academica = sga_alumnos.unidad_academica
          AND tit.carrera          = sga_alumnos.carrera
          AND tit.plan             = vcPlan               -- sga_alumnos.plan
          AND int_araunom_egres.unidad_academica = sga_alumnos.unidad_academica
          AND int_araunom_egres.carrera          = sga_alumnos.carrera
          AND int_araunom_egres.legajo           = sga_alumnos.legajo
          AND int_araunom_egres.titulo           = tit.titulo;

END FOREACH; -- Alumnos

-- Borro de la oferta aquellos alumnos que egresaron en un año academico anterior
DELETE FROM int_araunom_oferta
   WHERE anio_academico = pAnioAcademico
         AND fecha_egreso IS NOT NULL
         AND to_date(fecha_egreso, "%Y%m%d") < ld_FechaIniAA;


-- Borro de la tabla del archivo 0, los alumnos que no se van a informar por ningun titulo araucano en el archivo 1.
DELETE FROM int_araunom_alu
   WHERE anio_academico = pAnioAcademico
     AND tipo_documento || '|' || nro_documento NOT IN (SELECT tipo_documento || '|' || nro_documento 
	                                                      FROM int_araunom_oferta
                                                         WHERE anio_academico = pAnioAcademico
														);
                                           

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Archivo 2 
-- * Materias aprobadas/desaprobadas 
-- * Examenes/promociones/equivalencias totales con fecha de aprobacion entre el 01/04 del año academico a informar y el 31/03 del año siguiente.
-- * Se informan las materias que pertenecen a cada titulo a informar.
-- 
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


  -- Cargo tabla temporal de materias realizadas por los alumnos en el año academico a informar
  
  -- Materias aprobadas por PROMOCION de cursadas del año academico a evaluar
  INSERT INTO _temp_materias (forma_aprobacion, unidad_academica, carrera, legajo, materia, materia_nombre, resultado, obligatoria, carga_horaria, fecha, plan, version, acta, libro, folio_fisico)
    SELECT 
            2, -- Promocion
            d.unidad_academica,
            d.carrera,
            d.legajo,
            c.materia,
            NVL(sga_atrib_mat_plan.nombre_materia, sga_materias.nombre),
            'A', -- Aprobado
            CASE sga_atrib_mat_plan.obligatoria
              WHEN 'S' THEN 0
              WHEN 'N' THEN 
                  (CASE sga_atrib_mat_plan.tipo_materia
                    WHEN 'O' THEN 2 -- Optativa
                    ELSE 1          -- Electiva
                   END) 
              ELSE 1  -- Electiva
            END, 
            sga_atrib_mat_plan.carga_horaria_tot,
            to_char(d.fecha, "%Y%m%d"),
            d.plan, 
            d.version,
            p.acta,
            sga_libros_de_acta.nombre,
            sga_folios_promo.folio_fisico
       FROM sga_comisiones as c,
            sga_actas_promo as p,
            sga_det_acta_promo as d, 
            sga_materias,
            OUTER sga_libros_de_acta, 
            OUTER sga_folios_promo,
            OUTER sga_atrib_mat_plan
      WHERE p.comision = c.comision
        AND p.estado = 'C'
        AND d.unidad_academica = p.unidad_academica
        AND d.acta = p.acta
        AND d.rectificado = 'N'
        AND d.estado = 'A'
        AND d.resultado = 'P'  -- Promocionada
        AND d.fecha BETWEEN ld_FechaIniAA AND ld_FechaFinAA
        AND sga_materias.unidad_academica = c.unidad_academica
        AND sga_materias.materia = c.materia
        AND sga_libros_de_acta.libro = p.libro
        AND sga_folios_promo.unidad_academica = d.unidad_academica 
        AND sga_folios_promo.acta  = d.acta
        AND sga_folios_promo.folio = d.folio
        AND sga_atrib_mat_plan.unidad_academica = d.unidad_academica
        AND sga_atrib_mat_plan.carrera = d.carrera
        AND sga_atrib_mat_plan.plan    = d.plan
        AND sga_atrib_mat_plan.version = d.version
        AND sga_atrib_mat_plan.materia = c.materia;
        -- c.anio_academico = pAnioAcademico

  -- Promociones equivalentes. Promociones en otras carreras del alumno
  INSERT INTO _temp_materias (forma_aprobacion, unidad_academica, carrera, legajo, materia, materia_nombre, resultado, obligatoria, carga_horaria, fecha, plan, version, acta, libro, folio_fisico)
    SELECT 
            2, -- Promocion
            eq.unidad_academica,
            eq.carrera,
            eq.legajo,
            c.materia,
            NVL(sga_atrib_mat_plan.nombre_materia, sga_materias.nombre),
            'A', -- Aprobado
            CASE sga_atrib_mat_plan.obligatoria
              WHEN 'S' THEN 0
              WHEN 'N' THEN 
                  (CASE sga_atrib_mat_plan.tipo_materia
                    WHEN 'O' THEN 2 -- Optativa
                    ELSE 1          -- Electiva
                   END) 
              ELSE 1  -- Electiva
            END, 
            sga_atrib_mat_plan.carga_horaria_tot,
            to_char(eq.fecha, "%Y%m%d"),
            eq.plan, 
            eq.version,
            p.acta,
            sga_libros_de_acta.nombre,
            sga_folios_promo.folio_fisico
       FROM 
            sga_promo_equiv as eq,
            sga_comisiones as c,
            sga_actas_promo as p,
            sga_det_acta_promo as d, 
            sga_materias,
            OUTER sga_libros_de_acta, 
            OUTER sga_folios_promo,
            OUTER sga_atrib_mat_plan
      WHERE p.unidad_academica = eq.unidad_academica
        AND p.acta = eq.acta
        AND eq.estado = 'A' -- Activo
        AND p.comision = c.comision
        -- AND c.anio_academico = pAnioAcademico
        AND eq.fecha BETWEEN ld_FechaIniAA AND ld_FechaFinAA
        AND p.estado = 'C'
        AND d.unidad_academica = p.unidad_academica
        AND d.acta = p.acta
        AND d.carrera = eq.carrera_original
        AND d.legajo = eq.legajo_original 
        AND d.rectificado = 'N'
        AND d.estado = 'A'
        AND d.resultado = 'P'  -- Promocionada
        AND sga_materias.unidad_academica = c.unidad_academica
        AND sga_materias.materia = c.materia
        AND sga_libros_de_acta.libro = p.libro
        AND sga_folios_promo.unidad_academica = d.unidad_academica 
        AND sga_folios_promo.acta  = d.acta
        AND sga_folios_promo.folio = d.folio
        AND sga_atrib_mat_plan.unidad_academica = eq.unidad_academica
        AND sga_atrib_mat_plan.carrera = eq.carrera
        AND sga_atrib_mat_plan.plan    = eq.plan
        AND sga_atrib_mat_plan.version = eq.version
        AND sga_atrib_mat_plan.materia = c.materia;
 
  -- Materias rendidas por EXAMEN
  INSERT INTO _temp_materias (forma_aprobacion, unidad_academica, carrera, legajo, materia, materia_nombre, resultado, obligatoria, carga_horaria, fecha, plan, version, acta, libro, folio_fisico)
    SELECT 
            CASE d.tipo_inscripcion
                 WHEN 'R' THEN 0 -- Examen Final Regular
                 WHEN 'L' THEN 1 -- Examen Libre
                 WHEN 'T' THEN 1 -- Tesis Examen Libre ?
                 ELSE 1 -- Examen Libre                 
            END, 
            d.unidad_academica,
            d.carrera,
            d.legajo,
            ae.materia,
            NVL(sga_atrib_mat_plan.nombre_materia, sga_materias.nombre),
            d.resultado,
            CASE sga_atrib_mat_plan.obligatoria
              WHEN 'S' THEN 0 -- Obligatoria
              WHEN 'N' THEN 
                  (CASE sga_atrib_mat_plan.tipo_materia
                    WHEN 'O' THEN 2 -- Optativa
                    ELSE 1          -- Electiva
                   END) 
              ELSE 1  -- Electiva
            END, 
            sga_atrib_mat_plan.carga_horaria_tot,
            to_char(d.fecha_de_examen, "%Y%m%d"),
            d.plan,
            d.version,
            cast(d.acta as varchar(30)),
            sga_libros_de_acta.nombre,
            sga_folios.folio_fisico
            
       FROM sga_detalle_acta as d,
            sga_actas_examen as ae,
            sga_materias,  
            OUTER sga_libros_de_acta,
            OUTER sga_folios,
            OUTER sga_atrib_mat_plan
      WHERE d.fecha_de_examen BETWEEN ld_FechaIniAA AND ld_FechaFinAA
        AND d.estado = 'A'
        AND d.rectificado = 'N'
        AND d.resultado IN ('A','R','U')
        AND ae.unidad_academica = d.unidad_academica
        AND ae.acta = d.acta
        AND ae.tipo_acta = d.tipo_acta
        AND ae.estado = 'C'
        AND sga_materias.unidad_academica = ae.unidad_academica
        AND sga_materias.materia = ae.materia
        AND sga_libros_de_acta.libro = ae.libro
        AND sga_folios.unidad_academica = d.unidad_academica
        AND sga_folios.tipo_acta  = d.tipo_acta
        AND sga_folios.acta  = d.acta
        AND sga_folios.folio = d.folio
        AND sga_atrib_mat_plan.unidad_academica = d.unidad_academica
        AND sga_atrib_mat_plan.carrera = d.carrera
        AND sga_atrib_mat_plan.plan    = d.plan
        AND sga_atrib_mat_plan.version = d.version
        AND sga_atrib_mat_plan.materia = ae.materia;
  
  -- Examenes Equivalentes. Solo aprobados (no pasa los desaprobados por el tema de validacion de que se registran con la misma fecha cuando se registran en esta tabla y siempre se considera esta fecha y no la orignal)
  INSERT INTO _temp_materias (forma_aprobacion, unidad_academica, carrera, legajo, materia, materia_nombre, resultado, obligatoria, carga_horaria, fecha, plan, version, acta, libro, folio_fisico)
    SELECT 
            CASE d.tipo_inscripcion
                 WHEN 'R' THEN 0 -- Examen Final Regular
                 WHEN 'L' THEN 1 -- Examen Libre
                 WHEN 'T' THEN 1 -- Tesis Examen Libre ?
                 ELSE 1 -- Examen Libre                 
            END, 
            eq.unidad_academica,
            eq.carrera,
            eq.legajo,
            ae.materia,
            NVL(sga_atrib_mat_plan.nombre_materia, sga_materias.nombre),
            d.resultado,
            CASE sga_atrib_mat_plan.obligatoria
              WHEN 'S' THEN 0
              WHEN 'N' THEN 
                  (CASE sga_atrib_mat_plan.tipo_materia
                    WHEN 'O' THEN 2 -- Optativa
                    ELSE 1          -- Electiva
                   END) 
              ELSE 1  -- Electiva
            END, 
            sga_atrib_mat_plan.carga_horaria_tot,
            to_char(eq.fecha, "%Y%m%d"),
            eq.plan,
            eq.version,
            cast(eq.acta as varchar(30)),
            sga_libros_de_acta.nombre,
            sga_folios.folio_fisico
            
       FROM 
            sga_examenes_equiv as eq,  
            sga_detalle_acta as d,
            sga_actas_examen as ae,
            sga_materias,  
            OUTER sga_libros_de_acta,
            OUTER sga_folios,
            OUTER sga_atrib_mat_plan
  WHERE d.unidad_academica = eq.unidad_academica
        AND d.acta = eq.acta
        AND d.tipo_acta = eq.tipo_acta
        AND d.carrera = eq.carrera_original
        AND d.legajo = eq.legajo_original
        AND eq.estado = 'A'
        AND eq.fecha BETWEEN ld_FechaIniAA AND ld_FechaFinAA
        AND d.estado = 'A'
        AND d.rectificado = 'N'
        AND d.resultado IN ('A','R','U')
        AND ae.unidad_academica = d.unidad_academica
        AND ae.tipo_acta = d.tipo_acta
        AND ae.acta = d.acta
        AND ae.estado = 'C'
        AND sga_materias.unidad_academica = ae.unidad_academica
        AND sga_materias.materia = ae.materia
        AND sga_libros_de_acta.libro = ae.libro
        AND sga_folios.unidad_academica = d.unidad_academica
        AND sga_folios.tipo_acta  = d.tipo_acta
        AND sga_folios.acta  = d.acta
        AND sga_folios.folio = d.folio
        AND sga_atrib_mat_plan.unidad_academica = eq.unidad_academica
        AND sga_atrib_mat_plan.carrera = eq.carrera
        AND sga_atrib_mat_plan.plan    = eq.plan
        AND sga_atrib_mat_plan.version = eq.version
        AND sga_atrib_mat_plan.materia = ae.materia;


  -- Materias aprobadas por EQUIVALENCIA (Equivalencias Totales)
  INSERT INTO _temp_materias (forma_aprobacion, unidad_academica, carrera, legajo, materia, materia_nombre, resultado, obligatoria, carga_horaria, fecha, plan, version, expediente)
    SELECT 
            CASE sga_equiv_operac.origen
              WHEN 'E' THEN  3 -- Externa Libre
              WHEN 'S' THEN  4 -- Por Pase
              WHEN 'H' THEN  6 -- Homologada en el Plan de Estudios
              ELSE 5  -- Interna Libre (I, P, V, C)
            END,
            d.unidad_academica,
            d.carrera,
            d.legajo, 
            d.materia,
            NVL(sga_atrib_mat_plan.nombre_materia, sga_materias.nombre),
            d.resultado,
            CASE sga_atrib_mat_plan.obligatoria
              WHEN 'S' THEN 0 -- Obligatoria
              WHEN 'N' THEN 
                  (CASE sga_atrib_mat_plan.tipo_materia
                    WHEN 'O' THEN 2 -- Optativa
                    ELSE 1          -- Electiva
                   END) 
              ELSE 1  -- Electiva
            END, 
            sga_atrib_mat_plan.carga_horaria_tot,
            to_char(d.fecha, "%Y%m%d"),
            d.plan,
            d.version,
            sga_equiv_operac.nro_resolucion
            -- NVL(sga_equiv_resol.nro_expendiente, sga_equiv_operac.nro_resolucion)
          
       FROM sga_equiv_otorgada as d,
            sga_equiv_operac,
            sga_materias,
            OUTER sga_atrib_mat_plan,
            OUTER sga_equiv_resol
      WHERE d.fecha BETWEEN ld_FechaIniAA AND ld_FechaFinAA
        AND d.resultado = 'A'
        AND d.alcance = 'T' -- Equivalencia Total
        AND sga_equiv_operac.aplic_automatica = 'N'                
        AND sga_equiv_operac.origen IN ('E', 'S', 'I', 'H')
        AND d.estado = 'A'
        AND d.rectificado = 'N'
        AND sga_equiv_operac.operacion_equiv  = d.operacion_equiv
        AND sga_equiv_operac.estado = 'C'
        AND sga_equiv_resol.nro_resolucion = sga_equiv_operac.nro_resolucion
        AND sga_materias.unidad_academica = d.unidad_academica
        AND sga_materias.materia = d.materia
        AND sga_atrib_mat_plan.unidad_academica = d.unidad_academica
        AND sga_atrib_mat_plan.carrera = d.carrera
        AND sga_atrib_mat_plan.plan    = d.plan
        AND sga_atrib_mat_plan.version = d.version
        AND sga_atrib_mat_plan.materia = d.materia;


  -- Equivalencias Equivalentes. Equivalencias aprobadas otorgadas en otra carrera
  INSERT INTO _temp_materias (forma_aprobacion, unidad_academica, carrera, legajo, materia, materia_nombre, resultado, obligatoria, carga_horaria, fecha, plan, version, expediente)
    SELECT 
            CASE sga_equiv_operac.origen
              WHEN 'E' THEN  3 -- Externa Libre
              WHEN 'S' THEN  4 -- Por Pase
              WHEN 'H' THEN  6 -- Homologada en el Plan de Estudios
              ELSE 5  -- Interna Libre (I, P, V, C)
            END,
            eq.unidad_academica,
            eq.carrera,
            eq.legajo, 
            d.materia,
            NVL(sga_atrib_mat_plan.nombre_materia, sga_materias.nombre),
            d.resultado,
            CASE sga_atrib_mat_plan.obligatoria
              WHEN 'S' THEN 0 -- Obligatoria
              WHEN 'N' THEN 
                  (CASE sga_atrib_mat_plan.tipo_materia
                    WHEN 'O' THEN 2 -- Optativa
                    ELSE 1          -- Electiva
                   END) 
              ELSE 1  -- Electiva
            END, 
            sga_atrib_mat_plan.carga_horaria_tot,
            to_char(eq.fecha, "%Y%m%d"),
            eq.plan,
            eq.version,
            sga_equiv_operac.nro_resolucion
            -- NVL(sga_equiv_resol.nro_expendiente, sga_equiv_operac.nro_resolucion)
          
       FROM 
            sga_equiv_equiv as eq,
            sga_equiv_otorgada as d,
            sga_equiv_operac,
            sga_materias,
            OUTER sga_atrib_mat_plan,
            OUTER sga_equiv_resol
  WHERE d.equivalencia = eq.equivalencia
        AND eq.estado = 'A'
        AND eq.fecha BETWEEN ld_FechaIniAA AND ld_FechaFinAA
        AND d.resultado = 'A'
        AND d.alcance = 'T' -- Equivalencia Total
        AND sga_equiv_operac.aplic_automatica = 'N' 
        AND sga_equiv_operac.origen IN ('E', 'S', 'I', 'H')
        AND d.estado = 'A'
        AND d.rectificado = 'N'
        AND sga_equiv_operac.operacion_equiv = d.operacion_equiv
        AND sga_equiv_operac.estado = 'C'
        AND sga_equiv_resol.nro_resolucion = sga_equiv_operac.nro_resolucion
        AND sga_materias.unidad_academica = d.unidad_academica
        AND sga_materias.materia = d.materia
        AND sga_atrib_mat_plan.unidad_academica = eq.unidad_academica
        AND sga_atrib_mat_plan.carrera = eq.carrera
        AND sga_atrib_mat_plan.plan    = eq.plan
        AND sga_atrib_mat_plan.version = eq.version
        AND sga_atrib_mat_plan.materia = d.materia;


-- Creo un indice por legajo del alumno
CREATE INDEX  _id_temp_materias1 ON _temp_materias (unidad_academica, carrera, legajo, materia);
CREATE INDEX  _id_temp_materias2 ON _temp_materias (unidad_academica, carrera, plan);


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Inserto en tabla definitiva de materias aprobadas por cada titulo araucano a informar.
-- Solo materias que pertenezcan a cada titulo a informar.
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
INSERT INTO int_araunom_rend
	(anio_academico,
	tipo_documento,
	nro_documento,
	cuil_cuit,
	instituc_araucano,
	titulo_araucano,
	fecha,
	resultado,
	materia,
	materia_nombre,
	carga_horaria,
	obligatoriedad,
	forma_aprobacion,
	nro_libro,
	nro_acta,
	folio_fisico,
	expediente,
	unidad_academica, 
	carrera, 
	legajo, 
	plan)

SELECT DISTINCT
	o.anio_academico, 
	o.tipo_documento, 
	o.nro_documento, 
	o.cuil_cuit, 
	o.instituc_araucano, 
	o.titulo_araucano,
	mat.fecha, 
	DECODE(mat.resultado,'A', 1, 'R', 2), 
	mat.materia, 
	mat.materia_nombre, 
	mat.carga_horaria, 
	mat.obligatoria, 
	mat.forma_aprobacion, 
	mat.libro, 
	mat.acta, 
	mat.folio_fisico, 
	mat.expediente,
	o.unidad_academica, 
	o.carrera, 
	o.legajo, 
	o.plan
	FROM
	int_araunom_oferta as o, 
	_temp_materias_tit as mt,
	_temp_materias as mat

	WHERE o.anio_academico = pAnioAcademico

	  -- materias de cada titulo
	  AND mt.unidad_academica = o.unidad_academica
	  AND mt.carrera = o.carrera
	  AND mt.plan     = o.plan
	  AND mt.titulo_araucano  = o.titulo_araucano

	  -- materias realizadas por el alumno que pertenece al titulo a informar
	  AND mat.unidad_academica = o.unidad_academica
	  AND mat.carrera   = o.carrera
	  AND mat.legajo    = o.legajo
	  AND mat.plan       = mt.plan
	  -- AND mat.version   = mt.version
	  AND mat.materia   = mt.materia
	  AND mat.resultado IN ('A','R');

	  
	-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Recupero los alumnos que se informan en el archivo 1 que no tienen registro en el archivo 2.
	-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	-- Alumnos sin materias en el archivo 2 y que no realizaron otra actividad en la institucion (reinscripcion a carrera, inscripciones a cursadas, examenes)
	INSERT INTO _temp_alu_sin_act (unidad_academica, carrera, legajo, titulo_araucano)
	  SELECT unidad_academica, carrera, legajo, titulo_araucano
	    FROM int_araunom_oferta as t
	   WHERE anio_academico = pAnioAcademico
	     AND (carrera || '|' || legajo || '|' || titulo_araucano) NOT IN 
	          (SELECT carrera || '|' || legajo || '|' || titulo_araucano FROM int_araunom_rend WHERE anio_academico = pAnioAcademico);


	-- Alumnos que existen en actas de cursadas						 
	INSERT INTO _temp_alu_con_act (unidad_academica, carrera, legajo, titulo_araucano)
	  SELECT DISTINCT t.unidad_academica, t.carrera, t.legajo, t.titulo_araucano
	    FROM _temp_alu_sin_act as t, sga_det_acta_curs as da, sga_actas_cursado as ac, sga_comisiones as com
	               WHERE da.unidad_academica =  t.unidad_academica
	                 AND da.carrera =  t.carrera
	                 AND da.legajo =  t.legajo
					 AND ac.unidad_academica = da.unidad_academica
					 AND ac.acta = da.acta
					 AND ac.estado = 'C'
	                 AND com.comision = ac.comision
	                 AND com.anio_academico =  pAnioAcademico;

	-- Alumnos que existen en actas de examen. Pueden haber sido agregados al acta sin tener inscripciones...					 
	INSERT INTO _temp_alu_con_act (unidad_academica, carrera, legajo, titulo_araucano)
	  SELECT DISTINCT t.unidad_academica, t.carrera, t.legajo, t.titulo_araucano
	    FROM _temp_alu_sin_act as t, sga_detalle_acta as da, sga_actas_examen as ae
	               WHERE da.unidad_academica =  t.unidad_academica
	                 AND da.carrera =  t.carrera
	                 AND da.legajo =  t.legajo
					 AND ae.unidad_academica = da.unidad_academica
					 AND ae.tipo_acta = da.tipo_acta
	                 AND ae.acta = da.acta
					 AND ae.estado = 'C'
	                 AND ae.anio_academico =  pAnioAcademico
					 AND da.rectificado = 'N'
					 AND da.estado = 'A';
					 
	-- tiene inscripciones a cursadas
	INSERT INTO _temp_alu_con_act (unidad_academica, carrera, legajo, titulo_araucano)
	  SELECT DISTINCT t.unidad_academica, t.carrera, t.legajo, t.titulo_araucano
	    FROM _temp_alu_sin_act as t, sga_insc_cursadas as i, sga_comisiones as com
	               WHERE i.unidad_academica =  t.unidad_academica
	                 AND i.carrera =  t.carrera
	                 AND i.legajo =  t.legajo
	                 AND com.comision = i.comision
	                 AND com.anio_academico =  pAnioAcademico;

	-- tiene equivalencia parcial/total en el año a informar. Homologacion/Externa/Pase/Interna y que no es de aplicacion automatica.
	INSERT INTO _temp_alu_con_act (unidad_academica, carrera, legajo, titulo_araucano)
	  SELECT DISTINCT t.unidad_academica, t.carrera, t.legajo, t.titulo_araucano
	    FROM _temp_alu_sin_act as t, sga_equiv_otorgada as eq, sga_equiv_operac as e
	    WHERE eq.unidad_academica =  t.unidad_academica
	    AND eq.carrera =  t.carrera
	    AND eq.legajo =  t.legajo
	    AND eq.fecha BETWEEN ld_FechaIniAA AND ld_FechaFinAA
	    AND eq.estado = 'A'
	    AND eq.rectificado = 'N'
	    AND eq.alcance IN ('P','T')  -- Equiv Parcial / Equiv Total
	    AND e.operacion_equiv = eq.operacion_equiv
	    AND e.estado = 'C'
	    AND e.aplic_automatica = 'N' 
	    AND e.origen IN ('E', 'S', 'I', 'H');

					 
	-- es ingresante en el año academico que se informa (Nuevo Inscripto)
	INSERT INTO _temp_alu_con_act (unidad_academica, carrera, legajo, titulo_araucano)
	  SELECT t.unidad_academica, t.carrera, t.legajo, t.titulo_araucano
	    FROM _temp_alu_sin_act as t, sga_alumnos as alu, sga_carrera_aspira as ca, sga_periodo_insc as pic
	               WHERE alu.unidad_academica = t.unidad_academica
	                 AND alu.carrera = t.carrera
	                 AND alu.legajo = t.legajo
	                 AND ca.unidad_academica = alu.unidad_academica
	                 AND ca.carrera = alu.carrera
	                 AND ca.nro_inscripcion = alu.nro_inscripcion
	                 AND pic.periodo_inscripcio = ca.periodo_inscripcio
	                 AND pic.anio_academico = pAnioAcademico;
					 
	-- tiene reinscripcion en la carrera
	INSERT INTO _temp_alu_con_act (unidad_academica, carrera, legajo, titulo_araucano)
	  SELECT t.unidad_academica, t.carrera, t.legajo, t.titulo_araucano
	    FROM _temp_alu_sin_act as t, sga_reinscripcion as r
	               WHERE r.anio_academico = pAnioAcademico
	                 AND r.unidad_academica = t.unidad_academica
	                 AND r.carrera = t.carrera
	                 AND r.legajo = t.legajo;

	-- tiene inscripciones a examenes
	INSERT INTO _temp_alu_con_act (unidad_academica, carrera, legajo, titulo_araucano)
	  SELECT DISTINCT t.unidad_academica, t.carrera, t.legajo, t.titulo_araucano
	    FROM _temp_alu_sin_act as t, sga_insc_examen as i, sga_llamados_mesa as llm, sga_prestamos as p
	               WHERE i.unidad_academica = t.unidad_academica
	                 AND i.carrera = t.carrera
	                 AND i.legajo = t.legajo
	                 AND llm.unidad_academica = i.unidad_academica
	                 AND llm.materia = i.materia
	                 AND llm.anio_academico = i.anio_academico
	                 AND llm.turno_examen = i.turno_examen
	                 AND llm.mesa_examen = i.mesa_examen
	                 AND llm.llamado = i.llamado
	                 AND p.prestamo = llm.prestamo
	                 AND p.fecha BETWEEN ld_FechaIniAA AND ld_FechaFinAA;

	-- Borro los alumnos que realizaron alguna actividad en el año academico que considero reinscripto...				  
	DELETE FROM _temp_alu_sin_act
	   WHERE (unidad_academica || '|' || carrera  || '|' || legajo || '|' || titulo_araucano) IN 
	         (SELECT unidad_academica || '|' || carrera  || '|' || legajo || '|' || titulo_araucano FROM _temp_alu_con_act);
						 
						 
	-- Borro del archivo 1 los alumnos que no hicieron nada en el año academico a informar..
	DELETE FROM int_araunom_oferta
	  WHERE anio_academico = pAnioAcademico
	    AND (unidad_academica || '|' || carrera  || '|' || legajo || '|' || titulo_araucano) IN 
	         (SELECT unidad_academica || '|' || carrera  || '|' || legajo || '|' || titulo_araucano FROM _temp_alu_sin_act);
	
	
	-- Borro de la tabla del archivo 0, los alumnos que no se van a informar por ningun titulo araucano en el archivo 1.
	DELETE FROM int_araunom_alu
	      WHERE anio_academico = pAnioAcademico
	        AND (tipo_documento || '|' || nro_documento) NOT IN (SELECT tipo_documento || '|' || nro_documento FROM int_araunom_oferta WHERE anio_academico = pAnioAcademico);
	
  -- Borro tablas temporales
  DROP TABLE _temp_titulos;
  DROP TABLE _temp_alumnos;
  DROP TABLE _temp_personas;  
  DROP TABLE _temp_materias;  
  DROP TABLE _temp_materias_tit;
  DROP TABLE _temp_alu_sin_act;
  DROP TABLE _temp_alu_con_act;

  
  RETURN iCantAlumnos, 'Generación de información nominal de alumnos finalizada...';

END;
END PROCEDURE;         
-- ++++++++++++++++++++++++++++++ Fin Procedure sp_arau_nominal +++++++++++++++++++++++++++++

GRANT EXECUTE ON sp_arau_nominal TO public;
