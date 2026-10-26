CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_ser_alta_reinsc') THEN
		DROP PROCEDURE web_ser_alta_reinsc;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Procedure 
-- Version 2.05.0
-- Version de Modificación : 2.6.0
--
-- *******************************************************************************
-- DROP PROCEDURE "dba".web_ser_alta_reinsc;
CREATE PROCEDURE "dba".web_ser_alta_reinsc ( pUnidadAcademica LIKE sga_unidades_acad.unidad_academica,
	pCarrera LIKE sga_carreras.carrera,
	pPaisDocumento LIKE sga_personas.pais_documento,
	pTipoDocumento LIKE sga_personas.tipo_documento,
	pNroDocumento LIKE sga_personas.nro_documento,
	pAnioAcademico LIKE sga_periodo_insc.anio_academico,
	pFechaReinsc varchar(20),
	pNroTransaccion varchar(20),
	pInterfaz integer
	)

	Returning INT,VARCHAR(255);

-- Descripcion de Return:
-- INT: 	0 - OK
--	-1 - Error
-- VARCHAR(255): string con la descripcion del error

DEFINE iStatus                smallint;
DEFINE vcMsg                  varchar(255);

--variables para el manejo de excepciones

DEFINE sql_err                integer;
DEFINE isam_err               integer;
DEFINE error_info             varchar(76);
DEFINE vcUserError           varchar(10);

-- variables locales.

DEFINE vc_mensaje VARCHAR(255);
DEFINE pnro_inscripcion	varchar(10);
DEFINE plegajo		varchar(15);
DEFINE vc_retorno INTEGER;


DEFINE  viAnioAcad    LIKE sga_reinscripcion.anio_academico;
DEFINE vc_periodo_inscrip LIKE sga_periodo_insc.periodo_inscripcio;

-- blk de excepciones
-- si hay algun error
ON EXCEPTION SET sql_err, isam_err, error_Info                                        

      LET vcUserError  = 'Error de procedimiento.';
      LET iStatus 	  = 4; 
      LET vcMsg 	  =  vcUserError || ', ' || sql_err || ' - ' || error_Info || ' - ' || to_date(pFechaReinsc,"%Y-%m-%d %R");
      RETURN iStatus, vcMsg;
END EXCEPTION;

BEGIN

--INICIALIZACIONES

LET iStatus = 0 ;
LET vcMsg = 'OK';
LET pnro_inscripcion = NULL;
LET plegajo = NULL;
LET vc_mensaje = NULL;
LET vc_retorno = NULL;
LET viAnioAcad = NULL;


--OBTENGO EL LEGAJO DEL ALUMNO
--Se conviene que la reinscripción solicitada fuen controlada en el sistema de origen.
SELECT	per.nro_inscripcion, alu.legajo
INTO	pnro_inscripcion, plegajo
FROM	sga_personas per
		join sga_carrera_aspira asp
		on per.nro_inscripcion = asp.nro_inscripcion
		join sga_alumnos alu
		on asp.nro_inscripcion = alu.nro_inscripcion
			and asp.carrera = alu.carrera

WHERE	per.unidad_academica = punidadacademica
AND per.tipo_documento = pTipoDocumento
AND per.nro_documento = pNroDocumento
AND per.pais_documento = pPaisDocumento
AND alu.carrera = pCarrera;

IF plegajo IS NULL THEN

	LET vcMsg = 'No existe el alumno al que se quiere reinscribir';
	LET iStatus = -1;
        RETURN iStatus, vcMsg;
END IF;

-- Averiguo el anio_academico actual, imaginamos que el resultado es un solo valor;
EXECUTE PROCEDURE sp_ult_perins_act('R') INTO vc_periodo_inscrip;

SELECT anio_academico 
INTO viAnioAcad 
FROM sga_periodo_insc 
WHERE periodo_inscripcio=vc_periodo_inscrip;

IF viAnioAcad IS NULL THEN
	LET vcMsg = 'No hay período de reinscripción activo';
	LET iStatus = -2;
        RETURN iStatus, vcMsg;
ELSE
	IF viAnioAcad <> panioacademico THEN
		LET vcMsg = 'El año académico de reinscripción informado no corresponde al período de reinscripción activo';
		LET iStatus = -3;
		RETURN iStatus, vcMsg;
	END IF;	
END IF;

--INSERTO REINSCRIPCION
EXECUTE PROCEDURE sp820_i_reinsc_anio(punidadacademica, pcarrera, plegajo, 3, panioacademico, to_date(pFechaReinsc,"%Y-%m-%d %R"), pNroTransaccion) INTO vc_retorno, vc_mensaje;

IF vc_retorno = 0 THEN
	LET vcMsg = 'OK' || ' - ' || pnro_inscripcion;
ELSE
	LET iStatus = vc_retorno;
	LET vcMsg = vc_mensaje;

END IF;
RETURN iStatus, vcMsg;

END;
END PROCEDURE;
-- ******************************** Fin Procedure web_ser_alta_reinsc ***********************************************

-- execute  procedure web_ser_alta_reinsc('FBCB',  'EUG',  '54', '0',  '37300816',  '2015',  '2015-03-09 11:29',  'SIGUV', '3');

-- *****************************************************************************
-- Permisos del procedimiento "dba".web_ser_alta_reinsc
-- *****************************************************************************
revoke execute on "dba".web_ser_alta_reinsc from public;
grant execute on "dba".web_ser_alta_reinsc to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_ser_alta_reinsc to internet; -- Rol de usuario de Internet