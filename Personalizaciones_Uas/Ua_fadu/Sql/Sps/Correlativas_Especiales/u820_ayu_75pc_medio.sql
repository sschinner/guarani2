CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_ayu_75pc_medio') THEN
		DROP PROCEDURE u820_ayu_75pc_medio;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


create procedure "dba".u820_ayu_75pc_medio (	v_unidad_acad	like sga_alumnos.unidad_academica,
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
	define v_version_vigente	char(3);
	define v_materias		numeric(5);
	define vi_creditos		numeric(5);
	define aux_creditos		numeric(5);
	define vc_materia		varchar(10);	
	define vc_resultado 	char(1);

	-- si hay algun error
	ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo
		RETURN -1, errorInfo;
	END EXCEPTION;
	

	let v_resu = 1;
	let v_c_resu = "";
	let v_materias = 0;

	select version_actual  into v_version_vigente
	from sga_planes
	where carrera =  v_carrera
		and plan = v_plan;


	select materia
	from vw_hist_academica 
	where legajo = v_legajo
		and carrera = v_carrera
		and plan = v_plan
		and resultado = 'A'
		and materia in ('A0316', 'A0323', 'A0317', 'A0318', 'A0324', 'A0322', 'A0329', 'A0319', 'A0325', 'A0320', 'A0326', 'A0327', 'A0321', 'A0328')
	Into Temp aux_materias;


	select count(h.materia) into v_materias
	from aux_materias h
		join sga_atrib_mat_plan a
		  on h.materia = a.materia
			and a.carrera = v_carrera
			and a.plan = v_plan
			and a.version = v_version_vigente;

	if v_materias is null then
		let v_materias = 0;
	end if;
	
	if v_carrera = "1" and v_plan = "2001" then
		if v_materias < 11 then
			let v_resu = -1;
			let v_c_resu = "No tenés el 75% del ciclo medio aprobado para cursar esta materia";
		end if;
	end if;

drop table aux_materias;
return v_resu, v_c_resu;

end;

end procedure;
-- *************** Fin del procedimiento "dba".u820_ayu_75pc_medio ******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".u820_ayu_75pc_medio
-- *****************************************************************************
revoke execute on "dba".u820_ayu_75pc_medio from public;
grant execute on "dba".u820_ayu_75pc_medio to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_ayu_75pc_medio to internet; -- Rol de usuario de Internet