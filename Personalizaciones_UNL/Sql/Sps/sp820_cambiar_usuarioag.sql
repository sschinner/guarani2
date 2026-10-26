CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	
	IF EXISTS (SELECT procid
			FROM sysprocedures

			WHERE procname = 'sp820_cambiar_usuarioag') THEN

		DROP PROCEDURE sp820_cambiar_usuarioag;

	END IF;
END

END PROCEDURE;



EXECUTE PROCEDURE "dba".verifica_objeto();

DROP PROCEDURE "dba".verifica_objeto();



CREATE PROCEDURE "dba".sp820_cambiar_usuarioag(
	pTipoDocumento LIKE sga_personas.tipo_documento,
	pNroDocumento LIKE sga_personas.nro_documento,
	pPaisDocumento LIKE sga_personas.pais_documento,	
	pUsuario LIKE aca_usuarios_ag.identificacion)

	Returning INT,VARCHAR(200);


DEFINE pNroInscripcion	varchar(20);

DEFINE sql_err, isam_err  	int;

DEFINE error_info         	varchar(80);

DEFINE vcUserError	varchar(10);

DEFINE iStatus		int;

DEFINE vcMsg		varchar(200);


  -- si hay algun error

ON EXCEPTION SET sql_err, isam_err, error_Info

      LET vcUserError  = '800401' ;
      LET iStatus 	  = -1; 
      LET 	vcMsg 	  =  vcUserError || ',' || sql_err || ' - ' || error_Info;

      RETURN iStatus, vcMsg;

END EXCEPTION;

--------------------------------------------------

LET pNroInscripcion = NULL;
LET error_info = NULL;

LET sql_err = 0;

LET isam_err = 0;

LET iStatus = 0;

LET vcMsg = 'Se modifico el usuario correctamente';

--Recupero el nro_inscripcion del alumno que acabo de inscribir

SELECT distinct nro_inscripcion INTO pNroInscripcion
FROM sga_personas 
WHERE nro_documento = pNroDocumento
AND tipo_documento = pTipoDocumento
AND pais_documento = pPaisDocumento;

--Actualizo el usuario para el alumno en cuestión
IF  (pNroInscripcion is NOT NULL) THEN

set triggers for aca_usuarios_ag disabled;

	UPDATE aca_usuarios_ag
	SET  identificacion = pUsuario
	WHERE nro_inscripcion =  pNroInscripcion;

set triggers for aca_usuarios_ag enabled;

ELSE
   LET iStatus	= -1;
   LET vcMsg 	= 'No existe el alumno con los datos nro documento: ' ||  pNroDocumento || ', pais documento: ' || pPaisDocumento|| ' y tipo documento: ' || pTipoDocumento;
END IF;

return iStatus, VcMsg WITH RESUME;




END PROCEDURE;

-- *************** Fin del procedimiento "dba".sp820_cambiar_usuarioag ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_cambiar_usuarioag 
-- *****************************************************************************
revoke execute on "dba".sp820_cambiar_usuarioag from public;
grant execute on "dba".sp820_cambiar_usuarioag to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_cambiar_usuarioag to internet; -- Rol de usuario de Internet

-- *************************** Pruebas de ejecucion **********************************
-- execute procedure "dba".sp820_cambiar_usuarioag ('0', '26149239', '26149239');
