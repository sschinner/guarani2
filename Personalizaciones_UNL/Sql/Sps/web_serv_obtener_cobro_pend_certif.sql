CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_obtener_cobro_pend_certif') THEN
		DROP PROCEDURE web_serv_obtener_cobro_pend_certif;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Parametros de WS: hash;

CREATE PROCEDURE "dba".web_serv_obtener_cobro_pend_certif()
RETURNING 
varchar(255), 	-- id sistema de Cobro
integer; 		-- certificado

DEFINE vc_id_cobro varchar(255);
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
     RETURN iStatus, NULL;
END EXCEPTION;

LET vc_id_cobro = NULL;
LET vc_certificado = NULL;

FOREACH 
	SELECT upc.identificador_cobro, scp.certificado
		INTO vc_id_cobro, vc_certificado
		FROM u820_pedidos_certif upc
		JOIN sga_certif_pedidos scp ON scp.certif_pedido = upc.id_certif_pedido
		WHERE upc.estado_pago = 'M'

	/*SELECT identificador_cobro
		INTO vc_id_cobro
		FROM u820_pedidos_certif
		WHERE estado_pago = 'M'*/

	RETURN vc_id_cobro, vc_certificado WITH RESUME;

END FOREACH;

END PROCEDURE;

-- EXECUTE PROCEDURE "dba".web_serv_obtener_cobro_pend_certif(); --1
-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_obtener_cobro_pend_certif 
-- *****************************************************************************
revoke execute on "dba".web_serv_obtener_cobro_pend_certif from public;
grant execute on "dba".web_serv_obtener_cobro_pend_certif to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_serv_obtener_cobro_pend_certif to internet; -- Rol de usuario de Internet


