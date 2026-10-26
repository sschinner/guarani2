CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_obtener_certif_por_expediente') THEN
		DROP PROCEDURE web_serv_obtener_certif_por_expediente;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Parametros de WS: -;

CREATE PROCEDURE "dba".web_serv_obtener_certif_por_expediente(p_expediente varchar(255))
RETURNING 
varchar(10), 	-- iStatus
varchar(100), 	-- Mensaje
integer		-- idCertificado

DEFINE vc_certificado integer;

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
     RETURN iStatus, vcMsg, vc_certificado;
END EXCEPTION;

LET iStatus = 0;
LET vcMsg = '';

SELECT id_certif_pedido
INTO vc_certificado
	FROM u820_pedidos_certif
	WHERE expediente = p_expediente;
	
RETURN iStatus, vcMsg, vc_certificado;

END PROCEDURE;

-- EXECUTE PROCEDURE "dba".web_serv_obtener_certif_por_expediente(p_expediente varchar(255)); --1
-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_obtener_certif_por_expediente 
-- *****************************************************************************
revoke execute on "dba".web_serv_obtener_certif_por_expediente from public;
grant execute on "dba".web_serv_obtener_certif_por_expediente to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_serv_obtener_certif_por_expediente to internet; -- Rol de usuario de Internet


