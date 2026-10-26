CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_012000_ped') THEN
		DROP PROCEDURE u820_012000_ped;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


create procedure "dba".u820_012000_ped(	v_unidad_acad	like sga_alumnos.unidad_academica,
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
		and materia in ("MAT01", "MAT02", "MAT03", "MAT04", "MAT05", "MAT06", "MAT07", "MAT08", "MAT09", "MAT10", "MAT11", "MAT12", "MAT13", "MAT14", "MAT15", "FG001", "FG002", "FG003", "FG004")
	Into Temp aux_materias;

	
select count(*) into v_cantidad
	from aux_materias h;
	
	if v_cantidad < 13 then
		let v_resu = -1;
		let v_c_resu = '82001000';
	end if;

	drop table aux_materias;
	return v_resu, v_c_resu;
end;

end procedure;

-- *************** Fin del procedimiento "dba".u820_012000_ped ********************

REVOKE execute ON "dba".u820_012000_ped FROM public;
GRANT execute ON "dba".u820_012000_ped to guarani; -- Rol de usuarios de Gestion
GRANT execute ON "dba".u820_012000_ped to internet; -- Rol de usuario de Internet
