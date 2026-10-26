CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_ciclo_60001') THEN
		DROP PROCEDURE u820_ciclo_60001;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

create procedure "dba".u820_ciclo_60001(	pUnidadAcademica LIKE sga_alumnos.unidad_academica,
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

on exception set sql_err, isam_err, error_info
	let istatus = -1;
	let vcmsg = '800321' || ',' || 'u820_ciclo_60001' || ',' || sql_err || ' - ' || error_info;
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

-- Verificar que todas las materias del ciclo 60001 estén aprobadas
IF EXISTS 
(SELECT '*' FROM sga_materias_ciclo 
	WHERE ciclo =  '60001'
	AND materia NOT IN (select materia 
				from vw_hist_academica	
			where legajo = pLegajo
			and carrera = pCarrera
			and plan = pPlan
			and resultado = 'A'
			and materia = sga_materias_ciclo.materia)

) THEN

	let istatus = -1;
	let vcmsg = '82001025';
END IF

return istatus, vcmsg;

end;
end procedure;

-- execute procedure "dba".u820_ciclo_60001('FIQ', '00006', '34496553-9', '1', '2008', '6');

-- *****************************************************************************
-- Permisos del procedimiento "dba".u820_ciclo_60001
-- *****************************************************************************
revoke execute on "dba".u820_ciclo_60001 from public;
grant execute on "dba".u820_ciclo_60001 to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_ciclo_60001 to internet; -- Rol de usuario de Internet