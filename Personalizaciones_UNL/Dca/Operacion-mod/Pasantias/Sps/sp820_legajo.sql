-- **********************************************************************
-- SP: sp820_legajo
-- Descripcion: Recupera el legajo de un alumno para la carrera.
-- Fecha: 12/05/2005
--
-- Recibe: - Unidad_academica
--              - nro de Inscripcion
--	- carrera
-- Retorna: - legajo
-- **********************************************************************


--DROP procedure "dba".sp820_legajo;
CREATE PROCEDURE "dba".sp820_legajo(pUnidadAcademica LIKE sga_insc_examen.unidad_academica, pNroInscripcion  LIKE sga_personas.nro_inscripcion, pCarrera LIKE sga_carreras.carrera)
 
RETURNING  varchar(15);                -- legajo

   -- variables utilizadas.
DEFINE	vcLegajo LIKE sga_alumnos.legajo;

BEGIN

SELECT legajo Into vcLegajo
FROM sga_alumnos
WHERE unidad_academica = pUnidadAcademica
	and nro_inscripcion = pNroInscripcion
	and carrera = pCarrera;
RETURN vcLegajo;
END;
END PROCEDURE;
-- **********************************************************************

-- execute procedure "dba".sp820_legajo('FICH', '2122', '04');

