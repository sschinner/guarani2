CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_ciclo_sup') THEN
		DROP PROCEDURE u820_ciclo_sup;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

create procedure "dba".u820_ciclo_sup(	v_unidad_acad	like sga_alumnos.unidad_academica,
				v_carrera		like sga_alumnos.carrera,
				v_legajo		like sga_alumnos.legajo,
				v_materia		like sga_actas_examen.materia,
				v_plan		like sga_alumnos.plan,
				v_version		like sga_actas_examen.version)
				
		returning smallint, varchar(255);
begin
define v_resu numeric(1);
define v_c_resu char(76);
define v_cantidad numeric(3);

let v_c_resu = " ";

select distinct materia
from
vw_hist_academica
where legajo = v_legajo
	and carrera = v_carrera
	and plan = v_plan
	and resultado = "A"
	and materia in ("10062", "10064", "10065", "10004", "10044", "10057", "10067", "10063", "10009",
		"10010", "10043", "10058", "10060", "10012", "10019", "10037", "10039", "10045", "10040","10016", "10017", "10020", "10050", "10055")
into temp temp_materias;

select count(*) into v_cantidad
from temp_materias;

drop table temp_materias;

if v_cantidad >= 14 then
	let v_resu = 1;
else
	let v_resu = -1;
	let v_c_resu = "No has aprobado las 14 materias del ciclo básico necesarias para cursar el siclo superior.";
end if;

return v_resu, v_c_resu;
end;
end procedure;

-- *************** Fin del procedimiento "dba".u820_ciclo_sup ******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".u820_ciclo_sup
-- *****************************************************************************
revoke execute on "dba".u820_ciclo_sup from public;
grant execute on "dba".u820_ciclo_sup to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_ciclo_sup to internet; -- Rol de usuario de Internet