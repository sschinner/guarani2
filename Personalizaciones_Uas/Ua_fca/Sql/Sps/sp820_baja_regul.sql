CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_baja_regul') THEN
		DROP PROCEDURE sp820_baja_regul;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP PROCEDURE sp820_baja_regul;

CREATE PROCEDURE "dba".sp820_baja_regul()
RETURNING  varchar(5) ,varchar(60) , varchar(5) , varchar(15), varchar(30), varchar(30), varchar(5), varchar(100), date, int;

define v_carrera like sga_carreras.carrera;
define v_nombre_carrera like sga_carreras.nombre;
define v_plan like sga_planes.plan;
define v_legajo like sga_alumnos.legajo;
define v_nombres like sga_personas.nombres;
define v_apellido like sga_personas.apellido;
define v_materia like sga_materias.materia;
define v_nombre_materia like sga_materias.nombre;
define v_fecha_regularidad like sga_det_acta_curs.fecha_regularidad;
define v_cantidad int;

select cu.carrera, cu.plan, co.materia, cu.legajo, max(cu.fecha_regularidad) as fecha_regularidad
from sga_cursadas cu
	join sga_comisiones co
	  on cu.comision = co.comision
where cu.fin_vigencia_regul >= today
	and cu.resultado = "A"
group by cu.carrera, cu.plan, co.materia, cu.legajo
into temp temp1;
 

select *
from temp1
where carrera || plan || materia || legajo not in (
	select carrera || plan || materia || legajo
	from vw_hist_academica
	where resultado = "A")
into temp temp2;


select t.carrera, t.plan, t.materia, t.legajo, max(t.fecha_regularidad) as fecha_regularidad, count(*) as cantidad
from sga_actas_examen a
	join sga_detalle_acta d
		join temp2 t
		  on d.carrera = t.carrera
			and d.plan = t.plan
			and d.legajo = t.legajo
			and d.fecha_de_examen > t.fecha_regularidad
	  on a.acta = d.acta
where a.materia = t.materia
	and d.resultado = "R"
group by t.carrera, t.plan, t.materia, t.legajo
having count(*) >= 4
into temp temp3;

FOREACH select c.carrera, c.nombre as nombre_carrera, t.plan, a.legajo, p.nombres, p.apellido, 
		m.materia, m.nombre as nombre_materia, t.fecha_regularidad, t.cantidad
	into v_carrera, v_nombre_carrera, v_plan, v_legajo, v_nombres, v_apellido, 
		v_materia, v_nombre_materia, v_fecha_regularidad, v_cantidad
	from temp3 t
	join sga_alumnos a
		join sga_personas p
		  on a.nro_inscripcion = p.nro_inscripcion
	  on t.legajo = a.legajo
		and t.carrera = a.carrera
		and t.plan = a.plan
	join sga_carreras c
	  on t.carrera = c.carrera
	join sga_materias m
	  on t.materia = m.materia


	RETURN v_carrera, v_nombre_carrera, v_plan, v_legajo, v_nombres, v_apellido, 
		v_materia, v_nombre_materia, v_fecha_regularidad, v_cantidad  WITH RESUME;
END FOREACH;

drop table temp1;
drop table temp2;
drop table temp3;

END PROCEDURE;

--	execute procedure sp820_baja_regul();

-- *************** Fin del procedimiento "dba".sp820_baja_regul ******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_baja_regul
-- *****************************************************************************
revoke execute on "dba".sp820_baja_regul from public;
grant execute on "dba".sp820_baja_regul to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_baja_regul to internet; -- Rol de usuario de Internet