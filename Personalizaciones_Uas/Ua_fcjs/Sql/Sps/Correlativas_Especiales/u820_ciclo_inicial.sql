CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_ciclo_inicial') THEN
		DROP PROCEDURE u820_ciclo_inicial;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- Correlativa especial FCJS: 2/3 del Ciclo Inicial aprobadas para acceder al Ciclo Superior
-- ("1", "2", "3", "4", "5", "7", "8", "9", "10", "11")

create procedure "dba".u820_ciclo_inicial (	v_unidad_acad	like sga_alumnos.unidad_academica,
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


	if v_plan = '2018' then
		-- Plan 2018 cambian las materias del primer ciclo (#67833)
		select distinct materia
		from vw_hist_academica 
		where legajo =v_legajo
			and resultado = 'A'
			--and plan = v_plan
			and materia in ("1", "2", "3", "4", "5", "7", "8", "11", "118", "220")
		Into Temp aux_materias;
	else
		select distinct materia
		from vw_hist_academica 
		where legajo =v_legajo
			and resultado = 'A'
			--and plan = v_plan
			and materia in ("1", "2", "3", "4", "5", "7", "8", "9", "10", "11")
		Into Temp aux_materias;		
	end if;

	select count(*) into v_cantidad
	from aux_materias h;
	
	if v_cantidad < 6 then
		let v_resu = -1;
		let v_c_resu = "No tenés la cantidad de materias necesarias para rendir/cursar esta materia.";
	end if;

	drop table aux_materias;
	return v_resu, v_c_resu;
end;

end procedure;
-- *************** Fin del procedimiento "dba".u820_ciclo_inicial ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".u820_ciclo_inicial 
-- *****************************************************************************
revoke execute on "dba".u820_ciclo_inicial from public;
grant execute on "dba".u820_ciclo_inicial to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_ciclo_inicial to internet; -- Rol de usuario de Internet

-- *************************** Pruebas de ejecucion **********************************
-- execute procedure "dba".u820_ciclo_inicial ('FCJS', '1','43164040-8','18', '2018', 1);	-- tiene 4 aprobadas
-- execute procedure "dba".u820_ciclo_inicial ('FCJS', '1','43349736-7','18', '2018', 1);	-- tiene 3 aprobadas
-- execute procedure "dba".u820_ciclo_inicial ('FCJS', '1','27006782-4','18', '2018', 1);	-- tiene 7 aprobadas

-- SELECT * FROM sga_alumnos WHERE nro_inscripcion IN ('FCJS-15048','FCJS-14984')
-- execute procedure "dba".u820_ciclo_inicial ('FCJS', '1','40281503-7','18', '2018', 1);	-- tiene 6 aprobadas
-- execute procedure "dba".u820_ciclo_inicial ('FCJS', '1','39261271-8','18', '2018', 1);	-- tiene 6 aprobadas

-- execute procedure "dba".u820_ciclo_inicial ('FCJS', '1','37404547-5','18', '2000', 1);	-- tiene 5
-- execute procedure "dba".u820_ciclo_inicial ('FCJS', '1','36011468-4','18', '2000', 1);	-- tiene 10
