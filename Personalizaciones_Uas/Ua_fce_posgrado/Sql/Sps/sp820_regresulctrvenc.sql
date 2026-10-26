DROP PROCEDURE "dba".sp820_regresulctrvenc;
CREATE PROCEDURE "dba".sp820_regresulctrvenc(

	pUnidadAcademica LIKE sga_alumnos.unidad_academica,

	pCarrera LIKE sga_alumnos.carrera)



	RETURNING varchar(5),        -- sga_alumnos.unidad_academica

	          varchar(5),        -- sga_alumnos.carrera

	          varchar(15),       -- sga_alumnos.legajo

	          integer,

	          integer,           -- sga_anios_academicos.anio_academico

	          date,              -- sga_perdidas_regul.fecha_baja

	          varchar(15),       -- sga_perdidas_regul.nro_resol_baja

	          date,              -- sga_perdidas_regul.fecha_rehab

	          varchar(15),       -- sga_perdidas_regul.nro_resol_rehab

	          date,              -- sga_perdidas_regul.fecha_vencim_rehab

	          varchar(10),       -- sga_personas.nro_inscripcion

	          varchar(30),       -- sga_personas.apellido

	          varchar(30),       -- sga_personas.nombres

	          varchar(30);       -- sga_carreras.nombre_reducido



	-- Variables locales

	DEFINE vUnidadAcademica   LIKE sga_alumnos.unidad_academica;

	DEFINE vCarrera           LIKE sga_alumnos.carrera;

	DEFINE vLegajo            LIKE sga_alumnos.legajo;

	DEFINE vAnioAcademico     LIKE sga_perdidas_regul.anio_academico;

	DEFINE vFechaBaja         LIKE sga_perdidas_regul.fecha_baja;

	DEFINE vNroResolBaja      LIKE sga_perdidas_regul.nro_resol_baja;

	DEFINE vFechaRehab        LIKE sga_perdidas_regul.fecha_rehab;

	DEFINE vNroResolRehab     LIKE sga_perdidas_regul.nro_resol_rehab;

	DEFINE vFechaVencimRehab  LIKE sga_perdidas_regul.fecha_vencim_rehab;

	DEFINE vNroInscripcion    LIKE sga_personas.nro_inscripcion;

	DEFINE vApellido          LIKE sga_personas.apellido;

	DEFINE vNombres           LIKE sga_personas.nombres;

	DEFINE vCarNomRed         LIKE sga_carreras.nombre_reducido;

	DEFINE vResultado         integer;



	-- Variables para el manejo de excepciones

	DEFINE SQLErr             integer;

	DEFINE ISAMError          integer;

	DEFINE errorInfo          varchar(76);



	-- Si hay algun error

	ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        

		RAISE EXCEPTION SQLErr, ISAMError, errorInfo;

	END EXCEPTION;

BEGIN

	-- Busca el nombre de la carrera

	SELECT nombre_reducido

	  INTO vCarNomRed

	  FROM sga_carreras

	 WHERE carrera = pCarrera;
                 
                 LET vResultado = 0;


	FOREACH

		-- Lee los alumnos de la carrera a los que debe controlar

		EXECUTE PROCEDURE b820_regControlarVenc(pUnidadAcademica, pCarrera)

		   INTO vUnidadAcademica,

		        vCarrera,

		        vLegajo,

		        vResultado

                                 IF vResultado = 1 THEN ------------------------------ SOLO DEVUELVE LOS QUE TIENEN VENCIDA LA FINALIZACION DE LA PRORROGA

		SELECT sga_perdidas_regul.anio_academico,

		       sga_perdidas_regul.fecha_baja,

		       sga_perdidas_regul.nro_resol_baja,

		       sga_perdidas_regul.fecha_rehab,

		       sga_perdidas_regul.nro_resol_rehab,

		       sga_perdidas_regul.fecha_vencim_rehab,

		       sga_personas.nro_inscripcion,

		       sga_personas.apellido,

		       sga_personas.nombres

		  INTO vAnioAcademico,

		       vFechaBaja,

		       vNroResolBaja,

		       vFechaRehab,

		       vNroResolRehab,

		       vFechaVencimRehab,

		       vNroInscripcion,

		       vApellido,

		       vNombres

		  FROM sga_perdidas_regul,

		       sga_alumnos,

		       sga_personas

		 WHERE sga_perdidas_regul.unidad_academica = vUnidadAcademica

		   AND sga_perdidas_regul.carrera = vCarrera

		   AND sga_perdidas_regul.legajo = vLegajo
                                 

		   AND sga_perdidas_regul.unidad_academica = sga_alumnos.unidad_academica

		   AND sga_perdidas_regul.carrera = sga_alumnos.carrera

		   AND sga_perdidas_regul.legajo = sga_alumnos.legajo

		   AND sga_perdidas_regul.fecha_vencim_rehab IS NOT NULL

		   AND sga_alumnos.unidad_academica = sga_personas.unidad_academica

		   AND sga_alumnos.nro_inscripcion = sga_personas.nro_inscripcion;



		RETURN vUnidadAcademica, vCarrera, vLegajo, vResultado, vAnioAcademico,

		       vFechaBaja, vNroResolBaja, vFechaRehab, vNroResolRehab, vFechaVencimRehab,

		       vNroInscripcion, vApellido, vNombres, vCarNomRed WITH RESUME;
                              END IF;

	END FOREACH;

END;

END PROCEDURE
                                                                                                                                                                                                              
