CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_sur_d2_bibl') THEN
		DROP PROCEDURE sp820_sur_d2_bibl;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

--  ******************* ATENCIÓN VERIFICAR PRIMERO LA ACTUALIZACION DE FECHA DE RELEVAMIENTO ************************
-- Actualizar datos
-- select count(*) from sga_datos_censales where fecha_actualiz is null;
-- update sga_datos_censales set fecha_actualiz = fecha_relevamiento where fecha_actualiz is null;
-- Pueden existir alumnos duplicados, en el caso que cursen mas de una carrera.
-- Los alumnos con tipo_usuario = 2 son: Pasivos, Abandono, Baja
-- *********************************************************************************************************************************************************

-- execute PROCEDURE "dba".sp820_sur_d2_bibl('ISM', '22', 2013);
-- Creating procedure
CREATE PROCEDURE "dba".sp820_sur_d2_bibl(pUa LIKE sga_unidades_acad.unidad_academica, pCarrera LIKE sga_carreras.carrera, pAnioAcademico LIKE sga_anio_academico.anio_academico)

-- ***************************************************************************************************************
-- Listado de variables a devolver
-- ***************************************************************************************************************
RETURNING
	integer, 		-- anio
	varchar(5), 	-- unidad_academica.
	varchar (5 ), 	-- codigo carrera
	varchar(60),	-- carrera
	varchar(30),	-- nombres.
	varchar(30),		-- apellido.
	integer,			-- tipo_documento.
	varchar(15),		-- nro_documento.
	char(2),			-- tipo de usuario.
	char(1), 			-- calidad 
	date,			-- fecha_vencimiento.
	varchar(50),		-- e_mail.
	varchar(255),		-- calle_per_lect. 
	varchar(6), 		-- cp_per_lect
		varchar(255),		-- localidad_per_lect.
		varchar(255),		-- provincia_per_lect.
		varchar(255),		-- pais_per_lect.
		varchar(18),		-- te_per_lect.
		varchar(18),		-- fax_per_lect.

		varchar(255),		-- calle_proc.
		varchar(6), 		-- cp_proc
		varchar(255),		-- localidad_proc.
		varchar(255),		-- provincia_per_lect.
		varchar(255),		-- pais_proc.
		varchar(18),		-- te_proc.
		varchar(18);		-- fax_proc.

-- ***************************************************************************************************************
-- variables para el manejo de excepciones
DEFINE		SQLErr, ISAMError		integer;
DEFINE		errorInfo 			varchar(76);

-- Variables para la devolución de datos
-- ***************************************************************************************************************
-- Listado de variables a devolver
-- ***************************************************************************************************************
DEFINE v_anio integer;
DEFINE	v_unidad_academica		varchar(5);
DEFINE	v_carrera				varchar(5);
DEFINE	v_nombre_carrera			varchar(60);

DEFINE	v_nombres			varchar(30);
DEFINE	v_apellido			varchar(30);
DEFINE	v_tipo_documento			integer;
DEFINE	v_nro_documento			varchar(15);

DEFINE 	v_tipo_usuario			char(2);
DEFINE 	v_calidad				char(1);
DEFINE	v_fecha_vencimiento		date;

DEFINE	v_e_mail			varchar(50);
DEFINE	v_calle_proc			varchar(255);
DEFINE	v_cp_proc			varchar(15);
DEFINE	v_localidad_proc			integer;
DEFINE	v_provincia_proc			integer;
DEFINE	v_pais_proc			integer;
DEFINE	v_te_proc			varchar(18);
DEFINE	v_fax_proc			varchar(18);

DEFINE	v_calle_per_lect			varchar(255);
DEFINE	v_cp_per_lect			varchar(15);
DEFINE	v_localidad_per_lect		integer;
DEFINE	v_prov_per_lect			integer;
DEFINE	v_pais_per_lect			integer;
DEFINE	v_te_per_lect			varchar(18);
DEFINE	v_fax_per_lect			varchar(18);
DEFINE	v_nro_pasap			varchar(15);
-- ***************************************************************************************************************
-- ***************************************************************************************************************
DEFINE	v_anio_academico			integer;
DEFINE	vcInicio				LIKE sga_anio_academico.fecha_inicio;
DEFINE	vcFin				LIKE sga_anio_academico.fecha_fin;


-- si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo
	RAISE EXCEPTION  SQLErr, SQLErr, errorInfo ;
END EXCEPTION;

BEGIN

LET pCarrera = trim(pCarrera);

BEGIN

on exception in (-206)
       -- Tabla no existe continuo el proceso	
end exception with resume;
 drop table aux_max_censales;
 drop table aux_alu_biblio;
END;

select unidad_academica, nro_inscripcion, max(fecha_actualiz) fecha_actualiz
from sga_datos_censales
group by 1, 2
into temp aux_max_censales WITH NO LOG;

-- ***************************************
-- Alumnos que hicieron el SUR 2
-- ***************************************
select distinct pAnioAcademico anio_academico,
	pUA unidad_academica,
	c.carrera,
	c.nombre,
	p.nombres, 
	p.apellido, 
	p.tipo_documento,
	p.nro_documento,
	'67' as tipo_usuario,
	a.calidad,
  	stringToDate( '31/05/'||pAnioAcademico + 1, '%d/%m/%Y') as fecha_vencimiento,
	d.e_mail,
	d.calle_per_lect||' '||d.numero_per_lect as dom_per_lect,
	d.cp_per_lect,
	d.loc_per_lect,
	0 as provincia_per_lect, -- mgp.nombre as provincia,
	0 as pais_per_lect, -- mgpais.nombre as pais,
	d.te_per_lect,
	'                                           ' as fax,

	d.calle_proc||' '||d.numero_proc as dom_proc,
	d.cp_proc,
	d.loc_proc,
	0 as provincia_proc,
	0 as pais_proc,
	d.te_proc,
	'                                           ' as fax_proc	
	
from sga_reinscripcion r 
	join sga_alumnos a
		 join sga_personas p
			JOIN sga_datos_censales d
					JOIN aux_max_censales aux_dc
					  on d.nro_inscripcion = aux_dc.nro_inscripcion
						and d.fecha_actualiz = aux_dc.fecha_actualiz
			ON p.nro_inscripcion = d.nro_inscripcion
		on p.nro_inscripcion = a.nro_inscripcion	  
	on a.legajo = r.legajo 
		and a.carrera = r.carrera 
	
	join sga_carreras c
		on a.carrera = c.carrera
	join u820_codigos_univ univ
		on c.carrera = univ.carrera

where r.anio_academico = pAnioAcademico 
	and a.calidad in ('A', 'E') 
	and c.carrera = pCarrera
	
UNION

-- ***************
-- Ingresantes 
-- ***************
select distinct pAnioAcademico anio_academico,
	pUA unidad_academica,
	c.carrera,
	c.nombre,
	p.nombres, 
	p.apellido, 
	p.tipo_documento,
	p.nro_documento,
	'67' as tipo_usuario,
	'A' as calidad,
  	stringToDate( '31/05/'||pAnioAcademico + 1, '%d/%m/%Y') as fecha_vencimiento,
	d.e_mail,
	d.calle_per_lect||' '||d.numero_per_lect as dom_per_lect,
	d.cp_per_lect,
	d.loc_per_lect,
	0 as provincia_per_lect, -- mgp.nombre as provincia,
	0 as pais_per_lect, -- mgpais.nombre as pais,
	d.te_per_lect,
	'                                           ' as fax,

	d.calle_proc||' '||d.numero_proc as dom_proc,
	d.cp_proc,
	d.loc_proc,
	0 as provincia_proc,
	0 as pais_proc,
	d.te_proc,
	'                                           ' as fax_proc	
	
	
from sga_periodo_insc pi
	join sga_carrera_aspira car 
		 join sga_personas p
			 JOIN aux_max_censales aux_dc
				JOIN sga_datos_censales d
				  on d.nro_inscripcion = aux_dc.nro_inscripcion
					and d.fecha_actualiz = aux_dc.fecha_actualiz
			ON p.nro_inscripcion = aux_dc.nro_inscripcion
		 on p.nro_inscripcion = car.nro_inscripcion 	
	on pi.periodo_inscripcio = car.periodo_inscripcio

	join sga_carreras c
		on car.carrera = c.carrera
	join u820_codigos_univ univ
		on c.carrera = univ.carrera

where pi.anio_academico = pAnioAcademico 
	and car.situacion_asp in( 'IL', 'IC')
	and car.carrera = pCarrera

into temp aux_alu_biblio WITH NO LOG;

-- *******************************************************************************************************************************************
update aux_alu_biblio set provincia_proc =  (select pro.provincia from mug_localidades l
		JOIN mug_dptos_partidos dpto
		  ON l.dpto_partido = dpto.dpto_partido
			JOIN mug_provincias pro
			  ON dpto.provincia = pro.provincia
		  where l.localidad = aux_alu_biblio.loc_proc);

update aux_alu_biblio set provincia_per_lect = (select pro.provincia from mug_localidades l
		JOIN mug_dptos_partidos dpto
		  ON l.dpto_partido = dpto.dpto_partido
			JOIN mug_provincias pro
			  ON dpto.provincia = pro.provincia
		  where l.localidad = aux_alu_biblio.loc_per_lect);

update aux_alu_biblio set pais_proc = (select pa.pais from mug_localidades l
		JOIN mug_dptos_partidos dpto
		  ON l.dpto_partido = dpto.dpto_partido
			JOIN mug_provincias pro
				join mug_paises pa
				on pro.pais = pa.pais
			  ON dpto.provincia = pro.provincia
		  where l.localidad = aux_alu_biblio.loc_proc);

update aux_alu_biblio set pais_per_lect =  (select pa.pais from mug_localidades l
		JOIN mug_dptos_partidos dpto
		  ON l.dpto_partido = dpto.dpto_partido
			JOIN mug_provincias pro
			  ON dpto.provincia = pro.provincia
				join mug_paises pa
				on pro.pais = pa.pais
		  where l.localidad = aux_alu_biblio.loc_per_lect);

-- *******************************************************************************************************************************************
FOREACH  
	SELECT distinct i.anio_academico, 
		i.unidad_academica,
		i.carrera,
		i.nombre,
		i.nombres, 
		i.apellido, 
		i.tipo_documento, 
		i.nro_documento,
		i.tipo_usuario,
		i.calidad,
		i.fecha_vencimiento,
		i.e_mail,
		i.dom_per_lect,
		i.cp_per_lect,
		i.loc_per_lect, 
		i.provincia_per_lect,
		i.pais_per_lect,
		trim(i.te_per_lect), 
		trim(i.fax),
		i.dom_proc,
		i.cp_proc,
		i.loc_proc,
		i.provincia_proc,
		i.pais_proc,
		trim(i.te_proc),
		trim(i.fax_proc)

-- ***************************************************************************************************************
-- Listado de variables a devolver
-- ***************************************************************************************************************
	INTO	v_anio,
		v_unidad_academica,
		v_carrera,
		v_nombre_carrera,
		v_nombres,
		v_apellido,
		v_tipo_documento,
		v_nro_documento,
		v_tipo_usuario,
		v_calidad,
		v_fecha_vencimiento,
		v_e_mail,
		v_calle_per_lect,
		v_cp_per_lect,
		v_localidad_per_lect,
		v_prov_per_lect,
		v_pais_per_lect,
		v_te_per_lect,
		v_fax_per_lect,
		v_calle_proc,
		v_cp_proc,
		v_localidad_proc,
		v_provincia_proc,
		v_pais_proc,
		v_te_proc,
		v_fax_proc

-- ***************************************************************************************************************
-- ***************************************************************************************************************
	FROM aux_alu_biblio i
	ORDER BY 6, 5
		-- devuelve la lista SUR D2.
-- ***************************************************************************************************************
-- Listado de variables a devolver
-- ***************************************************************************************************************
	RETURN 			
		v_anio,
		v_unidad_academica,
		v_carrera,
		v_nombre_carrera,
		v_nombres,
		v_apellido,
		v_tipo_documento,
		v_nro_documento,
		v_tipo_usuario,
		v_calidad,
		v_fecha_vencimiento,
		v_e_mail,
		v_calle_per_lect,
		v_cp_per_lect,
		v_localidad_per_lect,
		v_prov_per_lect,
		v_pais_per_lect,
		v_te_per_lect,
		v_fax_per_lect,
		v_calle_proc,
		v_cp_proc,
		v_localidad_proc,
		v_provincia_proc,
		v_pais_proc,
		v_te_proc,
		v_fax_proc WITH RESUME;
-- ***************************************************************************************************************

END FOREACH;

END;

BEGIN

on exception in (-206)
       -- Tabla no existe continuo el proceso	
end exception with resume;
 drop table aux_max_censales;
 drop table aux_alu_biblio;
END;

END PROCEDURE;

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_sur_d2_bibl
-- *****************************************************************************
revoke execute on "dba".sp820_sur_d2_bibl from public;
grant execute on "dba".sp820_sur_d2_bibl to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_sur_d2_bibl to internet; -- Rol de usuario de Internet