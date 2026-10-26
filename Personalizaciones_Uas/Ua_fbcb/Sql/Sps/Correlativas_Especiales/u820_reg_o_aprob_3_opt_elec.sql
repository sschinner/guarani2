CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_reg_o_aprob_3_opt_elec') THEN
		DROP PROCEDURE u820_reg_o_aprob_3_opt_elec;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.9.2
-- Procedure u820_reg_o_aprob_3_opt_elec
--
-- Controla si un alumno posee al menos 3 materias aprobadas ó regularizadas
-- correspondientes a las materias genéricas LND y LNG.
-- *****************************************************************************

CREATE PROCEDURE "dba".u820_reg_o_aprob_3_opt_elec(	
				v_unidad_acad		LIKE sga_alumnos.unidad_academica,
				v_carrera		LIKE sga_alumnos.carrera,
				v_legajo		LIKE sga_alumnos.legajo,
				v_materia		LIKE sga_actas_examen.materia,
				v_plan			LIKE sga_alumnos.plan,
				v_version		LIKE sga_actas_examen.version)
				
		RETURNING smallint, varchar(255);

DEFINE sqlerr		integer;
DEFINE isamerr		integer;
DEFINE errorinfo	varchar(76);

-- si hay algun error
ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo
	RETURN -1, errorInfo;
END EXCEPTION;

BEGIN
	DEFINE v_cantidad_reg	numeric(2);
	DEFINE v_cantidad_aprob	numeric(2);
	DEFINE v_total		numeric(2);
	
	SELECT DISTINCT materia
	FROM sga_cursadas
	WHERE materia in (SELECT DISTINCT materia_optativa FROM sga_mat_genericas WHERE materia_generica IN ('LND', 'LNG'))
		AND resultado = 'A'
		AND fin_vigencia_regul > today
		AND legajo = v_legajo
		AND carrera = v_carrera
	INTO TEMP temp_reg;

	SELECT count(*) into v_cantidad_reg FROM temp_reg; -- cantidad de regularizadas
	DROP TABLE temp_reg;

	SELECT DISTINCT materia
	FROM vw_hist_academica
	WHERE materia in (SELECT DISTINCT materia_optativa FROM sga_mat_genericas WHERE materia_generica IN ('LND', 'LNG'))
		AND resultado IN ( 'A', 'P')
		AND legajo = v_legajo
		AND carrera = v_carrera
	INTO TEMP temp_aprob;

	SELECT count(*) INTO v_cantidad_aprob FROM temp_aprob; -- cantidad de aprobadas
	DROP TABLE temp_aprob;

	LET v_total = v_cantidad_reg + v_cantidad_aprob;

	IF v_total  >= 3 THEN
		RETURN 1, 'Posee al menos tres asignaturas aprobadas/regularizadas de las genéricas LND y/o LNG';
	ELSE
		RETURN -1, 'No tenés al tres materias aprobadas/regularizadas de las genéricas LND y/o LNG';
	END IF;
END;
END PROCEDURE;
-- *************** Fin del procedimiento "dba".u820_reg_o_aprob_3_opt_elec ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".u820_reg_o_aprob_3_opt_elec
-- *****************************************************************************
revoke execute on "dba".u820_reg_o_aprob_3_opt_elec FROM public;
grant execute on "dba".u820_reg_o_aprob_3_opt_elec to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_reg_o_aprob_3_opt_elec to internet; -- Rol de usuario de Internet
