CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_exa_c0304') THEN
		DROP PROCEDURE u820_exa_c0304;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

create procedure "dba".u820_exa_C0304(	v_unidad_acad	like sga_alumnos.unidad_academica,
					v_carrera		like sga_alumnos.carrera,
					v_legajo		like sga_alumnos.legajo,
					v_materia		like sga_actas_examen.materia,
					v_plan		like sga_alumnos.plan,
					v_version		like sga_actas_examen.version)
				
		returning smallint, varchar(255);

begin

	define sqlerr		integer;
	define isamerr		integer;
	define errorinfo		varchar(76);
	define v_resu		numeric(1);
	define v_c_resu		char(76);

	-- si hay algun error
	ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo
		RETURN -1, errorInfo;
	END EXCEPTION;
	

	let v_resu = 1;
	let v_c_resu = "OK";

	if exists(select materia
	from vw_hist_academica 
	where legajo = v_legajo
		and carrera = v_carrera
		and plan = v_plan
		and resultado = 'A'
		and materia in ('C0311')) then
	
			let v_resu = -1;
			let v_c_resu = '82012003';
	end if;

return v_resu, v_c_resu;

end;

end procedure;


-- *************** Fin del procedimiento  ******************

-- *****************************************************************************
-- Permisos del procedimiento 
-- *****************************************************************************
revoke execute on "dba".u820_exa_C0304 from public;
grant execute on "dba".u820_exa_C0304 to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_exa_C0304 to internet; -- Rol de usuario de Internet