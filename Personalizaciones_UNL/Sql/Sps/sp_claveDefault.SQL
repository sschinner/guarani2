CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_clavedefault') THEN
		DROP PROCEDURE sp_clavedefault;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- **********************************************************************
-- Genera una nueva Clave de Acceso para una persona
--
-- Recibe:   
-- Retorna:  
-- modificado por encriptacion de claves
-- ahora retorna el md5 de la vieja clave (NONE)
-- la clave sin encriptar no puede superar los 20 caracteres
-- **********************************************************************
-- execute procedure sp_claveDefault (null, null);
CREATE PROCEDURE "dba".sp_clavedefault(pUnidadAcademica 	LIKE aca_usuarios_ag.unidad_academica, 
				            pNroInscripcion 	LIKE aca_usuarios_ag.nro_inscripcion)
   RETURNING  	smallint,		-- status  -1 fallo / 1 OK
		varchar(255);	-- devuelve la pwd default 

/* Devuelve la Clave default de un usuario de AutoGestion, 
    preCondition: NO valida que exista la persona porque supone que es llamado por alguien que ya lo hizo
    NOTA: debe personalizarse  */

   -- vars para el manejo de excepciones
   DEFINE 	SQLErr 		integer		;
   DEFINE 	ISAMError	integer		;
   DEFINE 	errorInfo 		varchar(76)	;

   -- vars locales
   DEFINE 	iStatus 		smallint			;
   DEFINE 	vcPwdDefault 	LIKE aca_usuarios_ag.clave 	;

  -- si hay algun error
   ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
      RAISE EXCEPTION  SQLErr, ISAMError, errorInfo ;
   END EXCEPTION;

BEGIN

   -- seteo el status a OK
   LET iStatus		= 1 ;

   LET vcPwdDefault 	= (select lpad (nro_documento, 5)
		                   from  sga_personas
                                	   where sga_personas.nro_inscripcion = pNroInscripcion); 

   LET vcPwdDefault 	= sp_md5(vcPwdDefault);

    -- devueve el status y la pwdDefault
   RETURN iStatus, vcPwdDefault ;

END;
END PROCEDURE;
-- **********************************************************************

revoke execute on sp_clavedefault from public;

grant execute on sp_clavedefault to guarani; -- Rol de usuarios de Gestión
grant execute on sp_clavedefault to internet; -- Usuario de internet