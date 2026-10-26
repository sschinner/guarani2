CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ws_validar_req_diploma') THEN
		DROP PROCEDURE ws_validar_req_diploma;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP PROCEDURE "dba".ws_validar_req_diploma;
CREATE PROCEDURE "dba".ws_validar_req_diploma(
        p_unidad_academica      LIKE sga_unidades_acad.unidad_academica,
	p_pais_documento        LIKE sga_personas.pais_documento,
	p_tipo_documento        LIKE sga_personas.tipo_documento,
	p_nro_documento         LIKE sga_personas.nro_documento,
	p_certif_pedido         LIKE sga_certif_pedidos.certif_pedido,
	p_requisitos_validados  CHARACTER(1)
)
	RETURNING INT,VARCHAR(255);

-- Descripcion de Par?etros:

-- Descripcion de Return:
-- INT: 	
--      0   - OK
--      -1  - Error
-- VARCHAR(255): string con la descripcion del error
	
DEFINE _unidad_academica    LIKE sga_datos_censales.unidad_academica;
DEFINE _nro_inscripcion     LIKE sga_personas.nro_inscripcion;

DEFINE vc_resultado         VARCHAR (15);
DEFINE vi_cod_uno           INTEGER;
DEFINE vi_cod_dos           INTEGER;
DEFINE vc_mensaje           VARCHAR (250);

DEFINE sql_err, isam_err    INT;
DEFINE error_info           VARCHAR(80);
DEFINE vcUserError          VARCHAR(10);
DEFINE iStatus              INT;
DEFINE vcMsg                VARCHAR(255);

  -- si hay algun error
ON EXCEPTION SET sql_err, isam_err, error_Info                                        

      LET vcUserError  = 'Error de procedimiento.';
      LET iStatus 	  = 4; 
      LET vcMsg 	  =  vcUserError || ', ' || sql_err || ' - ' || error_Info;
      RETURN iStatus, vcMsg;
END EXCEPTION;
--------------------------------------------------

LET _nro_inscripcion = NULL;
LET error_info = NULL;
LET sql_err = 0;
LET isam_err = 0;
LET iStatus = 0;
LET vcMsg =  'OK - Se ha modificado el estado de validacion.';

------------------------------------------------------------------------------------ 

SELECT  per.nro_inscripcion
INTO    _nro_inscripcion
FROM    sga_personas per
WHERE   per.tipo_documento = p_tipo_documento 
    AND per.nro_documento = p_nro_documento
    AND per.pais_documento = p_pais_documento;


IF _nro_inscripcion IS NOT NULL
THEN
    IF EXISTS (
        SELECT certif_pedido, nro_inscripcion 
        FROM sga_certif_pedidos 
        WHERE certif_pedido = p_certif_pedido AND nro_inscripcion = _nro_inscripcion AND certificado = 102 
    )
    THEN
        UPDATE  u820_pedidos_certif_diploma 
        SET     requisitos_validados = p_requisitos_validados 
        WHERE   id_certif_pedido = p_certif_pedido;
    ELSE
        -- Error
        LET vcMsg = 'La solicitud especificada no pertenece a la persona.';
        LET iStatus = -2;
        RETURN iStatus, vcMsg;        
    END IF;
    
ELSE
    -- Error
    LET vcMsg = 'La persona no se encuentra inscripta.';
    LET iStatus = -1;
    RETURN iStatus, vcMsg;	

END IF;

RETURN iStatus, vcMsg;

END PROCEDURE;
-- *************** FIN DEL PROCEDURE "dba".ws_validar_req_diploma ***************

revoke execute on "dba".ws_validar_req_diploma from public;
grant execute on "dba".ws_validar_req_diploma to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ws_validar_req_diploma to internet; -- Rol de usuario de Internet

