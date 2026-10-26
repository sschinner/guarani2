CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_calidad_activo_regular') THEN
		DROP PROCEDURE sp820_calidad_activo_regular;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

--******  Determina si un alumno es activo regular en una determinada carrera

-- drop procedure "dba".sp820_calidad_activo_regular;
CREATE PROCEDURE "dba".sp820_calidad_activo_regular(	v_unidad_acad	like sga_alumnos.unidad_academica,
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

	select distinct a.legajo
	from sga_alumnos a --, sga_titulos_otorg t
	where      a.nro_inscripcion = v_nro_inscripcion
		and a.carrera = v_carrera
		and a.calidad = "A"
		and a.regular="S"
		--and a.legajo=t.legajo
		--and t.carrera=a.carrera
	into temp temp;
    
	select count(*) into v_cantidad
	from temp;
	drop  table temp;

	if v_cantidad = 1 then
		return v_resu;
	else
		let v_resu = -1;
		return v_resu;
	end if;
end;
end procedure;

--*****************************************************************************************
-- execute procedure sp820_calidad_activo_regular('FICH','01','FICH-4881')

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_calidad_activo_regular 
-- *****************************************************************************
revoke execute on "dba".sp820_calidad_activo_regular from public;
grant execute on "dba".sp820_calidad_activo_regular to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_calidad_activo_regular to internet; -- Rol de usuario de Internet

