--DROP PROCEDURE "dba".sp820_can_mat_apro_pas;

CREATE PROCEDURE "dba".sp820_can_mat_apro_pas (
                                    pUA      LIKE sga_alumnos.unidad_academica,
                                    pCarrera LIKE sga_alumnos.carrera,
                                    pLegajo  LIKE sga_alumnos.legajo)

RETURNING integer; -- cantidad materias aprobadas

-- Variables para el manejo de excepciones
DEFINE sql_err             integer;
DEFINE isam_err          integer;
DEFINE error_info          varchar(76);


DEFINE	vplan_alumno	LIKE sga_atrib_mat_plan.plan;
DEFINE	vplan_version_act	LIKE sga_atrib_mat_plan.version;
DEFINE	vCantMaterias	integer;


-- blk de excepciones
ON EXCEPTION SET sql_err, isam_err, error_info
   RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;


BEGIN

select plan into vplan_alumno
from sga_alumnos
where carrera = pCarrera
	and legajo = pLegajo;

select version_actual into vplan_version_act
from sga_planes
where carrera = pCarrera
	and plan = vplan_alumno;


	-- Retornar las sumas de las notas y la cantidad de EXAMENES Y PROMOCIONES.
	SELECT count(*) INTO vCantMaterias
	FROM vw_hist_academica
		join sga_atrib_mat_plan
		  on sga_atrib_mat_plan.unidad_academica = vw_hist_academica.unidad_academica
			and sga_atrib_mat_plan.carrera          = vw_hist_academica.carrera
			and sga_atrib_mat_plan.plan             = vw_hist_academica.plan
			and sga_atrib_mat_plan.version          = vw_hist_academica.version
			and sga_atrib_mat_plan.materia          = vw_hist_academica.materia
	WHERE sga_atrib_mat_plan.materia in (select materia from sga_atrib_mat_plan where carrera = pCarrera and plan = vplan_alumno and version = vplan_version_act and sale_listado = "S")
	AND vw_hist_academica.unidad_academica = pUA
	AND vw_hist_academica.carrera = pCarrera
	AND vw_hist_academica.legajo = pLegajo
	AND vw_hist_academica.resultado = 'A';


	RETURN vCantMaterias;

END;

END PROCEDURE
-- execute procedure sp820_can_mat_apro_pas ('FCJS', '1', '29642222-4');

