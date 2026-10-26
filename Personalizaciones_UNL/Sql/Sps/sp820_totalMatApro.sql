CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_tot_apro') THEN
		DROP PROCEDURE sp820_tot_apro;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Procedimiento que devuelve la cantidad de materias aprobadas por un alumno (Materias NORMALES Y GENERICAS que son obligatorias) 
CREATE PROCEDURE "dba".sp820_tot_apro (pNroInscripcion LIKE sga_personas.nro_inscripcion, pCarrera LIKE sga_carreras.carrera)
	RETURNING 

		integer; -- CANT. MAT. APROB.
                
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
DEFINE sCantMatGen integer;
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
	

	-- Calculo de las materias que tiene aprobadas el alumno
	SELECT count(*) 
	INTO viCantMatAprob
		FROM vw_hist_academica vw
			join sga_atrib_mat_plan mat
			on vw.materia = mat.materia
			and vw.carrera = mat.carrera
		WHERE vw.legajo = vcLegajo
		AND vw.carrera = vcCarrera
		AND vw.resultado = 'A'
		AND mat.carrera = vcCarrera
		AND mat.plan = vcplan
		AND mat.version = viVersionPlan
		AND mat.obligatoria = 'S' 
		AND mat.tipo_materia in ('N', 'G')
		AND mat.materia not in (Select uc.materia from  u820_cursos_ing uc );
		
	-- Calculo de la cantidad de materias genericas y obligatorias que el alumno tiene aprobado en el plan de estudios
	EXECUTE PROCEDURE sp820_Genericas_Aprobadas(vcUA, vcLegajo, vcCarrera, vcplan) INTO sCantMatGen;
	LET viCantMatAprob = viCantMatAprob + sCantMatGen;
 
	RETURN viCantMatAprob;
	
END FOREACH;

END
END PROCEDURE;
-- *************************** FIN PROCESO sp820_tot_apro *************************** 

revoke execute on "dba".sp820_tot_apro from public;
grant execute on "dba".sp820_tot_apro to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_tot_apro to internet; -- Rol de usuario de Internet
