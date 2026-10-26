CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_obtener_certif_sin_expediente') THEN
		DROP PROCEDURE web_serv_obtener_certif_sin_expediente;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Parametros de WS: -;

CREATE PROCEDURE "dba".web_serv_obtener_certif_sin_expediente()
RETURNING 
varchar(10), 	-- iStatus
varchar(100), 	-- Mensaje
integer,	-- idCertificado
varchar(10),	-- UA
varchar(100),	-- Apellido
varchar(100),	-- Nombres
varchar(10),	-- Tipo Documento
varchar(20),	-- Nro. Documento
varchar(255),	-- Carrera
integer,	-- tipoCertificado
varchar(255),	-- validacion ministerial
varchar(255),	-- UA COMPLETO
varchar(255),	-- nro inscripcion
varchar(255);	-- titulo

DEFINE vc_certificado integer;
DEFINE vc_tipo_certificado integer;
DEFINE vc_ua varchar(10);
DEFINE vc_apellido varchar(100);
DEFINE vc_nombres varchar(100);
DEFINE vc_tipo_doc varchar(10);
DEFINE vc_nro_documento varchar(20);
DEFINE vc_carrera varchar(255);
DEFINE vc_certificacion_ministerial varchar(255);
DEFINE vc_ua_completo varchar(255);
DEFINE vc_nro_inscripcion varchar(255);
DEFINE vc_titulo varchar(255);

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
     RETURN iStatus, vcMsg, vc_certificado, vc_ua, vc_apellido, vc_nombres, vc_tipo_doc, vc_nro_documento, vc_carrera, vc_tipo_certificado, vc_certificacion_ministerial, vc_ua_completo, vc_nro_inscripcion, vc_titulo;
END EXCEPTION;

LET iStatus = 0;
LET vcMsg = '';

FOREACH
SELECT u.id_certif_pedido, cp.certificado, cp.unidad_academica, p.apellido, p.nombres, m.desc_abreviada, p.nro_documento, c.nombre, cpa2.argumento, ua.nombre, p.nro_inscripcion, upcd.titulo
INTO vc_certificado, vc_tipo_certificado, vc_ua, vc_apellido, vc_nombres, vc_tipo_doc, vc_nro_documento, vc_carrera, vc_certificacion_ministerial, vc_ua_completo, vc_nro_inscripcion, vc_titulo
	FROM u820_pedidos_certif u
	JOIN sga_certif_pedidos cp
		ON u.id_certif_pedido = cp.certif_pedido
        JOIN sga_unidades_acad ua
                ON cp.unidad_academica = ua.unidad_academica
	JOIN sga_personas p
		ON cp.nro_inscripcion = p.nro_inscripcion
	JOIN mdp_tipo_documento m
		ON m.tipo_documento = p.tipo_documento
	LEFT JOIN sga_certif_argum ca
		ON ca.certificado = cp.certificado
		AND ca.nombre = 'carrera'
	LEFT JOIN sga_cert_ped_argum cpa
		ON cpa.certif_pedido = cp.certif_pedido
		AND ca.orden = cpa.orden
	LEFT JOIN u820_pedidos_certif_diploma upcd
		ON upcd.id_certif_pedido = cp.certif_pedido
	LEFT JOIN sga_carreras c
		ON (c.carrera = cpa.argumento OR c.carrera = upcd.carrera)
    LEFT JOIN sga_certif_argum ca2
		ON ca2.certificado = cp.certificado
		AND ca2.nombre = 'certificado_me'
    LEFT JOIN sga_cert_ped_argum cpa2
		ON cpa2.certif_pedido = cp.certif_pedido
		AND ca2.orden = cpa2.orden
	WHERE u.estado_pago = 'P'
	AND u.expediente IS NULL
	AND (cp.certificado <> 102 OR (cp.certificado = 102 AND upcd.requisitos_validados = 'S'))
	
	RETURN iStatus, vcMsg, vc_certificado, vc_ua, vc_apellido, vc_nombres, vc_tipo_doc, vc_nro_documento, vc_carrera, vc_tipo_certificado, vc_certificacion_ministerial, vc_ua_completo, vc_nro_inscripcion, vc_titulo WITH RESUME;

END FOREACH;

END PROCEDURE;

-- EXECUTE PROCEDURE "dba".web_serv_obtener_certif_sin_expediente(); --1
-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_obtener_certif_sin_expediente 
-- *****************************************************************************
revoke execute on "dba".web_serv_obtener_certif_sin_expediente from public;
grant execute on "dba".web_serv_obtener_certif_sin_expediente to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_serv_obtener_certif_sin_expediente to internet; -- Rol de usuario de Internet


