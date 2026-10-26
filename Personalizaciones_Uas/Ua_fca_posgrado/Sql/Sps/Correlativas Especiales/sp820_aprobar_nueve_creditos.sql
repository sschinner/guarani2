CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_aprobar_nueve_creditos') THEN
		DROP PROCEDURE u820_ciclo_sup04;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- drop procedure u820_aprobar_nueve_creditos;

create procedure "dba".u820_aprobar_nueve_creditos(	v_unidad_acad	like sga_alumnos.unidad_academica,
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

select	sum(amp.credito) into v_cantidad
from	vw_hist_academica ha
join	sga_atrib_mat_plan amp on ha.carrera = amp.carrera and ha.plan = amp.plan and ha.version = amp.version and ha.materia = amp.materia
where	ha.carrera = v_carrera
and	ha.legajo = v_legajo
and	ha.resultado = 'A'
and	amp.materia in ('00001', '00002', '00003', '00004', '00015', '00358');

if v_cantidad > 9 then
	let v_resu = 1;
else
	let v_resu = -1;
	let v_c_resu = 'Debés aprobar 9 créditos para cursar esta asignatura';
end if;

return v_resu, v_c_resu;
end;
end procedure;

-- *************** Fin del procedimiento "dba".u820_aprobar_nueve_creditos ******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".u820_aprobar_nueve_creditos
-- *****************************************************************************
revoke execute on "dba".u820_u820_aprobar_nueve_creditos from public;
grant execute on "dba".u820_u820_aprobar_nueve_creditos to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_u820_aprobar_nueve_creditos to internet; -- Rol de usuario de Internet