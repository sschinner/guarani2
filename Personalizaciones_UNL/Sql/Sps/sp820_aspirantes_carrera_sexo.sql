CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_aspirantes_x_sexo') THEN
		DROP PROCEDURE sp820_aspirantes_x_sexo;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- Creating procedure
CREATE PROCEDURE "dba".sp820_aspirantes_x_sexo(
	pUa		LIKE sga_unidades_acad.unidad_academica,
	pCarrera LIKE sga_carreras.carrera,
	pAnioAcademico	LIKE sga_periodo_insc.anio_academico)

RETURNING	varchar(5), 		-- unidad_academica. 1
		integer,		-- anio ingreso. 2
		varchar(60),		-- nombre_carrera. 3
		integer,		-- femeninos. 4
		integer;			-- masculinos. 5

DEFINE	vc_unidad_academica		varchar(5);
DEFINE 	vi_anio_ingreso			integer;
DEFINE	vc_nombre_carrera			varchar(60);
DEFINE  vi_mujer integer;
DEFINE  vi_varon integer;

-- variables para el manejo de excepciones

DEFINE		SQLErr, ISAMError		integer;

DEFINE		errorInfo 			varchar(76);



-- si hay algun error

ON EXCEPTION SET SQLErr, ISAMError, errorInfo

	RAISE EXCEPTION  SQLErr, SQLErr, errorInfo ;

END EXCEPTION;


BEGIN

LET vc_unidad_academica	= NULL;	
LET vi_anio_ingreso	= NULL;			
LET vc_nombre_carrera	= NULL;			
LET vi_mujer 	= NULL;
LET vi_varon 	= NULL;


FOREACH 
select p.unidad_academica,
	pAnioAcademico,
	car.nombre,
	sum(case p.sexo when '2' then 1 else 0 end) as mujeres,
	sum(case p.sexo when '1' then 1 else 0 end) as varones
into vc_unidad_academica, vi_anio_ingreso, vc_nombre_carrera, vi_mujer, vi_varon

from sga_personas p
	JOIN sga_carrera_aspira asp
		ON p.nro_inscripcion = asp.nro_inscripcion
	JOIN sga_periodo_insc insc
		ON asp.periodo_inscripcio = insc.periodo_inscripcio 
	JOIN sga_carreras car
		ON asp.carrera = car.carrera
	JOIN sga_carreras_grupo gc
		ON gc.carrera = asp.carrera

where insc.anio_academico = pAnioAcademico
-- AND asp.situacion_asp in ('AC', 'IL', 'IC') -- No se tiene en cuenta el estado. Solo interesa que si fue aspirante
AND (asp.carrera = pCarrera or pCarrera = '')
AND gc.grupo_carrera in ('00001', '00002')
group by 1, 2, 3
order by 1, 3

RETURN vc_unidad_academica, vi_anio_ingreso, vc_nombre_carrera, vi_mujer, vi_varon WITH RESUME;

END FOREACH;

END;
END PROCEDURE;

-- execute procedure sp820_aspirantes_x_sexo('FCJS', '', 2014);

-- *****************************************************************************

-- Permisos del procedimiento "dba".sp820_aspirantes_x_sexo

-- *****************************************************************************
revoke execute on "dba".sp820_aspirantes_x_sexo from public;
grant execute on "dba".sp820_aspirantes_x_sexo to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_aspirantes_x_sexo to internet; -- Rol de usuario de Internet