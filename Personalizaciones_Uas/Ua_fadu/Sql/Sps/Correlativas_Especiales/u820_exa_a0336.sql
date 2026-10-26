CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_exa_a0336') THEN
		DROP PROCEDURE u820_exa_a0336;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

create procedure "dba".u820_exa_a0336(v_unidad_acad	like sga_alumnos.unidad_academica,
				v_carrera		like sga_alumnos.carrera,
				v_legajo		like sga_alumnos.legajo,
				v_materia		like sga_actas_examen.materia,
				v_plan		like sga_alumnos.plan,
				v_version		like sga_actas_examen.version)
				
		returning smallint, 	-- status: -1 error/ 1 OK
			  varchar(255);

DEFINE sqlerr		integer;
DEFINE isamerr		integer;
DEFINE errorinfo	varchar(76);
DEFINE v_resu 		numeric(1);
DEFINE v_c_resu 	char(76);
DEFINE vc_puntaje	integer;
DEFINE vc_mat_opc08	varchar(5);
DEFINE vc_cant_opc08	integer;
DEFINE vc_mat_opc10	varchar(5);
DEFINE vc_cant_opc10	integer;
DEFINE vc_idioma	integer;

-- si hay algun error
ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo

RETURN -1, errorInfo;
END EXCEPTION;

BEGIN
	LET v_resu = 1;
	LET v_c_resu = "";
	LET vc_puntaje = "";
	LET vc_mat_opc08 = "";
	LET vc_cant_opc08 = "";
	LET vc_mat_opc10 = "";
	LET vc_cant_opc10 = "";
	LET vc_idioma = "";
	
	IF (vc_idioma < 1) THEN
		RETURN -1, "No tenés acreditado idioma extranjero";
	END IF;

	-- Verifico si suma 24 créditos en total con las materias optativas
	-- que pertenecen a las materias OPC08, OPC10, OPC13, OPC14, E0000
	SELECT SUM(mg.valor_materia)
		INTO vc_puntaje
    		FROM vw_hist_academica ha, sga_mat_genericas mg
		WHERE ha.unidad_academica = v_unidad_acad
		AND ha.carrera = v_carrera
		AND ha.legajo = v_legajo
		AND ha.plan = v_plan
    		AND ha.resultado = 'A'
    		AND ha.materia = mg.materia_optativa
    		AND mg.materia_generica IN ('OPC08', 'OPC10', 'OPC13', 'OPC14', 'E0000');  

	IF (vc_puntaje < 24) THEN
		RETURN -1, "No tenés el total de 24 créditos aprobados para rendir la materia";
	END IF;

	-- Verifico que contenga aprobadas:
	-- 1 materia de la OPC08 y 1 materia de la OPC10
	-- ó
	-- 2 materias de la OPC10
	SELECT mg.materia_generica, count(mg.materia_optativa)
		INTO vc_mat_opc08, vc_cant_opc08

    		FROM vw_hist_academica ha, sga_mat_genericas mg
		WHERE ha.unidad_academica = v_unidad_acad
		AND ha.carrera = v_carrera
		AND ha.legajo = v_legajo
		AND ha.plan = v_plan
    		AND ha.resultado = 'A'
    		AND ha.materia = mg.materia_optativa

    		AND mg.materia_generica = 'OPC08'
    		GROUP BY mg.materia_generica;

	SELECT mg.materia_generica, count(mg.materia_optativa)
		INTO vc_mat_opc10, vc_cant_opc10
    		FROM vw_hist_academica ha, sga_mat_genericas mg
		WHERE ha.unidad_academica = v_unidad_acad
		AND ha.carrera = v_carrera
		AND ha.legajo = v_legajo
		AND ha.plan = v_plan
    		AND ha.resultado = 'A'
    		AND ha.materia = mg.materia_optativa
    		AND mg.materia_generica = 'OPC10'
    		GROUP BY mg.materia_generica;

	IF (vc_cant_opc08 >= 1 AND vc_cant_opc10 >= 1) THEN
		return v_resu, v_c_resu;
	END IF;

	IF (vc_cant_opc10 >= 2) THEN
		return v_resu, v_c_resu;
	END IF;

	RETURN -1, "No tenés aprobadas las materias obligatorias del Área Historia y/o Área Social";
end;
end procedure;


-- *************** Fin del procedimiento  ******************

-- *****************************************************************************
-- Permisos del procedimiento 
-- *****************************************************************************
revoke execute on "dba".u820_exa_a0336 from public;
grant execute on "dba".u820_exa_a0336 to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_exa_a0336 to internet; -- Rol de usuario de Internet
