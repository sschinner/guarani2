CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_032000_esp3_pdoc') THEN
		DROP PROCEDURE u820_032000_esp3_pdoc;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


create procedure "dba".u820_032000_esp3_pdoc(	v_unidad_acad	like sga_alumnos.unidad_academica,
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
	define v_cantidad1		numeric(5);
	define v_cantidad2		numeric(5);

	-- si hay algun error
	ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo
		RETURN -1, errorInfo;
	END EXCEPTION;
	
	let v_resu = 1;
	let v_c_resu= "";


	select distinct materia
	from vw_hist_academica 
	where legajo = v_legajo
		and resultado = 'A'
		and materia in ("GEO01", "GEO02", "GEO03", "GEO04", "GEO05", "GEO08", "GEO09", "GEO10", "GEO20", "GEO18", "GEO19", "FG004")
	Into Temp aux_materias;

	select count(*) into v_cantidad
	from aux_materias h;
	
	select distinct materia
	from vw_hist_academica 
	where legajo = v_legajo
		and resultado = 'A'
		and materia in ("GEO06", "GEO07", "GEO14", "GEO15", "GEO16", "GEO11", "GEO12", "GEO13", "FD001", "FD002", "FD003", "GEO27", "OG31", "FG002", "FG001", "FG003")
	Into Temp aux_materias1;

	select count(*) into v_cantidad1
	from aux_materias1 h;

	select distinct materia
	from vw_hist_academica 
	where legajo = v_legajo
		and resultado = 'A'
		and materia in ("GEO14", "GEO15", "GEO16")
	Into Temp aux_materias2;

	select count(*) into v_cantidad2
	from aux_materias2 h;

	if v_cantidad < 8 or v_cantidad1 < 10 or v_cantidad2 < 1  then
		let v_resu = -1;
		let v_c_resu = "No tenés la cantidad de materias necesarias para rendir esta materia.";
	end if;

	drop table aux_materias;
	drop table aux_materias1;
	drop table aux_materias2;
	return v_resu, v_c_resu;
end;

end procedure;

-- *************** Fin del procedimiento "dba".u820_032000_esp3_pdoc ********************

REVOKE execute ON "dba".u820_032000_esp3_pdoc FROM public;
GRANT execute ON "dba".u820_032000_esp3_pdoc to guarani; -- Rol de usuarios de Gestion
GRANT execute ON "dba".u820_032000_esp3_pdoc to internet; -- Rol de usuario de Internet