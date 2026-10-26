CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_cur_xxx') THEN
		DROP PROCEDURE u820_cur_xxx;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

create procedure "dba".u820_cur_xxx(	v_unidad_acad	like sga_alumnos.unidad_academica,
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
	define v_resu	numeric(1);
	define v_c_resu	char(76);
	define v_cantidad	numeric(2);
	
	select distinct materia
	from sga_cursadas
	where materia in ('xxx', 'yyy', 'www')
		and resultado = 'A'
		and fin_vigencia_regul > today
		and legajo = v_legajo
		and carrera = v_carrera
	into temp temp;

	select count(*) into v_cantidad
	from temp;

	if v_cantidad  >= 2 then
		return 1, '';
	else
		return -1, 'No tenés al menos dos de las siguientes materias regulares: xxx, yyy, www';
	end if;
end;
end procedure;
-- *************** Fin del procedimiento "dba".u820_cur_xxx ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".u820_cur_xxx
-- *****************************************************************************
revoke execute on "dba".u820_cur_xxx from public;
grant execute on "dba".u820_cur_xxx to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_cur_xxx to internet; -- Rol de usuario de Internet