-- ******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.02.0
-- Procedure sp_int_arau_datequ
-- 
-- Proceso que recupera la información de historia académica necesaria 
-- de los alumnos para el proceso de Araucano.

-- Si la carrera tiene un ciclo comun busco la forma de ingreso al ciclo comun
-- 
-- Recibe: UA, Carrera, Legajo, Año académico
-- Retorna: 'S' si viene por Equivalencias o 'N' si es Nuevo en la UA.
-- ******************************************************************************
-- DROP PROCEDURE sp_int_arau_datequ;
CREATE PROCEDURE sp_int_arau_datequ( pUA      LIKE dba.sga_alumnos.unidad_academica,
                                     pCarrera LIKE dba.sga_alumnos.carrera,
                                     pLegajo  LIKE dba.sga_alumnos.legajo,
                                     pAnio    LIKE dba.sga_anio_academico.anio_academico )
       RETURNING CHAR(1);

-- Variables Internas.
DEFINE vc_Cant      INTEGER;
DEFINE vc_FechaIni  DATE;
DEFINE vc_FechaFin  DATE;
DEFINE vc_Retorno   CHAR(1);
DEFINE vcCarrera like sga_alumnos.carrera;
DEFINE vcLegajo like sga_alumnos.legajo;
DEFINE vc_NroInsc like sga_alumnos.nro_inscripcion;


-- Variables para el manejo de excepciones.
DEFINE SQLErr             integer;
DEFINE ISAMError          integer;
DEFINE errorInfo          varchar(76);

-- Si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo
   -- Borra la tabla temporal
   BEGIN
      -- Si no existía, continúa
      ON EXCEPTION IN  (-206)
      END EXCEPTION WITH RESUME;
      -- Borra la tabla temporal
      DROP TABLE temp_hist_acad;
   END
   
   RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;


BEGIN
   
   -- Creo la tabla temporal para la historia académica del alumno.
   CREATE TEMP TABLE temp_hist_acad ( 
               materia             varchar(5),
               fecha               date,
               resultado           char(1),
               forma_aprobacion    varchar(30) );


   -- ID de la Persona.
   SELECT sga_personas.nro_inscripcion
     INTO vc_NroInsc
     FROM sga_personas,
          sga_alumnos
    WHERE sga_alumnos.unidad_academica = pUA
      AND sga_alumnos.carrera = pCarrera
      AND sga_alumnos.legajo = pLegajo
      AND sga_personas.unidad_academica = sga_alumnos.unidad_academica
      AND sga_personas.nro_inscripcion  = sga_alumnos.nro_inscripcion;

--------------------------------------------------------------------------------------------------------------------------
--- Si la carrera tiene ciclo comun, tengo que buscar el ingreso al ciclo comun

IF EXISTS (SELECT '' 
		FROM int_arau_car_cc
		WHERE unidad_academica = pUA
			AND carrera = pCarrera) THEN

	SELECT carrera_ciclocomun
		INTO vcCarrera
		FROM int_arau_car_cc
		WHERE unidad_academica = pUA
			AND carrera = pCarrera;

	IF vcCarrera IS NOT NULL THEN

		LET pCarrera = vcCarrera;

	END IF

	SELECT legajo
		INTO vcLegajo
		FROM sga_alumnos
		WHERE unidad_academica=pUA
			AND carrera = vcCarrera
			AND nro_inscripcion = vc_NroInsc;

	IF vcLegajo IS NOT NULL THEN

		LET pLegajo = vcLegajo;
	END IF
		
END IF; 
--------------------------------------------------------------------------------------------------------------------------
   -- Carga la historia académica del alumno en la tabla temporal
   INSERT INTO temp_hist_acad
   SELECT materia,
          fecha,
          resultado,
          forma_aprobacion
     FROM sga_hist_acade_aux
    WHERE unidad_academica = pUA
      AND carrera = pCarrera
      AND legajo = pLegajo
      AND materia not in (select distinct materia from u820_cursos_ing);
   
   -- Averiguo la fecha del Calendario.
   SELECT sga_anio_academico.fecha_inicio,
          sga_anio_academico.fecha_fin
     INTO vc_FechaIni,
          vc_FechaFin
     FROM sga_anio_academico
    WHERE sga_anio_academico.anio_academico = pAnio;
   
   
   -- Averiguo si el alumno tiene materias por equivalencias o comunes.
   SELECT COUNT(*)
     INTO vc_Cant
     FROM temp_hist_acad
    WHERE fecha BETWEEN vc_FechaIni AND vc_FechaFin
      AND forma_aprobacion IN ( 'Equivalencia', 'Equivalencia equivalente', 'Examen equivalente', 'Promoción en otra carrera', 'Homologada' );
   
   IF vc_Cant > 0 THEN
      LET vc_Retorno = 'S';
   ELSE
      LET vc_Retorno = 'N';
   END IF;
   
   -- Elimino la tabla temporal.
   DROP TABLE temp_hist_acad;
   
   -- Devuelvo el resultado
   RETURN vc_Retorno;
   
END;
END PROCEDURE;
-- ********************* FIN DEL PROCESO sp_int_arau_datequ *********************

