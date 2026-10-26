CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_registrar_cobro_certif') THEN
		DROP PROCEDURE web_serv_registrar_cobro_certif;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Parametros de WS: hash;

CREATE PROCEDURE "dba".web_serv_registrar_cobro_certif(p_id_cobro varchar(20))
RETURNING 
integer; -- resultado de la operacion de UPDATE

DEFINE vc_resultado integer;

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

LET vc_resultado = NULL;

UPDATE sga_certif_pedidos
	SET pagado = 'P'
	WHERE id_cobro = p_id_cobro;

SELECT count(*)
	INTO vc_resultado
	FROM sga_certif_pedidos
	WHERE id_cobro = p_id_cobro
	AND pagado = 'P';

RETURN vc_resultado;

END PROCEDURE;

-- EXECUTE PROCEDURE "dba".web_serv_registrar_cobro_certif('239854'); --1
-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_registrar_cobro_certif 
-- *****************************************************************************
revoke execute on "dba".web_serv_registrar_cobro_certif from public;
grant execute on "dba".web_serv_registrar_cobro_certif to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_serv_registrar_cobro_certif to internet; -- Rol de usuario de Internet


