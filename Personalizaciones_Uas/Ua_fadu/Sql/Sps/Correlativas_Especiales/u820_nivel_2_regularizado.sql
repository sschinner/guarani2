CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_nivel_2_regularizado') THEN
		DROP PROCEDURE u820_nivel_2_regularizado;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Procedimiento: u820_nivel_2_regularizado
-- Version 2.9.2
-- Descripcion: Verifica que el alumno tenga regularizadas las materias del nivel 2

-- Recibe:     	
--				- legajo
--				- carrera
--              - plan
--				- version
	
-- Retorna:      1: OK
--				-1: Debe tener regularizadas las materias de nivel 2.

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

CREATE PROCEDURE "dba".u820_nivel_2_regularizado
	(	
	v_legajo		LIKE sga_alumnos.legajo,
	v_carrera		LIKE sga_alumnos.carrera,	
	v_plan			LIKE sga_alumnos.plan,
	v_version 		LIKE sga_planes.version_actual
	)
RETURNING smallint, varchar(255);

BEGIN
	DEFINE sqlerr		integer;
	DEFINE isamerr		integer;
	DEFINE errorinfo	varchar(76);
	DEFINE v_resu		numeric(1);
	DEFINE v_c_resu		char(256);
	DEFINE _materia_adeudada LIKE sga_atrib_mat_plan.materia;

-- Si hay algun error
ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo
	RETURN SQLErr, errorInfo;
END EXCEPTION;
	
LET v_resu = 1;
LET v_c_resu = "OK";

-- Cantidad de materias de nivel 2 para la carrera, plan y version
SELECT materia 
FROM sga_atrib_mat_plan 
WHERE carrera = v_carrera AND anio_de_cursada = 2 AND plan = v_plan AND version = v_version 
INTO TEMP _materias_nivel_2;

-- Materias regularizadas por el alumno
SELECT DISTINCT materia 
	FROM vw_hist_academica 
	WHERE legajo = v_legajo
		AND carrera = v_carrera
		AND plan = v_plan
		AND resultado = 'A'
		AND materia IN (SELECT * FROM _materias_nivel_2)

UNION

SELECT DISTINCT H.materia 
	FROM sga_cursadas H 
	WHERE H.legajo = v_legajo
		AND H.carrera = v_carrera
		AND H.plan = v_plan
		AND H.resultado = 'A'
		AND H.fin_vigencia_regul >= TODAY
		AND H.materia IN (SELECT * FROM _materias_nivel_2)

INTO TEMP _materias;

-- Materias que estan en el plan pero NO estan regularizadas
SELECT * 
FROM _materias_nivel_2 
WHERE materia NOT IN (SELECT * FROM _materias)
INTO TEMP _adeuda;

-- Si adeuda alguna materia
IF EXISTS (SELECT * FROM _adeuda) THEN 
	LET v_resu = -1;
--	LET v_c_resu = ' '; 		

	-- Listo las materias (no se usa en el retorno porque ahora los mensajes van codificados)
--	FOREACH SELECT materia INTO _materia_adeudada FROM _adeuda 
--		LET v_c_resu = _materia_adeudada || ' - ' ||  v_c_resu;
--	END FOREACH;
--
--	LET v_c_resu = 'Debe regularizar las siguientes materias del nivel 2: ' || v_c_resu;
	LET v_c_resu = "82001003";  
END IF;

DROP TABLE _materias_nivel_2;
DROP TABLE _materias;
DROP TABLE _adeuda;

RETURN v_resu, v_c_resu;

END;
END PROCEDURE;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Permisos del procedimiento 
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

revoke execute on "dba".u820_nivel_2_regularizado from public;
grant execute on "dba".u820_nivel_2_regularizado to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_nivel_2_regularizado to internet; -- Rol de usuario de Internet
