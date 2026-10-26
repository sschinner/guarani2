CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_genericas_aprobadas_becas_prog') THEN
		DROP PROCEDURE sp820_genericas_aprobadas_becas_prog;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- Procedimiento que devuelve la cantidad de Materias Genéricas Obligatorias que tiene aprobada un alumno en una carrera
CREATE PROCEDURE "dba".sp820_genericas_aprobadas_becas_prog(pUA LIKE sga_unidades_acad.unidad_academica, 
												pLegajo LIKE sga_alumnos.legajo,
												pCarrera LIKE sga_atrib_mat_plan.carrera,
												pPlan LIKE sga_atrib_mat_plan.plan, 
												pFechaInicio LIKE sga_alumnos.fecha_ingreso,
												pFechaFin LIKE sga_alumnos.fecha_ingreso)
RETURNING
		decimal(2);	-- CANTIDAD DE MATERIAS GENÉRICAS OBLIGATORIAS APROBADAS

DEFINE vcTitulo LIKE sga_titulos.titulo;
DEFINE vcMateria LIKE sga_materias.materia;
DEFINE sResultado decimal(2);
DEFINE sResulProc char(1);
DEFINE sCreditos integer; -- Variable nueva de la versión 2.06 que devuelve los creditos de la materia generica

-----  VARS PARA EL MANEJO DE EXCEPCIONES

DEFINE sql_err	 			integer;
DEFINE isam_err 				integer;
DEFINE error_info				varchar(76);

ON EXCEPTION SET sql_err, isam_err, error_info                                        
      RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;     

BEGIN

LET sResultado = 0;
LET sCreditos = 0;

FOREACH SELECT DISTINCT materia 
			INTO vcMateria
			FROM sga_atrib_mat_plan 
			WHERE plan = pPlan 
			AND carrera = pCarrera 
			AND obligatoria = "S"
			
		IF (SELECT tipo_materia
			FROM sga_materias
			WHERE unidad_academica = pUA
			AND materia = vcMateria) = 'G'  THEN
	
			-- Recupero el Titulo de Grado del Plan-Version
			SELECT sga_orientaciones.titulo
				INTO vcTitulo
				FROM sga_orientaciones, sga_titulos
				WHERE sga_orientaciones.unidad_academica = pUA
				AND sga_orientaciones.carrera = pCarrera
				AND sga_orientaciones.plan = pPlan
				AND sga_orientaciones.orientacion = '0'
				AND sga_orientaciones.unidad_academica = sga_titulos.unidad_academica
				AND sga_orientaciones.titulo = sga_titulos.titulo
				AND sga_titulos.nivel = 'GRADO';
		
				LET sResulProc = '';
				-- PERSONALIZACION EXCLUSIVA PARA FCM QUE NO QUIERE QUE SE CUENTE LA GENERICA AIE
				IF (pCarrera = '1' AND (vcMateria = 'AIE' OR vcMateria = 'AIE01') AND pUA = 'FCM') THEN
					LET sResulProc = '';
				ELSE
					EXECUTE PROCEDURE sp_resultGenericaBecaUltAnio (pUA, pCarrera, pLegajo, vcTitulo, '0', vcMateria,pFechaInicio, pFechaFin) INTO sResulProc, sCreditos;
				END IF;
				IF sResulProc == 'A' THEN
					LET sResultado = sResultado + 1;
				END IF;
		END IF;
END FOREACH;

RETURN sResultado;

END;
END PROCEDURE;



-- **************************  Fin del Procedure sp820_genericas_aprobadas **************************
revoke execute on "dba".sp820_genericas_aprobadas_becas_prog from public;

grant execute on "dba".sp820_genericas_aprobadas_becas_prog to guarani; -- Rol de usuarios de Gestión
grant execute on "dba".sp820_genericas_aprobadas_becas_prog to internet; -- Usuario de internet
