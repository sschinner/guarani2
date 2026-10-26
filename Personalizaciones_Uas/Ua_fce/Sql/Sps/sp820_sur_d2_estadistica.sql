CREATE PROCEDURE verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_sur_d2') THEN
		DROP PROCEDURE sp820_sur_d2;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE verifica_objeto();
DROP PROCEDURE verifica_objeto();

-- Condiciones:
-- Se consideran todas las materias sean por examen, promoción o equivalencia.
-- Se utiliza la historia academica estandar: vw_hist_academica
-- Se consideran solo materias del Plan y Versión actual del alumno
-- Se consideran los cursos de ingreso
-- Creating procedure
CREATE PROCEDURE "dba".sp820_sur_d2(pUa LIKE sga_unidades_acad.unidad_academica, pCarrera LIKE sga_carreras.carrera, pAnioAcademico LIKE sga_anio_academico.anio_academico)

-- ***************************************************************************************************************
-- Listado de variables a devolver
-- ***************************************************************************************************************
RETURNING	integer,			-- anio. 1
		varchar(20),			-- anio ingreso. 2
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
		integer,			-- rendidos. 34
		integer,			-- aprobadas. 35
		integer,			-- aprobadas_ant. 36

		varchar(255),		-- sit_laboral_alu. 37
		varchar(255),		-- horas_trabaja. 38
		varchar(255),		-- sector. 39
		varchar(255),		-- tareas. 40
		varchar(255),		-- jerarquia. 41
		varchar(5);			-- plan. 42
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
DEFINE 	v_anio_ingreso			varchar(20);
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
DEFINE	v_rendidos			integer;
DEFINE	v_aprobadas			integer;
DEFINE	v_aprobadas_ant			integer;
DEFINE	v_sit_lab_alu			varchar(255);
DEFINE	v_horas_trabaja			varchar(255);
DEFINE	v_sector_econom_alum		varchar(255);
DEFINE	v_tareas_act_alum			varchar(255);
DEFINE	v_jerarquia_act_alum		varchar(255);
DEFINE	v_plan			varchar(5);
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
-- Calcular el Año Academico, correspondiente al Año anterior al Año Academico Seleccionado (pAnioacademico).
-- Se delega al SP del SIU
-- *******************************************************************************************************************************************

-- *******************************************************************************************************************************************
-- *******************************************************************************************************************************************

-- *******************************************************************************************************************************************
-- Obtengo el conjunto de alumnos: Correr el proceso de actualización de Reinscriptos para el Araucano.
-- Tener en cuenta que este proceso descarta alumnos que no tengan cargado determinados atributos. 
-- Por lo que primero se debe correr el proceso normal de araucano de actualizar Orden1 (ifz00005) y Orden 2 (ifz00003)
-- *******************************************************************************************************************************************

EXECUTE PROCEDURE sp_int_arau_ingrei ( pAnioAcademico);


SELECT a.nro_inscripcion, a.carrera, r.tot_rendidas, r.tot_aprobadas, r.mat_aprobadas as aprobadas_ant, pAnioAcademico as anio_academico
FROM 	int_arau_reinscrip r 
		JOIN sga_alumnos a
			ON r.carrera = a.carrera
			AND r.legajo = a.legajo

		JOIN sga_carreras_grupo gc
			ON gc.carrera = r.carrera
	
WHERE (r.carrera = pCarrera or pCarrera = '')
AND gc.grupo_carrera = '00001'
AND r.anio_academico = pAnioAcademico 
INTO TEMP tmp_alumnos_sur1 WITH NO LOG;

-- *******************************************************************************************************************************************
-- Obtengo el último dato censal del alumnos
-- *******************************************************************************************************************************************
SELECT sur1.nro_inscripcion, sur1.carrera, MAX(dat.fecha_actualiz) AS fecha_actualiz, max(sur1.tot_rendidas) tot_rendidas, max(sur1.tot_aprobadas) tot_aprobadas, max(sur1.aprobadas_ant) aprobadas_ant, MAX(sur1.anio_academico) as anio_academico
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
	pinsc.anio_academico,
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
	aux_dc.tot_rendidas,
	aux_dc.tot_aprobadas,
	aux_dc.aprobadas_ant,

	case ""||dat.sit_laboral_alu	when "1" then "Desocupado"
						when "2" then "Ocupado Temporal"
						when "3" then "Ocupado Permanente"
						when "4" then "Subocupado"
						when "5" then "Atención del Hogar y la Familia"
						when "6" then "Jubilado o Pencionado"
						when "7" then "Otros"
	end as sit_laboral_alu,

	horas.descripcion as hora_trabaja,
	act_econ.descripcion as sector_econom_alum,
	u820_rama.nombre as tareas_act_alum,
	categ.descripcion as jerarquia_act_alum

FROM sga_alumnos a
		JOIN sga_carrera_aspira asp
			ON a.nro_inscripcion = asp.nro_inscripcion 
			AND a.carrera = asp.carrera
		
		JOIN sga_personas p
			ON asp.nro_inscripcion = p.nro_inscripcion
		
		JOIN sga_datos_censales dat
			ON p.nro_inscripcion = dat.nro_inscripcion

		JOIN aux_max_censales aux_dc
			ON dat.nro_inscripcion = aux_dc.nro_inscripcion
			AND dat.fecha_actualiz = aux_dc.fecha_actualiz
			AND a.carrera = aux_dc.carrera

		JOIN sga_periodo_insc pinsc
			ON asp.periodo_inscripcio = pinsc.periodo_inscripcio
			
	JOIN sga_carreras c
		on a.carrera = c.carrera

	LEFT JOIN sga_categ_ocup categ
		on dat.categ_ocup_alum = categ.categ_ocup

	LEFT JOIN u820_rama_actividad u820_rama
		on dat.det_rama_act_alum = u820_rama.rama

	LEFT JOIN sga_act_economica act_econ
		on dat.act_econom_alum = act_econ.act_economica

	LEFT JOIN sga_horas_sem_trab horas
		on dat.hora_sem_trab_alum = horas.hora_sem_trab

WHERE pinsc.anio_academico < aux_dc.anio_academico
ORDER BY a.carrera
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



FOREACH  
	SELECT distinct pAnioAcademico,
		i.anio_academico,
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
		i.tot_rendidas,
		i.tot_aprobadas,
		i.aprobadas_ant,
		i.sit_laboral_alu,
		i.hora_trabaja,
		i.sector_econom_alum,
		i.tareas_act_alum,
		i.jerarquia_act_alum

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
		v_rendidos,
		v_aprobadas,
		v_aprobadas_ant,
		v_sit_lab_alu,
		v_horas_trabaja,
		v_sector_econom_alum,
		v_tareas_act_alum,
		v_jerarquia_act_alum

-- ***************************************************************************************************************
-- ***************************************************************************************************************
	FROM aux_alumno i
		
	ORDER BY i.carrera, i.apellido, i.nombres

		-- devuelve la lista SUR D2 por carrera.
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

				v_rendidos,
				v_aprobadas,
				v_aprobadas_ant,

				v_sit_lab_alu,
				v_horas_trabaja,
				v_sector_econom_alum,
				v_tareas_act_alum,
				v_jerarquia_act_alum,
				v_plan    
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

-- execute procedure sp820_sur_d2('FADU', '1', 2014);

