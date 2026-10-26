CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_aceptacion_banco_sangre') THEN
		DROP PROCEDURE sp820_aceptacion_banco_sangre;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Creo el procedimiento para que cargar la opcion que elige el alumno.

-- DROP PROCEDURE "dba".sp820_aceptacion_banco_sangre;
CREATE PROCEDURE "dba".sp820_aceptacion_banco_sangre ( pUA LIKE sga_alumnos.unidad_academica,
						pNro_inscripcion LIKE sga_alumnos.nro_inscripcion,
						pOpcion CHAR(1) )

-- U820 ***************************************************************
-- Variables auxiliares personalizadas
-- U820 ***************************************************************

DEFINE sql_err int;
DEFINE isam_err int;
DEFINE error_info varchar(70);

-- Bloque de excepciones
on exception set sql_err, isam_err, error_info
-- error
	Rollback Work;
	raise exception  sql_err, isam_err, error_info;
end exception;

BEGIN WORK;

	-- Realizo una insercion porque el alumno no tiene registro en la tabla
	INSERT INTO u820_banco_sangre VALUES (pUA, pNro_inscripcion, CURRENT, pOpcion);

COMMIT WORK;

END PROCEDURE;

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_aceptacion_banco_sangre
-- *****************************************************************************
revoke execute on "dba".sp820_aceptacion_banco_sangre from public;
grant execute on "dba".sp820_aceptacion_banco_sangre to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_aceptacion_banco_sangre to internet; -- Rol de usuario de Internet