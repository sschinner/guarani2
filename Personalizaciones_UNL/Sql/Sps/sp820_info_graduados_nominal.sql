CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_info_graduados_nominal') THEN
		DROP PROCEDURE sp820_info_graduados_nominal;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- PERSONALIZACION:
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Procedure sp820_info_graduados_nominal
-- 
-- Recupera los datos de los graduados que completaron la encuesta de Graduados
-- Recientes por el código de respuesta en Kolla
-- *****************************************************************************

CREATE PROCEDURE "dba".sp820_info_graduados_nominal (pRespuesta like gde_encues_persona.respuesta)
	RETURNING varchar(30), varchar(30), varchar(3), varchar(15), varchar(10), varchar(10), varchar(100), varchar(60), varchar(60), varchar(40), varchar(10), varchar(50), varchar(255), integer, varchar(10);

-- Descripcion del Return:
-- varchar(30),  -- apellido
-- varchar(30),  -- nombres
-- varchar(3), 	 -- tipo_documento
-- varchar(15),  -- nro_documento
-- varchar(10),  -- fecha_nacimiento
-- varchar(10),  -- sexo
-- varchar(100), -- loc_nac
-- varchar(60),  -- dpto_nac
-- varchar(60),  -- prov_nac
-- varchar(40),  -- pais_nac
-- varchar(10),  -- edad
-- varchar(50),  -- e_mail
-- varchar(255), -- titulo
-- integer,      -- titulo_araucano
-- varchar(10),	 -- anio_egreso

DEFINE	v_apellido		LIKE sga_personas.apellido;
DEFINE	v_nombres		LIKE sga_personas.nombres;
DEFINE	v_tipo_documento	LIKE mdp_tipo_documento.desc_abreviada;
DEFINE	v_nro_documento		LIKE sga_personas.nro_documento;
DEFINE	v_fecha_nacimiento	varchar(10);
DEFINE	v_sexo			varchar(10);
DEFINE	v_loc_nacimiento	LIKE mug_localidades.nombre;
DEFINE	v_dpto_nacimiento	LIKE mug_dptos_partidos.nombre;
DEFINE	v_prov_nacimiento	LIKE mug_provincias.nombre;
DEFINE	v_pais_nacimiento	LIKE mug_paises.nombre;
DEFINE	v_edad			varchar(10);
DEFINE	v_e_mail		LIKE sga_datos_censales.e_mail;
DEFINE	v_titulo		LIKE sga_titulos.nombre;
DEFINE	v_titulo_araucano	LIKE sga_titulos.titulo_araucano;
DEFINE	v_anio_egreso		varchar(10);

BEGIN

LET	v_apellido		= NULL;
LET	v_nombres		= NULL;
LET	v_tipo_documento	= NULL;
LET	v_nro_documento		= NULL;
LET	v_fecha_nacimiento	= NULL;
LET	v_sexo			= NULL;
LET	v_loc_nacimiento	= NULL;
LET	v_dpto_nacimiento	= NULL;
LET	v_prov_nacimiento	= NULL;
LET	v_pais_nacimiento	= NULL;
LET	v_edad			= NULL;
LET	v_e_mail		= NULL;
LET	v_titulo		= NULL;
LET	v_titulo_araucano	= NULL;
LET	v_anio_egreso		= NULL;

SELECT		p.apellido
		,p.nombres
		,td.desc_abreviada
		,p.nro_documento
		,to_char(p.fecha_nacimiento, '%d-%m-%Y')
		,case when p.sexo = '1' then 'Masculino' when p.sexo = '2' then 'Femenino' else null end
		,lo.nombre as loc_nac
		,d.nombre as dpto_nac
		,pr.nombre as prov_nac
		,pa.nombre as pais_nac
		,floor((today - p.fecha_nacimiento)/365)
		,an.e_mail
		,case when p.sexo = '1' then t.nombre when p.sexo = '2' then t.nombre_femenino else null end
		,t.titulo_araucano
		,year(fecha_egreso)
INTO		v_apellido, v_nombres, v_tipo_documento, v_nro_documento, v_fecha_nacimiento, v_sexo, v_loc_nacimiento, v_dpto_nacimiento, v_prov_nacimiento, 					v_pais_nacimiento, v_edad, v_e_mail, v_titulo, v_titulo_araucano, v_anio_egreso
FROM		gde_encues_persona ep
JOIN		sga_personas p on ep.nro_inscripcion = p.nro_inscripcion
JOIN		mdp_tipo_documento td on p.tipo_documento = td.tipo_documento
LEFT JOIN	mug_localidades lo on p.loc_nacimiento = lo.localidad
LEFT JOIN	mug_dptos_partidos d on lo.dpto_partido = d.dpto_partido
LEFT JOIN	mug_provincias pr on d.provincia = pr.provincia
LEFT JOIN	mug_paises pa on pr.pais = pa.pais
JOIN		gda_anun_conf_pers an on p.nro_inscripcion = an.nro_inscripcion
JOIN		sga_alumnos a on p.nro_inscripcion = a.nro_inscripcion
JOIN		sga_titulos_otorg tit on a.carrera = tit.carrera and a.legajo = tit.legajo
JOIN		sga_titulos t on tit.titulo = t.titulo
WHERE		respuesta = pRespuesta
AND		fecha_egreso = (select max(fecha_egreso) from sga_titulos_otorg where nro_inscripcion = p.nro_inscripcion); 

RETURN		v_apellido, v_nombres, v_tipo_documento, v_nro_documento, v_fecha_nacimiento, v_sexo, v_loc_nacimiento, v_dpto_nacimiento, v_prov_nacimiento, 					v_pais_nacimiento, v_edad, v_e_mail, v_titulo, v_titulo_araucano, v_anio_egreso
WITH RESUME;

END;

END PROCEDURE;
-- **************************  Fin del Procedure "dba".sp820_info_graduados_nominal**************************

-- execute PROCEDURE "dba".sp820_info_graduados_nominal (105590)

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_info_graduados_nominal
-- *****************************************************************************
revoke execute on "dba".sp820_info_graduados_nominal from public;
grant execute on "dba".sp820_info_graduados_nominal to guarani;  -- Rol de usuarios de Gestion
grant execute on "dba".sp820_info_graduados_nominal to internet; -- Rol de usuario de Internet

execute PROCEDURE "dba".sp820_info_graduados_nominal (49320);
execute PROCEDURE "dba".sp820_info_graduados_nominal (49347);
execute PROCEDURE "dba".sp820_info_graduados_nominal (49393);
execute PROCEDURE "dba".sp820_info_graduados_nominal (49350);
execute PROCEDURE "dba".sp820_info_graduados_nominal (105504);



select	*
from	systables
where	tabname like 'gde_%'

select	*
from	gde_encues_persona

create table graduados(
orden		integer,
respuesta	integer);

load from 'Z:\Descargas\datos.csv' delimiter '|'
insert into graduados;

SELECT		g.orden
		,ep.respuesta
		,ep.unidad_academica
		,p.apellido
		,p.nombres
		,td.desc_abreviada
		,p.nro_documento
		,to_char(p.fecha_nacimiento, '%d-%m-%Y')
		,case when p.sexo = '1' then 'Masculino' when p.sexo = '2' then 'Femenino' else null end
		,lo.nombre as loc_nac
		,d.nombre as dpto_nac
		,pr.nombre as prov_nac
		,pa.nombre as pais_nac
		,floor((today - p.fecha_nacimiento)/365)
		,an.e_mail
		,case when p.sexo = '1' then t.nombre when p.sexo = '2' then t.nombre_femenino else null end
		,t.titulo_araucano
		,year(fecha_egreso)
FROM		graduados g
JOIN		gde_encues_persona ep on g.respuesta = ep.respuesta
JOIN		sga_personas p on ep.nro_inscripcion = p.nro_inscripcion
JOIN		mdp_tipo_documento td on p.tipo_documento = td.tipo_documento
LEFT JOIN	mug_localidades lo on p.loc_nacimiento = lo.localidad
LEFT JOIN	mug_dptos_partidos d on lo.dpto_partido = d.dpto_partido
LEFT JOIN	mug_provincias pr on d.provincia = pr.provincia
LEFT JOIN	mug_paises pa on pr.pais = pa.pais
JOIN		gda_anun_conf_pers an on p.nro_inscripcion = an.nro_inscripcion
JOIN		sga_alumnos a on p.nro_inscripcion = a.nro_inscripcion
JOIN		sga_titulos_otorg tit on a.carrera = tit.carrera and a.legajo = tit.legajo
JOIN		sga_titulos t on tit.titulo = t.titulo
WHERE		formulario in (select formulario from gde_formulario where alcance in (select alcance from gde_encues_alcance where encuesta in (select	encuesta from gde_encuestas where kolla_id_encuesta = 123)))
AND		fecha_egreso = (select max(fecha_egreso) from sga_titulos_otorg where nro_inscripcion = p.nro_inscripcion) 
order by g.orden;

drop table graduados;