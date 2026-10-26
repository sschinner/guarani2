CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_identifdocenag') THEN
		DROP PROCEDURE sp_identifdocenag;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Procedure: sp_identifDocenAg
-- 
-- Genera por Default el Codigo de Identificacion de un Docente para
-- Autogestion
--
-- Version 1.9.0
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE PROCEDURE "dba".sp_identifdocenag ( pUnidadAcademica LIKE aca_usuarios_ag.unidad_academica,
                                     pNroInscripcion  LIKE aca_usuarios_ag.nro_inscripcion )

       RETURNING -- smallint,      -- status  -1 fallo / 1 OK
                 varchar(255);  -- devuelve la pwd default

/*  
Devuelve la Identificación default de un usuario de AutoGestion, 
preCondición: NO valida que exista la persona porque supone que es llamado por alguien que ya lo hizo
NOTA: debe personalizarse
*/

-- vars para el manejo de excepciones
DEFINE SQLErr          integer;
DEFINE ISAMError       integer;
DEFINE errorInfo       varchar(76);

-- vars locales
DEFINE iStatus         smallint;
DEFINE vcIdentDefault  LIKE aca_usuarios_ag.identificacion;
DEFINE nro_doc like sga_personas.nro_documento;

-- si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo
   RAISE EXCEPTION  SQLErr, ISAMError, errorInfo;
END EXCEPTION;

BEGIN

   -- seteo el status a OK
   LET iStatus = 1;

   -- Esta asignacion debe personalizarse.
   -- Usuario por default es 'DOC' + número de documento.
   select nro_documento 
	into nro_doc
	from sga_personas
	where nro_inscripcion = pNroInscripcion;

    -- devueve el status y la pwdDefault
   LET vcIdentDefault = 'DOC' || nro_doc;


   RETURN vcIdentDefault;

END;
END PROCEDURE;
-- +++++++++++++++++++++++++ Fin SP "dba".sp_identifdocenag ++++++++++++++++++++++++++++

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_identifdocenag 
-- *****************************************************************************
revoke execute on "dba".sp_identifdocenag from public;
grant execute on "dba".sp_identifdocenag to guarani;  -- Rol de usuarios de Gestion
grant execute on "dba".sp_identifdocenag to internet; -- Rol de usuario de Internet