CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_exa_a0111') THEN
		DROP PROCEDURE u820_exa_a0111;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

create procedure "dba".u820_exa_A0111(	v_unidad_acad	like sga_alumnos.unidad_academica,
				v_carrera		like sga_alumnos.carrera,
				v_legajo		like sga_alumnos.legajo,
				v_materia		like sga_actas_examen.materia,
				v_plan		like sga_alumnos.plan,
				v_version		like sga_actas_examen.version)
				
		returning smallint, varchar(255);

begin
	define v_resu numeric(1);
	define v_c_resu char(76);

	execute procedure "dba".u820_exa_opc04 (v_unidad_acad, v_legajo, v_carrera, v_plan) into v_resu, v_c_resu;
	return v_resu, v_c_resu;
end;
end procedure;

-- *************** Fin del procedimiento  ******************

-- *****************************************************************************
-- Permisos del procedimiento 
-- *****************************************************************************
revoke execute on "dba".u820_exa_A0111 from public;
grant execute on "dba".u820_exa_A0111 to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_exa_A0111 to internet; -- Rol de usuario de Internet