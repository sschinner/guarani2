-- DROP PROCEDURE "dba".sp820_inscribir_carrera_capic;
CREATE PROCEDURE "dba".sp820_inscribir_carrera_capic(
	pAnioAcademico LIKE sga_periodo_insc.anio_academico,
	--pCarrera LIKE sga_carreras.carrera,
	pFechaInscripcion LIKE sga_datos_censales.fecha_relevamiento,
	pApellido LIKE sga_personas.apellido,
	pNombres LIKE sga_personas.nombres,
	pTipoDocumento LIKE sga_personas.tipo_documento,
	pNroDocumento LIKE sga_personas.nro_documento,
	pSexo LIKE sga_personas.sexo)

	Returning INT;
	--Returning varchar(80), varchar(80), varchar(80), varchar(80);

DEFINE aunidad_academica LIKE sga_datos_censales.unidad_academica;
DEFINE aanio_academico LIKE sga_periodo_insc.anio_academico;
DEFINE aperiodo_inscripcio LIKE sga_periodo_insc.periodo_inscripcio;
DEFINE afecha_inicio LIKE sga_periodo_insc.fecha_inicio;
DEFINE anro_inscripcion LIKE sga_personas.nro_inscripcion;
DEFINE aux_nro_inscripcion LIKE sga_personas.nro_inscripcion;
DEFINE aLegajo LIKE sga_alumnos.legajo;
DEFINE aCarrera LIKE sga_carreras.carrera;



DEFINE sql_err, isam_err  	int;
DEFINE error_info         	varchar(80);
DEFINE vcUserError	varchar(10);
DEFINE iStatus		int;
--DEFINE vcMsg		varchar(100);


LET aunidad_academica 	= 	NULL;
LET aanio_academico 	= 	NULL;
LET aperiodo_inscripcio 	= 	NULL;
LET afecha_inicio 		= 	NULL;
LET anro_inscripcion 	= 	NULL;
LET aLegajo 		=	NULL;
LET aux_nro_inscripcion 	= 	NULL;
LET iStatus 		=	0;
--LET vcMsg 		=	NULL;
LET aCarrera 		=	NULL;


-- Obtengo la Unidad Academica en la que nos encontramos.
SELECT unidad_academica INTO aunidad_academica 
	FROM sga_valor_inicial;

-- Obtengo la carrera de integración de la unidad academica
SELECT carrera INTO aCarrera
	FROM sga_carreras_grupo
		WHERE grupo_carrera = 'i0001';


-- Obtengo el periodo de Inscripcion. En base al anio de inscripcion del alumno
SELECT periodo_inscripcio INTO aperiodo_inscripcio
	FROM sga_periodo_insc 
		WHERE anio_academico = pAnioAcademico 
		AND tipo in ("I","A");
		--AND today between fecha_inicio and fecha_fin; 


-- Verifico si el alumno es persona en la UA.
-- Si la consulta siguiente devuelve un numero de inscripcion, es porque el alumno ya existe 
-- en la unidad académica.
SELECT nro_inscripcion INTO anro_inscripcion
	FROM sga_personas
		WHERE tipo_documento = pTipoDocumento 
		AND nro_documento = pNroDocumento
		AND unidad_academica = aunidad_academica;


-- Obtenemos un nuevo numero de inscripcion para el alumno
-- El siguiente IF se ejecuta solo si la anterior consulta no devolvio nada. Primero obtiene
-- un nuevo numero de inscripción y despues lo inscribe en sga_personas.

IF anro_inscripcion IS NULL THEN
	EXECUTE PROCEDURE sp_nro_inscripcion(aunidad_academica) INTO anro_inscripcion;

	-- Insertamos una nueva persona en sga_persona.
	INSERT INTO sga_personas (unidad_academica, nro_inscripcion, fecha_inscripcion, apellido, nombres, tipo_documento, pais_documento, nro_documento, sexo) 
		VALUES (aunidad_academica, anro_inscripcion, pFechaInscripcion, pApellido, pNombres, pTipoDocumento, 54, pNroDocumento, pSexo);
ELSE
	--LET iStatus = -1;
END IF;


-- El IF controla la existencia de una entrada del alumno en la tabla sga_carrera_aspira para la unidad academica y la carrera. Si no existe ninguna entrada, la inserta
-- Si existe una entrada, actualiza los valores sin importar los estados en los que estaban

IF NOT EXISTS (SELECT nro_inscripcion FROM sga_carrera_aspira
              		WHERE unidad_academica = aunidad_academica
	                AND nro_inscripcion = anro_inscripcion
                	AND carrera = aCarrera
	                --AND periodo_inscripcio = aperiodo_inscripcio
		) THEN

	INSERT INTO sga_carrera_aspira (unidad_academica, carrera, nro_inscripcion, periodo_inscripcio, fecha_inscripcion, sede, situacion_asp) 
		VALUES (aunidad_academica, aCarrera, anro_inscripcion, aperiodo_inscripcio, pfechaInscripcion, '00000', 'AC');

ELSE
	IF EXISTS (SELECT c.nro_inscripcion FROM sga_carrera_aspira c, sga_situacion_asp s
              		WHERE c.unidad_academica = aunidad_academica
	                AND c.nro_inscripcion = anro_inscripcion
                	AND c.carrera = aCarrera
		AND s.resultado_asp = 'R'
		AND c.situacion_asp = s.situacion_asp
	                --AND periodo_inscripcio = aperiodo_inscripcio
		) THEN
		
		set triggers for sga_carrera_aspira disabled;
		UPDATE sga_carrera_aspira 
			SET situacion_asp = 'AC',
			periodo_inscripcio = aperiodo_inscripcio,
			fecha_inscripcion = pFechaInscripcion
				WHERE unidad_academica = aunidad_academica
				AND nro_inscripcion = anro_inscripcion
				AND carrera = aCarrera;
				--AND sga_carrera_aspira.periodo_inscripcio = aperiodo_inscripcio;
		set triggers for sga_carrera_aspira enabled;
	END IF;
END IF; 
                		
--Verifica si existe un alumno en sga_personas para la unidad academica y para la carrera. De existir no hace nada. Si no existe, o bien existe para otra carrera, es
-- controlado por el procedimiento sp_crear_alumno

SELECT legajo INTO aLegajo
	FROM sga_alumnos alu JOIN sga_personas per
		ON alu.nro_inscripcion = per.nro_inscripcion
			WHERE per.nro_documento = pNroDocumento
			AND per.tipo_documento = pTipoDocumento
			AND carrera = aCarrera;


IF aLegajo is NULL THEN
	EXECUTE PROCEDURE sp820_crear_alumno(aunidad_academica, anro_inscripcion, aCarrera, pFechaInscripcion, null, null) Into aLegajo ,sql_err, isam_err, error_info;
ELSE
	--LET iStatus = -1;
END IF;


RETURN iStatus;


END PROCEDURE;
