CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_aprobar_primer_ciclo') THEN
		DROP PROCEDURE u820_aprobar_primer_ciclo;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

create procedure "dba".u820_aprobar_primer_ciclo (pUnidadAcademica LIKE sga_alumnos.unidad_academica,
						  pCarrera LIKE sga_alumnos.carrera,
						  pLegajo LIKE sga_alumnos.legajo,
					  	  pMateria LIKE sga_materias.materia,
						  pPlan LIKE sga_alumnos.plan,
						  pVersion LIKE sga_planes.version_actual)
	returning smallint, varchar(255);

define sql_err, isam_err, istatus integer;
define error_info, vcmsg varchar(100);

DEFINE vinro_documento LIKE sga_personas.nro_documento;
DEFINE vctipo_documento LIKE sga_personas.tipo_documento;
DEFINE vcCarreraNombre varchar (60);
DEFINE vcCodigoUNL varchar(5);
DEFINE viCantMatPlan integer;
DEFINE viCantMatAprob integer;
DEFINE vcNroInscripcion varchar(10);
DEFINE viOrientacion varchar(5);

on exception set sql_err, isam_err, error_info
	let istatus = -1;
	let vcmsg = '800321' || ',' || 'u820_aprobar_primer_ciclo' || ',' || sql_err || ' - ' || error_info;
	return istatus, vcmsg;
end exception;

begin
let istatus = 1;
let vcmsg = '800320';

LET vinro_documento = NULL;
LET vctipo_documento = NULL;
LET vcCarreraNombre = NULL;
LET viCantMatPlan = NULL;
LET viCantMatAprob = NULL;
LET viOrientacion = NULL;

select	orientacion into viOrientacion
from	sga_orient_alumno
where	legajo = pLegajo
and	carrera = pCarrera;

select	count(*) into viCantMatAprob
from	vw_hist_academica
where	resultado = 'A'
and	legajo = pLegajo
and	materia in ('TSL01', 'TSL02', 'TSL03', 'TSL04', 'TSL05', 'TSL06', 'TSL07', 'TSL08', 'TSL09', 'TSL10');

if viOrientacion is null then
	let istatus = -1;
	let vcmsg = '820000501';
else if viOrientacion = 'TRA01' then
	if not exists (select * from sga_materias_ciclo where ciclo = 'TSL01' and materia = pMateria) then
		if viCantMatAprob < 10 then
			let istatus = -1;
			let vcmsg = '820000502';
		end if;
	end if;
	else if viOrientacion = 'TRA02' then
		if not exists (select * from sga_materias_ciclo where ciclo = 'TSL02' and materia = pMateria) then
			if viCantMatAprob < 10 then
				let istatus = -1;
				let vcmsg = '820000502';
			end if;
		end if;
		else if viOrientacion = 'TRA03' then
			if not exists (select * from sga_materias_ciclo where ciclo = 'TSL03' and materia = pMateria) then
				if viCantMatAprob < 10 then
					let istatus = -1;
					let vcmsg = '820000502';
				end if;
			end if;
		end if;
	end if;
end if;
end if;

return istatus, vcmsg;

end;

end procedure;

-- *************** Fin del procedimiento "dba".u820_9_aprobadas ******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".u820_aprobar_primer_ciclo 
-- *****************************************************************************
revoke execute on "dba".u820_aprobar_primer_ciclo from public;
grant execute on "dba".u820_aprobar_primer_ciclo to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_aprobar_primer_ciclo to internet; -- Rol de usuario de Internet

--execute procedure u820_aprobar_primer_ciclo('FICH', '0005', '25910156-5', 'TSL12', '2015', '1')