
CREATE PROCEDURE "dba".verifica_objeto()

BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ws_url_solicitud') THEN
		DROP PROCEDURE ws_url_solicitud ;
	END IF;		
END

END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

CREATE PROCEDURE "dba".ws_url_solicitud (p_pais_doc integer, p_tipo_doc integer, p_nro_doc varchar(15), p_solicitud integer)
RETURNING 
    varchar (255),  -- url  
    varchar (255),  -- nombreRequisito
    char(1),        -- requisitosValidados
    varchar (10),    -- codigoRequisito
    varchar (255)  -- uid_nuxeo


DEFINE _url                 varchar (255);
DEFINE _nombreRequisito     varchar (255);
DEFINE _codigoRequisito     varchar (10);
DEFINE _requisitosValidados char(1);
DEFINE _nro_inscripcion     varchar (20);
DEFINE _uid_nuxeo                 varchar (255);

-- Variables para el manejo de excepciones
DEFINE sql_err, isam_err  	int;
DEFINE error_info         	varchar(80);
DEFINE vcUserError          varchar(25);
DEFINE iStatus              int;
DEFINE vcMsg                varchar(255);

-- Si hay algun error
ON EXCEPTION SET sql_err, isam_err, error_Info                                        
    LET vcUserError  = 'Error de procedimiento';
    LET iStatus 	  = -4; 
    LET vcMsg 	  =  vcUserError || ' (' || sql_err || ', ' || error_Info || ')';
    RETURN '-4', vcMsg, NULL, NULL, NULL;
END EXCEPTION;

BEGIN

LET _nro_inscripcion = NULL;

SELECT  nro_inscripcion
INTO    _nro_inscripcion
FROM    sga_personas p
WHERE   p.nro_documento     = p_nro_doc
    and p.pais_documento    = p_pais_doc
    and p.tipo_documento    = p_tipo_doc;

FOREACH
    SELECT PDR.url, R.nombre, R.requisito, PDD.requisitos_validados, PDR.uid_nuxeo 
    INTO _url, _nombreRequisito, _codigoRequisito, _requisitosValidados, _uid_nuxeo
    FROM sga_certif_pedidos CP
    JOIN u820_pedidos_certif PD             ON CP.certif_pedido = PD.id_certif_pedido
    JOIN u820_pedidos_certif_diploma PDD    ON PD.id_certif_pedido = PDD.id_certif_pedido
    JOIN u820_pedidos_certif_diploma_req PDR    ON PDD.id_certif_pedido = PDR.id_certif_pedido
    JOIN sga_requisitos R                       ON PDR.requisito = R.requisito
    
    WHERE   nro_inscripcion = _nro_inscripcion AND 
            CP.certif_pedido = p_solicitud AND 
            CP.certificado = 102 -- Diploma digital

    RETURN _url, _nombreRequisito, _requisitosValidados, _codigoRequisito, _uid_nuxeo WITH RESUME;
END FOREACH;

END;
END PROCEDURE;
-- *****************************************************************************
-- Permisos del procedimiento "dba".ws_url_solicitud 
-- *****************************************************************************
revoke execute on "dba".ws_url_solicitud from public;
grant execute on "dba".ws_url_solicitud to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ws_url_solicitud to internet; -- Rol de usuario de Internet

