CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_registrar_path_requisito_diploma') THEN
		DROP PROCEDURE web_serv_registrar_path_requisito_diploma;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Parametros de WS: hash;

CREATE PROCEDURE "dba".web_serv_registrar_path_requisito_diploma(p_hash varchar(255), p_path varchar(255), p_uid varchar(255))
RETURNING 
integer; -- estado del path: 0 (no actualizado) - 1 (actualizado)

DEFINE vc_estado integer;
DEFINE vc_certif_pedido integer;
DEFINE vc_requisito varchar(10);

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
     RETURN iStatus;
END EXCEPTION;

LET vc_estado = 0;
LET vc_certif_pedido = NULL;
LET vc_requisito = NULL;

SELECT id_certif_pedido, requisito
	INTO vc_certif_pedido, vc_requisito
	FROM u820_pedidos_certif_diploma_req
	WHERE hash_notificacion = p_hash;

IF vc_certif_pedido IS NOT NULL THEN
	UPDATE u820_pedidos_certif_diploma_req
		SET url = p_path, fecha_actualizacion = TODAY, uid_nuxeo = p_uid
		WHERE hash_notificacion = p_hash;
	LET vc_estado = 1;
END IF;

RETURN vc_estado;

END PROCEDURE;

-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_registrar_path_requisito_diploma 
-- *****************************************************************************
revoke execute on "dba".web_serv_registrar_path_requisito_diploma from public;
grant execute on "dba".web_serv_registrar_path_requisito_diploma to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_serv_registrar_path_requisito_diploma to internet; -- Rol de usuario de Internet


