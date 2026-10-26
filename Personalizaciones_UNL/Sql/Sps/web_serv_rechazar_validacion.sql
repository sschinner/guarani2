CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_rechazar_validacion') THEN
		DROP PROCEDURE web_serv_rechazar_validacion;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Parametros de WS: hash;

CREATE PROCEDURE "dba".web_serv_rechazar_validacion(p_expediente varchar(255), p_motivorechazo varchar(255))
RETURNING 
integer; -- 0 (no actualizado) - 1 (actualizado)

DEFINE vc_id_certificado varchar(20);
DEFINE vc_estado integer;

DEFINE sql_err, isam_err  	int;
DEFINE error_info         	varchar(80);
DEFINE vcUserError		varchar(10);
DEFINE iStatus			integer;
DEFINE vcMsg			varchar(100);

-- si hay algun error
ON EXCEPTION SET sql_err, isam_err, error_Info                                        
      LET vcUserError  = 'Error de procedimiento.';
      LET iStatus 	  = 4; 
      LET vcMsg 	  =  vcUserError || ', ' || sql_err || ' - ' || error_Info;
     RETURN iStatus ;
END EXCEPTION;

LET vc_id_certificado = NULL;
LET vc_estado = 0;

SELECT id_certif_pedido
	INTO vc_id_certificado
	FROM u820_pedidos_certif
	WHERE expediente = p_expediente;

IF (vc_id_certificado IS NOT NULL) THEN

	UPDATE sga_certif_pedidos
		SET fecha_de_emision = NULL, copias_impresas = 0
		WHERE certif_pedido = vc_id_certificado;

	UPDATE u820_pedidos_certif
		SET validado = 'R',
			motivorechazo = p_motivorechazo,
			url_descarga = NULL
		WHERE id_certif_pedido = vc_id_certificado;
		
	LET vc_estado = 1;
END IF;

RETURN vc_estado;

END PROCEDURE;

-- EXECUTE PROCEDURE "dba".web_serv_rechazar_validacion('FADU-008989-17', 'Se rechaza porque SI'); --1
-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_rechazar_validacion 
-- *****************************************************************************
revoke execute on "dba".web_serv_rechazar_validacion from public;
grant execute on "dba".web_serv_rechazar_validacion to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_serv_rechazar_validacion to internet; -- Rol de usuario de Internet


