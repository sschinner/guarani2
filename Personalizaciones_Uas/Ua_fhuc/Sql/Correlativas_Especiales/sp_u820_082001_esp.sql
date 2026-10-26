CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_082001_esp') THEN
		DROP PROCEDURE u820_082001_esp;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

create procedure "dba".u820_082001_esp(	v_unidad_acad	like sga_alumnos.unidad_academica,
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
		and materia in ("LET01", "LET05", "LET02", "LET03", "LET04", "LET06", "LET07", "LET08", "LET09", "LET10", "FG004")
	Into Temp aux_materias;

	select count(*) into v_cantidad
	from aux_materias h;
	
	if v_cantidad < 8 then
		let v_resu = -1;
		let v_c_resu = '82006001' || ', ' || 'al menos 8 materias aprobadas';
	end if;
	if "LET01" not in (select materia from aux_materias) then
		let v_resu = -1;
		let v_c_resu = '82006001' || ', ' || 'Int. a los Est. Lit.';
	end
 if
	if "LET06" not in (select materia from aux_materias) then
		let v_resu = -1;
		let v_c_resu = '82006001' || ', ' || 'Lingüística General';
	end if
	if "LET07" not in (select materia from aux_materias) then
		let v_resu = -1;
		let v_c_resu = '82006001' || ', ' || 'Gramática del Español';
	end if
	if "FG004" not in (select materia from aux_materias) then
		let v_resu = -1;
		let v_c_resu = '82006001' || ', ' || 'Prac. de la Com. Oral y Esc.';
	end if

	drop table aux_materias;
	return v_resu, v_c_resu;
end;
end procedure;

-- *************** Fin del procedimiento "dba".u820_082001_esp ********************

REVOKE execute ON "dba".u820_082001_esp FROM public;
GRANT execute ON "dba".u820_082001_esp to guarani; -- Rol de usuarios de Gestion
GRANT execute ON "dba".u820_082001_esp to internet; -- Rol de usuario de Internet