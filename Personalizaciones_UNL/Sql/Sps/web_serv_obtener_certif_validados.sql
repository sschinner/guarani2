CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_obtener_certif_validados') THEN
		DROP PROCEDURE web_serv_obtener_certif_validados;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Parametros de WS: -;

CREATE PROCEDURE "dba".web_serv_obtener_certif_validados()
RETURNING 
varchar(10), 	-- iStatus
varchar(100), 	-- Mensaje
integer,	-- idCertificado
varchar(10),	-- UA
varchar(100),	-- Apellido
varchar(100),	-- Nombres
varchar(255),	-- Expediente
varchar(10),	-- Nro. Inscripcion
integer,	-- tipoCertificado
date;           -- fechaSolicitud

DEFINE vc_certificado integer;
DEFINE vc_tipo_certificado integer;
DEFINE vc_ua varchar(10);
DEFINE vc_apellido varchar(100);
DEFINE vc_nombres varchar(100);
DEFINE vc_expediente varchar(255);
DEFINE vc_nro_inscripcion varchar(10);
DEFINE d_fechaSolicitud date;

DEFINE sql_err, isam_err  	int;
DEFINE error_info         	varchar(80);
DEFINE vcUserError		varchar(10);
DEFINE iStatus			varchar(10);
DEFINE vcMsg			varchar(100);

-- si hay algun error
ON EXCEPTION SET sql_err, isam_err, error_Info                                        
      LET vcUserError  = 'Error de procedimiento.';
      LET iStatus 	  = 4; 
      LET vcMsg 	  =  vcUserError || ', ' || sql_err || ' - ' || error_Info;
     RETURN iStatus, vcMsg, vc_certificado, vc_ua, vc_apellido, vc_nombres, vc_expediente, vc_nro_inscripcion, vc_tipo_certificado, d_fechaSolicitud;
END EXCEPTION;

LET iStatus = 0;
LET vcMsg = '';

FOREACH
	SELECT u.id_certif_pedido, cp.certificado, cp.unidad_academica, p.apellido, p.nombres, u.expediente, cp.nro_inscripcion, cp.fecha_de_pedido
		INTO vc_certificado, vc_tipo_certificado, vc_ua, vc_apellido, vc_nombres, vc_expediente, vc_nro_inscripcion, d_fechaSolicitud
		FROM u820_pedidos_certif u
		JOIN sga_certif_pedidos cp
			ON u.id_certif_pedido = cp.certif_pedido
		JOIN sga_personas p
			ON cp.nro_inscripcion = p.nro_inscripcion
		WHERE u.validado = 'S'
		AND cp.fecha_de_emision IS NULL

	RETURN iStatus, vcMsg, vc_certificado, vc_ua, vc_apellido, vc_nombres, vc_expediente, vc_nro_inscripcion, vc_tipo_certificado, d_fechaSolicitud WITH RESUME;

END FOREACH;

END PROCEDURE;

-- EXECUTE PROCEDURE "dba".web_serv_obtener_certif_validados(); --1
-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_obtener_certif_validados 
-- *****************************************************************************
revoke execute on "dba".web_serv_obtener_certif_validados from public;
grant execute on "dba".web_serv_obtener_certif_validados to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_serv_obtener_certif_validados to internet; -- Rol de usuario de Internet


