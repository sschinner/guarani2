CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_graba_datos_principales') THEN
		DROP PROCEDURE sp820_graba_datos_principales;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

--***** Actualiza los datos principales de una persona. 
--***** Actualizo Apellido, Nombres, Tipo Documento, Nro. Documento, Sexo, Fecha Nacimiento, E-mail
 
CREATE PROCEDURE "dba".sp820_graba_datos_principales(
				pUA 		LIKE sga_unidades_acad.unidad_academica,
				pApellido	LIKE sga_personas.apellido,
				pNombres	LIKE sga_personas.nombres,
				pEmail		LIKE sga_datos_censales.e_mail,
				pTipoDoc	LIKE sga_personas.tipo_documento,
				pNroDoc		LIKE sga_personas.nro_documento,
				pSexo		LIKE sga_personas.sexo,
				pFecha		varchar(10) -- LIKE sga_personas.fecha_nacimiento
				)

RETURNING 
		smallint,      -- 0- OK, -1- Error, 1-Observaciones
		varchar(255);  -- mensaje

DEFINE iStatus		smallint;
DEFINE vcMsg		varchar(255);
DEFINE vMaxFecha	date;
DEFINE vNroInsc		varchar(10);

-----  VARS PARA EL MANEJO DE EXCEPCIONES
DEFINE sql_err		integer;
DEFINE isam_err		integer;
DEFINE error_info	varchar(76);
DEFINE v_user_error	varchar(10);

ON EXCEPTION SET sql_err, isam_err, error_info                                        
	LET iStatus = sql_err ;
	LET vcMsg = isam_err ;
	RETURN iStatus, vcMsg;
END EXCEPTION;    

BEGIN

	-- Inicializaciones.
	LET iStatus		= 0 ;
	LET vcMsg		= 'Ok';
	LET vMaxFecha	= null;
	LET vNroInsc	= null;

	-- Obtengo la �ltima fecha de relevamiento para la actualizaci�n del Email
	SELECT max(dc.fecha_relevamiento), dc.nro_inscripcion
		INTO vMaxFecha, vNroInsc
		FROM sga_datos_censales dc
		WHERE dc.nro_inscripcion IN (SELECT nro_inscripcion
										FROM sga_personas
										WHERE nro_documento = pNroDoc
										AND tipo_documento = pTipoDoc)
		GROUP BY dc.nro_inscripcion;
	
	-- Actualizo la direcci�n de Email
	UPDATE sga_datos_censales
		SET e_mail = pEmail
		WHERE nro_inscripcion = vNroInsc
		AND fecha_relevamiento = vMaxFecha
		AND unidad_academica = pUA;
		
	-- Actualizo Apellido, Nombres, Tipo Documento, Nro. Documento, Sexo, Fecha Nacimiento
	UPDATE sga_personas
		SET apellido = pApellido,
			nombres = pNombres,
			tipo_documento = pTipoDoc,
			nro_documento = pNroDoc,
			sexo = pSexo,
			fecha_nacimiento = TO_DATE(pFecha,'%d/%m/%Y')
		WHERE nro_inscripcion = vNroInsc
		AND unidad_academica = pUA;										
		
	RETURN iStatus, vcMsg;

END;
END PROCEDURE;

--EXECUTE PROCEDURE dba.sp820_graba_datos_principales('FICH', 'SCHINNER', 'SEBASTI�N', 'sschinner@rectorado.unl.edu.ar', '0', '30171912', '1', '02/06/83');

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_graba_datos_principales 
-- *****************************************************************************
revoke execute on "dba".sp820_graba_datos_principales from public;
grant execute on "dba".sp820_graba_datos_principales to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_graba_datos_principales to internet; -- Rol de usuario de Internet
