CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_cur_22023') THEN
		DROP PROCEDURE u820_cur_22023;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

create procedure "dba".u820_cur_22023(	v_unidad_acad	like sga_alumnos.unidad_academica,
				v_carrera		like sga_alumnos.carrera,
				v_legajo		like sga_alumnos.legajo,
				v_materia		like sga_actas_examen.materia,
				v_plan		like sga_alumnos.plan,
				v_version		like sga_actas_examen.version)
				
		returning smallint, varchar(255);

DEFINE sqlerr		integer;
DEFINE isamerr		integer;
DEFINE errorinfo		varchar(76);

-- si hay algun error
ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo
	RETURN -1, errorInfo;
END EXCEPTION;

begin
	define vc_resultado	char(1);
	define vc_puntaje	integer;
	define vc_puntaje_requerido	integer;
	define vc_mat_generica	varchar(5);

	LET vc_mat_generica = '25001';
	LET vc_puntaje_requerido = '120';
	
	EXECUTE PROCEDURE sp_resultGenerica(v_unidad_acad, v_carrera, v_legajo, null, null, vc_mat_generica) into vc_resultado, vc_puntaje;

	if vc_puntaje >= vc_puntaje_requerido then
		return 1, '';
	else
		return -1, 'No tenés las materias optativas necesarias para cursar esta materia';
	end if;
end;
end procedure;
-- *************** Fin del procedimiento "dba".u820_cur_22023 ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".u820_cur_22023 
-- *****************************************************************************
revoke execute on "dba".u820_cur_22023 from public;
grant execute on "dba".u820_cur_22023 to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_cur_22023 to internet; -- Rol de usuario de Internet

-- *************************** Pruebas de ejecucion **********************************
-- EXECUTE PROCEDURE "dba".u820_cur_22023 ('FBCB', '0302', '34147851-6', '22023', '1997', '55')
-- EXECUTE PROCEDURE "dba".u820_cur_22023 ('FBCB', '0302', '39255527-3', '22023', '1997', '55')