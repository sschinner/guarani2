CREATE PROCEDURE verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_sur_d1') THEN
		DROP PROCEDURE sp820_sur_d1;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE verifica_objeto();
DROP PROCEDURE verifica_objeto();


-- Creating procedure
CREATE PROCEDURE "dba".sp820_sur_d1(
	pUa		LIKE sga_unidades_acad.unidad_academica,
	pCarrera LIKE sga_carreras.carrera,
	pAnioAcademico	LIKE sga_periodo_insc.anio_academico)

-- ***************************************************************************************************************
-- Listado de variables a devolver
-- ***************************************************************************************************************
RETURNING	integer,			-- anio. 1
		integer,			-- anio ingreso. 2
		varchar(30),		-- apellido. 3
		varchar(30),		-- nombres. 4
		date,			-- fecha_nacimiento. 5
		char(1),			-- sexo. 6
	 	varchar(50),		-- tipo_documento. 7
	 	varchar(15),		-- nro_documento. 8
		varchar(15),		-- legajo. 9
		varchar(5), 		-- unidad_academica. 10
		varchar(5),		-- carrera. 11
		varchar(60),		-- nombre_carrera. 12
		varchar(50),		-- estado_civil. 13
		varchar(100),		-- calle_per_lect. 14
		varchar(5),		-- numero_per_lect. 15
		varchar(3),		-- piso_per_lect. 16
		varchar(5),		-- dpto_per_lect. 17
		varchar(3),		-- unidad_per_lect. 18
		varchar(255),		-- localidad_per_lect. 19
		varchar(255),		-- patido_per_lect. 20
		varchar(255),		-- provincia_per_lect. 21
		varchar(6),		-- cp_per_lect. 22
		varchar(18),		-- te_per_lect. 23
		varchar(100),		-- calle_proc. 24
		varchar(5),		-- numero_proc. 25
		varchar(3),		-- piso_proc. 26
		varchar(5),		-- dpto_proc. 27
		varchar(3),		-- unidad_proc. 28
		varchar(255),		-- localidad_proc. 29
		varchar(255),		-- patido_proc. 30
		varchar(255),		-- provincia_proc. 31
		varchar(6),		-- cp_proc. 32
		varchar(18),		-- te_proc. 33
		varchar(255),		-- sit_laboral_alu. 34
		varchar(255),		-- horas_trabaja. 35
		varchar(255),		-- sector. 36
		varchar(255),		-- tareas. 37
		varchar(255),		-- sit_laboral_pad. 38
		varchar(255),		-- sit_laboral_mad. 39
		varchar(255),		-- ultimos estudios cursados del padre. 40
		varchar(255);		-- ultimos estudios cursados de la madre. 41

-- ***************************************************************************************************************
-- ***************************************************************************************************************

-- variables para el manejo de excepciones
DEFINE		SQLErr, ISAMError		integer;
DEFINE		errorInfo 			varchar(76);

-- Variables para la devolución de datos
-- ***************************************************************************************************************
-- Listado de variables a devolver
-- ***************************************************************************************************************
DEFINE 	v_anio				integer;
DEFINE 	v_anio_ingreso			integer;
DEFINE	v_unidad_academica		varchar(5);
DEFINE	v_carrera				varchar(5);
DEFINE	v_nombre_carrera			varchar(60);
DEFINE	v_legajo				varchar(15);
DEFINE	v_apellido			varchar(30);
DEFINE	v_nombres			varchar(30);
DEFINE	v_fecha_nacimiento		date;
DEFINE	v_sexo				char(1);
DEFINE	v_tipo_documento			varchar(50);
DEFINE	v_nro_documento			varchar(15);
DEFINE	v_estado_civil			varchar(50);
DEFINE	v_calle_proc			varchar(100);
DEFINE	v_numero_proc			varchar(5);
DEFINE	v_piso_proc			varchar(3);
DEFINE	v_dpto_proc			varchar(5);
DEFINE	v_unidad_proc			varchar(3);
DEFINE	v_localidad_proc			varchar(255);
DEFINE	v_patido_proc			varchar(255);
DEFINE	v_provincia_proc			varchar(255);
DEFINE	v_cp_proc			varchar(6);
DEFINE	v_te_proc			varchar(18);
DEFINE	v_calle_per_lect			varchar(100);
DEFINE	v_numero_per_lect			varchar(5);
DEFINE	v_piso_per_lect			varchar(3);
DEFINE	v_dpto_per_lect			varchar(5);
DEFINE	v_unidad_per_lect			varchar(3);
DEFINE	v_loc_per_lect			varchar(255);
DEFINE	v_patido_per_lect			varchar(255);
DEFINE	v_prov_per_lect		varchar(255);
DEFINE	v_cp_per_lect			varchar(6);
DEFINE	v_te_per_lect			varchar(18);
DEFINE	v_sit_lab_alu			varchar(255);
DEFINE	v_horas_trabaja			varchar(255);
DEFINE	v_sector_econom_alum		varchar(255);
DEFINE	v_tareas_act_alum			varchar(255);
DEFINE	v_sit_lab_pad			varchar(255);
DEFINE	v_sit_lab_mad			varchar(255);
DEFINE	v_ult_est_cur_mad			varchar(255);
DEFINE	v_ult_est_cur_pad			varchar(255);
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

BEGIN

on exception in (-206)
       -- Tabla no existe continuo el proceso	
end exception with resume;
	DROP TABLE aux_alumno;
	DROP TABLE tmp_alumnos_sur1;
	DROP TABLE aux_max_censales;
END;

-- *******************************************************************************************************************************************
-- Obtengo el conjunto de alumnos: utilizo criterios de Araucano para actualizar nuevos inscriptos
-- *******************************************************************************************************************************************
-- Correr el proceso de actualización de Nuevos Inscriptos para el Araucano.
EXECUTE PROCEDURE sp_int_arau_ingnui( pAnioAcademico);


SELECT a.nro_inscripcion, a.carrera, pAnioAcademico as anio_academico
FROM 	int_arau_nuinscrip i
		JOIN sga_alumnos a
			ON i.carrera = a.carrera
			AND i.legajo = a.legajo

		JOIN sga_carreras_grupo gc
			ON gc.carrera = i.carrera
	
WHERE i.anio_academico = pAnioAcademico
AND (i.carrera = pCarrera or pCarrera = '')
AND gc.grupo_carrera = '00001'
INTO TEMP tmp_alumnos_sur1 WITH NO LOG;

-- *******************************************************************************************************************************************
-- Obtengo el último dato censal del alumnos
-- *******************************************************************************************************************************************
SELECT sur1.nro_inscripcion, sur1.carrera, MAX(dat.fecha_actualiz) AS fecha_actualiz, MAX(sur1.anio_academico) as anio_academico
FROM sga_datos_censales dat
	JOIN tmp_alumnos_sur1 sur1
		ON dat.nro_inscripcion = sur1.nro_inscripcion
GROUP BY sur1.nro_inscripcion, sur1.carrera
INTO TEMP aux_max_censales WITH NO LOG;

CREATE INDEX idx_aux_max_censales ON aux_max_censales (nro_inscripcion, carrera, fecha_actualiz);

-- *******************************************************************************************************************************************
-- Obtengo el conjunto de datos de los alumnos
-- *******************************************************************************************************************************************


SELECT  distinct a.nro_inscripcion,
	insc.anio_academico as periodo_inscripcio,
	a.carrera,
	a.plan,
	
	p.unidad_academica,

	c.nombre AS nombre_carrera,
	a.legajo, 
	p.apellido, 
	p.nombres,
	p.fecha_nacimiento,
	case ""||p.sexo	when "1" then "M"
			when "2" then "F"
	end as sexo,

	case ""||p.tipo_documento	when "0" then "DNI"
				when "2" then "CI"
				when "18" then "LE"
				when "19" then "LC"
				when "90" then "Pas"
	end as tipo_documento,

 	p.nro_documento, 
	case ""||dat.estado_civil	when "1" then "Soltero"
				when "2" then "Casado"
				when "3" then "Separado"
				when "4" then "Divorciado"
				when "5" then "Unión concensual"
				when "6" then "Viudo"
	end as estado_civil,

	dat.calle_proc, 
	dat.numero_proc,
	dat.piso_proc,
	dat.dpto_proc,  
	dat.unidad_proc, 
	dat.loc_proc, 
	"                                                                                                                             " AS localidad_proc,  --l.nombre 
	"                                                                                                                             " AS partido_proc, --dpto.nombre 
	"                                                                                                                             " AS provincia_proc,  --pro.nombre 
	dat.cp_proc, 
	dat.te_proc,
	dat.calle_per_lect,
	dat.numero_per_lect,
	dat.piso_per_lect,
	dat.dpto_per_lect,  
	dat.unidad_per_lect, 
	dat.loc_per_lect,
	"                                                                                                                             " AS localidad_per_lect,  --l1.nombre 
	"                                                                                                                             " AS partido_per_lect, --dpto1.nombre 
	"                                                                                                                             " AS provincia_per_lect,  --pro1.nombre 
	dat.cp_per_lect, 
	dat.te_per_lect,

	case ""||dat.sit_laboral_alu	when "1" then "Desocupado"
		when "2" then "Ocupado Temporal"
		when "3" then "Ocupado Permanente"
		when "4" then "Subocupado"
		when "5" then "Atención del Hogar y la Familia"
		when "6" then "Jubilado o Pencionado"
		when "7" then "Otros"
	end as sit_laboral_alu,

	case ""||dat.hora_sem_trab_alum	when "1" then "hasta 20 hs."
				when "2" then "de 21 a 35 hs."
				when "3" then "más de 35 hs."
				when "4" then "no trabaja"
		end as hora_trabaja,

	case ""||dat.act_econom_alum	when "1" then "Agricultura, Ganadería y Minería"
				when "2" then "Industria y Construcción"
				when "3" then "Comercio"
				when "4" then "Bancos, Bolsas, Seguros y Sociedades Financieras"
				when "5" then "Enseñanza"
				when "6" then "Entes Civiles del Estado"
				when "7" then "Fuerzas Armadas y de Seguridad"
				when "8" then "Ejercicio de profesión liberal"
				when "9" then "Servicios públicos y privados part."
				when "10" then "Instituciones deportivas y afines"
				when "11" then "Artes en general y actividades afines"
				when "12" then "Medios de comunicación"
				when "13" then "Ocupaciones varias"
				when "14" then "Explotación de Minas y Canteras"
				when "15" then "Hoteles y restaurantes"
				when "16" then "Transporte, almacenamiento y comunicación"
				when "17" then "Activ. Inmobiliarias, empresariales y de alquiler"
				when "18" then "Servicios Sociales y de Salud"
				when "19" then "Otras activ. de servicios comunit.,soc. y personales"
				when "20" then "Hogares privados con servicio doméstico"
				when "21" then "Organizaciones y órganos extraterritoriales"
				when "22" then "Industrias Manufactureras"
				when "23" then "Suministro de Electricidad"
				when "24" then "Actividades inmobiliarias, empresariales y de alquiler"
		end as sector_econom_alum,
	case ""||dat.det_rama_act_alum	when "1" then "Administrativas, en planificación o informática"
				when "2" then "Contables, financieras o presupuestarias"
				when "3" then "Comerciales, de transporte, almacenaje o telecomunicaciones"
				when "4" then "Servicios sociales básicos (Ej.: educación, salud, etc.)"
				when "5" then "Servicios varios (Ej.: peluquería, cocina, etc.)"
				when "6" then "Agropecuario, forestales, pesca y caza"
				when "7" then "Producción de energia, agua potable, gas, extracción de minerales, construcción o infraestructura"
				when "8" then "Producción industrial o artesanal (Ej.: Panificación, mataderos, mueblerías)"
				when "9" then "Otras"
		end as tareas_act_alum,

	case ""||dat.sit_laboral_padre	when "1" then "Desocupado"
		when "2" then "Ocupado Temporal"
		when "3" then "Ocupado Permanente"
		when "4" then "Subocupado"
		when "5" then "Atención del Hogar y la Familia"
		when "6" then "Jubilado o Pencionado"
		when "7" then "Otros"
	end as sit_laboral_pad,

	case ""||dat.sit_laboral_madre	when "1" then "Desocupado"
		when "2" then "Ocupado Temporal"
		when "3" then "Ocupado Permanente"
		when "4" then "Subocupado"
		when "5" then "Atención del Hogar y la Familia"
		when "6" then "Jubilado o Pencionado"
		when "7" then "Otros"
	end as sit_laboral_mad,
	
	est_padre.descripcion as ult_est_padre,
	est_madre.descripcion as ult_est_madre	

FROM 	sga_periodo_insc insc

		JOIN sga_carrera_aspira asp
			ON asp.periodo_inscripcio = insc.periodo_inscripcio 

		JOIN sga_alumnos a
			ON asp.nro_inscripcion = a.nro_inscripcion and asp.carrera = a.carrera

		JOIN sga_personas p
			ON p.nro_inscripcion = a.nro_inscripcion

		JOIN sga_datos_censales dat
			ON p.nro_inscripcion = dat.nro_inscripcion

		JOIN aux_max_censales aux_dc
			on dat.nro_inscripcion = aux_dc.nro_inscripcion
			and dat.fecha_actualiz = aux_dc.fecha_actualiz
			and a.carrera = aux_dc.carrera

		JOIN sga_carreras c	
			ON a.carrera = c.carrera

		JOIN sga_tipos_est_curs est_padre
			ON dat.ult_est_cur_padre = est_padre.estudio_cur	

		JOIN sga_tipos_est_curs est_madre
			ON dat.ult_est_cur_madre = est_madre.estudio_cur

WHERE aux_dc.anio_academico = insc.anio_academico
INTO TEMP aux_alumno WITH NO LOG;

update aux_alumno set localidad_proc = (select nombre from mug_localidades  where localidad = aux_alumno.loc_proc);
update aux_alumno set localidad_per_lect = (select nombre from mug_localidades where localidad = aux_alumno.loc_per_lect);

update aux_alumno set partido_proc = (select dpto.nombre from mug_localidades l
		JOIN mug_dptos_partidos dpto
		  ON l.dpto_partido = dpto.dpto_partido
			JOIN mug_provincias pro
			  ON dpto.provincia = pro.provincia
		  where l.localidad = aux_alumno.loc_proc);

update aux_alumno set partido_per_lect =  (select dpto.nombre from mug_localidades l
		JOIN mug_dptos_partidos dpto
		  ON l.dpto_partido = dpto.dpto_partido
			JOIN mug_provincias pro
			  ON dpto.provincia = pro.provincia
		  where l.localidad = aux_alumno.loc_per_lect);

update aux_alumno set provincia_proc =  (select pro.nombre from mug_localidades l
		JOIN mug_dptos_partidos dpto
		  ON l.dpto_partido = dpto.dpto_partido
			JOIN mug_provincias pro
			  ON dpto.provincia = pro.provincia
		  where l.localidad = aux_alumno.loc_proc);

update aux_alumno set provincia_per_lect = (select pro.nombre from mug_localidades l
		JOIN mug_dptos_partidos dpto
		  ON l.dpto_partido = dpto.dpto_partido
			JOIN mug_provincias pro
			  ON dpto.provincia = pro.provincia
		  where l.localidad = aux_alumno.loc_per_lect);

-- *******************************************************************************************************************************************
-- *******************************************************************************************************************************************

FOREACH  
	SELECT distinct pAnioAcademico,
		i.periodo_inscripcio,
		i.unidad_academica,
		i.carrera,
		i.nombre_carrera,
		i.legajo,
		i.apellido, 
		i.nombres, 
		i.fecha_nacimiento,
		i.sexo,
		i.tipo_documento, 
		i.nro_documento, 
		i.estado_civil,
		i.calle_proc, 
		i.numero_proc, 
		i.piso_proc, 
		i.dpto_proc, 
		i.unidad_proc, 
		i.localidad_proc,
		i.partido_proc, 
		i.provincia_proc,
		i.cp_proc, 
		i.te_proc,
		i.calle_per_lect, 
		i.numero_per_lect, 
		i.piso_per_lect, 
		i.dpto_per_lect, 
		i.unidad_per_lect, 
		i.localidad_per_lect, 
		i.partido_per_lect, 
		i.provincia_per_lect, 
		i.cp_per_lect, 
		i.te_per_lect, 
		i.sit_laboral_alu,
		i.hora_trabaja,
		i.sector_econom_alum,
		i.tareas_act_alum,
		i.sit_laboral_pad,
		i.sit_laboral_mad,
		i.ult_est_padre,
		i.ult_est_madre
-- ***************************************************************************************************************
-- Listado de variables a devolver
-- ***************************************************************************************************************
	INTO	v_anio,
		v_anio_ingreso,
		v_unidad_academica,
		v_carrera,
		v_nombre_carrera,
		v_legajo,
		v_apellido,
		v_nombres,
		v_fecha_nacimiento,
		v_sexo,
		v_tipo_documento,
		v_nro_documento,
		v_estado_civil,
		v_calle_proc,
		v_numero_proc,
		v_piso_proc,
		v_dpto_proc,
		v_unidad_proc,
		v_localidad_proc,
		v_patido_proc,
		v_provincia_proc,
		v_cp_proc,
		v_te_proc,
		v_calle_per_lect,
		v_numero_per_lect,
		v_piso_per_lect,
		v_dpto_per_lect,
		v_unidad_per_lect,
		v_loc_per_lect,
		v_patido_per_lect,
		v_prov_per_lect,
		v_cp_per_lect,
		v_te_per_lect,
		v_sit_lab_alu,
		v_horas_trabaja,
		v_sector_econom_alum,
		v_tareas_act_alum,
		v_sit_lab_pad,
		v_sit_lab_mad,
		v_ult_est_cur_pad,
		v_ult_est_cur_mad
-- ***************************************************************************************************************
-- ***************************************************************************************************************
	FROM aux_alumno i
	ORDER BY nombre_carrera, apellido, nombres
		-- devuelve la lista SUR D1 por carrera.
-- ***************************************************************************************************************
-- Listado de variables a devolver
-- ***************************************************************************************************************
		RETURN 	v_anio,
				v_anio_ingreso,
				v_apellido,
				v_nombres,
				v_fecha_nacimiento,
				v_sexo,
				v_tipo_documento,
				v_nro_documento,
				v_legajo,
				v_unidad_academica,
				v_carrera,
				v_nombre_carrera,
				v_estado_civil,
				v_calle_per_lect,
				v_numero_per_lect,
				v_piso_per_lect,
				v_dpto_per_lect,
				v_unidad_per_lect,
				v_loc_per_lect,
				v_patido_per_lect,
				v_prov_per_lect,
				v_cp_per_lect,
				v_te_per_lect,

				v_calle_proc,
				v_numero_proc,
				v_piso_proc,
				v_dpto_proc,
				v_unidad_proc,
				v_localidad_proc,
				v_patido_proc,
				v_provincia_proc,
				v_cp_proc,
				v_te_proc,

				v_sit_lab_alu,
				v_horas_trabaja,
				v_sector_econom_alum,
				v_tareas_act_alum,
				v_sit_lab_pad,
				v_sit_lab_mad,
				v_ult_est_cur_pad,
				v_ult_est_cur_mad  WITH RESUME;
-- ***************************************************************************************************************
-- ***************************************************************************************************************
END FOREACH;
END;
	
BEGIN

on exception in (-206)
       -- Tabla no existe continuo el proceso	
end exception with resume;
	DROP TABLE aux_alumno;
	DROP TABLE tmp_alumnos_sur1;
	DROP TABLE aux_max_censales;
END;
END PROCEDURE;

-- execute procedure sp820_sur_d1('FCJS', '3', 2014);
