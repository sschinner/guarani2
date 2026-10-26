CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_can_mat_apro_alu') THEN
		DROP PROCEDURE sp820_can_mat_apro_alu;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


CREATE PROCEDURE "dba".sp820_can_mat_apro_alu (
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


	-- Retornar lassumas de las notas y la cantidad de EXAMENES Y PROMOCIONES.
	SELECT count(*) INTO vCantMaterias
	FROM vw_hist_academica
		join sga_atrib_mat_plan
		  on sga_atrib_mat_plan.unidad_academica = vw_hist_academica.unidad_academica
			and sga_atrib_mat_plan.carrera          = vw_hist_academica.carrera
			and sga_atrib_mat_plan.plan             = vw_hist_academica.plan
			and sga_atrib_mat_plan.version          = vw_hist_academica.version
			and sga_atrib_mat_plan.materia          = vw_hist_academica.materia
	WHERE sga_atrib_mat_plan.materia in (select materia from sga_atrib_mat_plan where carrera = pCarrera and plan = vplan_alumno and version = vplan_version_act and sale_listado = "S" and promediable = "S")
	AND vw_hist_academica.unidad_academica = pUA
	AND vw_hist_academica.carrera = pCarrera
	AND vw_hist_academica.legajo = pLegajo
	AND vw_hist_academica.resultado = 'A';


	RETURN vCantMaterias;

END;

END PROCEDURE;
-- *************** Fin del procedimiento "dba".sp820_can_mat_apro_alu ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_can_mat_apro_alu 
-- *****************************************************************************
revoke execute on "dba".sp820_can_mat_apro_alu from public;
grant execute on "dba".sp820_can_mat_apro_alu to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_can_mat_apro_alu to internet; -- Rol de usuario de Internet

-- *************************** Pruebas de ejecucion **********************************
-- execute procedure "dba".sp820_can_mat_apro_alu ('FCJS', '1', '33945056-2');

{
select * from sga_alumnos where legajo = '33945056-2'
select * from sga_planes

select * from sga_atrib_mat_plan where carrera = 1 and plan = '2000' and version = 47 and sale_listado = "S" and promediable = "S"

select * from sga_atrib_mat_plan
where carrera = 1 and plan = '2000' and version = 47  and materia in ('83', '84', '85', '278', '277', '264')

set triggers for sga_atrib_mat_plan disabled;
update sga_atrib_mat_plan
set promediable = 'S', sale_listado = 'S'
where carrera = 1 and plan = '2000' and version = 47  and materia in ('83', '84', '85', '278', '277', '264');
set triggers for sga_atrib_mat_plan enabled;

set triggers for sga_atrib_mat_plan disabled;
update sga_atrib_mat_plan
set promediable = 'N', sale_listado = 'N'
where carrera = 1 and plan = '2000' and version = 47  and materia in ('83', '84', '85');
update sga_atrib_mat_plan
set promediable = 'N', sale_listado = 'S'
where carrera = 1 and plan = '2000' and version = 47  and materia in ('278', '277', '264');
set triggers for sga_atrib_mat_plan enabled;
}