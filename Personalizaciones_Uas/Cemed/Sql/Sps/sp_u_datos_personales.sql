CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_u_datos_personales') THEN
		DROP PROCEDURE sp_u_datos_personales;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Procedure sp_i_dc_princ
-- Version 2.05.0
-- Version de Modificación : 2.6.0
--
-- Graba el Dato Censal principal del alumno.
-- *******************************************************************************

CREATE PROCEDURE "dba".sp_u_datos_personales ( 
	pdocumento_tipo		integer,
	pdocumento_numero		varchar(15),
	papellido			varchar(30),
	pnombres			varchar(30),
	pfecha_nacimiento		varchar(10),
	ploc_nacimiento		integer,
	pestado_civil		integer,
	pemail			varchar(50),
	pdireccion			varchar(50),
	plocalidad		integer,
	pcodigopostal		integer,
	ptelefono			varchar(18)
	)

RETURNING smallint,  varchar(255), varchar(5), varchar(10), date; -- mensaje

/*
Retorna:
     -- 0- OK, -1- Error, 1-Observaciones
      varchar(255); -- mensaje
*/

DEFINE iStatus                smallint;
DEFINE vcMsg                  varchar(255);

--variables para el manejo de excepciones

DEFINE sql_err                integer;
DEFINE isam_err               integer;
DEFINE error_info             varchar(76);
DEFINE v_user_error           varchar(10);

-- variables locales.

DEFINE vcNivel      VARCHAR(20);
DEFINE vd_Fecha     DATE;
DEFINE vc_Rtn       CHAR(1);
DEFINE vc_retorno INTEGER;
DEFINE vc_mensaje VARCHAR(255);
DEFINE pnro_inscripcion	varchar(10);
DEFINE plegajo		varchar(15);
DEFINE punidad_academica	varchar(5);
DEFINE pnfecha_nacimiento DATE;

-- blk de excepciones

ON EXCEPTION SET sql_err, isam_err, error_info
LET iStatus = sql_err ;
LET vcMsg = isam_err ;
RETURN iStatus, vcMsg, punidad_academica, pnro_inscripcion, vd_Fecha;
END EXCEPTION; 

BEGIN

--INICIALIZACIONES

LET iStatus = 0 ;
LET vcMsg = 'Ok';
LET vd_Fecha = NULL;

--OBTENGO EL NÚMERO DE INSCRIPCIÓN DE LA PERSONA

SELECT	nro_inscripcion
INTO	pnro_inscripcion
FROM	sga_personas
WHERE	tipo_documento = pdocumento_tipo
AND	nro_documento = pdocumento_numero;

--OBTENGO LA UNIDAD ACADEMICA

SELECT	unidad_academica
INTO	punidad_academica
FROM	sga_unidades_acad;

--VERIFICO SI LA PERSONA TIENE ALGÚN DATO CENSAL CARGADO

EXECUTE PROCEDURE sp_dato_cen_valido (punidad_academica, pnro_inscripcion) INTO vc_Rtn;
iF vc_Rtn = "I" THEN
	EXECUTE PROCEDURE sp_crea_datocensal(punidad_academica, pnro_inscripcion);
END IF;

--BUSCO LA FECHA DE RELEVAMIENTO A ACTUALIZAR

SELECT	MAX(fecha_relevamiento)
INTO	vd_Fecha
FROM	sga_datos_censales
WHERE	unidad_academica = punidad_academica
AND	nro_inscripcion  = pnro_inscripcion;

--SETEO EL FORMATO DE FECHA
LET pnfecha_nacimiento = to_date(pfecha_nacimiento, "%m/%d/%Y");
   
--ACTUALIZO DATOS PERSONALES

UPDATE	sga_personas
SET	apellido		=	papellido
	,nombres		=	pnombres
	,fecha_nacimiento	=	pnfecha_nacimiento
	,loc_nacimiento	=	ploc_nacimiento
WHERE	unidad_academica = punidad_academica
AND	nro_inscripcion  = pnro_inscripcion;
   
--ACTUALIZO SGA_DATOS_CENSALES

UPDATE	sga_datos_censales
SET	fecha_actualiz		=	TODAY
	,estado_civil		=	pestado_civil   
	,e_mail			=	pemail
	,te_proc			=	ptelefono
	,te_per_lect		=	ptelefono
	,calle_proc		=	pdireccion
	,calle_per_lect		=	pdireccion
	,loc_proc			=	plocalidad
	,loc_per_lect		=	plocalidad
	,cp_proc			=	pcodigopostal
	,cp_per_lect		=	pcodigopostal
WHERE	unidad_academica = punidad_academica
AND	nro_inscripcion = pnro_inscripcion
AND	fecha_relevamiento = vd_Fecha;

--ACTUALIZO GDA_ANUN_CONF_PERS
UPDATE	gda_anun_conf_pers
SET	e_mail			=	pemail
WHERE	unidad_academica = punidad_academica
AND	nro_inscripcion = pnro_inscripcion;

RETURN iStatus, vcMsg, punidad_academica, pnro_inscripcion, vd_Fecha;

END;
END PROCEDURE;
-- ******************************** Fin Procedure sp_u_datos_personales  ***********************************************

-- *****************************************************************************
-- Permisos del procedimiento
-- *****************************************************************************
revoke execute on "dba".sp_u_datos_personales from public;
grant execute on "dba".sp_u_datos_personales to guarani; -- Rol de usuarios de Gestión
grant execute on "dba".sp_u_datos_personales to siguv_consulta; -- Rol de usuarios de SIGUV
grant execute on "dba".sp_u_datos_personales to ue_siguv_guarani; -- Rol de usuarios de SIGUV