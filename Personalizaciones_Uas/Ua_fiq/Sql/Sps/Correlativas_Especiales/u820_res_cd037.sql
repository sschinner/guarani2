CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_res_cd037') THEN
		DROP PROCEDURE u820_res_cd037;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

create procedure "dba".u820_res_cd037(	pUnidadAcademica LIKE sga_alumnos.unidad_academica,
					pCarrera LIKE sga_alumnos.carrera,
					pLegajo LIKE sga_alumnos.legajo,
					pMateria LIKE sga_materias.materia,
					pPlan LIKE sga_alumnos.plan,
					pVersion LIKE sga_planes.version_actual)
	returning smallint, varchar(255);

define sql_err, isam_err, istatus, istatus1, istatus2, istatus3,istatus4,istatus5 integer;
define error_info, vcmsg varchar(100);

on exception set sql_err, isam_err, error_info
	let istatus = -1;
	let vcmsg = '800321' || ',' || 'u820_res_cd037' || ',' || sql_err || ' - ' || error_info;
	return istatus, vcmsg;
end exception;


begin
let istatus1 = 1;
let istatus2 = 1;
let istatus3 = 1;
let istatus4 = 1;
let istatus5=1;

let istatus = 1;
let vcmsg = '800320';

if exists(select *
		from sga_cursadas
		where legajo = pLegajo
			and carrera = pCarrera
			and legajo = pLegajo
			and materia in(select materia_optativa from sga_mat_genericas where materia_generica="I0074")
			and resultado = "A")
 then
		let istatus5 = -1;
end if



if not exists(	select *
		from sga_cursadas
		where legajo = pLegajo
			and carrera = pCarrera
			and legajo = pLegajo
			and materia = "Q0017"
			and resultado = "A") then
		let istatus1 = -1;
end if

if not exists(	select *
		from sga_cursadas
		where legajo = pLegajo
			and carrera = pCarrera
			and legajo = pLegajo
			and materia ="I0086"
			and resultado = "A") then
		let istatus2 = -1;
end if



if not exists(	   select *
		from sga_cursadas
		where legajo = pLegajo
			and carrera = pCarrera
			and legajo = pLegajo
			and materia = "Q0016"
			and resultado = "A") then
		let istatus3 = -1;
end if;

if not exists(	   select *
		from sga_cursadas
		where legajo = pLegajo
			and carrera = pCarrera
			and legajo = pLegajo
			and materia = "I0092"
			and resultado = "A") then
		let istatus4 = -1;
end if;

if istatus1=-1 and istatus2=-1 and istatus3=-1 and istatus4=-1 and istatus5=-1
    then
    let istatus = -1;
    let vcmsg = '82001009';
end if
return istatus, vcmsg;

end;
end procedure;

-- *************** Fin del procedimiento "dba".u820_res_cd037 ******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".u820_res_cd037
-- *****************************************************************************
revoke execute on "dba".u820_res_cd037 from public;
grant execute on "dba".u820_res_cd037 to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_res_cd037 to internet; -- Rol de usuario de Internet