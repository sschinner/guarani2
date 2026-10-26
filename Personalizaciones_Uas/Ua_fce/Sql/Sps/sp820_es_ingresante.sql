
-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.0.0
-- Ultima modificacion: 2.01.0
-- Procedure sp_es_ingresante
-- 
-- Controla si el alumno es ingresante en la carrera.
-- SE TOMA EL AÑO CALENDARIO Y NO EL ACADEMICO, DE ESTA FORMA ESTA EN CONGRUENCIA CON LO EL CONTROL ctr820_reinscrAlumno 
-- *****************************************************************************
-- DROP PROCEDURE sp820_es_ingresante;
CREATE PROCEDURE sp820_es_ingresante(
	pUnidadAcademica  LIKE sga_alumnos.unidad_academica,
	pCarrera          LIKE sga_alumnos.carrera,
	pLegajo           LIKE sga_alumnos.legajo,
	pAnio            LIKE sga_anio_academico.anio_academico)

	RETURNING char(1);  -- S - Es Ingresante / N - No es ingresante en la carrera.

-- vars para la respuesta
DEFINE vcRtn             char(1);

-- vars para el manejo de excepciones
DEFINE sql_err, isam_err            integer;
DEFINE error_info          varchar(76);

-- vars locales
DEFINE v_anio              like sga_anio_academico.anio_academico;
DEFINE cnt         integer;
DEFINE vcNroInscripcion	LIKE sga_personas.nro_inscripcion;

-- blk de excepciones
ON EXCEPTION SET sql_err, isam_err, error_info
   RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;

BEGIN
   
   -- OK
   LET vcRtn = 'N'; -- no es Ingresante
   
   -- Busca el año académico actual
  -- SELECT max(anio_academico)
   --  INTO v_anio
   --  FROM sga_anio_academico
   -- WHERE TODAY BETWEEN fecha_inicio AND fecha_fin;
   
   -- Verifico si la persona es o no INgresante en la Carrera "pCarrera"
   SELECT nro_inscripcion
     INTO vcNroInscripcion
     FROM sga_alumnos
    WHERE unidad_academica = pUnidadAcademica
      AND carrera = pCarrera
      AND legajo = pLegajo;
   
   LET cnt = 0;

   IF (pCarrera <> '0201' AND pCarrera <> '0202' AND pCarrera <> '0203') THEN
	   SELECT COUNT(*) 
	     INTO cnt
	     FROM sga_periodo_insc,
		  sga_carrera_aspira,
		  sga_situacion_asp
	    WHERE sga_periodo_insc.anio_academico = panio
	      AND sga_carrera_aspira.unidad_academica   = pUnidadAcademica
	      AND sga_carrera_aspira.carrera	        = pCarrera
	      AND sga_carrera_aspira.nro_inscripcion    = vcNroInscripcion
	      AND sga_carrera_aspira.periodo_inscripcio = sga_periodo_insc.periodo_inscripcio
	      AND sga_situacion_asp.situacion_asp       = sga_carrera_aspira.situacion_asp
	      AND sga_situacion_asp.resultado_asp       in ('I','A');
   END IF;
	
   IF cnt > 0 THEN
      -- La persona es ingresante en la carrera.
      LET vcRtn = 'S';
   END IF;

  RETURN vcRtn;
   
END;
END PROCEDURE;
-- ************************* Procedure sp_es_ingresante ****************************

