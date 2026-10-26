CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_can_apro_fiq') THEN
		DROP PROCEDURE sp820_can_apro_fiq;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Procedimiento que devuelve la cantidad de materias que tiene un plan (Materias NORMALES y GENERICAS que son obligatorias) junto a la cantidad de estas que tiene aprobada un alumno pasado como parámetro.
-- El Sp es usado para recuperar datos para el sistema de electivas.
CREATE PROCEDURE "dba".sp820_can_apro_fiq (pNroInscripcion LIKE sga_personas.nro_inscripcion, pCarrera LIKE sga_carreras.carrera)
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

FOREACH 
	SELECT apellido, nombres, tipo_documento, nro_documento, a.legajo, a.carrera, car.nombre, a.plan, pl.version_actual, a.unidad_academica, cod.unl_carrera
	INTO vcApellido, vcNombres, vctipo_documento, vinro_documento, vcLegajo, vcCarrera, vcCarreraNombre, vcPlan, viVersionPlan, vcUA, vcUNLCarrera
		FROM sga_personas p
			join sga_alumnos a
				join sga_planes pl
					join sga_carreras car
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
	SELECT count(*) 
	INTO viCantMatPlan
		FROM sga_atrib_mat_plan atm
		WHERE carrera = vcCarrera
		AND plan = vcPlan
		AND version = viVersionPlan
		AND obligatoria = 'S' 
		AND tipo_materia in ('N', 'G')
		AND materia not in ("Q0112","60034","70013","30030","60034","I0094","Q0012","60015","C0015","M0015");
	
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
		AND vw.materia not in ("Q0112","60034","70013","30030","60034","I0094","Q0012","60015","C0015","M0015");
		
	-- Calculo de la cantidad de materias genericas que el alumno tiene aprobado en el plan de estudios
	EXECUTE PROCEDURE sp820_Genericas_Aprobadas(vcUA, vcLegajo, vcCarrera, vcplan) INTO sCantMatGen;
	LET viCantMatAprob = viCantMatAprob + sCantMatGen;
 
	RETURN vctipo_documento, vinro_documento, vcUNLCarrera, vcCarreraNombre, viCantMatPlan, viCantMatAprob;
	
END FOREACH;

END
END PROCEDURE;
-- *************************** FIN PROCESO sp820_can_apro *************************** 
-- execute procedure sp820_can_apro_FIQ ( 'FIQ-1688', '00001');
-- select * from u820_codigos_univ;


-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_can_apro_fiq 
-- *****************************************************************************
revoke execute on "dba".sp820_can_apro_fiq  from public;
grant execute on "dba".sp820_can_apro_fiq  to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_can_apro_fiq  to internet; -- Rol de usuario de Internet