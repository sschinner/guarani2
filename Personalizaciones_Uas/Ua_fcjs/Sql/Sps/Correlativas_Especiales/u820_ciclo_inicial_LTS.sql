CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_ciclo_inicial_lts') THEN
		DROP PROCEDURE u820_ciclo_inicial_lts;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Correlativa especial FCJS: 2/3 del Ciclo Inicial aprobadas para acceder al Ciclo Superior de LTS
-- (Materias del ciclo 301 - Ciclo 1ro. Trabajo Social)

create procedure "dba".u820_ciclo_inicial_lts (	v_unidad_acad	like sga_alumnos.unidad_academica,
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
		and materia in ("TS001", "TS002", "TS003", "TS004", "TS005", "TS006", "TS007", "TS008", "TS009", "TS010", "TS011", "TS012", "TS013", "TS014")
	Into Temp aux_materias;

	select count(*) into v_cantidad
	from aux_materias h;
	
	if v_cantidad < 9 then
		let v_resu = -1;
		let v_c_resu = "No tenés la cantidad de materias necesarias para rendir/cursar esta materia.";
	end if;

	drop table aux_materias;
	return v_resu, v_c_resu;
end;

end procedure;
-- *************** Fin del procedimiento "dba".u820_ciclo_inicial_lts ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".u820_ciclo_inicial_lts 
-- *****************************************************************************
revoke execute on "dba".u820_ciclo_inicial_lts from public;
grant execute on "dba".u820_ciclo_inicial_lts to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_ciclo_inicial_lts to internet; -- Rol de usuario de Internet

-- *************************** Pruebas de ejecucion **********************************
-- execute procedure "dba".u820_ciclo_inicial_lts ('FCJS', '1','27633370-2','18', '2000', 2);
