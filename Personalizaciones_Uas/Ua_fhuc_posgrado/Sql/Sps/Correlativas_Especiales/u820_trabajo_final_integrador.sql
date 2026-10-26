CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_trabajo_final_integrador') THEN
		DROP PROCEDURE u820_trabajo_final_integrador;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Procedimiento: u820_trabajo_final_integrador
-- Version 2.9.2
-- Descripcion: Verifica que el alumno tenga aprobados todos los modulos y seminarios,
-- y la materia EMM21 de la carrera Especialización en Educación Matemática.

-- Recibe:     	- carrera
--              - legajo
--				- plan
	
-- Retorna:      1: OK
--				-1: Debe alguna de las siguientes materias: XXXX

-- EEM08 - Seminario I
-- EEM12 - Seminario II
-- EEM20 - Seminario III
-- EEM21 - La escuela...

-- EMMI - Modulo I
-- EMMII - Modulo II
-- EEM22 - Modulo III

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

CREATE PROCEDURE "dba".u820_trabajo_final_integrador
	(	
	v_carrera		LIKE sga_alumnos.carrera,
	v_legajo		LIKE sga_alumnos.legajo,
	v_plan			LIKE sga_alumnos.plan
	)
RETURNING smallint, varchar(255);

BEGIN

	DEFINE sqlerr		integer;
	DEFINE isamerr		integer;
	DEFINE errorinfo	varchar(76);
	DEFINE v_resu		numeric(1);
	DEFINE v_c_resu		char(128);
	DEFINE _aprobadas	integer;
	DEFINE _materia		varchar(24);
	DEFINE _resultado	char(1);
	DEFINE _creditos	integer;

	-- si hay algun error
	ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo
		RETURN SQLErr, errorInfo;
	END EXCEPTION;
	
	LET v_resu = 1;
	LET v_c_resu = "OK";
	LET _aprobadas = 0;

	SELECT materia
	FROM vw_hist_academica 
	WHERE legajo = v_legajo
		AND carrera = v_carrera
		AND plan = v_plan
		AND resultado = 'A'
		AND materia IN ('EEM08','EEM12','EEM20','EEM21')
	INTO TEMP aux_materias;

	-- Cuento las materias normales aprobadas
	SELECT count(*) INTO _aprobadas FROM aux_materias; 
	DROP TABLE aux_materias;
	
	-- Cuento las materias genericas aprobadas
	FOREACH SELECT materia INTO _materia FROM sga_materias WHERE materia IN ('EMMI', 'EMMII', 'EEM22')
		EXECUTE PROCEDURE sp_resultGenerica('FHUC','40', v_legajo, '40', NULL, _materia) INTO _resultado, _creditos;

		IF _resultado = 'A' THEN
			LET _aprobadas = _aprobadas + 1; 
		END IF;
	END FOREACH;				
   	
	IF _aprobadas < 7 THEN
		LET v_resu = -1;
		LET v_c_resu = 'Debe alguna de las siguientes materias: EEM08, EEM12, EEM20, EEM21, EMMI, EMMII, EEM22.';	
	END IF; 

	RETURN v_resu, v_c_resu;

END;
END PROCEDURE;


-- EXECUTE PROCEDURE "dba".u820_trabajo_final_integrador	('40',	'32860891-9',	'2001'	)

-- *****************************************************************************
-- Permisos del procedimiento 
-- *****************************************************************************
revoke execute on "dba".u820_trabajo_final_integrador from public;
grant execute on "dba".u820_trabajo_final_integrador to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_trabajo_final_integrador to internet; -- Rol de usuario de Internet
