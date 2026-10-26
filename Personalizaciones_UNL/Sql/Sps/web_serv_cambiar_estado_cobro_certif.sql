CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_cambiar_estado_cobro_certif') THEN
		DROP PROCEDURE web_serv_cambiar_estado_cobro_certif;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Parametros de WS: hash;

CREATE PROCEDURE "dba".web_serv_cambiar_estado_cobro_certif(p_hash varchar(255))
RETURNING 
integer; -- estado del cobro: 0 (no actualizado) - 1 (actualizado)

DEFINE vc_id_cobro varchar(20);
DEFINE vc_estado integer;

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

LET vc_id_cobro = NULL;
LET vc_estado = 0;

SELECT identificador_cobro
	INTO vc_id_cobro
	FROM u820_pedidos_certif
	WHERE hash_pago = p_hash;

IF vc_id_cobro IS NOT NULL THEN
	UPDATE u820_pedidos_certif
		SET estado_pago = 'M'
		WHERE hash_pago = p_hash
		AND estado_pago <> 'P';
	LET vc_estado = 1;
END IF;

RETURN vc_estado;

END PROCEDURE;

-- EXECUTE PROCEDURE "dba".web_serv_obtener_id_cobro_certif('lkjhdfs68f687dfskdjf987234bsdf'); --1
-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_cambiar_estado_cobro_certif 
-- *****************************************************************************
revoke execute on "dba".web_serv_cambiar_estado_cobro_certif from public;
grant execute on "dba".web_serv_cambiar_estado_cobro_certif to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_serv_cambiar_estado_cobro_certif to internet; -- Rol de usuario de Internet


