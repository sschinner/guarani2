CREATE PROCEDURE "dba".verifica_objeto()

BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_listado_alu_fecha') THEN
		DROP PROCEDURE web_serv_listado_alu_fecha ;
	END IF;		
END

END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Par�metros de WS: anio academico; periodo lectivo; 
-- Objetivo: obtener el promedio hist�rico de las carreras en los ultimos 5 a�os


CREATE PROCEDURE "dba".web_serv_listado_alu_fecha (pFecha Date)
RETURNING varchar(20), --0)  N�mero de documento
varchar(50), --1) Apellido
varchar(50), --2) Nombres
varchar(10), --3) Carrera
date;  --4) Fecha de generacion legajo


DEFINE vc_nro_doc varchar(20);
DEFINE vd_fecha date;
DEFINE vc_apellido varchar(50); 
DEFINE vc_nombre varchar(50); 
DEFINE vc_carrera varchar(10); 

-- Variables para el manejo de excepciones
DEFINE SQLErr             integer;
DEFINE ISAMError          integer;
DEFINE errorInfo          varchar(76);

-- Si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo
	RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;

BEGIN

LET vc_nro_doc = NULL;
LET vd_fecha = NULL;
LET vc_apellido = NULL;
LET vc_nombre = NULL;
LET vc_carrera = NULL;


FOREACH

SELECT p.apellido, p.nombres, p.nro_documento, a.carrera, a.fecha_ingreso  INTO vc_apellido, vc_nombre , vc_nro_doc, vc_carrera, vd_fecha 
	FROM sga_alumnos a 
		JOIN sga_personas p
			ON  a.nro_inscripcion = p.nro_inscripcion
	WHERE  a.fecha_ingreso >= pFecha
ORDER BY 5,1,2



RETURN vc_apellido, vc_nombre , vc_nro_doc, vc_carrera, vd_fecha  WITH RESUME;


END FOREACH;
END;
END PROCEDURE;


-- execute procedure "dba".web_serv_listado_alu_fecha('10/10/2014');

-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_listado_alu_fecha 
-- *****************************************************************************
revoke execute on "dba".web_serv_listado_alu_fecha from public;
grant execute on "dba".web_serv_listado_alu_fecha to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_serv_listado_alu_fecha to internet; -- Rol de usuario de Internet