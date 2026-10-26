CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_sur_d1') THEN
		DROP PROCEDURE sp820_sur_d1;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


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

		varchar(5),		-- plan.

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
		varchar(255),		-- ultimos estudios cursados de la madre. 41
		char(2),		-- situacion del aspirante. 42
		varchar(255),		-- nombre del colegio. 43


		integer,
		integer,
		integer,
		varchar(20),
		integer,
		date, -- fecha en que se inscribió al aspirante.
		integer,
		integer,
		varchar(50),
		varchar(255),
		char(1),
		varchar(255),
		varchar(255),
		char(1),
		integer,
		char(1),

		integer,
		integer,
		integer,
		integer,
		integer,

		varchar(40),

		varchar(255),
		varchar(255),

		varchar(40),

		varchar(255),
		varchar(255),

		varchar(40);

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
DEFINE	v_act_econom_alum		varchar(255);
DEFINE	v_det_rama_act_alum			varchar(255);
DEFINE	v_sit_lab_pad			varchar(255);
DEFINE	v_sit_lab_mad			varchar(255);
DEFINE	v_ult_est_cur_mad			varchar(255);
DEFINE	v_ult_est_cur_pad			varchar(255);

DEFINE	v_situacion_asp			char(2);
DEFINE	v_nombre_colegio			varchar(255);
DEFINE	v_plan			varchar(5);

DEFINE v_cnt_materias integer;
DEFINE v_cnt_optativas integer;
DEFINE v_cnt_idiomas integer;
DEFINE v_duracion_teorica varchar(20);
DEFINE v_titulo_araucano integer;
DEFINE v_fecha_inscripcion date; -- fecha en que se inscribió al aspirante.
DEFINE v_instituc_araucano integer;
DEFINE v_colegio integer;
DEFINE v_e_mail varchar(50);
DEFINE v_alu_otestsup_uni varchar(255);
DEFINE v_alu_otestsup_tipo char(1);
DEFINE v_alu_otestsup_area varchar(255);
DEFINE v_alu_otestsup_carr varchar(255);
DEFINE v_alu_otestsup_esta char(1);
DEFINE v_alu_otestsup_egre integer;
DEFINE v_alu_otestsup_niv char(1);

DEFINE v_vive_con_conyuge integer;
DEFINE v_vive_con_padre integer;
DEFINE v_vive_con_madre integer;
DEFINE v_vive_con_hijos integer;
DEFINE v_vive_con_hermanos integer;

DEFINE v_categ_ocup_alum varchar(40);

DEFINE v_act_econom_padre varchar(255);
DEFINE v_det_rama_act_padre varchar(255);

DEFINE v_categ_ocup_padre varchar(40);

DEFINE v_act_econom_madre varchar(255);
DEFINE v_det_rama_act_madre varchar(255);

DEFINE v_categ_ocup_madre varchar(40);


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
AND gc.grupo_carrera in ( '00001', '00002')
INTO TEMP tmp_alumnos_sur1 WITH NO LOG;

-- *******************************************************************************************************************************************
-- Obtengo el último dato censal del alumnos
-- *******************************************************************************************************************************************
SELECT sur1.nro_inscripcion, sur1.carrera, MAX(dat.fecha_relevamiento) AS fecha_relevamiento, MAX(sur1.anio_academico) as anio_academico
FROM sga_datos_censales dat
	JOIN tmp_alumnos_sur1 sur1
		ON dat.nro_inscripcion = sur1.nro_inscripcion
GROUP BY sur1.nro_inscripcion, sur1.carrera
INTO TEMP aux_max_censales WITH NO LOG;

CREATE INDEX idx_aux_max_censales ON aux_max_censales (nro_inscripcion, carrera, fecha_relevamiento);

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
				else "Desconoce"
		end as hora_trabaja,

	act_econ.descripcion as act_econom_alum,
	u820_rama.nombre as det_rama_act_alum,

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
	est_madre.descripcion as ult_est_madre,
	asp.situacion_asp as situacion_asp,
	col.nombre as nombre_colegio,

	pl.cnt_materias,
	pl.cnt_optativas,
	pl.cnt_idiomas,
	pl.duracion_teorica,
	tt.titulo_araucano,
	p.fecha_inscripcion, -- fecha en que se inscribió al aspirante.
	ua.instituc_araucano,
	col.colegio,
	dat.e_mail,
	dat1.alu_otestsup_uni,
	dat1.alu_otestsup_tipo,
	dat1.alu_otestsup_area,
	dat1.alu_otestsup_carr,
	dat1.alu_otestsup_esta,
	dat1.alu_otestsup_egre,
	dat1.alu_otestsup_niv,

	dat2.vive_con_conyuge,
	dat2.vive_con_padre,
	dat2.vive_con_madre,
	dat2.vive_con_hijos,
	dat2.vive_con_hermanos,

	categ.descripcion as categ_ocup_alum,

	act_econ1.descripcion as act_econom_padre,
	u820_rama1.nombre as det_rama_act_padre,

	categ1.descripcion as categ_ocup_padre,

	act_econ2.descripcion as act_econom_madre,
	u820_rama2.nombre as det_rama_act_madre,

	categ2.descripcion as categ_ocup_madre



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
			and dat.fecha_relevamiento = aux_dc.fecha_relevamiento
			and a.carrera = aux_dc.carrera

		-- Nuevos datos requeridos
		JOIN sga_planes pl
			on a.carrera = pl.carrera
			and a.plan = pl.plan
		JOIN sga_titulos_plan tp
			on pl.carrera = tp.carrera
			and pl.plan = tp.plan
		JOIN sga_titulos tt
			on tp.titulo = tt.titulo
			and tt.nivel = 'GRADO'

		JOIN sga_unidades_acad ua
			on a.unidad_academica = ua.unidad_academica

		JOIN sga_carreras c	
			ON a.carrera = c.carrera


		LEFT JOIN sga_datos_cen_aux2 dat1
			on dat.nro_inscripcion = dat1.nro_inscripcion
			and dat.fecha_relevamiento = dat1.fecha_relevamiento

		LEFT JOIN sga_datos_cen_aux dat2
			on dat.nro_inscripcion = dat2.nro_inscripcion
			and dat.fecha_relevamiento = dat2.fecha_relevamiento

		LEFT JOIN sga_categ_ocup categ
			on dat.categ_ocup_alum = categ.categ_ocup
		LEFT JOIN sga_categ_ocup categ1
			on dat.categ_ocup_padre = categ1.categ_ocup
		LEFT JOIN sga_categ_ocup categ2
			on dat.categ_ocup_madre = categ2.categ_ocup

		LEFT JOIN u820_rama_actividad u820_rama
			on dat.det_rama_act_alum = u820_rama.rama
		LEFT JOIN sga_act_economica act_econ
			on dat.act_econom_alum = act_econ.act_economica

		LEFT JOIN u820_rama_actividad u820_rama1
			on dat.det_rama_act_padre = u820_rama.rama
		LEFT JOIN sga_act_economica act_econ1
			on dat.act_econom_padre = act_econ.act_economica

		LEFT JOIN u820_rama_actividad u820_rama2
			on dat.det_rama_act_madre = u820_rama.rama
		LEFT JOIN sga_act_economica act_econ2
			on dat.act_econom_madre = act_econ.act_economica

		LEFT JOIN sga_tipos_est_curs est_padre
			ON dat.ult_est_cur_padre = est_padre.estudio_cur	

		LEFT JOIN sga_tipos_est_curs est_madre
			ON dat.ult_est_cur_madre = est_madre.estudio_cur

		LEFT JOIN sga_coleg_sec col
			ON p.colegio_secundario = col.colegio

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
		i.plan,
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
		i.act_econom_alum,
		i.det_rama_act_alum,
		i.sit_laboral_pad,
		i.sit_laboral_mad,
		i.ult_est_padre,
		i.ult_est_madre,
		i.situacion_asp,
		i.nombre_colegio,
		i.cnt_materias,
		i.cnt_optativas,
		i.cnt_idiomas,
		i.duracion_teorica,
		i.titulo_araucano,
		i.fecha_inscripcion, -- fecha en que se inscribió al aspirante.
		i.instituc_araucano,
		i.colegio,
		i.e_mail,
		i.alu_otestsup_uni,
		i.alu_otestsup_tipo,
		i.alu_otestsup_area,
		i.alu_otestsup_carr,
		i.alu_otestsup_esta,
		i.alu_otestsup_egre,
		i.alu_otestsup_niv,

		i.vive_con_conyuge,
		i.vive_con_padre,
		i.vive_con_madre,
		i.vive_con_hijos,
		i.vive_con_hermanos,

		i.categ_ocup_alum,

		i.act_econom_padre,
		i.det_rama_act_padre,

		i.categ_ocup_padre,

		i.act_econom_padre,
		i.det_rama_act_padre,

		i.categ_ocup_madre



-- ***************************************************************************************************************
-- Listado de variables a devolver
-- ***************************************************************************************************************
	INTO	v_anio,
		v_anio_ingreso,
		v_unidad_academica,
		v_carrera,
		v_nombre_carrera,
		v_plan,
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
		v_act_econom_alum,
		v_det_rama_act_alum,
		v_sit_lab_pad,
		v_sit_lab_mad,
		v_ult_est_cur_pad,
		v_ult_est_cur_mad,
		v_situacion_asp,
		v_nombre_colegio,

		v_cnt_materias,
		v_cnt_optativas,
		v_cnt_idiomas,
		v_duracion_teorica,
		v_titulo_araucano,
		v_fecha_inscripcion, -- fecha en que se inscribió al aspirante.
		v_instituc_araucano,
		v_colegio,
		v_e_mail,
		v_alu_otestsup_uni,
		v_alu_otestsup_tipo,
		v_alu_otestsup_area,
		v_alu_otestsup_carr,
		v_alu_otestsup_esta,
		v_alu_otestsup_egre,
		v_alu_otestsup_niv,

		v_vive_con_conyuge,
		v_vive_con_padre,
		v_vive_con_madre,
		v_vive_con_hijos,
		v_vive_con_hermanos,

		v_categ_ocup_alum,

		v_act_econom_padre,
		v_det_rama_act_padre,

		v_categ_ocup_padre,

		v_act_econom_madre,
		v_det_rama_act_madre,

		v_categ_ocup_madre



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
				v_plan,
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
				v_act_econom_alum,
				v_det_rama_act_alum,
				v_sit_lab_pad,
				v_sit_lab_mad,
				v_ult_est_cur_pad,
				v_ult_est_cur_mad,
				v_situacion_asp,
				v_nombre_colegio,
				v_cnt_materias,
				v_cnt_optativas,
				v_cnt_idiomas,
				v_duracion_teorica,
				v_titulo_araucano,
				v_fecha_inscripcion, -- fecha en que se inscribió al aspirante.
				v_instituc_araucano,
				v_colegio,
				v_e_mail,
				v_alu_otestsup_uni,
				v_alu_otestsup_tipo,
				v_alu_otestsup_area,
				v_alu_otestsup_carr,
				v_alu_otestsup_esta,
				v_alu_otestsup_egre,
				v_alu_otestsup_niv,

				v_vive_con_conyuge,
				v_vive_con_padre,
				v_vive_con_madre,
				v_vive_con_hijos,
				v_vive_con_hermanos,

				v_categ_ocup_alum,

				v_act_econom_padre,
				v_det_rama_act_padre,

				v_categ_ocup_padre,

				v_act_econom_madre,
				v_det_rama_act_madre,

				v_categ_ocup_madre



  WITH RESUME;
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

-- execute procedure sp820_sur_d1('FADU', '1', 2014);

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_sur_d1
-- *****************************************************************************
revoke execute on "dba".sp820_sur_d1 from public;
grant execute on "dba".sp820_sur_d1 to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_sur_d1 to internet; -- Rol de usuario de Internet