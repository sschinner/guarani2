-- ******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.8.0
-- Procedure sp_int_arau_datnip
-- 
-- proceso que recupera la información censal necesaria de los alumnos para 
-- el proceso de Araucano cuadro 15
-- Nivel de instruccion de los padres
-- Recibe: UA, Carrera, Legajo, Anio Académico informado
-- Retorna: id de nivel de instruccion del padre y de la madre
--1: No hizo estudios
--2: Escuela Primaria Incompleta
--3: Escuela Primaria Completa
--4: Secundario Incompleto
--5: Secundario Completo
--6: Universitario o Superior Incompleto
--7: Universitario o Superior Completo
--8: Posgrado
--9: No Sabe
--10 No Dispone Información

-- ******************************************************************************
-- execute procedure sp_int_arau_datnip ('ECON', '1', '20821', '2009');
-- DROP PROCEDURE sp_int_arau_datnip;
CREATE PROCEDURE sp_int_arau_datnip( pUA      LIKE dba.sga_alumnos.unidad_academica,
                                     pCarrera LIKE dba.sga_alumnos.carrera,
                                     pLegajo  LIKE dba.sga_alumnos.legajo,
                                     pAnio    LIKE dba.sga_anio_academico.anio_academico )
       RETURNING INTEGER, INTEGER;


-- Variables Internas.
DEFINE i_Retorno       INTEGER;

DEFINE i_ult_est_cur_padre INTEGER;
DEFINE i_ult_est_cur_madre INTEGER;
DEFINE vc_FechaDC      DATE;
DEFINE vc_FechaAct     DATE;
DEFINE vc_NroInsc      LIKE sga_personas.nro_inscripcion;
DEFINE vc_FechaIni     LIKE sga_anio_academico.fecha_inicio;
DEFINE vc_Fechafin     LIKE sga_anio_academico.fecha_inicio;
DEFINE vc_FechaReins   LIKE sga_anio_academico.fecha_inicio;

-- VARIABLES PARA EL MANEJO DE EXCEPCIONES.
DEFINE SQLErr               INTEGER;
DEFINE ISAMError            INTEGER;
DEFINE errorInfo            VARCHAR(76);


-- SI HAY ALGÚN ERROR.
ON EXCEPTION SET SQLErr, ISAMError, errorInfo
   RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;


BEGIN

     -- SETEO NO TENGO INFORMACION DEL ALUMNO.
   LET i_Retorno = 0;
   LET i_ult_est_cur_padre = 0;
   LET i_ult_est_cur_madre = 0;
   
   -- Averiguo ID de la Persona.
   SELECT sga_personas.nro_inscripcion
     INTO vc_NroInsc
     FROM sga_personas,
          sga_alumnos
    WHERE sga_alumnos.unidad_academica = pUA
      AND sga_alumnos.carrera = pCarrera
      AND sga_alumnos.legajo = pLegajo
      AND sga_personas.unidad_academica = sga_alumnos.unidad_academica
      AND sga_personas.nro_inscripcion  = sga_alumnos.nro_inscripcion;

       LET i_Retorno = 0;
   
   -- Averiguo ID de la Persona.
   SELECT sga_personas.nro_inscripcion
     INTO vc_NroInsc
     FROM sga_personas,
          sga_alumnos
    WHERE sga_alumnos.unidad_academica = pUA
      AND sga_alumnos.carrera = pCarrera
      AND sga_alumnos.legajo = pLegajo
      AND sga_personas.unidad_academica = sga_alumnos.unidad_academica
      AND sga_personas.nro_inscripcion  = sga_alumnos.nro_inscripcion;
   
   
   -- Averiguo la Fecha de Inicio y Fin del Año Académico.
   SELECT sga_anio_academico.fecha_inicio,
          sga_anio_academico.fecha_fin
     INTO vc_FechaIni,
          vc_FechaFin
     FROM sga_anio_academico
    WHERE anio_academico = pAnio;
   
   
   -- Averiguo si existe un Dato Censal que corresponda al Año Académico que se va a informar.
   SELECT MAX(sga_datos_censales.fecha_relevamiento),
          MAX(sga_datos_censales.fecha_actualiz)
     INTO vc_FechaDC,
          vc_FechaAct
     FROM sga_datos_censales
    WHERE sga_datos_censales.unidad_academica = pUA
      AND sga_datos_censales.nro_inscripcion  = vc_NroInsc
      AND sga_datos_censales.fecha_actualiz BETWEEN vc_FechaIni AND vc_FechaFin;
   
   
   -- Si no existe, busco el dato censal del alumno cuando se reinscribio
   -- (que pudo haber quedado fuera del año académico que se va a informar)
   IF vc_FechaDC IS NULL THEN
      
      SELECT sga_reinscripcion.fecha_reinscrip
        INTO vc_FechaReins
        FROM sga_reinscripcion
       WHERE sga_reinscripcion.unidad_academica = pUA 
         AND sga_reinscripcion.carrera          = pCarrera
         AND sga_reinscripcion.legajo           = pLegajo
         AND sga_reinscripcion.anio_academico   = pAnio;
      
      -- El alumno no se reinscribió en el año académico informado.
      IF vc_FechaReins IS NULL THEN
         
         -- INFORMO QUE NO TENGO INFORMACION LABORAL DEL ALUMNO.
         LET i_Retorno = 10;
         
      -- Busco el Dato Censal correspondiente a la reinscripción.
      ELSE
         
         SELECT sga_datos_censales.fecha_relevamiento,
                sga_datos_censales.fecha_actualiz
           INTO vc_FechaDC,
                vc_FechaAct
           FROM sga_datos_censales
          WHERE sga_datos_censales.unidad_academica = pUA
            AND sga_datos_censales.nro_inscripcion  = vc_NroInsc
            AND ((sga_datos_censales.fecha_relevamiento = vc_FechaReins)); --OR (sga_datos_censales.fecha_actualiz = vc_FechaReins));
         
      END IF
   END IF
   
   -- Busco la información de las horas trabajadas del alumno.
   IF vc_FechaDC IS NOT NULL THEN
      
      -- Averiguo ultimos estudios padre y madre
      SELECT DECODE(ult_est_cur_padre, 8, 6, 9, 7, 10, 6, 11, 7, 12, 8, 13, 9, ult_est_cur_padre)
			, DECODE(ult_est_cur_madre, 8, 6, 9, 7, 10, 6, 11, 7, 12, 8, 13, 9, ult_est_cur_madre)
        INTO i_ult_est_cur_padre, i_ult_est_cur_madre
        FROM sga_datos_censales
       WHERE sga_datos_censales.unidad_academica = pUA
         AND sga_datos_censales.nro_inscripcion  = vc_NroInsc
         AND sga_datos_censales.fecha_relevamiento = vc_FechaDC;
   
   END IF
   
   IF (i_ult_est_cur_padre = 0) OR (i_ult_est_cur_padre IS NULL) THEN
      LET i_ult_est_cur_padre = 10;
   END IF;
   
   IF (i_ult_est_cur_madre = 0) OR (i_ult_est_cur_madre IS NULL) THEN
      LET i_ult_est_cur_madre = 10;
   END IF;
   
   RETURN i_ult_est_cur_padre, i_ult_est_cur_madre;


END;
END PROCEDURE;

-- ************************** fin procedure sp_int_arau_datnip **************************