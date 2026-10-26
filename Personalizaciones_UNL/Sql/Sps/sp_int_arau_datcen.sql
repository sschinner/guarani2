-- ******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.05.0
-- Procedure sp_int_arau_datcen
-- 
-- proceso que recupera la información censal necesaria de los alumnos para 
-- el proceso de Araucano.
-- 
-- Recibe: UA, Carrera, Legajo, Anio Académico informado
-- Retorna: Horas Trabajadas.
-- ******************************************************************************
-- execute procedure sp_int_arau_datcen ('03', 'J0003', '010-3', '2004');
-- DROP PROCEDURE sp_int_arau_datcen;
CREATE PROCEDURE sp_int_arau_datcen( pUA      LIKE dba.sga_alumnos.unidad_academica,
                                     pCarrera LIKE dba.sga_alumnos.carrera,
                                     pLegajo  LIKE dba.sga_alumnos.legajo,
                                     pAnio    LIKE dba.sga_anio_academico.anio_academico )
       RETURNING VARCHAR(4);


-- Variables Internas.
DEFINE vc_HTrab        VARCHAR(4);
DEFINE vc_ExisteTrab   VARCHAR(4);
DEFINE vc_Retorno      VARCHAR(4);
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

   -- SETEO NO TENGO INFORMACION LABORAL DEL ALUMNO.
   LET vc_Retorno = 'NDI';
   
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
         LET vc_Retorno = 'NDI';
         
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
      
      -- Averiguo si trabaja.
      SELECT NVL(DECODE(sga_datos_cen_aux.existe_trab_alum, 1, 'T', 2, 'NT', 3, 'NT'), 'NDI')
        INTO vc_ExisteTrab
        FROM sga_datos_cen_aux
       WHERE sga_datos_cen_aux.unidad_academica = pUA
         AND sga_datos_cen_aux.nro_inscripcion  = vc_NroInsc
         AND sga_datos_cen_aux.fecha_relevamiento = vc_FechaDC;
      
      IF vc_ExisteTrab IS NULL THEN
         LET vc_HTrab = 'NDI';
      END IF;
         
      -- Si trabaja, busco si cargo la cantidad de horas.
      IF vc_ExisteTrab = 'T' THEN
         
         SELECT NVL(DECODE(sga_datos_censales.hora_sem_trab_alum, 1, '20', 2, '20', 3, '2035', 4, '+35' ), 'TNDI')
           INTO vc_HTrab
           FROM sga_datos_censales
          WHERE sga_datos_censales.unidad_academica = pUA
            AND sga_datos_censales.nro_inscripcion  = vc_NroInsc
            AND sga_datos_censales.fecha_relevamiento = vc_FechaDC;
         
         IF vc_HTrab IS NULL THEN
            LET vc_HTrab = 'NDI';
         END IF;
         
         LET vc_Retorno = vc_HTrab;
      ELSE
         LET vc_Retorno = vc_ExisteTrab;
      END IF
   
   END IF
   
   IF vc_Retorno IS NULL THEN
      LET vc_Retorno = 'NDI';
   END IF;
   
   RETURN vc_Retorno;
   
END;
END PROCEDURE;
-- ********************* FIN DEL PROCESO sp_int_arau_datcen *********************


