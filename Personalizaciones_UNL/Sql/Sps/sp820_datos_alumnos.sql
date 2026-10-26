CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_datos_alumnos') THEN
		DROP PROCEDURE sp820_datos_alumnos;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();
 
CREATE PROCEDURE "dba".sp820_datos_alumnos(pUA LIKE sga_unidades_acad.unidad_academica)

RETURNING
		varchar(15),	-- DNI					X
		varchar(30),	-- APELLIDO				X
		varchar(30),	-- NOMBRES				X
		varchar(50),	-- EMAIL					X
		char(18),  	-- TELEFONO (PROC)
		varchar(100),	-- DOMICILIO (PROC)
		varchar(100),	-- LOCALIDAD (PROC)
		varchar(100),	-- DEPARTEMENTO (PROC)
		varchar(100),	-- PROVINCIA (PROC)
		varchar(100),	-- PAIS (PROC)
		char(18),  	-- TELEFONO (LECT)
		varchar(100),	-- DOMICILIO (LECT)
		varchar(100),	-- LOCALIDAD (LECT)
		varchar(100),	-- DEPARTEMENTO (LECT)
		varchar(100),	-- PROVINCIA (LECT)
		varchar(100),	-- PAIS (LECT)
		varchar(15),	-- LEGAJO				X
		varchar(5),	-- CARRERA				X
		varchar(5),	-- PLAN					X
		varchar(5),	-- AÑO DE INGRESO			X
		decimal(3),	-- CANTIDAD DE MATERIAS APROBADAS	X
		decimal(3),	-- CANTIDAD DE MATERIAS REPROBADAS	X
		decimal(4,2),	-- PROMEDIO CON APLAZOS		X
		decimal(4,2);	-- PROMEDIO SIN APLAZOS			X


DEFINE vdni varchar(15);
DEFINE vapellido varchar(30);
DEFINE vnombres varchar(30);
DEFINE vemail varchar(50);
DEFINE vtel_proc char(18);
DEFINE vdom_proc varchar(100);
DEFINE vloc_proc varchar(100);
DEFINE vdpto_proc varchar(100);
DEFINE vprov_proc varchar(100);
DEFINE vpais_proc varchar(100);
DEFINE vtel_per_lect char(18);
DEFINE vdom_per_lect varchar(100);
DEFINE vloc_per_lect varchar(100);
DEFINE vdpto_per_lect varchar(100);
DEFINE vprov_per_lect varchar(100);
DEFINE vpais_per_lect varchar(100);
DEFINE vlegajo varchar(15);
DEFINE vcarrera varchar(5);
DEFINE vplan varchar(5);
DEFINE vingreso varchar(5);
DEFINE vmat_aprob decimal(3);
DEFINE vmat_reprob decimal(3);
DEFINE vprom_aplazo decimal(4,2);
DEFINE vprom_sin_aplazo decimal(4,2);
DEFINE sResultado decimal(2);
-- DEFINE sCreditos integer;


-----  VARS PARA EL MANEJO DE EXCEPCIONES

DEFINE sql_err	 			integer;
DEFINE isam_err 				integer;
DEFINE error_info				varchar(76);

ON EXCEPTION SET sql_err, isam_err, error_info                                        
      RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;     



BEGIN

BEGIN

     on exception in (-206)

       -- Tabla no existe continuo el proceso	

      end exception with resume;

	DROP TABLE tmp_datos_censales1;
	DROP TABLE tmp_datos_censales2;
	DROP TABLE tmp_datos_censales3;
	DROP TABLE tmp_datos_censales4;
	DROP TABLE tmp_promedio_c;
	DROP TABLE tmp_promedio_s;
	DROP TABLE tmp_carrera_plan;
	DROP TABLE tmp_materias_ayr;


END;

-------- REALIZO UNA PRIMERA CONSULTA PARA RECUPERAR LOS PROMEDIOS DE LOS ALUMNOS...
SELECT legajo, carrera,
	sp820_prom_alu_res1(pUA, carrera, legajo, 'S') as prom_c
	FROM sga_alumnos
	WHERE calidad = "A"
	AND regular = "S"
	INTO TEMP tmp_promedio_c;


SELECT legajo, carrera,
	sp820_prom_alu_res1(pUA, carrera, legajo, 'N') as prom_s
	FROM sga_alumnos
	WHERE calidad = "A"
	AND regular = "S"
	INTO TEMP tmp_promedio_s;



-------- REALIZO UNA CONSULTA PARA RECUPERAR LA CANTIDAD DE MATERIA APROBADAS Y REPROBADAS DE LOS ALUMNOS...

-- Se obtiene el plan del alumno segun su legajo y carrera en la que esta inscripto
-- Se obtiene la ultima version del plan activo correspondiente a la carrera del alumno

SELECT alu.legajo, alu.carrera, alu.plan, pla.version_actual
	FROM sga_alumnos alu, sga_planes pla
	WHERE alu.calidad = "A"
	AND alu.regular = "S"
	AND alu.carrera = pla.carrera
	AND alu.plan = pla.plan
	INTO TEMP tmp_carrera_plan;

-- En base a su historia académica se obtiene la cantidad de materias aprobadas que posee el alumno que a la vez sean obligatorias y de tipo normal o genérica
SELECT cp.legajo, cp.plan, cp.carrera, 
	SUM(CASE WHEN (NVL(h.resultado, "R") = "A") THEN 1 ELSE 0 END) as mat_aprob,
	SUM(CASE WHEN (NVL(h.resultado, "A") = "R") THEN 1 ELSE 0 END) as mat_reprob
	FROM tmp_carrera_plan cp
	LEFT JOIN vw_hist_academica h
		ON cp.legajo = h.legajo
        		AND cp.carrera = h.carrera
				AND h.materia NOT IN (SELECT materia FROM u820_cursos_ing WHERE carrera = h.carrera)
		AND h.materia IN (SELECT DISTINCT materia FROM sga_atrib_mat_plan p WHERE p.plan = cp.plan AND p.carrera = cp.carrera AND p.obligatoria = "S")
	GROUP BY cp.legajo, cp.plan, cp.carrera
	INTO TEMP tmp_materias_ayr WITH NO LOG;

DROP TABLE tmp_carrera_plan;

-------- REALIZO UNA PRIMERA CONSULTA PARA RECUPERAR LOS DATOS CENSALES DE LOS ALUMNOS, CARRERA, ETC...

SELECT per.nro_documento, per.apellido, per.nombres, 
	dc.e_mail, dc.te_proc, 
	dc.calle_proc, dc.numero_proc, dc.piso_proc, dc.dpto_proc,
	dc.loc_proc, 
	dc.te_per_lect, 
	dc.calle_per_lect, dc.numero_per_lect, dc.piso_per_lect, dc.dpto_per_lect,
	dc.loc_per_lect,
	alu.carrera, alu.plan, alu.legajo
	FROM sga_personas per, sga_alumnos alu, sga_datos_censales dc
	WHERE per.nro_inscripcion = alu.nro_inscripcion
	AND per.unidad_academica = pUA
	AND per.unidad_academica = alu.unidad_academica
	AND per.unidad_academica = dc.unidad_academica
	AND per.nro_inscripcion = dc.nro_inscripcion
	AND dc.fecha_relevamiento = (SELECT MAX(dc2.fecha_relevamiento) FROM sga_datos_censales dc2 WHERE dc.unidad_academica = dc2.unidad_academica AND dc.nro_inscripcion = dc2.nro_inscripcion)
	AND alu.calidad = "A"
	AND alu.regular = "S"
	INTO TEMP tmp_datos_censales1 WITH NO LOG;

-- SELECT count(*) FROM tmp_datos_censales1;

-------- CON LA SIGUIENTE CONSULTA RECUPERO EL NOMBRE DE LOCALIDAD, DEPARTAMENTO, PROVINCIA Y PAIS DE PROCEDENCIA

SELECT dc1.nro_documento, dc1.apellido, dc1.nombres, 
	dc1.e_mail, dc1.te_proc, 
	dc1.calle_proc, dc1.numero_proc, dc1.piso_proc, dc1.dpto_proc,
	loc.nombre loc_proc, dto.nombre depto_proc, pro.nombre prov_loc, pai.nombre pais_proc,
	dc1.te_per_lect, 
	dc1.calle_per_lect, dc1.numero_per_lect, dc1.piso_per_lect, dc1.dpto_per_lect,
	dc1.loc_per_lect,
	dc1.carrera, dc1.plan, dc1.legajo
	FROM tmp_datos_censales1 dc1
		LEFT JOIN mug_localidades loc
			LEFT JOIN mug_dptos_partidos dto
				LEFT JOIN mug_provincias pro
					LEFT JOIN mug_paises pai
						ON pro.pais = pai.pais
					ON dto.provincia = pro.provincia
				ON loc.dpto_partido = dto.dpto_partido
			ON dc1.loc_proc = loc.localidad
	INTO TEMP tmp_datos_censales2  WITH NO LOG;
	
DROP TABLE tmp_datos_censales1;
-- SELECT count(*) FROM tmp_datos_censales2;

-------- CON LA SIGUIENTE CONSULTA RECUPERO EL NOMBRE DE LOCALIDAD, DEPARTAMENTO, PROVINCIA Y PAIS DURANTE EL PERÍODO LECTIVO

SELECT dc2.nro_documento, dc2.apellido, dc2.nombres, 
	dc2.e_mail, dc2.te_proc, 
	dc2.calle_proc, dc2.numero_proc, dc2.piso_proc, dc2.dpto_proc,
	dc2.loc_proc, dc2.depto_proc, dc2.prov_loc, dc2.pais_proc,
	dc2.te_per_lect, 
	dc2.calle_per_lect, dc2.numero_per_lect, dc2.piso_per_lect, dc2.dpto_per_lect,
	loc.nombre loc_per_lect, dto.nombre as depto_per_lect, pro.nombre prov_per_lect, pai.nombre pais_per_lect,
	dc2.carrera, dc2.plan, dc2.legajo
	FROM tmp_datos_censales2 dc2
		LEFT JOIN mug_localidades loc
			LEFT JOIN mug_dptos_partidos dto
				LEFT JOIN mug_provincias pro
					LEFT JOIN mug_paises pai
						ON pro.pais = pai.pais
					ON dto.provincia = pro.provincia
				ON loc.dpto_partido = dto.dpto_partido
			ON dc2.loc_per_lect = loc.localidad
	INTO TEMP tmp_datos_censales3  WITH NO LOG;

DROP TABLE tmp_datos_censales2;
-- SELECT count(*) FROM tmp_datos_censales3;

-------- CON LA SIGUIENTE CONSULTA RECUPERO EL PROMEDIO CON APLAZOS Y SIN APLAZOS

SELECT dc3.nro_documento, dc3.apellido, dc3.nombres, 
 		dc3.e_mail, dc3.te_proc, 
  		dc3.calle_proc || " " || dc3.numero_proc || " - " || dc3.piso_proc || " - " || dc3.dpto_proc as dom_proc,
  		dc3.loc_proc, dc3.depto_proc, 
  		dc3.prov_loc, dc3.pais_proc,
  		dc3.te_per_lect, 
  		dc3.calle_per_lect || " " || dc3.numero_per_lect || " - " || dc3.piso_per_lect || " - " || dc3.dpto_per_lect as dom_per_lect,
  		dc3.loc_per_lect, dc3.depto_per_lect, 
  		dc3.prov_per_lect, dc3.pais_per_lect,
  		dc3.legajo, dc3.carrera, dc3.plan, spi.anio_academico, 
		mat.mat_aprob, mat.mat_reprob,
		pr1.prom_c, pr2.prom_s
  	FROM tmp_datos_censales3 dc3, tmp_promedio_c pr1, tmp_materias_ayr mat, tmp_promedio_s pr2, sga_carrera_aspira sca, sga_periodo_insc spi, sga_alumnos alu
	WHERE pr1.legajo = dc3.legajo
	AND pr1.carrera = dc3.carrera
	AND pr2.legajo = dc3.legajo
	AND pr2.carrera = dc3.carrera
	AND mat.legajo = dc3.legajo
	AND mat.carrera = dc3.carrera
	AND alu.legajo = dc3.legajo
	AND alu.carrera = dc3.carrera
	AND alu.plan = dc3.plan
	AND alu.nro_inscripcion = sca.nro_inscripcion
	AND alu.carrera = sca.carrera	
	AND sca.periodo_inscripcio = spi.periodo_inscripcio
  	INTO TEMP tmp_datos_censales4  WITH NO LOG;


DROP TABLE tmp_datos_censales3;
DROP TABLE tmp_promedio_c;
DROP TABLE tmp_promedio_s;
DROP TABLE tmp_materias_ayr;

FOREACH SELECT dc4.*
 	INTO vdni, vapellido, vnombres,
 		vemail, vtel_proc, vdom_proc,
 		vloc_proc, vdpto_proc, 
 		vprov_proc, vpais_proc,
 		vtel_per_lect, vdom_per_lect,
 		vloc_per_lect, vdpto_per_lect,
 		vprov_per_lect, vpais_per_lect,
 		vlegajo, vcarrera, vplan, vingreso,
		vmat_aprob, vmat_reprob,
 		vprom_aplazo, 
  		vprom_sin_aplazo
	FROM tmp_datos_censales4 dc4
	ORDER BY dc4.apellido, dc4.nombres

	-- Evalúo si tiene materias genéricas obligatorias aprobadas
	LET sResultado = 0;
	EXECUTE PROCEDURE sp820_Genericas_Aprobadas(pUA, vlegajo, vcarrera, vplan) INTO sResultado;
	LET vmat_aprob = vmat_aprob + sResultado;
		
	RETURN
		vdni, vapellido, vnombres,
		vemail, vtel_proc, vdom_proc,
		vloc_proc, vdpto_proc, 
		vprov_proc, vpais_proc,
		vtel_per_lect, vdom_per_lect,
		vloc_per_lect, vdpto_per_lect,
		vprov_per_lect, vpais_per_lect,
		vlegajo, vcarrera, vplan, vingreso,
		vmat_aprob, vmat_reprob,
		vprom_aplazo, vprom_sin_aplazo
		WITH RESUME; 

END FOREACH;

DROP TABLE tmp_datos_censales4;

END;
END PROCEDURE;
-- ********************************** FIN PROCESO "dba".sp820_datos_alumnos **********************************

-- EXECUTE PROCEDURE dba.sp820_datos_alumnos("FCJS");

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_datos_alumnos 
-- *****************************************************************************
revoke execute on "dba".sp820_datos_alumnos from public;
grant execute on "dba".sp820_datos_alumnos to guarani;  -- Rol de usuarios de Gestion
grant execute on "dba".sp820_datos_alumnos to internet; -- Rol de usuario de Internet