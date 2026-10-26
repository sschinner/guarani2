CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_tot_plan') THEN
		DROP PROCEDURE sp820_tot_plan;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Procedimiento que devuelve la cantidad de materias que tiene un plan (Materias NORMALES Y GENERICAS que son obligatorias) 
CREATE PROCEDURE "dba".sp820_tot_plan (pNroInscripcion LIKE sga_personas.nro_inscripcion, pCarrera LIKE sga_carreras.carrera)
	RETURNING 
		integer; -- CANT. MAT. PLAN

                
BEGIN

DEFINE vcApellido varchar(30);
DEFINE vcNombres varchar (30);
DEFINE vinro_documento LIKE sga_personas.nro_documento;
DEFINE vctipo_documento LIKE sga_personas.tipo_documento;
DEFINE vcLegajo varchar (15);
DEFINE vcCarrera varchar (5);
DEFINE vcCarreraNombre varchar (60);
DEFINE vcPlan varchar (5);
DEFINE viVersionPlan varchar(5);
DEFINE viCantMatPlan integer;
DEFINE viCantMatAprob integer;
DEFINE sCantMatGen decimal(2);
DEFINE vcUA LIKE sga_unidades_acad.unidad_academica;

LET vinro_documento = NULL;
LET vctipo_documento = NULL;
LET vcApellido = NULL;
LET vcNombres = NULL;
LET vcLegajo = NULL;
LET vcCarrera = NULL;
LET vcCarreraNombre = NULL;
LET vcPlan = NULL;
LET viVersionPlan = NULL;
LET viCantMatPlan = NULL;
LET viCantMatAprob = NULL;
LET sCantMatGen = 0;
LET vcUA = NULL;

FOREACH 
	SELECT apellido, nombres, tipo_documento, nro_documento, a.legajo, a.carrera, car.nombre, a.plan, pl.version_actual, a.unidad_academica
	INTO vcApellido, vcNombres, vctipo_documento, vinro_documento, vcLegajo, vcCarrera, vcCarreraNombre, vcPlan, viVersionPlan, vcUA
		FROM sga_personas p
			join sga_alumnos a
				join sga_planes pl
					join sga_carreras car
					on pl.carrera = car.carrera
				on a.carrera = pl.carrera
				and a.plan = pl.plan
			on p.nro_inscripcion = a.nro_inscripcion
		WHERE p.nro_inscripcion = pNroInscripcion
		AND a.carrera = pCarrera
	
	-- Calculo de la cantidad de materias del plan de estudios al cual pertenece el alumno
	SELECT count(*) 
	INTO viCantMatPlan
		FROM sga_atrib_mat_plan atm
		WHERE carrera = vcCarrera
		AND plan = vcPlan
		AND version = viVersionPlan
		AND obligatoria = 'S' 
		AND tipo_materia in ('N', 'G')
		AND materia not in (Select uc.materia from  u820_cursos_ing uc );
	
 
	RETURN viCantMatPlan;
	
END FOREACH;

END
END PROCEDURE;
-- *************************** FIN PROCESO sp820_tot_plan *************************** 

revoke execute on "dba".sp820_tot_plan from public;
grant execute on "dba".sp820_tot_plan to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_tot_plan to internet; -- Rol de usuario de Internet

