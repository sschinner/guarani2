CREATE PROCEDURE "dba".verifica_objeto()

BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_carreras_ua') THEN
		DROP PROCEDURE web_serv_carreras_ua;
	END IF;
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Parametros de WS: carrera; 
-- Objetivo: obtener el listado de materias de una determinada carrera y plan vigente
-- execute procedure web_serv_carreras_ua();

CREATE PROCEDURE web_serv_carreras_ua ()
RETURNING varchar(5), -- 0)carrera
varchar(255), -- nombre carrera
varchar(10), -- plan
varchar(10), -- version
varchar(1), -- estado
varchar (50), --tipo_carrera 
varchar (50) --vc_alcance_titulo 

DEFINE vc_carrera like sga_carreras.carrera;
DEFINE vc_nombre_car like sga_carreras.nombre;
DEFINE vc_plan varchar(10);
DEFINE vi_version varchar(10);
DEFINE vc_estado varchar(1);
DEFINE vc_tipo_carrera  varchar(50);
DEFINE vc_alcance_titulo  varchar(50);


LET vc_carrera = NULL;
LET vc_nombre_car = NULL;
LET vc_plan =NULL;
LET vi_version = 0;
LET vc_estado =NULL;
LET vc_tipo_carrera   = NULL;

FOREACH

SELECT c.carrera, c.nombre, a.plan, a.version_actual , a.estado, tc.nombre as tipo_carrera, TT.desc_abreviada 
INTO vc_carrera, vc_nombre_car, vc_plan, vi_version   , vc_estado, vc_tipo_carrera, vc_alcance_titulo 
FROM sga_planes a
    join  sga_carreras c on c.carrera = a.carrera	
    join  sga_tipos_carrera tc on tc.tipo_de_carrera = c.tipo_de_carrera 	
    LEFT JOIN sga_titulos_plan TP ON TP.carrera = c.carrera AND TP.plan = a.plan
    LEFT JOIN sga_titulos T ON T.titulo = TP.titulo --AND nivel = 'GRADO'
    LEFT JOIN sga_tipos_titulo TT ON TT.tipo_de_titulo = T.tipo_de_titulo
WHERE  tc.tipo_de_carrera not in ('I', 'E', 'Z', 'V') AND (nivel == 'GRADO' OR nivel IS NULL) AND c.estado <> 'B'

RETURN vc_carrera, vc_nombre_car, vc_plan, vi_version, vc_estado,vc_tipo_carrera, vc_alcance_titulo   WITH RESUME;
END FOREACH;

END PROCEDURE;
