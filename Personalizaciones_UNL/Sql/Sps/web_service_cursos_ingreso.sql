CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_service_cursos_ingreso') THEN
		DROP PROCEDURE web_service_cursos_ingreso;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Parametros de WS: tipo_documento, nro_documento y carrera;

CREATE PROCEDURE "dba".web_service_cursos_ingreso(ptipo_documento	LIKE dba.sga_personas.tipo_documento,
				pnro_documento	LIKE dba.sga_personas.nro_documento,
				pcarrera	LIKE dba.sga_carreras.carrera)

RETURNING varchar(10),	-- curso
	varchar(50),	-- nombre
	varchar(15),	-- fecha
	varchar(10),	-- nota
	varchar(20);	-- forma_aprobacion

-- Variables locales del procedimiento
DEFINE vcurso			varchar(10);
DEFINE vnombre			varchar(50);
DEFINE vfecha			varchar(15);
DEFINE vnota			varchar(10);
DEFINE vforma_aprobacion	varchar(20);
DEFINE vlegajo LIKE sga_alumnos.legajo;

--Variables para el manejo de excepciones
DEFINE sql_err	 	integer;
DEFINE isam_err 	integer;
DEFINE error_info	varchar(76);

ON EXCEPTION SET sql_err, isam_err, error_info                                        
	RAISE EXCEPTION  sql_err, isam_err, error_info;
	END EXCEPTION;   
BEGIN

LET vcurso= NULL;
LET vnombre= NULL;
LET vfecha= NULL;
LET vnota= NULL;
LET vforma_aprobacion= NULL;
LET vlegajo= NULL;

	-- Verifico si existe el alumno
	IF EXISTS (SELECT *
		FROM 	sga_alumnos as a
		JOIN	sga_personas as p ON a.nro_inscripcion = p.nro_inscripcion
		WHERE	p.tipo_documento = ptipo_documento
			AND p.nro_documento = pnro_documento
			AND a.carrera = pcarrera) THEN
			
		-- Obtengo el numero de legajo del alumno
		SELECT	FIRST 1 a.legajo
		INTO	vlegajo
		FROM 	sga_alumnos as a
		JOIN	sga_personas as p ON a.nro_inscripcion = p.nro_inscripcion
		WHERE	p.tipo_documento = ptipo_documento
			AND p.nro_documento = pnro_documento
			AND a.carrera = pcarrera;
		
		-- Retorno los cursos de ingreso vinculados al alumno
		FOREACH 
			SELECT	DISTINCT ci.curso_ingreso, m.nombre, to_char(ha.fecha, '%d/%m/%Y'), ha.nota, ha.forma_aprobacion
			INTO	vcurso, vnombre, vfecha, vnota, vforma_aprobacion
			FROM	vw_hist_academica as ha
			JOIN	sga_alumnos as a ON a.legajo = ha.legajo AND a.carrera = ha.carrera
			JOIN	u820_cursos_ing as ci ON ci.carrera = ha.carrera AND ci.plan = ha.plan AND ci.materia = ha.materia
			JOIN	sga_materias as m ON ci.materia = m.materia
			WHERE	ha.legajo = vlegajo
				AND ha.carrera = pcarrera

			RETURN vcurso, vnombre, vfecha, vnota, vforma_aprobacion WITH RESUME;
		END FOREACH;
	END IF;

END;

END PROCEDURE;

-- Casos de prueba
{
Casos:
EXECUTE PROCEDURE "dba".web_service_cursos_ingreso(0, '31862148', '03');
EXECUTE PROCEDURE "dba".web_service_cursos_ingreso(0, '31862148', '02');
EXECUTE PROCEDURE "dba".web_service_cursos_ingreso(0, '28856097', '03');
EXECUTE PROCEDURE "dba".web_service_cursos_ingreso(0, '30171912', '03');

}

-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_dat_acad_hefe 
-- *****************************************************************************
revoke execute on "dba".web_service_cursos_ingreso from public;
grant execute on "dba".web_service_cursos_ingreso to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_service_cursos_ingreso to internet; -- Rol de usuario de Internet
