CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_exa_d0320') THEN
		DROP PROCEDURE u820_exa_d0320;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

create procedure "dba".u820_exa_d0320(v_unidad_acad	like sga_alumnos.unidad_academica,
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
DEFINE vc_idioma	integer;

-- si hay algun error
ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo
   RETURN -1, errorInfo;
END EXCEPTION;

BEGIN
	LET v_resu = 1;
	LET v_c_resu = "";
	LET vc_puntaje = "";
	LET vc_idioma = "";
	
	-- Verifico que tenga un idioma extranjero acreditado.
	SELECT count(materia)
		INTO vc_idioma
		FROM vw_hist_academica
		WHERE unidad_academica = v_unidad_acad
		AND carrera = v_carrera
		AND legajo = v_legajo
		AND plan = v_plan
    		AND resultado = 'A'
    		AND materia IN ('C0304', 'E0413', 'E0120', 'E0038');  

	IF (vc_idioma < 1) THEN
		RETURN -1, 'No tenés acreditado idioma extranjero';
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
    		AND mg.materia_generica IN ('OPC09', 'OPC11', 'E0000');  

	IF (vc_puntaje < 18) THEN
		RETURN -1, 'No tenés el total de 18 créditos aprobados para rendir la materia';
	END IF;

	return v_resu, v_c_resu;
end;
end procedure;


-- *************** Fin del procedimiento  ******************

-- *****************************************************************************
-- Permisos del procedimiento 
-- *****************************************************************************
revoke execute on "dba".u820_exa_d0320 from public;
grant execute on "dba".u820_exa_d0320 to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_exa_d0320 to internet; -- Rol de usuario de Internet