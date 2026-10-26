CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_2ap_bio_b42') THEN
		DROP PROCEDURE u820_2ap_bio_b42;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

create procedure "dba".u820_2ap_bio_b42(	v_unidad_acad	like sga_alumnos.unidad_academica,
				v_carrera		like sga_alumnos.carrera,
				v_legajo		like sga_alumnos.legajo,
				v_materia		like sga_actas_examen.materia,
				v_plan		like sga_alumnos.plan,
				v_version		like sga_actas_examen.version)
				
		returning smallint, varchar(255);

DEFINE sqlerr		integer;
DEFINE isamerr		integer;
DEFINE errorinfo		varchar(76);

-- si hay algun error
ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo
	RETURN -1, errorInfo;
END EXCEPTION;

begin
	define v_resu	numeric(1);
	define v_c_resu	varchar(255);
	define v_cantidad	numeric(2);
	
let v_c_resu = '';
let v_resu = 1;

	select distinct materia
	from vw_hist_academica
	where materia in ('11014', '11015', '11019')
		and resultado In ( 'A', 'P')
		and legajo = v_legajo
		and carrera = v_carrera
	into temp temp;

	select count(*) into v_cantidad
	from temp;
	drop  table temp;
	if v_cantidad  >= 2 then
		return v_resu, v_c_resu;
	else
		let v_resu = -1;
		let v_c_resu = 'No tenés al menos dos de las siguientes materias aprobadas: 11014, 11015, 11019';
		return v_resu, v_c_resu;
	end if;
end;
end procedure;
-- *************** Fin del procedimiento "dba".u820_2ap_bio_b42 ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".u820_2ap_bio_b42 
-- *****************************************************************************
revoke execute on "dba".u820_2ap_bio_b42 from public;
grant execute on "dba".u820_2ap_bio_b42 to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_2ap_bio_b42 to internet; -- Rol de usuario de Internet