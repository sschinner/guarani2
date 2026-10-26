CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_sur_d2_bibl') THEN
		DROP PROCEDURE web_serv_sur_d2_bibl;
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

-- execute PROCEDURE "dba".web_serv_sur_d2_bibl('FICH', 2000, 0, '29349542');
-- drop PROCEDURE "dba".web_serv_sur_d2_bibl;
-- Creating procedure
CREATE PROCEDURE "dba".web_serv_sur_d2_bibl(pUa LIKE sga_unidades_acad.unidad_academica, pAnioAcademico LIKE sga_anio_academico.anio_academico, ptipo_documento LIKE sga_personas.tipo_documento, pnro_documento LIKE sga_personas.nro_documento)

-- ***************************************************************************************************************
-- Listado de variables a devolver
-- ***************************************************************************************************************
RETURNING
		integer, -- codigo retorno
		varchar(255), -- mensaje
		varchar(30),		-- nombres.
		varchar(30),		-- apellido.
	 	integer,			-- tipo_documento.
	 	varchar(15),		-- nro_documento.
		varchar(15), 		-- pasaporte
		char(1),			-- tipo de usuario.
		varchar(5), 		-- unidad_academica.
		varchar(5),		-- codigo carrera univ.
		date,			-- fecha_vencimiento.

		varchar(50),		-- e_mail.
		varchar(100),		-- calle_per_lect. 
		varchar(15),		-- localidad_per_lect.
		integer,		-- provincia_per_lect.
		integer,		-- pais_per_lect.
		varchar(18),		-- te_per_lect.
		varchar(18),		-- fax_per_lect.

		varchar(100),		-- calle_proc.
		varchar(15),		-- localidad_proc.
		integer,		-- provincia_per_lect.
		integer,		-- pais_proc.
		varchar(18),		-- te_proc.
		varchar(18);		-- fax_proc.

-- ***************************************************************************************************************
-- variables para el manejo de excepciones y codigo de retorno
DEFINE		SQLErr, ISAMError		integer;
DEFINE		errorInfo 			varchar(76);
DEFINE 		vi_codigo_ret integer;
DEFINE 		vcMsg varchar(255);

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
DEFINE	v_nro_documento			decimal(15,0);

DEFINE 	v_tipo_usuario			char(1);
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
	RAISE EXCEPTION  SQLErr, ISAMError, errorInfo ;
END EXCEPTION;

BEGIN

LET 		vi_codigo_ret = -1;
LET		 vcMsg = "No existe la persona en la Unidad Académica";
LET 		v_nombres = NULL;
LET 		v_apellido = NULL;
LET 		v_tipo_documento = NULL;
LET 		v_nro_documento = NULL;
LET 		v_nro_pasap = NULL;
LET 		v_tipo_usuario = NULL;
LET 		v_unidad_academica = NULL;
LET 		v_carrera = NULL;
LET 		v_fecha_vencimiento = NULL;
LET 		v_e_mail = NULL;
LET 		v_calle_per_lect = NULL;
LET 		v_localidad_per_lect = NULL;
LET 		v_prov_per_lect = NULL;
LET 		v_pais_per_lect = NULL;
LET 		v_te_per_lect = NULL;
LET 		v_fax_per_lect = NULL;
LET 		v_calle_proc = NULL;
LET 		v_localidad_proc = NULL;
LET 		v_provincia_proc = NULL;
LET 		v_pais_proc = NULL;
LET 		v_te_proc = NULL;
LET 		v_fax_proc = NULL;

BEGIN
on exception in (-206)
       -- Tabla no existe continuo el proceso	
end exception with resume;
 drop table aux_max_censales;
 drop table aux_alu_biblio;
END;

-- SE MODIFICA PARA QUE REALICE EL MAX DE LA FECHA DE RELEVAMIENTO YA QUE SI ES INGRESANTE NO TIENE FECHA DE ACTUALIZACION
select dat.unidad_academica, dat.nro_inscripcion, max(dat.fecha_relevamiento) fecha_actualiz
from sga_datos_censales dat
	join sga_personas per
	on dat.unidad_academica = per.unidad_academica
	and dat.nro_inscripcion = per.nro_inscripcion
where per.unidad_academica = pUa
and per.tipo_documento = ptipo_documento
and per.nro_documento = pnro_documento
group by 1, 2
into temp aux_max_censales WITH NO LOG;

create index idx_aux_max_censales on aux_max_censales (nro_inscripcion);

-- ***************************************
-- Alumnos que hicieron el SUR 2
-- ***************************************
select distinct
	p.nombres, 
	p.apellido, 
	case p.tipo_documento when 0 then '1' when 2 then '4' when 18 then '3' when 19 then '2' when 90 then '5' end tipo_doc, 
	p.nro_documento,
	p.nro_pasap,
	'67' as tipo_usuario,
	case a.unidad_academica 
		when 'FIQ' then '2' 
		when 'FICH' then '3' 
		when 'FBCB' then '4' 
		when 'FCE' then '5' 
		when 'FCJS' then '6' 
		when 'FCV' then '7' 		
		when 'FCA' then '8' 
		when 'FHUC' then '9' 
		when 'FADU' then '10' 
		when 'EIS' then '11'
		when 'EUAA' then '17' 
		when 'EUA' then '19' 
		when 'ISM' then '21' 
		when 'FCM' then '20'
		when 'CI' then '24'
		when 'ESS' then '22' end UA,
	univ.unl_carrera,  
	stringToDate( '31/05/'||pAnioAcademico + 1, '%d/%m/%Y') as fecha_vencimiento,
	--DMY('31', '05', pAnioAcademico + 1) as fecha_vencimiento,
	d.e_mail,
	d.calle_per_lect||' '||d.numero_per_lect as dom_per_lect,
	d.loc_per_lect,
	0 as provincia_per_lect, -- mgp.nombre as provincia,
	0 as pais_per_lect, -- mgpais.nombre as pais,
	d.te_per_lect,
	'                                           ' as fax,

	d.calle_proc||' '||d.numero_proc as dom_proc,
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
	and p.tipo_documento = ptipo_documento
	and p.nro_documento = pnro_documento
UNION

-- ***************
-- Ingresantes 
-- ***************
select distinct
	p.nombres, 
	p.apellido, 
	case p.tipo_documento when 0 then '1' when 2 then '4' when 18 then '3' when 19 then '2' when 90 then '5' end tipo_doc, 
	p.nro_documento,
	p.nro_pasap,
	'67' as tipo_usuario,
	case car.unidad_academica 
		when 'FIQ' then '2' 
		when 'FICH' then '3' 
		when 'FBCB' then '4' 
		when 'FCE' then '5' 
		when 'FCJS' then '6' 
		when 'FCV' then '7' 		
		when 'FCA' then '8' 
		when 'FHUC' then '9' 
		when 'FADU' then '10' 
		when 'EIS' then '11'
		when 'EUAA' then '17' 
		when 'EUA' then '19' 
		when 'ISM' then '21' 
		when 'FCM' then '20'
		when 'CI' then '24'
		when 'ESS' then '22' end UA,
	univ.unl_carrera,  
	stringToDate( '31/05/'||pAnioAcademico + 1, '%d/%m/%Y') as fecha_vencimiento,
	-- DMY('31', '05', pAnioAcademico + 1) as fecha_vencimiento,
	d.e_mail,
	d.calle_per_lect||' '||d.numero_per_lect as dom_per_lect,
	d.loc_per_lect,
	0 as provincia_per_lect, -- mgp.nombre as provincia,
	0 as pais_per_lect, -- mgpais.nombre as pais,
	d.te_per_lect,
	'                                           ' as fax,

	d.calle_proc||' '||d.numero_proc as dom_proc,
	d.loc_proc,
	0 as provincia_proc,
	0 as pais_proc,
	d.te_proc,
	'                                           ' as fax_proc	
-- SE MODIFICA PARA QUE REALICE EL MAX DE LA FECHA DE RELEVAMIENTO YA QUE SI ES INGRESANTE NO TIENE FECHA DE ACTUALIZACION
from sga_periodo_insc pi
	join sga_carrera_aspira car 
		 join sga_personas p
			 JOIN aux_max_censales aux_dc
				JOIN sga_datos_censales d
				  on d.nro_inscripcion = aux_dc.nro_inscripcion
					and d.fecha_relevamiento = aux_dc.fecha_actualiz
			ON p.nro_inscripcion = aux_dc.nro_inscripcion
		 on p.nro_inscripcion = car.nro_inscripcion 	
	on pi.periodo_inscripcio = car.periodo_inscripcio

	join sga_carreras c
		on car.carrera = c.carrera
	join u820_codigos_univ univ
		on c.carrera = univ.carrera

where pi.anio_academico = pAnioAcademico 
	and car.situacion_asp in( 'IL', 'IC')
	and p.tipo_documento = ptipo_documento
	and p.nro_documento = pnro_documento
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
	SELECT distinct 
		i.nombres, 
		i.apellido, 
		i.tipo_doc, 
		i.nro_documento,
		i.nro_pasap,
		i.tipo_usuario,
		i.ua,
		i.unl_carrera,
		i.fecha_vencimiento,
		i.e_mail,
		i.dom_per_lect,
		i.loc_per_lect, 
		case i.provincia_per_lect
			when 5406 then 6
			when 5410 then 10
			when 5414 then 14
			when 5418 then 18
			when 5422 then 22
			when 5426 then 26
			when 5430 then 30
			when 5434 then 34
			when 5438 then 38
			when 5446 then 46
			when 5442 then 42
			when 5450 then 50
			when 5454 then 54
			when 5458 then 58
			when 5462 then 62
			when 5466 then 66
			when 5470 then 70
			when 5474 then 74
			when 5478 then 78
			when 5482 then 82
			when 5486 then 86
			when 5494 then 94	
			when 5490 then 90
			when 5402 then 2 else provincia_per_lect end as provincia_per_lect, 
		i.pais_per_lect,
		trim(i.te_per_lect), 
		trim(i.fax),
		i.dom_proc,
		i.loc_proc,
		case i.provincia_proc
			when 5406 then 6
			when 5410 then 10
			when 5414 then 14
			when 5418 then 18
			when 5422 then 22
			when 5426 then 26
			when 5430 then 30
			when 5434 then 34
			when 5438 then 38
			when 5446 then 46
			when 5442 then 42
			when 5450 then 50
			when 5454 then 54
			when 5458 then 58
			when 5462 then 62
			when 5466 then 66
			when 5470 then 70
			when 5474 then 74
			when 5478 then 78
			when 5482 then 82
			when 5486 then 86
			when 5494 then 94	
			when 5490 then 90
			when 5402 then 2 else provincia_per_lect end as provincia_proc,
		i.pais_proc,
		trim(i.te_proc),
		trim(i.fax_proc)

-- ***************************************************************************************************************
-- Listado de variables a devolver
-- ***************************************************************************************************************
	INTO	
		v_nombres,
		v_apellido,
		v_tipo_documento,
		v_nro_documento,
		v_nro_pasap,
		v_tipo_usuario,
		v_unidad_academica,
		v_carrera,
		v_fecha_vencimiento,
		v_e_mail,
		v_calle_per_lect,
		v_localidad_per_lect,
		v_prov_per_lect,
		v_pais_per_lect,
		v_te_per_lect,
		v_fax_per_lect,
		v_calle_proc,
		v_localidad_proc,
		v_provincia_proc,
		v_pais_proc,
		v_te_proc,
		v_fax_proc

-- ***************************************************************************************************************
-- ***************************************************************************************************************
	FROM aux_alu_biblio i
	
		-- devuelve la lista SUR D2.
-- ***************************************************************************************************************
-- Listado de variables a devolver
-- ***************************************************************************************************************
		LET vcMsg = "OK";
		LET vi_codigo_ret = 0;

	RETURN 			
		vi_codigo_ret,
		vcMsg,
		v_nombres,
		v_apellido,
		v_tipo_documento,
		v_nro_documento,
		v_nro_pasap,
		v_tipo_usuario,
		v_unidad_academica,
		v_carrera,
		v_fecha_vencimiento,
		v_e_mail,
		v_calle_per_lect,
		v_localidad_per_lect,
		v_prov_per_lect,
		v_pais_per_lect,
		v_te_per_lect,
		v_fax_per_lect,
		v_calle_proc,
		v_localidad_proc,
		v_provincia_proc,
		v_pais_proc,
		v_te_proc,
		v_fax_proc WITH RESUME;
-- ***************************************************************************************************************

END FOREACH;

IF (vi_codigo_ret = -1)  THEN
RETURN 			
	vi_codigo_ret,
	vcMsg,
	v_nombres,
	v_apellido,
	v_tipo_documento,
	v_nro_documento,
	v_nro_pasap,
	v_tipo_usuario,
	v_unidad_academica,
	v_carrera,
	v_fecha_vencimiento,
	v_e_mail,
	v_calle_per_lect,
	v_localidad_per_lect,
	v_prov_per_lect,
	v_pais_per_lect,
	v_te_per_lect,
	v_fax_per_lect,
	v_calle_proc,
	v_localidad_proc,
	v_provincia_proc,
	v_pais_proc,
	v_te_proc,
	v_fax_proc;
END IF;

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
-- Permisos del procedimiento "dba".web_serv_sur_d2_bibl
-- *****************************************************************************
revoke execute on "dba".web_serv_sur_d2_bibl from public;
grant execute on "dba".web_serv_sur_d2_bibl to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_serv_sur_d2_bibl to internet; -- Rol de usuario de Internet
