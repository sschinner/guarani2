CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_calidad_alumno_grado') THEN
		DROP PROCEDURE sp820_calidad_alumno_grado;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

--***** Determina si un alumno es egresado o no, en caso de ser egresado 
--***** verifica si realizó la encuenta correspondiente

-- drop procedure "dba".sp820_calidad_alumno_grado;
CREATE PROCEDURE "dba".sp820_calidad_alumno_grado(	v_unidad_acad	like sga_alumnos.unidad_academica,
				v_carrera		like sga_alumnos.carrera,
				v_nro_inscripcion		like sga_alumnos.nro_inscripcion
				)
				
		returning integer;

DEFINE sqlerr		integer;
DEFINE isamerr		integer;
DEFINE errorinfo		varchar(76);

begin
	define v_resu	integer;

define v_cantidad	numeric(2);
define v_control numeric (1);
define v_legajo varchar(15);
define v_mensaje varchar(255);

LET v_legajo = null;

let v_resu = 1;


	IF EXISTS (select a.legajo
	from sga_alumnos a 
		join sga_titulos_otorg t
		on a.legajo=t.legajo
		and a.carrera=t.carrera
	where      a.nro_inscripcion = v_nro_inscripcion
		and a.carrera = v_carrera) THEN
		
		select distinct(a.legajo) into v_legajo
			from sga_alumnos a 
				join sga_titulos_otorg t
				on a.legajo=t.legajo
				and a.carrera=t.carrera
			where      a.nro_inscripcion = v_nro_inscripcion
			and a.carrera = v_carrera;

		execute PROCEDURE ctr_encCompPers(v_unidad_acad, v_nro_inscripcion, '') INTO  v_control, v_mensaje;
		if  v_control = 1 then
			return v_resu;
		else
			let v_resu = -1;
			return v_resu;
		end if;

	else
		let v_resu = -2;
		return v_resu;
	end if;

end;
end procedure;


--******************************************************************************
-- execute procedure sp820_calidad_alumno_grado ('FCJS','1','00091224')

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_calidad_alumno_grado 
-- *****************************************************************************
revoke execute on "dba".sp820_calidad_alumno_grado from public;
grant execute on "dba".sp820_calidad_alumno_grado to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_calidad_alumno_grado to internet; -- Rol de usuario de Internet
