CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_porf_let_let51_esp') THEN
		DROP PROCEDURE u820_Porf_let_let51_esp;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();



create procedure "dba".u820_Porf_let_let51_esp(	v_unidad_acad	like sga_alumnos.unidad_academica,
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
		and materia in ("LET01", "LET05", "LET02", "LET03", "LET04", "LET06", "LET07", "LET08", "LET09", "LET10", "FG001", "FG002", "FG003", "FG004", "LET11","LET12","LET13","LET14","LET15","LET16","LET17","LET18")
	Into Temp aux_materias;

	select count(*) into v_cantidad
	from aux_materias h;
	
	if v_cantidad < 8 then
		let v_resu = -1;
		let v_c_resu = "No tenés la cantidad de materias necesarias para rendir esta materia.";
	end if;
	if "LET01" not in (select materia from aux_materias) then
		let v_resu = -1;
		let v_c_resu = "Para rendir materias del segundo bloque nececitas 'Int. a los Est. Lit.'.";
	end if
	if "LET06" not in (select materia from aux_materias) then
		let v_resu = -1;
		let v_c_resu = "Para rendir materias del segundo bloque nececitas 'Lingüística General'.";

	end if
	if "LET07" not in (select materia from aux_materias) then
		let v_resu = -1;
		let v_c_resu = "Para rendir materias del segundo bloque nececitas 'Gramática del Español'.";
	end if
	if "FG004" not in (select materia from aux_materias) then

		let v_resu = -1;
		let v_c_resu = "Para rendir materias del segundo bloque nececitas 'Prac. de la Com. Oral y Esc.'.";
	end if
	
	if (not exists(select materia from vw_hist_academica 
			where legajo = v_legajo
			and resultado = 'A'
			and materia in ("LET11", "LET12", "LET13", "LET15"))  ) then

		let v_resu = -1;
		let v_c_resu = "Para rendir  Didáctica de la lengua y la literatura nececitas tener aprobada al menos 1 materia del área Literatura y Teoría Literaria.";
	end if

	if (not exists(	select materia
			from vw_hist_academica 
			where legajo = v_legajo
				and resultado = 'A'
				and materia in ("LET14", "LET16", "LET17", "LET18")) ) then

		let v_resu = -1;
		let v_c_resu = "Para rendir  Didáctica de la lengua y la literatura nececitas tener aprobada al menos 1 materia del área Ciencias del Lenguaje.";
	end if

	drop table aux_materias;
	return v_resu, v_c_resu;
end;

end procedure;

-- *************** Fin del procedimiento "dba".u820_Porf_let_let51_esp ********************

REVOKE execute ON "dba".u820_Porf_let_let51_esp FROM public;
GRANT execute ON "dba".u820_Porf_let_let51_esp to guarani; -- Rol de usuarios de Gestion
GRANT execute ON "dba".u820_Porf_let_let51_esp to internet; -- Rol de usuario de Internet




