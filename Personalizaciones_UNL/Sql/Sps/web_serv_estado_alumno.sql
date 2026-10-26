CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_estado_alumno') THEN
		DROP PROCEDURE web_serv_estado_alumno;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Par?metros de WS: usuario guaran?;
-- Criterios: se asume que es un usuario autenticado

--  EXECUTE PROCEDURE web_serv_estado_alumno ('carrera' ,'03','0',54); --1
--  EXECUTE PROCEDURE web_serv_estado_alumno ('ingreso' ,2018,'0',54); --1
--  EXECUTE PROCEDURE web_serv_estado_alumno ('reinscripcion' ,2018,'0',54); --1
--  EXECUTE PROCEDURE web_serv_estado_alumno ('documento' ,'39579471','0',54); --1
CREATE PROCEDURE web_serv_estado_alumno(pfiltro varchar(20),pvalor1 varchar(10), pvalor2 varchar(10), pvalor3 integer)

RETURNING 
varchar(5),     --0) carrera
varchar(255),   --1) nombre carrera
integer,        --2) Tipo de documento
varchar(20),    --3) Numero de documento
date,           --4) Fecha ingreso
varchar(2),     --5) Calidad
varchar(255),   --6) Situacion asp
integer,        --7) sanciones
varchar(30),    --8) regular
integer,        --9) egresado
varchar(10),    --10) unidad academica
integer,        --11) cod retorno 
varchar(150),   --12) Mensaje retorno
varchar(255);   --13) plan

DEFINE vi_codigo_ret integer;
DEFINE vc_mje_ret varchar(150);
DEFINE vi_tipo_doc integer;
DEFINE vc_nro_doc varchar(20);
DEFINE vd_fecha_ing date;
DEFINE vd_fecha_reinsc date;
DEFINE vc_carrera varchar(5); 
DEFINE vc_nombre_carrera varchar(255); 
DEFINE vc_plan varchar(255); 
DEFINE vc_calidad char(2);
DEFINE vc_regular smallint; 
DEFINE vc_mens_reg varchar(255); 
DEFINE vc_sit_asp varchar(255); 
DEFINE vc_sanciones integer; 
DEFINE vc_ua varchar(10)  ; 
DEFINE vc_legajo varchar(20); 
DEFINE vc_egresado integer; 

LET vi_codigo_ret = 0;
LET vc_mje_ret = 'OK - Estado Alumno';
LET vi_tipo_doc = NULL;
LET vc_nro_doc = NULL;
LET vd_fecha_ing = NULL;
LET vd_fecha_reinsc = NULL;
LET vc_carrera = NULL;
LET vc_nombre_carrera = NULL;
LET vc_plan = NULL;
LET vc_calidad = NULL;
LET vc_regular = NULL;
LET vc_sit_asp = NULL;
LET vc_sanciones  = 0;
LET vc_ua  = NULL;
LET vc_legajo  = NULL;
LET vc_egresado = NULL;

IF  (pfiltro = 'carrera'  ) THEN

FOREACH 
	SELECT  per.tipo_documento, per.nro_documento,a.carrera,c.nombre, a.fecha_ingreso, a.calidad, sa.descripcion, CASE a.unidad_academica WHEN 'ECM' THEN 'FCM' ELSE a.unidad_academica END CASE AS unidad_academica, a.legajo, CASE WHEN a.calidad = 'E' THEN 1 ELSE 0 END as egresado, a.plan
		INTO  vi_tipo_doc, vc_nro_doc, vc_carrera , vc_nombre_carrera , vd_fecha_ing,  vc_calidad , vc_sit_asp,vc_ua, vc_legajo, vc_egresado, vc_plan
	FROM sga_personas per
		inner join sga_carrera_aspira car	
			on car.nro_inscripcion = per.nro_inscripcion
		inner join sga_alumnos a
			on a.nro_inscripcion = car.nro_inscripcion and car.carrera = a.carrera
		inner join sga_carreras c
			on c.carrera = car.carrera
		inner join sga_situacion_asp sa
			on sa.situacion_asp = car.situacion_asp
	WHERE  car.carrera = pvalor1
	AND car.situacion_asp in ('IL','IC')
	order by a.carrera,per.nro_documento

	execute PROCEDURE ctr_reinscrAlumno( vc_ua, vc_carrera, vc_legajo,'') INTO vc_regular, vc_mens_reg;

        -- Sancion en la carrera o directamente a la persona
        select limit 1 1 as sancion
        into vc_sanciones
        from sga_personas per 
        join sga_sancion_pers s on s.nro_inscripcion = per.nro_inscripcion 
        where per.tipo_documento = pvalor2 
            AND per.nro_documento = pvalor1	
            AND per.pais_documento = pvalor3 
            AND (today between s.fecha_desde and s.fecha_hasta)
            AND (s.carrera = vc_carrera OR s.carrera IS NULL);

	RETURN  vc_carrera , vc_nombre_carrera ,vi_tipo_doc, vc_nro_doc,  vd_fecha_ing, vc_calidad , vc_sit_asp, vc_sanciones , vc_regular, vc_egresado, vc_ua, vi_codigo_ret, vc_mje_ret, vc_plan  WITH RESUME; 
END FOREACH ;

	IF vi_tipo_doc is null THEN 
		LET vi_codigo_ret = -1;
		LET vc_mje_ret = 'No hay datos - Carrera ' || pvalor1 || ' inexistente';
		RETURN  vc_carrera , vc_nombre_carrera ,vi_tipo_doc, vc_nro_doc,  vd_fecha_ing, vc_calidad , vc_sit_asp, vc_sanciones , vc_regular, vc_egresado, vc_ua, vi_codigo_ret,  vc_mje_ret, vc_plan WITH RESUME; 
	END IF;

ELIF  ( pfiltro  = 'ingreso' ) THEN

FOREACH 
	SELECT  per.tipo_documento, per.nro_documento,a.carrera,c.nombre, a.fecha_ingreso, a.calidad, sa.descripcion, CASE a.unidad_academica WHEN 'ECM' THEN 'FCM' ELSE a.unidad_academica END CASE AS unidad_academica, a.legajo, CASE a.calidad WHEN 'E' THEN 1 ELSE 0 END as egresado, a.plan
		INTO  vi_tipo_doc, vc_nro_doc, vc_carrera , vc_nombre_carrera , vd_fecha_ing,  vc_calidad , vc_sit_asp,vc_ua, vc_legajo, vc_egresado, vc_plan
	FROM sga_personas per
		inner join sga_carrera_aspira car	
			on car.nro_inscripcion = per.nro_inscripcion
		join sga_periodo_insc pi
			on car.periodo_inscripcio = pi.periodo_inscripcio
		inner join sga_alumnos a
			on a.nro_inscripcion = car.nro_inscripcion and car.carrera = a.carrera
		inner join sga_carreras c
			on c.carrera = car.carrera
		inner join sga_situacion_asp sa
			on sa.situacion_asp = car.situacion_asp
	WHERE  pi.anio_academico = pvalor1
        AND c.tipo_de_carrera not in ('I', 'E', 'Z', 'V')
	order by a.carrera

	execute PROCEDURE ctr_reinscrAlumno( vc_ua, vc_carrera, vc_legajo,'') INTO vc_regular, vc_mens_reg;

        -- Sancion en la carrera o directamente a la persona
        select limit 1 1 as sancion
        into vc_sanciones
        from sga_personas per 
        join sga_sancion_pers s on s.nro_inscripcion = per.nro_inscripcion 
        where per.tipo_documento = pvalor2 
            AND per.nro_documento = pvalor1	
            AND per.pais_documento = pvalor3 
            AND (today between s.fecha_desde and s.fecha_hasta)
            AND (s.carrera = vc_carrera OR s.carrera IS NULL);

	RETURN  vc_carrera , vc_nombre_carrera ,vi_tipo_doc, vc_nro_doc,  vd_fecha_ing, vc_calidad , vc_sit_asp, vc_sanciones , vc_regular, vc_egresado, vc_ua, vi_codigo_ret,  vc_mje_ret, vc_plan  WITH RESUME; 
END FOREACH ;

	IF vi_tipo_doc is null THEN 
		LET vi_codigo_ret = -1;
		LET vc_mje_ret = 'No hay datos - Ingreso ' || pvalor1 || ' inexistente';
		RETURN  vc_carrera , vc_nombre_carrera ,vi_tipo_doc, vc_nro_doc,  vd_fecha_ing, vc_calidad , vc_sit_asp, vc_sanciones , vc_regular, vc_egresado, vc_ua, vi_codigo_ret,  vc_mje_ret, vc_plan  WITH RESUME; 
	END IF;

ELIF ( pfiltro  = 'reinscripcion' ) THEN

FOREACH 
	SELECT  per.tipo_documento, per.nro_documento,a.carrera,c.nombre, a.fecha_ingreso, a.calidad, sa.descripcion, CASE a.unidad_academica WHEN 'ECM' THEN 'FCM' ELSE a.unidad_academica END CASE AS unidad_academica, a.legajo, CASE a.calidad WHEN 'E' THEN 1 ELSE 0 END as egresado, a.plan
		INTO  vi_tipo_doc, vc_nro_doc, vc_carrera , vc_nombre_carrera , vd_fecha_ing,  vc_calidad , vc_sit_asp,vc_ua, vc_legajo, vc_egresado, vc_plan
	FROM  sga_personas per
		inner join sga_carrera_aspira car	
			on car.nro_inscripcion = per.nro_inscripcion
		join sga_periodo_insc pi
			on car.periodo_inscripcio = pi.periodo_inscripcio
		inner join sga_alumnos a
			on a.nro_inscripcion = car.nro_inscripcion and car.carrera = a.carrera
		inner join sga_carreras c
			on c.carrera = car.carrera
		inner join sga_situacion_asp sa
			on sa.situacion_asp = car.situacion_asp
		join sga_reinscripcion r
			on a.legajo = r.legajo 
	WHERE  r.anio_academico = pvalor1
        AND c.tipo_de_carrera not in ('I', 'E', 'Z', 'V')
	order by a.carrera

	execute PROCEDURE ctr_reinscrAlumno( vc_ua, vc_carrera, vc_legajo,'') INTO vc_regular, vc_mens_reg;

        -- Sancion en la carrera o directamente a la persona
        select limit 1 1 as sancion
        into vc_sanciones
        from sga_personas per 
        join sga_sancion_pers s on s.nro_inscripcion = per.nro_inscripcion 
        where per.tipo_documento = pvalor2 
            AND per.nro_documento = pvalor1	
            AND per.pais_documento = pvalor3 
            AND (today between s.fecha_desde and s.fecha_hasta)
            AND (s.carrera = vc_carrera OR s.carrera IS NULL);

	RETURN  vc_carrera , vc_nombre_carrera ,vi_tipo_doc, vc_nro_doc,  vd_fecha_ing, vc_calidad , vc_sit_asp, vc_sanciones , vc_regular, vc_egresado, vc_ua, vi_codigo_ret,  vc_mje_ret, vc_plan  WITH RESUME; 	

END FOREACH ;

	IF vi_tipo_doc is null THEN 
		LET vi_codigo_ret = -1;
		LET vc_mje_ret = 'No hay datos - A\F1o reinscripcion ' || pvalor1 || ' inexistente';
		RETURN  vc_carrera , vc_nombre_carrera ,vi_tipo_doc, vc_nro_doc,  vd_fecha_ing, vc_calidad , vc_sit_asp, vc_sanciones , vc_regular, vc_egresado, vc_ua, vi_codigo_ret,  vc_mje_ret, vc_plan  WITH RESUME; 
	END IF;

ELIF ( pfiltro  = 'documento' ) THEN

FOREACH 
	SELECT  per.tipo_documento, per.nro_documento,a.carrera,c.nombre, a.fecha_ingreso, a.calidad, sa.descripcion, CASE a.unidad_academica WHEN 'ECM' THEN 'FCM' ELSE a.unidad_academica END CASE AS unidad_academica, a.legajo, CASE a.calidad WHEN 'E' THEN 1 ELSE 0 END as egresado, a.plan
		INTO  vi_tipo_doc, vc_nro_doc, vc_carrera , vc_nombre_carrera , vd_fecha_ing,  vc_calidad , vc_sit_asp,vc_ua, vc_legajo, vc_egresado, vc_plan
	FROM  sga_personas per
		inner join sga_carrera_aspira car	
			on car.nro_inscripcion = per.nro_inscripcion
		join sga_periodo_insc pi
			on car.periodo_inscripcio = pi.periodo_inscripcio
	    inner join sga_alumnos a
			on a.nro_inscripcion = car.nro_inscripcion and car.carrera = a.carrera
		inner join sga_carreras c
			on c.carrera = car.carrera
		inner join sga_situacion_asp sa
			on sa.situacion_asp = car.situacion_asp
	WHERE  per.tipo_documento = pvalor2
	AND per.nro_documento = pvalor1
	AND per.pais_documento = pvalor3
	AND car.situacion_asp in ('IL','IC')
        AND c.tipo_de_carrera not in ('I', 'E', 'Z', 'V')
	order by a.carrera

	execute PROCEDURE ctr_reinscrAlumno( vc_ua, vc_carrera, vc_legajo,'') INTO vc_regular, vc_mens_reg;

        -- Sancion en la carrera o directamente a la persona
        select limit 1 1 as sancion
        into vc_sanciones
        from sga_personas per 
        join sga_sancion_pers s on s.nro_inscripcion = per.nro_inscripcion 
        where per.tipo_documento = pvalor2 
            AND per.nro_documento = pvalor1	
            AND per.pais_documento = pvalor3 
            AND (today between s.fecha_desde and s.fecha_hasta)
            AND (s.carrera = vc_carrera OR s.carrera IS NULL);

	RETURN  vc_carrera , vc_nombre_carrera ,vi_tipo_doc, vc_nro_doc,  vd_fecha_ing, vc_calidad , vc_sit_asp, vc_sanciones , vc_regular, vc_egresado, vc_ua, vi_codigo_ret,  vc_mje_ret, vc_plan  WITH RESUME; 

END FOREACH ;

	IF vi_tipo_doc is null THEN 
		LET vi_codigo_ret = -1;
		LET vc_mje_ret = 'No hay datos - Tipo documento ' || pvalor2 || ', Pais documento ' || pvalor3 || ' y Nro documento ' || pvalor1 || ' inexistente';
		RETURN  vc_carrera , vc_nombre_carrera ,vi_tipo_doc, vc_nro_doc,  vd_fecha_ing, vc_calidad , vc_sit_asp, vc_sanciones , vc_regular, vc_egresado, vc_ua, vi_codigo_ret,  vc_mje_ret, vc_plan  WITH RESUME; 
	END IF;

ELSE
	IF vi_tipo_doc is null THEN 
		LET vi_codigo_ret= -2;
		LET vc_mje_ret = 'El filtro indicado "' || pfiltro || '" no se reconoce - Valores posibles: carrera, documento, ingreso y reinscripcion ';
		RETURN  vc_carrera , vc_nombre_carrera ,vi_tipo_doc, vc_nro_doc,  vd_fecha_ing, vc_calidad , vc_sit_asp, vc_sanciones , vc_regular, vc_egresado, vc_ua, vi_codigo_ret,  vc_mje_ret, vc_plan  WITH RESUME; 
	END IF;

END IF;

END PROCEDURE;
