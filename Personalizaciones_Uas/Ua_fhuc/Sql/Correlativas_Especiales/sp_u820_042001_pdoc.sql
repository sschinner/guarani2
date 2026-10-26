CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_042001_pdoc') THEN
		DROP PROCEDURE u820_042001_pdoc;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


create procedure "dba".u820_042001_pdoc(	v_unidad_acad	like sga_alumnos.unidad_academica,
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
	let v_c_resu = "";




	select distinct materia
	from vw_hist_academica 
	where legajo = v_legajo
		and resultado = 'A'
		and materia in ("LET01", "LET02", "LET03", "LET04", "LET05", "LET06", "LET07", "LET08", "LET09", "LET10", "FG001", "FG002", "FG003", "FG004")
	Into Temp aux_materias;

	select count(*) into v_cantidad
	from aux_materias h;
	
	if v_cantidad < 12 then
		let v_resu = -1;
		let v_c_resu = "No tenés las materias del primer ciclo, necesario para cursar esta materia.";
	end if;

	select distinct materia
	from vw_hist_academica 
	where legajo = v_legajo
		and resultado = 'A'
		and materia in ("LET11", "LET12", "LET13", "LET15", "LET19")
	Into Temp aux_materias1;

	select count(*) into v_cantidad1
	from aux_materias1 h;
	
	if v_cantidad1 < 2 then
		let v_resu = -1;
		let v_c_resu = "No tenés el primer ciclo, necesario para rendir esta materia.";
	end if;

	select distinct materia
	from vw_hist_academica 
	where legajo = v_legajo
		and resultado = 'A'
		and materia in ("LET14", "LET16","LET17", "LET18")
	Into Temp aux_materias2;

	select count(*) into v_cantidad2
	from aux_materias2 h;
	
	if v_cantidad2 < 2 then
		let v_resu = -1;
		let v_c_resu = "No tenés el primer ciclo, necesario para rendir esta materia.";
	end if;

	drop
 table aux_materias;
	drop table aux_materias1;
	drop table aux_materias2;
	return v_resu, v_c_resu;
end;

end procedure;

-- *************** Fin del procedimiento "dba".u820_042001_pdoc ********************

REVOKE execute ON "dba".u820_042001_pdoc FROM public;
GRANT execute ON "dba".u820_042001_pdoc to guarani; -- Rol de usuarios de Gestion
GRANT execute ON "dba".u820_042001_pdoc to internet; -- Rol de usuario de Internet