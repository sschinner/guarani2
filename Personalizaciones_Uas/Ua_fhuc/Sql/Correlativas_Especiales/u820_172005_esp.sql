CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_172005_esp') THEN
		DROP PROCEDURE u820_172005_esp;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Correlativa especial Profesorado de Filosofia: 2/3 del 1er. Ciclo aprobadas para acceder al 2do. Ciclo
-- ("FIL01", "FIL02", "FIL04", "N1IC", "FIL11", "FIL12", "FIL13", "N2IC", "PF001", "OPF01", "PF002", "OPF2")

--drop procedure "dba".u820_172005_esp;
create procedure "dba".u820_172005_esp(	v_unidad_acad	like sga_alumnos.unidad_academica,
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
		and materia in  ('FG002','FG003','FIL001','FIL02','FIL03','FIL04','FIL08','FIL09','FIL10','FIL11','FIL12','FIL13','FIL14','FIL47','FIL53','FIL54','HIS01','HIS02','HIS11','HIS18','HIS23','LET01','LET02','LET06','LET07','LET08','LET10','LET28','LET30','LET31','MAT01','OF02','PF001','PF002','SOC03','SOC04')
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

-- *************** Fin del procedimiento "dba".u820_172005_esp ********************

REVOKE execute ON "dba".u820_172005_esp FROM public;
GRANT execute ON "dba".u820_172005_esp to guarani; -- Rol de usuarios de Gestion
GRANT execute ON "dba".u820_172005_esp to internet; -- Rol de usuario de Internet
