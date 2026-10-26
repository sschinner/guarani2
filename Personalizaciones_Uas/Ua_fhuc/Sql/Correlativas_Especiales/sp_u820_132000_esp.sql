CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_132000_esp') THEN
		DROP PROCEDURE u820_132000_esp;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

create procedure "dba".u820_132000_esp(	v_unidad_acad	like sga_alumnos.unidad_academica,
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
	define v_cantidad		numeric(5);

	-- si hay algun error
	ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo
		RETURN -1, errorInfo;
	END EXCEPTION;
	
	let v_resu = 1;
	let v_c_resu = "";


	select distinct materia
	from vw_hist_academica 
	where legajo =v_legajo
		and resultado = 'A'
		and materia in ("SOC01", "SOC02", "HIS23", "HIS22", "FIL03", "CP003", "SOC04", "SOC05", "GEO31", "HIS11", "SOC06", "AIE I")
	Into Temp aux_materias;

	select count(*) into v_cantidad
	from aux_materias h;
	

	if v_cantidad < 8 then
		let v_resu = -1;
		let v_c_resu = "No tenés la cantidad de materias necesarias para rendir esta materia.";
	end if;

	drop table aux_materias;
	return v_resu, v_c_resu;
end;

end procedure;

-- *************** Fin del procedimiento "dba".u820_132000_esp ********************

REVOKE execute ON "dba".u820_132000_esp FROM public;
GRANT execute ON "dba".u820_132000_esp to guarani; -- Rol de usuarios de Gestion
GRANT execute ON "dba".u820_132000_esp to internet; -- Rol de usuario de Internet