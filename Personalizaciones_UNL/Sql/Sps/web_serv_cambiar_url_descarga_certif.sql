CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_cambiar_url_descarga_certif') THEN
		DROP PROCEDURE web_serv_cambiar_url_descarga_certif;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Parametros de WS: hash;

CREATE PROCEDURE "dba".web_serv_cambiar_url_descarga_certif(p_expediente varchar(255), p_url varchar(255), p_tipo_notificacion varchar(255))
RETURNING 
integer; -- URL Descarga: 0 (no actualizado) - 1 (actualizado)

DEFINE vc_id_certificado varchar(20);
DEFINE vc_tipo_certificado integer;
DEFINE vc_estado integer;
DEFINE vc_nro_inscripcion varchar(20);
DEFINE vc_carrera varchar(5);
DEFINE vc_titulo varchar(5);

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

BEGIN

LET vc_id_certificado = NULL;
LET vc_tipo_certificado = NULL;
LET vc_nro_inscripcion = NULL;
LET vc_carrera = NULL;
LET vc_titulo = NULL;
LET vc_estado = 0;

SELECT id_certif_pedido
	INTO vc_id_certificado
	FROM u820_pedidos_certif
	WHERE expediente = p_expediente;

IF (vc_id_certificado IS NOT NULL) THEN

	SELECT certificado
		INTO vc_tipo_certificado
		FROM sga_certif_pedidos
		WHERE certif_pedido = vc_id_certificado;

	IF (vc_tipo_certificado = 102 AND p_tipo_notificacion <> 'DIPLOMA') THEN
		IF (p_tipo_notificacion = 'CA_PROVISORIO' OR p_tipo_notificacion = 'CA_DEFINITIVO') THEN
        	UPDATE u820_pedidos_certif_diploma
				SET url_certificado_analitico = p_url
				WHERE id_certif_pedido = vc_id_certificado;
      	ELSE 
        	UPDATE u820_pedidos_certif_diploma
				SET url_titulo_tramite = p_url
				WHERE id_certif_pedido = vc_id_certificado;
      	END IF;
	ELSE
		UPDATE u820_pedidos_certif
			SET url_descarga = p_url
			WHERE expediente = p_expediente;

		UPDATE sga_certif_pedidos
				SET copias_impresas = copias_pedidas
				WHERE certif_pedido = vc_id_certificado;

		IF (vc_tipo_certificado = 102 AND p_tipo_notificacion = 'DIPLOMA') THEN
			SELECT nro_inscripcion
				INTO vc_nro_inscripcion
				FROM sga_certif_pedidos
				WHERE certif_pedido = vc_id_certificado;

			SELECT carrera, titulo
				INTO vc_carrera, vc_titulo
				FROM u820_pedidos_certif_diploma
				WHERE id_certif_pedido  = vc_id_certificado;
			
			-- Actualizo a estado Diplomado
			UPDATE sga_titulos_otorg
				SET estado = 'D'
				WHERE nro_inscripcion = vc_nro_inscripcion
				AND carrera = vc_carrera
				AND titulo = vc_titulo;

		END IF;

	END IF;
		
	LET vc_estado = 1;
END IF;

RETURN vc_estado;

END;
END PROCEDURE;

-- EXECUTE PROCEDURE "dba".web_serv_cambiar_url_descarga_certif('lkjhdfs68f687dfskdjf987234bsdf'); --1
-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_cambiar_url_descarga_certif 
-- *****************************************************************************
revoke execute on "dba".web_serv_cambiar_url_descarga_certif from public;
grant execute on "dba".web_serv_cambiar_url_descarga_certif to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_serv_cambiar_url_descarga_certif to internet; -- Rol de usuario de Internet


