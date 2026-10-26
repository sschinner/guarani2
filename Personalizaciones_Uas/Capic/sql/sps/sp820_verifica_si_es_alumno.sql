-- Procedimiento que verifica la existencia de un alumno en la carrera de integracion de Gaurani.
-- Devuelve 1 si es alumno.

-- DROP PROCEDURE "dba".sp820_verifica_si_es_alumno;
CREATE PROCEDURE "dba".sp820_verifica_si_es_alumno(
	pTipoDocumento LIKE sga_personas.tipo_documento,
	pNroDocumento LIKE sga_personas.nro_documento)
	Returning INT;

DEFINE iStatus		int;
DEFINE aCarrera LIKE sga_carreras.carrera;

LET iStatus 		=	0;


-- Obtengo la carrera de integración de la unidad academica
SELECT carrera INTO aCarrera
	FROM sga_carreras_grupo
		WHERE grupo_carrera = 'i0001';


IF EXISTS (SELECT a.legajo 
		FROM sga_alumnos a, sga_personas p
			WHERE p.tipo_documento = pTipoDocumento
			AND p.nro_documento = pNroDocumento
			AND a.nro_inscripcion = p.nro_inscripcion
			AND a.carrera = aCarrera
	) THEN
		LET iStatus = 1; -- Si devuelve un 1 es porque es alumno
END IF


RETURN iStatus;


END PROCEDURE;



--  select * from sga_personas
-- select * from sga_alumnos
--  execute procedure sp820_verifica_si_es_alumno("0","28276279");

