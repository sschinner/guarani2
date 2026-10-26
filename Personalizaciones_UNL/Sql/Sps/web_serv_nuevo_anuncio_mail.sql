CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_nuevo_anuncio_mail') THEN
		DROP PROCEDURE web_serv_nuevo_anuncio_mail;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Parametros de WS: hash;

CREATE PROCEDURE "dba".web_serv_nuevo_anuncio_mail(p_titulo varchar(255), p_mensaje varchar(255), p_campo_where varchar(30), p_dato_busqueda varchar(255))
RETURNING 
integer; -- URL Descarga: 0 (no actualizado) - 1 (actualizado)

DEFINE vc_id_certificado varchar(20);
DEFINE vc_estado integer;
DEFINE vc_unidad_academica varchar(10);
DEFINE vc_nro_inscripcion varchar(10);
DEFINE cust_qry varchar(250);
DEFINE vc_anuncio integer;

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

LET cust_qry = "SELECT id_certif_pedido FROM u820_pedidos_certif WHERE " || p_campo_where || " = '" || p_dato_busqueda || "'";
PREPARE stmt_id FROM cust_qry;
DECLARE cust_cur cursor FOR stmt_id;
OPEN cust_cur;
FETCH cust_cur INTO vc_id_certificado;
CLOSE cust_cur;
FREE cust_cur;
FREE stmt_id;

IF (vc_id_certificado IS NOT NULL) THEN
	SELECT unidad_academica, nro_inscripcion
		INTO vc_unidad_academica, vc_nro_inscripcion
		FROM sga_certif_pedidos
		WHERE certif_pedido = vc_id_certificado;

	INSERT INTO gda_anuncios (tipo_anuncio, fecha_desde, fecha_hasta, titulo_anuncio, enviado_por_mail, enviado_por_sms, int_gestion,
		int_autogestion, int_telefono, int_internet, unidad_academica, nro_inscripcion, fecha_de_registro, mensaje, todos_algunos) 
		VALUES ('P', TO_CHAR(TODAY, '%m/%d/%Y'), TO_CHAR(TODAY+3, '%m/%d/%Y'), p_titulo, 'S', 'N', 'S', 'S', 'N', 'S', 
		vc_unidad_academica, vc_nro_inscripcion, current, p_mensaje, 'T');

	SELECT MAX(anuncio)
		INTO vc_anuncio
		FROM gda_anuncios
		WHERE nro_inscripcion = vc_nro_inscripcion;
		
	INSERT INTO gda_anuncios_log VALUES (vc_anuncio, vc_unidad_academica, vc_nro_inscripcion, null, 'P');
	
	UPDATE gda_anun_conf_pers 
		SET recibe_mail = 'S'
		WHERE unidad_academica = vc_unidad_academica
		AND nro_inscripcion = vc_nro_inscripcion;
		
	LET vc_estado = 1;
END IF;

RETURN vc_estado;

END PROCEDURE;

-- EXECUTE PROCEDURE "dba".web_serv_nuevo_anuncio_mail('lkjhdfs68f687dfskdjf987234bsdf'); --1
-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_nuevo_anuncio_mail 
-- *****************************************************************************
revoke execute on "dba".web_serv_nuevo_anuncio_mail from public;
grant execute on "dba".web_serv_nuevo_anuncio_mail to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_serv_nuevo_anuncio_mail to internet; -- Rol de usuario de Internet


