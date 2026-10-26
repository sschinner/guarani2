CREATE PROCEDURE verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_can_repro_sci') THEN
		DROP PROCEDURE sp820_can_repro_sci;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE verifica_objeto();
DROP PROCEDURE verifica_objeto();

-- Procedimiento que devuelve la cantidad de materias que tiene un plan (Materias NORMALES y GENERICAS que son obligatorias) junto a la cantidad de estas que tiene reprobada un alumno pasado como parámetro.
-- El Sp es usado para recuperar datos para el sistema de electivas.
CREATE PROCEDURE "dba".sp820_can_repro_sci (pNroInscripcion LIKE sga_personas.nro_inscripcion, pCarrera LIKE sga_carreras.carrera)
	RETURNING 
		integer, -- TIPO_DOCUMENTO
		varchar(15), -- NRO_DOCUMENTO
		varchar(5), -- CODIGO DE CARRERA DE UNL 	 
		varchar(60), -- CARRERA
		integer, -- CANT. MAT. PLAN
		integer; -- CANT. MAT. APROB.
                
BEGIN

DEFINE vcApellido varchar(30);
DEFINE vcNombres varchar (30);
DEFINE vinro_documento LIKE sga_personas.nro_documento;
DEFINE vctipo_documento LIKE sga_personas.tipo_documento;
DEFINE vcLegajo varchar (15);
DEFINE vcCarrera varchar (5);
DEFINE vcUNLCarrera varchar (5);
DEFINE vcCarreraNombre varchar (60);
DEFINE vcPlan varchar (5);
DEFINE viVersionPlan varchar(5);
DEFINE viCantMatPlan integer;
DEFINE viCantMatAprob integer;
DEFINE sCantMatGen decimal(2);
DEFINE vcUA LIKE sga_unidades_acad.unidad_academica;
DEFINE vcGrupoCarrera  varchar (5);

LET vinro_documento = NULL;
LET vctipo_documento = NULL;
LET vcApellido = NULL;
LET vcNombres = NULL;
LET vcLegajo = NULL;
LET vcCarrera = NULL;
LET vcCarreraNombre = NULL;
LET vcUNLCarrera = NULL;
LET vcPlan = NULL;
LET viVersionPlan = NULL;
LET viCantMatPlan = NULL;
LET viCantMatAprob = NULL;
LET sCantMatGen = 0;
LET vcUA = NULL;
LET vcGrupoCarrera  = NULL;

FOREACH 
	SELECT apellido, nombres, tipo_documento, nro_documento, a.legajo, a.carrera, car.nombre, a.plan, pl.version_actual, a.unidad_academica, cod.unl_carrera, cg.grupo_carrera
	INTO vcApellido, vcNombres, vctipo_documento, vinro_documento, vcLegajo, vcCarrera, vcCarreraNombre, vcPlan, viVersionPlan, vcUA, vcUNLCarrera, vcGrupoCarrera  
		FROM sga_personas p
			join sga_alumnos a
				join sga_planes pl
					join sga_carreras car
						join sga_carreras_grupo cg 
							on cg.carrera = car.carrera
						left join u820_codigos_univ cod
						on car.unidad_academica = cod.unidad_academica
						and car.carrera = cod.carrera
					on pl.carrera = car.carrera
				on a.carrera = pl.carrera
				and a.plan = pl.plan
			on p.nro_inscripcion = a.nro_inscripcion
		WHERE p.nro_inscripcion = pNroInscripcion
		AND a.carrera = pCarrera
	
	-- Calculo de la cantidad de materias del plan de estudios al cual pertenece el alumno
	IF vcGrupoCarrera  <> 'i0001' THEN
	SELECT count(*) 
	INTO viCantMatPlan
		FROM sga_atrib_mat_plan atm 
		WHERE carrera = vcCarrera
		AND plan = vcPlan
		AND version = viVersionPlan
		AND obligatoria = 'S' 
		AND tipo_materia in ('N', 'G')
		AND materia not in (Select uc.materia from  u820_cursos_ing uc );

	
	-- Calculo de las materias que tiene aprobadas el alumno
	SELECT count(*) 
	INTO viCantMatAprob
		FROM vw_hist_academica vw
			join sga_atrib_mat_plan mat
			on vw.materia = mat.materia
			and vw.carrera = mat.carrera
		WHERE vw.legajo = vcLegajo
		AND vw.carrera = vcCarrera
		AND vw.resultado = 'R'
		AND mat.carrera = vcCarrera
		AND mat.plan = vcplan
		AND mat.version = viVersionPlan
		AND mat.obligatoria = 'S' 
		AND mat.tipo_materia in ('N', 'G')
		AND mat.materia not in (Select uc.materia from  u820_cursos_ing uc );
	ELSE
		SELECT count(*) 
	INTO viCantMatPlan
		FROM sga_atrib_mat_plan atm 
		WHERE carrera = vcCarrera
		AND plan = vcPlan
		AND version = viVersionPlan
		AND obligatoria = 'S' 
		
		AND materia not in (Select uc.materia from  u820_cursos_ing uc );

	
	-- Calculo de las materias que tiene aprobadas el alumno
	SELECT count(*) 
	INTO viCantMatAprob
		FROM vw_hist_academica vw
			join sga_atrib_mat_plan mat
			on vw.materia = mat.materia
			and vw.carrera = mat.carrera
		WHERE vw.legajo = vcLegajo
		AND vw.carrera = vcCarrera
		AND vw.resultado = 'R'
		AND mat.carrera = vcCarrera
		AND mat.plan = vcplan
		AND mat.version = viVersionPlan
		AND mat.obligatoria = 'S' 
		
		AND mat.materia not in (Select uc.materia from  u820_cursos_ing uc );	
	END IF;
 
	RETURN vctipo_documento, vinro_documento, vcUNLCarrera, vcCarreraNombre, viCantMatPlan, viCantMatAprob;
	
END FOREACH;

END
END PROCEDURE;

