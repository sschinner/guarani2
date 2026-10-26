CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_modulo_regularizado') THEN
		DROP PROCEDURE u820_modulo_regularizado;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Procedimiento: u820_modulo_regularizado
-- Version 2.9.2
-- Descripcion: Retorna si un alumno tiene regularizado el modulo del trayecto que incluye al seminario.
-- Requerimiento de Posgrado FHUC

-- Recibe:     	- carrera
--              - seminario (materia)
--				- legajo
	
-- Retorna:      1: OK
--				-1: Debe regularizar el módulo <modulo>.

-- Usa los SP: 	- sp820_RegulAlumno
--				- sp_resultGenerica
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

CREATE PROCEDURE "dba".u820_modulo_regularizado
	(	
	v_carrera		LIKE sga_alumnos.carrera,
	v_seminario		LIKE sga_materias.materia,
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
	DEFINE _modulo		varchar(24);
	DEFINE _resultado	char(1);
	DEFINE _creditos	integer;


	-- si hay algun error
	ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo
		RETURN SQLErr, errorInfo;
	END EXCEPTION;
	
	LET v_resu = 1;
	LET v_c_resu = 'OK';

	-- Obtengo el modulo a partir del seminario.
	IF v_seminario = 'EEM08' 	THEN -- Seminario I
		LET _modulo = 'EMMI';

	ELIF v_seminario = 'EEM12' 	THEN -- Seminario II
		LET _modulo = 'EMMII';

	ELIF v_seminario = 'EEM20' 	THEN -- Seminario III
		LET _modulo = 'EEM22';

	-- Si no es un seminario, asumo que me pasan directamente el modulo.
	ELSE LET _modulo = v_seminario;

	END IF;

	-- Obtengo el resultado de aprobacion del modulo.
	EXECUTE PROCEDURE sp_resultGenerica('FHUC', v_carrera, v_legajo, NULL, NULL, _modulo) INTO _resultado, _creditos;
	
	-- Si el modulo esta aprobado, retorno.
	IF _resultado = 'A' THEN
		RETURN v_resu, v_c_resu;
	END IF;

	-- Si no, cuento los cursos que tiene aprobados en el modulo.
	SELECT count(*) INTO _aprobados
		FROM vw_hist_academica H
		JOIN sga_mat_genericas G 	
			ON H.materia = G.materia_optativa
		WHERE 	H.legajo = v_legajo
			AND H.carrera = v_carrera
			AND G.materia_generica = _modulo
			AND H.resultado = 'A'; 		

	-- cuento los cursos que tiene regularizados en el modulo.
	SELECT count(*) INTO _regularizados
		FROM sga_cursadas C 
		JOIN sga_mat_genericas G 	
			ON C.materia = G.materia_optativa
		WHERE 	C.carrera = v_carrera 
			AND C.legajo =  v_legajo 
			AND G.materia_generica = _modulo 
			AND (C.estado = 'A') OR (C.fin_vigencia_regul >= TODAY);

	LET _total = _aprobados + _regularizados;
	
	-- Para el Modulo II, si tiene al menos regularizado el unico curso, retorno.			
	IF (_modulo = 'EMMII') AND (_total > 0) THEN
		RETURN v_resu, v_c_resu;
	
	-- Si tiene mas de dos cursos regularizados en un modulo, retorno.	
	ELIF
		(_total > 2) THEN
			RETURN v_resu, v_c_resu;		
	END IF;

	LET v_resu = -1;  
	LET v_c_resu = 'Debe regularizar el modulo ' || _modulo;
	
	RETURN v_resu, v_c_resu;

END;
END PROCEDURE;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Permisos del procedimiento 
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

revoke execute on "dba".u820_modulo_regularizado from public;
grant execute on "dba".u820_modulo_regularizado to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_modulo_regularizado to internet; -- Rol de usuario de Internet
