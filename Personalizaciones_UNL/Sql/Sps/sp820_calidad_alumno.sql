CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_calidad_alumno') THEN
		DROP PROCEDURE sp820_calidad_alumno;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


--***** Determina si un alumno es egresado en una determinada carrera **********

-- drop procedure "dba".sp820_calidad_alumno;
CREATE PROCEDURE  "dba".sp820_calidad_alumno(	v_unidad_acad	like sga_alumnos.unidad_academica,
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

let v_resu = 1;

	IF EXISTS (select a.legajo
	from sga_alumnos a 
		join sga_titulos_otorg t
		on a.legajo=t.legajo
		and a.carrera=t.carrera
	where      a.nro_inscripcion = v_nro_inscripcion
		and a.carrera = v_carrera and t.titulo NOT IN (SELECT titulo FROM sga_titulos WHERE unidad_academica = 'FCE' AND titulo = '02-11')) THEN

		return v_resu;
	else
		let v_resu = -1;
		return v_resu;
	end if;
end;
end procedure;

--******************************************************************************
-- execute procedure sp820_calidad_alumno ('FCJS','1','00091224')

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_calidad_alumno 
-- *****************************************************************************
revoke execute on "dba".sp820_calidad_alumno from public;
grant execute on "dba".sp820_calidad_alumno to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_calidad_alumno to internet; -- Rol de usuario de Internet

