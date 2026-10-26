drop PROCEDURE "dba".sp820_fce_datos_alumnos;

CREATE PROCEDURE "dba".sp820_fce_datos_alumnos(pCarrera LIKE sga_carreras.carrera,  pCalidad char(1), pDesdeapr  smallint, pHastaapr  smallint, pDesderepr  smallint, pHastarepr  smallint ) 

RETURNING
		varchar(20),	-- DNI					X
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
 		char(1),	                -- CALIDAD   				X
		decimal(3),	-- CANTIDAD DE MATERIAS APROBADAS	X
		decimal(3),	-- CANTIDAD DE MATERIAS REPROBADAS	X
		decimal(4,2),	-- PROMEDIO CON APLAZOS		X
		decimal(4,2);	-- PROMEDIO SIN APLAZOS			X

DEFINE vdni varchar(20);
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
DEFINE vmat_aprob decimal(3);
DEFINE vmat_reprob decimal(3);
DEFINE vprom_aplazo decimal(4,2);
DEFINE vprom_sin_aplazo decimal(4,2);
DEFINE sResultado decimal(2);
DEFINE vcalidad char(1);


-----  VARS PARA EL MANEJO DE EXCEPCIONES

DEFINE sql_err	 			integer;
DEFINE isam_err 				integer;
DEFINE error_info				varchar(76);

ON EXCEPTION SET sql_err, isam_err, error_info                                        
      RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;     

BEGIN

LET vdni = NULL;
LET vapellido = NULL;
LET vnombres  = NULL;
LET vemail  = NULL;
LET vtel_proc  = NULL;
LET vdom_proc  = NULL;
LET vloc_proc  = NULL;
LET vdpto_proc  = NULL;
LET vprov_proc  = NULL;
LET vpais_proc  = NULL;
LET vtel_per_lect  = NULL;
LET vdom_per_lect  = NULL;
LET vloc_per_lect  = NULL;
LET vdpto_per_lect  = NULL;
LET vprov_per_lect  = NULL;
LET vpais_per_lect  = NULL;
LET vlegajo  = NULL;
LET vcarrera  = NULL;
LET vplan  = NULL;
LET vmat_aprob  = 0;
LET vmat_reprob = 0;
LET vprom_aplazo = 0;
LET vprom_sin_aplazo = 0;
LET sResultado = 0;
LET vcalidad = NULL;



--------  CARRERA-CALIDAD
SELECT   alu.unidad_academica,
                per.nro_documento, 
                 per.apellido, 
                  per.nombres, 
	alu.carrera, 
                  alu.plan, 
                 alu.legajo, 
                 alu.nro_inscripcion,
                 alu.calidad,
                 per.fecha_nacimiento
	FROM sga_personas per, sga_alumnos alu
	WHERE per.nro_inscripcion = alu.nro_inscripcion
--	AND per.unidad_academica = pUA
	AND per.unidad_academica = alu.unidad_academica

	AND ((alu.calidad = "A" and pCalidad = 'S') or pCalidad = 'N')
                AND alu.carrera = pCarrera
-- 	AND alu.regular = "S"
--                AND alu.legajo = '17396606-4'
	INTO TEMP tmp_a_alumnos0;


-------- CANTIDAD DE MATERIA APROBADAS Y REPROBADAS  --------------------------    VER

select alu.*,
u820_cuenta_mat (alu.unidad_academica, alu.carrera, alu.legajo, "A") mat_aprob,
u820_cuenta_mat (alu.unidad_academica, alu.carrera, alu.legajo, "R") mat_reprob
        FROM tmp_a_alumnos0 alu           
WHERE	      
         alu.carrera = pCarrera
        GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

  HAVING 
u820_cuenta_mat (alu.unidad_academica, alu.carrera, alu.legajo, "A") >=  pDesdeapr and
u820_cuenta_mat (alu.unidad_academica, alu.carrera, alu.legajo, "A") <=  pHastaapr and
u820_cuenta_mat (alu.unidad_academica, alu.carrera, alu.legajo, "R") >=  pDesderepr and
u820_cuenta_mat (alu.unidad_academica, alu.carrera, alu.legajo, "R") <=  pHastarepr 
	INTO TEMP tmp_a_alumnos1;


--------  PROMEDIOS DE LOS ALUMNOS

SELECT ta.*, 
           sp820_prom_alu_res1 (unidad_academica, carrera, legajo, 'S') as prom_c,
           sp820_prom_alu_res1 (unidad_academica, carrera, legajo, 'N') as prom_s
	FROM tmp_a_alumnos1 ta
	INTO TEMP tmp_a_promedio;


-------- RECUPERA  DATOS CENSALES 

SELECT   tp.*,
	dc.e_mail, dc.te_proc, 
	dc.calle_proc, dc.numero_proc, 
--                 dc.piso_proc, dc.dpto_proc,
                (case when dc.piso_proc is null then  "" else dc.piso_proc end) as piso_proc,
                (case when dc.dpto_proc is null then  "" else dc.dpto_proc end) as dpto_proc,
	dc.loc_proc  loc_proc1, 
	dc.te_per_lect, 
	dc.calle_per_lect, dc.numero_per_lect, 
--               dc.piso_per_lect, dc.dpto_per_lect,
                (case when dc.piso_per_lect is null then  "" else dc.piso_per_lect end) as piso_per_lect,
                (case when dc.dpto_per_lect is null then  "" else dc.dpto_per_lect end) as dpto_per_lect,

	dc.loc_per_lect  loc_per_lect1
	
	FROM  sga_datos_censales dc, tmp_a_promedio tp
	WHERE 
--	AND per.unidad_academica = pUA
--	AND per.unidad_academica = alu.unidad_academica
--	AND per.unidad_academica = dc.unidad_academica
	 tp.nro_inscripcion = dc.nro_inscripcion
	AND dc.fecha_relevamiento = (SELECT MAX(dc2.fecha_relevamiento) 
                                                                      FROM sga_datos_censales dc2 WHERE dc.unidad_academica = dc2.unidad_academica AND dc.nro_inscripcion = dc2.nro_inscripcion)

	INTO TEMP tmp_a_datos_censales1;


--------  RECUPERA EL NOMBRE DE LOCALIDAD, DEPARTAMENTO, PROVINCIA Y PAIS DE PROCEDENCIA

SELECT  dc1.*,
	loc.nombre loc_proc, dto.nombre depto_proc, pro.nombre prov_loc, pai.nombre pais_proc
	FROM tmp_a_datos_censales1 dc1
		LEFT JOIN mug_localidades loc
			LEFT JOIN mug_dptos_partidos dto
				LEFT JOIN mug_provincias pro
					LEFT JOIN mug_paises pai
						ON pro.pais = pai.pais
					ON dto.provincia = pro.provincia
				ON loc.dpto_partido = dto.dpto_partido
			ON dc1.loc_proc1 = loc.localidad
	INTO TEMP tmp_a_datos_censales2;
	

-------- RECUPERA EL NOMBRE DE LOCALIDAD, DEPARTAMENTO, PROVINCIA Y PAIS DURANTE EL PERÍODO LECTIVO

SELECT dc2.*,
	loc.nombre loc_per_lect, dto.nombre as depto_per_lect, pro.nombre prov_per_lect, pai.nombre pais_per_lect
	FROM tmp_a_datos_censales2 dc2
		LEFT JOIN mug_localidades loc
			LEFT JOIN mug_dptos_partidos dto
				LEFT JOIN mug_provincias pro
					LEFT JOIN mug_paises pai
						ON pro.pais = pai.pais
					ON dto.provincia = pro.provincia
				ON loc.dpto_partido = dto.dpto_partido
			ON dc2.loc_per_lect1 = loc.localidad
	INTO TEMP tmp_a_datos_censales3;


-------- FORMATO TABLA

SELECT dc3.nro_documento, dc3.apellido, dc3.nombres, dc3.calidad,
 		dc3.e_mail, dc3.te_proc, 
  		dc3.calle_proc || " " || dc3.numero_proc || " - " || dc3.piso_proc || " - " || dc3.dpto_proc as dom_proc,
  		dc3.loc_proc, dc3.depto_proc, 
  		dc3.prov_loc, dc3.pais_proc,
  		dc3.te_per_lect, 
  		dc3.calle_per_lect || " " || dc3.numero_per_lect || " - " || dc3.piso_per_lect || " - " || dc3.dpto_per_lect as dom_per_lect,
  		dc3.loc_per_lect, dc3.depto_per_lect, 
  		dc3.prov_per_lect, 
   -- dc3.pais_per_lect,
                                day(dc3.fecha_nacimiento)|| "/" || month(dc3.fecha_nacimiento) || "/" || year(dc3.fecha_nacimiento) as pais_per_lect ,
  		dc3.legajo, dc3.carrera, dc3.plan, 
		dc3.mat_aprob, dc3.mat_reprob,
		dc3.prom_c, dc3.prom_s
  	FROM tmp_a_datos_censales3 dc3
  	INTO TEMP tmp_a_datos_censales4;


FOREACH SELECT dc4.*
 	INTO vdni, vapellido, vnombres, vcalidad,
 		vemail, vtel_proc, vdom_proc,
 		vloc_proc, vdpto_proc, 
 		vprov_proc, vpais_proc,
 		vtel_per_lect, vdom_per_lect,
 		vloc_per_lect, vdpto_per_lect,
 		vprov_per_lect, vpais_per_lect,
 		vlegajo, vcarrera, vplan,
		vmat_aprob, vmat_reprob,
 		vprom_aplazo, 
  		vprom_sin_aplazo
	FROM tmp_a_datos_censales4 dc4
	ORDER BY dc4.apellido, dc4.nombres
		
	RETURN
		vdni, vapellido, vnombres,
		vemail, vtel_proc, vdom_proc,
		vloc_proc, vdpto_proc, 
		vprov_proc, vpais_proc,
		vtel_per_lect, vdom_per_lect,
		vloc_per_lect, vdpto_per_lect,
		vprov_per_lect, vpais_per_lect,
		vlegajo, vcarrera, vplan,
		vcalidad,		
		vmat_aprob, vmat_reprob,
		vprom_aplazo, vprom_sin_aplazo

		WITH RESUME; 

END FOREACH;


DROP TABLE tmp_a_alumnos0;
DROP TABLE tmp_a_alumnos1;
DROP TABLE tmp_a_promedio;
DROP TABLE tmp_a_datos_censales1;
DROP TABLE tmp_a_datos_censales2;
DROP TABLE tmp_a_datos_censales3;
DROP TABLE tmp_a_datos_censales4;

END;
END PROCEDURE;                                                                                             
