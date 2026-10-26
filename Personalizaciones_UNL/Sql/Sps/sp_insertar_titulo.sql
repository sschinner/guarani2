CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_insertar_titulo') THEN
		DROP PROCEDURE sp_insertar_titulo;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Stored Procedure: sp_insertar_titulo
-- 
-- Ultima version de modificacion: 2.0.0, 2.01.0, 2.01.1, 2.03.0, 2.04.1, 2.05.0
--
-- Este procedure inserta un registro en sga_titulos_otorg y en XXXXX (tabla de orientaciones por titulo otorgado) si el alumno es egresado.
-- Si no lo es retorna las materias que le faltan para terminar.
--
-- el parametro pRespuesta se usa para acotar esta salida.  si solo se desea saber si egresó o no, se envia 'P' (parcial) y el proceso solo
-- retorna una de las materias que debe.
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE PROCEDURE "dba".sp_insertar_titulo (
	pUA like dba.sga_alumnos.unidad_academica, 
	pCarrera like dba.sga_alumnos.carrera, 
	pLegajo like dba.sga_alumnos.legajo, 
	pTitulo like dba.sga_titulos_otorg.titulo , 
	pNroExpediente like dba.sga_titulos_otorg.nro_expediente,
	pRespuesta char (1))
  RETURNING VARCHAR(5),    -- Titulo
            VARCHAR(5),    -- Plan
            VARCHAR(5),    -- Version
            VARCHAR(5),    -- Orientacion
            VARCHAR(5),    -- Ciclo
            VARCHAR(5),    -- Materia
            FLOAT;         -- Puntos

DEFINE iStatus             SMALLINT;
DEFINE vcMsg                 VARCHAR(255);

DEFINE vcNroInscripcion      LIKE sga_titulos_otorg.nro_inscripcion;
DEFINE vcPlan                VARCHAR(5);
DEFINE vcVersion             VARCHAR(5);
DEFINE vcOrientacion         VARCHAR(5);
DEFINE vcOrientBasica        VARCHAR(5);
DEFINE vcOrientAlumno        VARCHAR(5);
DEFINE vcOrientAdicional     VARCHAR(5);
DEFINE vcCiclo               VARCHAR(5);
DEFINE vcMateria             VARCHAR(5);
DEFINE fPuntos               FLOAT;
DEFINE fPromGral             LIKE sga_titulos_otorg.prom_general;
DEFINE fPromSinAplazos       LIKE sga_titulos_otorg.prom_sin_aplazos;

DEFINE iTieneOrient          INTEGER;	-- Indica si tiene orientaciones o solo la básica.
DEFINE iEsEgresadoOrient     INTEGER;
DEFINE iEsEgresado           INTEGER;
DEFINE iFEgrOrientBasica     INTEGER;
DEFINE iOrientAprobada       INTEGER;
DEFINE iCantMaterias        INTEGER;

DEFINE dFechaEgreso          DATE;
DEFINE dfecha                DATE;
DEFINE dFechaEgresoFinal     DATE;
DEFINE vcEgreso              LIKE sga_titulos_plan.calculo_egreso;

DEFINE cPromedioResolucion char(1);

DEFINE sql_err              INTEGER;
DEFINE isam_err             INTEGER;
DEFINE error_info           VARCHAR(70);


BEGIN

-- Selecciono el ID de la persona.
SELECT nro_inscripcion
INTO vcNroInscripcion
FROM sga_alumnos
WHERE unidad_academica = pUA
AND carrera = pCarrera
AND legajo = pLegajo;

LET vcOrientBasica = '0';
LET iFEgrOrientBasica = 0; -- Si se calculo la fecha de ultima materia de la orientacion basica.
LET iTieneOrient = 0;      -- Por defecto no tiene orientaciones.
LET iEsEgresado = 1;
LET iEsEgresadoOrient = 0; -- No tiene orientaciones aprobadas hasta que demuestre lo contrario.
LET dFechaEgresoFinal = to_date("01011900","%d%m%Y");
LET dFecha = TODAY;
LET cPromedioResolucion = NULL;   
   -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
   -- Creo una tabla temporal para guardar las materias que debe.
   -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
   BEGIN
      ON EXCEPTION IN (-206)
        -- Tabla no existe continuo el proceso. Es por el delete de la
        -- tabla temporal	
      END EXCEPTION WITH RESUME;

      DROP TABLE temp_debe_materias;
      -- Borro la tabla temporal	
      DROP TABLE temp_i_titulo;
   END;
   
   -- Tabla de materias que debe el alumno
   CREATE TEMP TABLE temp_debe_materias (orientacion varchar(5), ciclo varchar(5), materia varchar(5), puntos float) WITH NO LOG;

   -- Tabla de las orientaciones por las que egresa el alumno.
   -- Solo se utilizara el campo orientacion.
   CREATE TEMP TABLE temp_i_titulo (
		orientacion	varchar(5), 
		prom_general	float, 
		prom_sin_aplazos	float, 
		fecha_egreso	date
	) WITH NO LOG;
   
   -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
   -- Obtengo el plan y version del alumno
   -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
   EXECUTE PROCEDURE sp_plan_de_alumno( pUA, pCarrera, pLegajo, dFecha) INTO vcPlan, vcVersion;
   
   -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
   -- Obtengo el Modo de Egreso del Título
   -----------------------------------------------------------------------------------------------------------------------------------------------------------------------  
   SELECT calculo_egreso
     INTO vcEgreso
     FROM sga_titulos_plan 
    WHERE unidad_academica = pUA 
      AND carrera = pCarrera
      AND plan = vcPlan
      AND titulo = pTitulo;
   
   -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
   -- Verifico que tenga las orientaciones aprobadas, primero la orientacion básica y luego las otras.
   -----------------------------------------------------------------------------------------------------------------------------------------------------------------------  
   LET dFechaEgresoFinal = to_date('01011900','%d%m%Y'); 
   
   LET iEsEgresado = 0;
   
   BEGIN
      ON EXCEPTION SET   sql_err, isam_err, error_info
         -- error
--         -- Se agrego esta excepcion para que continue si encontro algun problema!!!	
--         -- Poruqe si da error el titulo por orientacion no seleccionada, devuelve un -746	
--      END EXCEPTION WITH RESUME;   
	raise exception sql_err, isam_err, error_info;
      END EXCEPTION ;   
      
      -- Devuelve todas las orientaciones del plan ( Retorna la Orientacion Básica si el plan no tiene otras orientaciones)
      FOREACH EXECUTE PROCEDURE sp_titulo_aprobado(pUa, pCarrera, pLegajo, pTitulo ) INTO vcOrientacion, vcPlan, vcVersion 
         
         LET iEsEgresado = 1;
         -- Tomo esta fecha de egreso, despues la cambio si hace falta.
         EXECUTE PROCEDURE sp_fecha_egreso(pUA, pCarrera, pLegajo, pTitulo, vcPlan, vcVersion, vcOrientacion) INTO dFechaEgreso ;
         IF vcOrientacion = '0' THEN
            LET iFEgrOrientBasica = 1; 
         END IF;
         
         --La fecha de egreso es la menos de todas las orientaciones
         IF dFechaEgreso > dFechaEgresoFinal THEN
            LET dFechaEgresoFinal = dFechaEgreso;
         END IF;
         
         IF iEsEgresadoOrient = 0 THEN  -- No esta cargado el registro en titulos otorgados.
	-- Inserto un registro para el título otorgado, paso de no egresado a egresado. (solo lo hago una vez para todas las orientaciones)
	-- Hago esto para poder insertar un registro en las orientaciones y que no pinche la foreign key
	LET iEsEgresadoOrient = 1; -- Para que no cargue otra vez el titulo otorgado.
         END IF;
         
	-- Agrego la Orientacion por la que egresa el alumno a la tabla temporal         
	INSERT INTO temp_i_titulo (orientacion, prom_general, prom_sin_aplazos, fecha_egreso) VALUES (vcOrientacion, NULL , NULL, dFechaEgreso);
	
      END FOREACH;  -- Orientaciones Aprobadas por el Alumno.
   
   END; -- FIN DEL BEGIN DEL CONTROL DE EXCEPCION.

   
   IF iEsEgresado  = 1 THEN
       -- ++++++++++++++++++++++++++++++++++++++++++++++++++++
       -- ES EGRESADO
       -- ++++++++++++++++++++++++++++++++++++++++++++++++++++

	-- U820 
	-- Calculo los promedios:
	EXECUTE PROCEDURE sp820_prom_alu_res ( pUA, pCarrera, pLegajo, 'S' ) INTO fPromGral, cPromedioResolucion;
	EXECUTE PROCEDURE sp820_prom_alu_res ( pUA, pCarrera, pLegajo, 'N' ) INTO fPromSinAplazos, cPromedioResolucion;
	-- U820 
      
      -- Calculo la fecha de la ultima materia de la Orientación básica (si el plan tiene orientaciones)
      -- Podria ser que el alumno egresa por una orientación x, pero la ultima materia rendida es de la orientacion básica.
      -- No se calcula si egresa por la orientacion básica, ya que esto se calculo antes.
      IF iFEgrOrientBasica <> 1 THEN
         -- (El sp_titulo_aprobado no devuelve la orientacion basica si el plan tiene otras orientaciones)
         EXECUTE PROCEDURE sp_fecha_egreso(pUA, pCarrera, pLegajo, pTitulo, vcPlan, vcVersion, vcOrientBasica) INTO dFechaEgreso ;
         IF dFechaEgreso > dFechaEgresoFinal THEN
            LET dFechaEgresoFinal = dFechaEgreso;
         END IF;
      END IF;
      
   -- ++++++++++++++++++++++++++++++++++++++++++++++
   -- Inserto el registro en el titulo otorgado y las orientaciones.
   -- ++++++++++++++++++++++++++++++++++++++++++++++
   EXECUTE PROCEDURE sp_i_titulos_otorg(pUA, pCarrera, pLegajo,  pTitulo, vcPlan, vcVersion, pNroExpediente, dFechaEgresoFinal, fPromGral, fPromSinAplazos)  INTO iStatus, vcMsg;
   IF iStatus = -1 THEN
	-- Error
	raise exception -746,0, vcMsg;
   END IF;

    -- Inserto las Orientaciones por la cual egreso el alumno.
    INSERT INTO sga_orie_tit_otorg (unidad_academica, nro_inscripcion, carrera, plan,  titulo, orientacion)
	SELECT pUA, vcNroInscripcion, pCarrera, vcPlan, pTitulo, orientacion
	FROM temp_i_titulo;

   -- Borro la tabla temporal	
   DROP TABLE temp_i_titulo;
	
   ELSE
      -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++      
      -- NO ES EGRESADO
      -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++      
      IF vcegreso <> 'AM' THEN
         -- Dvuelve al menos una fila para indicar que el alumno no cumple con el título
         RETURN ptitulo, vcPlan, vcVersion, null, null, null, 0 ;
      ELSE
         
         -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
         -- Creo una tabla temporal para guardar las materias aprobadas por el alumno
         -- Esta tabla es usada por los procedures que se llaman a continuacion.
         -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
         BEGIN
            ON EXCEPTION IN (-206)
            -- Tabla no existe continuo el proceso. Es por el delete de la tabla temporal	
            END EXCEPTION WITH RESUME;
            DROP TABLE tmp_ha_titulos;
         END;
         
         CREATE TEMP TABLE tmp_ha_titulos (materia varchar(5)) WITH NO LOG;
         
         INSERT INTO tmp_ha_titulos (materia)
              SELECT materia
                FROM vw_hist_academica
               WHERE unidad_academica = pUA
                 AND carrera = pCarrera  
                 AND legajo  = pLegajo
                 AND resultado = 'A'
                 AND fecha <= dFecha;
         
         -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
         -- Recorro las Orientaciones del Título a evaluar.
         -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
         FOREACH SELECT orientacion INTO	vcOrientacion
          FROM sga_orientaciones
         WHERE unidad_academica = pUA
           AND carrera = pCarrera
           AND plan = vcPlan
           AND titulo = pTitulo
            
            FOREACH EXECUTE PROCEDURE dba.sp_orient_aprobada( pUA, pCarrera, pLegajo, pTitulo, vcPlan, vcVersion ,vcOrientacion , vcEgreso, pRespuesta ) 
               INTO vcOrientAdicional, vcCiclo, vcMateria,  fPuntos
               
               RETURN ptitulo, vcPlan, vcVersion, vcOrientacion, vcCiclo, vcMateria, fpuntos WITH RESUME;
               
            END FOREACH; -- Orientaciones aprobadas
         END FOREACH; -- Todas las Orientaciones del titulo plan
         
         BEGIN
            ON EXCEPTION IN (-206)
               -- Tabla no existe continuo el proceso. Es por el delete de la tabla temporal	
            END EXCEPTION WITH RESUME;
            DROP TABLE tmp_ha_titulos;
         END;
         
      END IF;
      
   END IF;
   
   BEGIN
      ON EXCEPTION IN (-206)
         -- Tabla no existe continuo el proceso. Es por el delete de la
         -- tabla temporal	
      END EXCEPTION WITH RESUME;
      DROP TABLE temp_debe_materias;
   END;

END;
END PROCEDURE;
-- +++++++++++++++++++++++ Fin procedure sp_insertar_titulo +++++++++++++++++++++++++++++++++
-- *****************************************************************************
revoke execute on "dba".sp_insertar_titulo from public;
grant execute on "dba".sp_insertar_titulo to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_insertar_titulo to internet; -- Rol de usuario de Internet
