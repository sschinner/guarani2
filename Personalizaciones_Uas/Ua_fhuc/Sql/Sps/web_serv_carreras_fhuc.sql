 CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_carreras_fhuc') THEN
		DROP PROCEDURE web_serv_carreras_fhuc ;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Parámetros de WS: anio academico; periodo lectivo; 
-- Objetivo: obtener los datos de las cursadas de un determinado año y periodo lectivo 

--execute procedure "dba".web_serv_carreras_fhuc(2000, '06')
CREATE PROCEDURE "dba".web_serv_carreras_fhuc (pplan integer, pcarrera varchar(5))

RETURNING 	integer, -- 0)carrera
			varchar(80), -- nombre carrera
			integer, -- promedio aplazos
			integer,-- promedio sin aplazos
			varchar(5), --materia
			varchar (50), --nombre_materia 
			varchar(1),-- obligatoriedad
			varchar(1),-- promediable
			varchar(2)--tipo_materia 

DEFINE vi_carrera integer;
DEFINE vc_nombre_car varchar(80);
DEFINE vi_plan integer;
DEFINE vi_version integer;
DEFINE materia varchar(5) ;
DEFINE nombre_materia varchar(50); 
DEFINE obligatoria varchar(1) ;
DEFINE promediable varchar(1) ;
DEFINE tipo_materia varchar(2); 

LET vi_carrera = 0;
LET vc_nombre_car = NULL;
LET vi_plan = 0;
LET vi_version = 0;
LET materia = NULL;
LET nombre_materia  = NULL;
LET obligatoria = NULL;
LET promediable = NULL;
LET tipo_materia = NULL;

FOREACH
	SELECT a.carrera, c.nombre, a.plan, a.version, a.materia, a.nombre_materia, a.obligatoria, a.promediable, a.tipo_materia 
		INTO vi_carrera, vc_nombre_car, vi_plan, vi_version, materia, nombre_materia, obligatoria, promediable, tipo_materia 
			FROM sga_planes p
			INNER JOIN sga_atrib_mat_plan a ON (p.carrera=a.carrera 
							AND p.plan=a.plan
							AND  p.version_actual=a.version)
			INNER JOIN sga_carreras c ON (a.carrera=c.carrera)
			WHERE a.carrera = pcarrera
			AND a.plan = pplan 




	RETURN vi_carrera, vc_nombre_car, vi_plan, vi_version, materia, nombre_materia, obligatoria, promediable, tipo_materia   WITH RESUME;
END FOREACH;
END PROCEDURE;

-- **************************  Fin del Procedure web_serv_carreras_fhuc **************************

REVOKE execute ON "dba".web_serv_carreras_fhuc FROM public;
GRANT execute ON "dba".web_serv_carreras_fhuc to guarani; -- Rol de usuarios de Gestion
GRANT execute ON "dba".web_serv_carreras_fhuc to internet; -- Rol de usuario de Internet