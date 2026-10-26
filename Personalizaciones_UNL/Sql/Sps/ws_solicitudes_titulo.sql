
CREATE PROCEDURE "dba".verifica_objeto()

BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ws_solicitudes_titulo') THEN
		DROP PROCEDURE ws_solicitudes_titulo ;
	END IF;		
END

END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Parametros de Sps: p_pais_doc integer, p_tipo_doc integer, p_nro_doc 
CREATE PROCEDURE "dba".ws_solicitudes_titulo (p_pais_doc integer, p_tipo_doc integer, p_nro_doc varchar(15))
RETURNING 
    integer,        --0) solicitud
    varchar (255)  --1)	 nombreTitulo


DEFINE _solicitud       integer;
DEFINE _nombreTitulo    varchar (255);
DEFINE _nro_inscripcion varchar (20);

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
    RETURN iStatus, vcMsg;
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
    SELECT certif_pedido, T.nombre
    INTO _solicitud, _nombreTitulo
    FROM sga_certif_pedidos CP
    JOIN u820_pedidos_certif PD             ON CP.certif_pedido = PD.id_certif_pedido
    JOIN u820_pedidos_certif_diploma PDD    ON PD.id_certif_pedido = PDD.id_certif_pedido
    JOIN sga_titulos T                      ON PDD.titulo = T.titulo
    WHERE nro_inscripcion = _nro_inscripcion AND PD.estado_pago <> 'V'

    RETURN _solicitud, _nombreTitulo WITH RESUME;
END FOREACH;

END;
END PROCEDURE;
-- *****************************************************************************
-- Permisos del procedimiento "dba".ws_solicitudes_titulo 
-- *****************************************************************************
revoke execute on "dba".ws_solicitudes_titulo from public;
grant execute on "dba".ws_solicitudes_titulo to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ws_solicitudes_titulo to internet; -- Rol de usuario de Internet

