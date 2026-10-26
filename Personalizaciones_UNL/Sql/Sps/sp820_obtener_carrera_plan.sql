CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_obtener_carrera_plan') THEN
		DROP PROCEDURE sp820_obtener_carrera_plan;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- PROCEDIMIENTO QUE OBTIENE LAS CARRERAS Y PLANES DE LOS ALUMNOS QUE SE PASAN COMO PARÁMETROS, QUE ESTÉN  ACTIVOS Y REGULARES.
CREATE PROCEDURE "dba".sp820_obtener_carrera_plan(pNroInsc LIKE sga_req_cumplidos.nro_inscripcion)

RETURNING
		varchar(5),	-- CODIGO CARRERA
		varchar(255),	-- NOMBRE CARRERA
		varchar(5);	-- PLAN

DEFINE vcCarrera varchar(5);
DEFINE vcNombre varchar(255);
DEFINE vcPlan varchar(5);

-----  VARS PARA EL MANEJO DE EXCEPCIONES

DEFINE sql_err	 			integer;
DEFINE isam_err 				integer;
DEFINE error_info				varchar(76);

ON EXCEPTION SET sql_err, isam_err, error_info                                        
      RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;     

BEGIN

FOREACH SELECT alu.carrera, car.nombre, alu.plan
	INTO vcCarrera, vcNombre, vcPlan
	FROM sga_alumnos alu, sga_carreras car
	WHERE alu.nro_inscripcion = pNroInsc
	AND alu.carrera = car.carrera
	AND alu.regular = "S"
	AND alu.calidad = "A"

	RETURN
		vcCarrera, vcNombre, vcPlan
		WITH RESUME; 

END FOREACH;

END;
END PROCEDURE;

-- *****************************************************************************
revoke execute on "dba".sp820_obtener_carrera_plan from public;
grant execute on "dba".sp820_obtener_carrera_plan to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_obtener_carrera_plan to internet; -- Rol de usuario de Internet

