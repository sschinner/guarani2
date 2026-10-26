CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_estado_requisitos') THEN
		DROP PROCEDURE sp820_estado_requisitos;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- PROCEDIMIENTO QUE VERIFICA EL ESTADO DE LOS REQUISITOS DE INGERSO PARA UNA PERSONA INGRESADA COMO PAR�METRO
CREATE PROCEDURE "dba".sp820_estado_requisitos(pNroInsc LIKE sga_req_cumplidos.nro_inscripcion, pCarrera LIKE sga_req_cumplidos.carrera)

RETURNING
		varchar(60),	-- NOMBRE REQUISITO
		varchar(20);	-- FECHA DE PRESENTACION

DEFINE vcNombre varchar(60);
DEFINE vcFecha varchar(20);

-----  VARS PARA EL MANEJO DE EXCEPCIONES

DEFINE sql_err	 			integer;
DEFINE isam_err 				integer;
DEFINE error_info				varchar(76);

ON EXCEPTION SET sql_err, isam_err, error_info                                        
      RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;     

BEGIN

FOREACH SELECT r.nombre, 
	CASE WHEN (rc.fecha_presentacion IS NULL AND rc.requisito IS NOT NULL) THEN "Adeuda" WHEN (rc.fecha_presentacion IS NULL AND rc.requisito IS NULL) THEN "Sin Informaci�n" ELSE TO_CHAR(rc.fecha_presentacion, '%d/%m/%Y') END as fecha
	INTO vcNombre, vcFecha
	FROM sga_requisitos r
	LEFT JOIN sga_req_cumplidos rc
		ON r.requisito = rc.requisito
		AND rc.nro_inscripcion = pNroInsc
		AND rc.carrera = pCarrera
	WHERE r.requisito IN ("UNL01", "UNL02", "UNL03", "UNL04", "UNL05", "UNL06", "UNL07")
	ORDER BY r.requisito

	RETURN
		vcNombre, vcFecha
		WITH RESUME; 

END FOREACH;

END;
END PROCEDURE;

--EXECUTE PROCEDURE dba.sp820_estado_requisitos("FCM-211", "1");


-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_estado_requisitos 
-- *****************************************************************************
revoke execute on "dba".sp820_estado_requisitos from public;
grant execute on "dba".sp820_estado_requisitos to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_estado_requisitos to internet; -- Rol de usuario de Internet