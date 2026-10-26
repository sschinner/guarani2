CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_12_aprobadas') THEN
		DROP PROCEDURE u820_12_aprobadas;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

create procedure "dba".u820_12_aprobadas(	pUnidadAcademica LIKE sga_alumnos.unidad_academica,
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
DEFINE vcCodigoUNL varchar(5);
DEFINE vcCarreraNombre varchar (60);
DEFINE viCantMatPlan integer;
DEFINE viCantMatAprob integer;
DEFINE vcNroInscripcion varchar(10);


on exception set sql_err, isam_err, error_info
	let istatus = -1;
	let vcmsg = '800321' || ',' || 'u820_12_aprobadas' || ',' || sql_err || ' - ' || error_info;
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

Select nro_inscripcion Into vcNroInscripcion 
from  sga_alumnos
Where legajo = pLegajo
	and carrera = pCarrera;

  EXECUTE PROCEDURE "dba".sp820_can_apro (vcNroInscripcion, pCarrera) INTO vctipo_documento, vinro_documento, vcCodigoUNL, vcCarreraNombre, viCantMatPlan, viCantMatAprob;

if viCantMatAprob < 12 then
	let istatus = -1;
	let vcmsg = '82001012';
end if;

return istatus, vcmsg;

end;

end procedure;


-- *************** Fin del procedimiento "dba".u820_12_aprobadas ******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".u820_12_aprobadas
-- *****************************************************************************
revoke execute on "dba".u820_12_aprobadas from public;
grant execute on "dba".u820_12_aprobadas to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_12_aprobadas to internet; -- Rol de usuario de Internet