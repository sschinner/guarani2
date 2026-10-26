CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_identdefaultag') THEN
		DROP PROCEDURE sp_identdefaultag;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Procedure: sp_identDefaultag
-- 
-- Genera por Default el Codigo de Identificacion de un Usuario para
-- Autogestion
--
-- Version 1.6
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE PROCEDURE "dba".sp_identdefaultag(pUnidadAcademica LIKE aca_usuarios_ag.unidad_academica, 
								pNroInscripcion	LIKE aca_usuarios_ag.nro_inscripcion)
				RETURNING smallint,	-- status  -1 fallo / 1 OK
						varchar(255);	-- devuelve la pwd default 

/*  Devuelve la Identificación default de un usuario de AutoGestion, 
preCondition: NO valida que exista la persona porque supone que es llamado por alguien que ya lo hizo
NOTA: debe personalizarse  */

-- vars para el manejo de excepciones
DEFINE SQLErr integer;
DEFINE ISAMError integer;
DEFINE errorInfo varchar(76);
DEFINE nro_doc like sga_personas.nro_documento;

-- vars locales
DEFINE iStatus smallint;
DEFINE vcIdentDefault LIKE aca_usuarios_ag.identificacion;

-- si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
    RAISE EXCEPTION  SQLErr, ISAMError, errorInfo ;
END EXCEPTION;

BEGIN

	select nro_documento 
		into nro_doc
		from sga_personas
		where nro_inscripcion = pNroInscripcion;

	-- seteo el status a OK
	LET iStatus	= 1;

	-- Esta asignacion debe personalizarse.	
	-- Usuario por default es el número de documento.

	LET vcIdentDefault = nro_doc;

    -- devueve el status y la pwdDefau
	RETURN iStatus, vcIdentDefault ;

END;
END PROCEDURE;
-- ********************************** FIN PROCESO "dba".sp_identdefaultag ******************************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_identdefaultag
-- *****************************************************************************
revoke execute on "dba".sp_identdefaultag from public;
grant execute on "dba".sp_identdefaultag to guarani;  -- Rol de usuarios de Gestion
grant execute on "dba".sp_identdefaultag to internet; -- Rol de usuario de Internet