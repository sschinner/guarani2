CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_i_datos_censales_sur2') THEN
		DROP PROCEDURE sp_i_datos_censales_sur2;
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

CREATE PROCEDURE "dba".sp_i_datos_censales_sur2 ( 
	pcarrera			varchar(5),
	pdocumento_tipo		integer,
	pdocumento_numero	varchar(15),
	pestado_civil		integer,
	pemail			varchar(50),
	pdireccion		varchar(50),
	pcodigopostal		varchar(15),
	pid_localidad		integer,
	pid_pais			integer,
	ptelefono			varchar(18),
	pcelular			varchar(18),
	panio_academico		varchar(5)
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
LET vc_Rtn = NULL;
LET vc_retorno  = NULL;
LET vc_mensaje = NULL;
LET pnro_inscripcion = NULL;
LET punidad_academica = NULL;

--OBTENGO LA UNIDAD ACADÉMICA

SELECT	unidad_academica
INTO	punidad_academica
FROM	sga_unidades_acad;

--OBTENGO EL NÚMERO DE INSCRIPCIÓN DE LA PERSONA

SELECT	nro_inscripcion
INTO	pnro_inscripcion
FROM	sga_personas
WHERE	unidad_academica = punidad_academica
AND	tipo_documento = pdocumento_tipo
AND	nro_documento = pdocumento_numero;

--OBTENGO EL LEGAJO DEL ALUMNO

SELECT	legajo
INTO	plegajo
FROM	sga_alumnos
WHERE	unidad_academica = punidad_academica
AND	nro_inscripcion = pnro_inscripcion
AND	carrera = pcarrera;

--INSERTO REINSCRIPCION

EXECUTE PROCEDURE sp_i_reinsc_anio(punidad_academica, pcarrera, plegajo, 1, panio_academico) INTO vc_retorno, vc_mensaje;

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
   
--ACTUALIZO DATOS PERSONALES

--UPDATE	sga_personas
--SET	
--WHERE	unidad_academica = punidad_academica
--AND	nro_inscripcion  = pnro_inscripcion;
   
--ACTUALIZO SGA_DATOS_CENSALES

UPDATE	sga_datos_censales
SET	fecha_actualiz		=	TODAY
	,estado_civil		=	pestado_civil   
	,e_mail			=	pemail
	,te_proc			=	ptelefono
	,te_per_lect		=	ptelefono
	,calle_proc		=	pdireccion
	,calle_per_lect		=	pdireccion
	,loc_proc			=	pid_localidad
	,loc_per_lect		=	pid_localidad
	,cp_proc			=	pcodigopostal
	,cp_per_lect		=	pcodigopostal
WHERE	unidad_academica = punidad_academica
AND	nro_inscripcion = pnro_inscripcion
AND	fecha_relevamiento = vd_Fecha;

--ACTUALIZO SGA_DATOS_CEN_AUX

UPDATE	sga_datos_cen_aux
SET	pais_nacionalidad		=	pid_pais
	,celular_numero		=	pcelular
WHERE	unidad_academica   = punidad_academica
AND	nro_inscripcion = pnro_inscripcion
AND	fecha_relevamiento = vd_Fecha;

RETURN iStatus, vcMsg, punidad_academica, pnro_inscripcion, vd_Fecha;

END;
END PROCEDURE;
-- *************************** Fin Procedure sp_i_datos_censales_sur2  *************************************

-- *****************************************************************************
-- Permisos del procedimiento
-- *****************************************************************************
revoke execute on "dba".sp_i_datos_censales_sur2 from public;
grant execute on "dba".sp_i_datos_censales_sur2 to guarani; -- Rol de usuarios de Gestión
grant execute on "dba".sp_i_datos_censales_sur2 to siguv_consulta; -- Rol de usuarios de SIGUV
grant execute on "dba".sp_i_datos_censales_sur2 to ue_siguv_guarani; -- Rol de usuarios de SIGUV
