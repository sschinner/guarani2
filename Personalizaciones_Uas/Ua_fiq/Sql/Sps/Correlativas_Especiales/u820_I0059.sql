CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_i0059') THEN
		DROP PROCEDURE u820_i0059;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

create procedure "dba".u820_i0059(	pUnidadAcademica LIKE sga_alumnos.unidad_academica,
					pCarrera LIKE sga_alumnos.carrera,
					pLegajo LIKE sga_alumnos.legajo,
					pMateria LIKE sga_materias.materia,
					pPlan LIKE sga_alumnos.plan,
					pVersion LIKE sga_planes.version_actual)
	returning smallint, varchar(255);

define sql_err, isam_err, istatus integer;
define error_info, vcmsg varchar(100);

on exception set sql_err, isam_err, error_info
	let istatus = -1;
	let vcmsg = '800321' || ',' || 'u820_i0059' || ',' || sql_err || ' - ' || error_info;
	return istatus, vcmsg;
end exception;

begin
let istatus = 1;
let vcmsg = '800320';

if not exists(	select *
		from sga_cursadas
		where legajo = pLegajo
			and carrera = pCarrera
			and legajo = pLegajo
			and materia ="I0059"
			and resultado = "A") then
		let istatus = -1;
		let vcmsg = '82001013';
end if;

return istatus, vcmsg;

end;
end procedure;

-- *************** Fin del procedimiento "dba".u820_i0059 ******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".u820_i0059
-- *****************************************************************************
revoke execute on "dba".u820_i0059 from public;
grant execute on "dba".u820_i0059 to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_i0059 to internet; -- Rol de usuario de Internet