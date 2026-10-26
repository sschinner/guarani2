CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_ingles_aprob') THEN
		DROP PROCEDURE u820_ingles_aprob;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ***************  Correlativa especial de las materias de 3er. año y superior: *****************************
-- Se controla que si es la materia 20 a rendir (o superior), tenga aprobada la materia Ingles.
-- ************************************************************************************

-- drop procedure "dba".u820_ingles_aprob ;
create procedure "dba".u820_ingles_aprob (	v_unidad_academica	like sga_alumnos.unidad_academica,
				v_carrera		like sga_alumnos.carrera,
				v_legajo		like sga_alumnos.legajo,
				v_materia		like sga_actas_examen.materia,
				v_plan		like sga_alumnos.plan,
				v_version		like sga_planes.version_actual)
				
		returning smallint, varchar(255);

DEFINE sqlerr		integer;
DEFINE isamerr		integer;
DEFINE errorinfo		varchar(76);

-- si hay algun error
ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo
	RETURN -1, errorInfo;
END EXCEPTION;

begin

DEFINE vcMensaje  		varchar(255);
DEFINE vnRetorno, v_ok integer;

LET vnRetorno = 1 ;

select count (*) into 	v_ok
	from vw_hist_academica
	where unidad_academica = v_unidad_academica
		and carrera = v_carrera
		and legajo = v_legajo
		and plan = v_plan
		and resultado = 'A'
		and materia not in ('CCP-M', 'CCP-Q', 'CCP-U', 'CCP-P', '124');

if v_ok >= 19 then

	if exists (select "1" from vw_hist_academica
		where unidad_academica = v_unidad_academica
		and carrera = v_carrera
		and legajo = v_legajo
		and plan = v_plan
		and resultado = 'A'
		and materia = '124') then
			return 1, '';
	else
		return -1, 'No tenés Inglés aprobado para poder seguir cursando/rindiendo';
	end if;
else
	return 1, '';
end if;
end;
end procedure;
-- ************************************************************************************
-- execute procedure u820_ingles_aprob ('EUAA', '1102', '30265212-5', '121', '2004', '1')
revoke execute on "dba".u820_ingles_aprob from public;

grant execute on "dba".u820_ingles_aprob to guarani; -- Rol de usuarios de Gestión
grant execute on "dba".u820_ingles_aprob to internet; -- Usuario de internet
