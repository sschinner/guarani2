CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_trayecto_regularizado') THEN
		DROP PROCEDURE u820_trayecto_regularizado;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Procedimiento: u820_trayecto_regularizado
-- Version 2.9.2
-- Descripcion: Retorna si un alumno tiene regularizado al menos un Trayecto de la carrera
-- Especialización en Educación Matemática

-- Requerimiento de Posgrado FHUC

-- Recibe:     	- carrera
--              - legajo
	
-- Retorna:      1: OK
--				-1: Debe regularizar al menos un trayecto.

-- Usa SP:		u820_modulo_regularizado

-- Condiciones:
-- 	Para cursar EEM21 - "La escuela..." el alumno debe tener REGULARIZADO al menos un trayecto.

-- 	Regularizar un trayecto implica tener su modulo regularizado.

-- 	Regularizar un modulo implica tener al menos tres de sus cursos regularizados.
-- 	EMMI 	-> Modulo I
-- 	EMMII 	-> Modulo II
-- 	EEM22	-> Modulo III

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

CREATE PROCEDURE "dba".u820_trayecto_regularizado
	(	
	v_carrera		LIKE sga_alumnos.carrera,
	v_legajo		LIKE sga_alumnos.legajo
	)
RETURNING smallint, varchar(255);

BEGIN

	DEFINE sqlerr		integer;
	DEFINE isamerr		integer;
	DEFINE errorinfo	varchar(76);
	DEFINE v_resu		numeric(1);
	DEFINE v_c_resu		char(76);
	DEFINE _regularizados	integer;
	DEFINE _aprobados	integer;
	DEFINE _total		integer;
	DEFINE _materia		varchar(24);
	DEFINE _resultado	smallint;
	DEFINE _mensaje			varchar(128);
	DEFINE _mat_optativa		varchar(24);

	-- si hay algun error
	ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo
		RETURN SQLErr, errorInfo;
	END EXCEPTION;
	
	LET v_resu = -1;  
	LET v_c_resu = 'Debe regularizar al menos un trayecto.';

	-- Recorro los modulos de los trayectos
	FOREACH SELECT materia INTO _materia FROM sga_materias WHERE materia IN ('EMMI', 'EMMII', 'EEM22')
		
		EXECUTE PROCEDURE u820_modulo_regularizado(v_carrera, _materia, v_legajo) INTO _resultado, _mensaje;
		
		-- Si encuentro un modulo regularizado, retorno.
		IF _resultado = 1 THEN
			RETURN 1, 'OK';
		END IF;
	END FOREACH;

	RETURN v_resu, v_c_resu;

END;
END PROCEDURE;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Permisos del procedimiento 
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

revoke execute on "dba".u820_trayecto_regularizado from public;
grant execute on "dba".u820_trayecto_regularizado to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_trayecto_regularizado to internet; -- Rol de usuario de Internet
