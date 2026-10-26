--DROP PROCEDURE sp820_prom_pond_alu;
CREATE PROCEDURE "dba".sp820_prom_pond_alu (
                                    pUA      LIKE sga_alumnos.unidad_academica,
                                    pCarrera LIKE sga_alumnos.carrera,
                                    pLegajo  LIKE sga_alumnos.legajo)

RETURNING DECIMAL(4,2); -- promedio ponderado

-- Variables para el manejo de excepciones
DEFINE sql_err		INTEGER;
DEFINE isam_err		INTEGER;
DEFINE error_info		VARCHAR(76);


DEFINE vplan_alumno	LIKE sga_atrib_mat_plan.plan;
DEFINE vplan_version_act	LIKE sga_atrib_mat_plan.version;

DEFINE nPromedio		DECIMAL(4,2);
DEFINE nCantAprobadas	INTEGER;
DEFINE vCantMateriasPlan	INTEGER;
DEFINE cPromedioResolucion char(1);

-- blk de excepciones
ON EXCEPTION SET sql_err, isam_err, error_info
	-- Borra la tabla temporal
	BEGIN
		-- Si no existía, continúa
		ON EXCEPTION IN  (-206)
		END EXCEPTION WITH RESUME ;
	END
	RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;


BEGIN

  -- inicializo las vars.
LET nPromedio		= NULL;
LET nCantAprobadas	= 0;
LET vCantMateriasPlan	= 0;
LET cPromedioResolucion = NULL;

EXECUTE PROCEDURE "dba".sp820_prom_alu_res(pUA, pCarrera, pLegajo, "S") INTO nPromedio, cPromedioResolucion;

SELECT plan INTO vplan_alumno
FROM sga_alumnos
WHERE carrera = pCarrera
	AND legajo = pLegajo;

SELECT version_actual, cnt_materias INTO vplan_version_act, vCantMateriasPlan
FROM sga_planes
WHERE carrera = pCarrera
	AND plan = vplan_alumno;

-- Creo un temporal con la Historia Academica
SELECT  COUNT(DISTINCT materia) INTO nCantAprobadas
FROM vw_hist_academica
WHERE unidad_academica        = pUA
	AND carrera                 = pCarrera
	AND legajo                  = pLegajo
	AND materia NOT IN (SELECT materia FROM u820_cursos_ing WHERE carrera = pCarrera);

LET nPromedio = CASE WHEN nCantAprobadas IS null OR vCantMateriasPlan IS null OR vCantMateriasPlan = 0 OR nPromedio IS null THEN
				0
			ELSE
				nPromedio + ( nCantAprobadas / vCantMateriasPlan )
			END;

RETURN nPromedio;

END;

END PROCEDURE;
-- ********************* FIN PROCEDURE sp820_prom_alu_res *********************

-- select * from sga_alumnos
-- select * from vw_hist_academica where legajo = "23929361-3" and resultado = "A" and materia not in (SELECT materia FROM u820_cursos_ing); 
-- EXECUTE PROCEDURE "dba".sp820_prom_alu_res("FCJS", "1", "23929361-3", "S");
-- EXECUTE PROCEDURE "dba".sp820_prom_alu_res("FCJS", "1", "23929361-3", "N");
-- SELECT cnt_materias FROM sga_planes WHERE carrera = "1" AND plan = "1985";
-- execute procedure sp820_prom_pond_alu ("FCJS", "1", "23929361-3");

