CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_egresado') THEN
		DROP PROCEDURE ctr820_egresado;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- **************************************************************************
-- Control: ctr820_egresado
-- Version 2.6.3
--
-- Verifica si el alumno es un egresado. Si lo es verifica en que estado está 
-- el titulo y si se permite continuar de acuerdo al param del sistema
-- Se permite modificar hasta el estado del parametro del sistema inclusive.
-- Usa el parametro del sistema:  "estado_modificacion_egresado"
-- **************************************************************************

CREATE PROCEDURE "dba".ctr820_egresado(pUnidadAcademica		LIKE sga_alumnos.unidad_academica,
					pCarrera		 	LIKE sga_alumnos.carrera,
					pLegajo		 	LIKE sga_alumnos.legajo)
	RETURNING 	smallint, 		-- status
			varchar(255);	-- <mensaje, parametros>

  /*  Controla si el alumno es egresado
       devuelve:  1 - si está OK            
	       -1 - No OK.
  */

  -- vars para la respuesta
  DEFINE iStatus 		smallint		;	-- status
  DEFINE vcMsg 		varchar(255)	;	-- mensaje y parametros

  -- var's para el manejo de excepciones
   DEFINE sql_err,isam_err 		integer		;
   DEFINE error_info 	varchar(76)	;
   DEFINE vcUserError	varchar(10) 	;

  --vars locales
  DEFINE estado_egresado		LIKE sga_param_sistema.valor;
  DEFINE estado_sol_titulo		char(1);

   -- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info                                        
     LET iStatus = -1 ;
     LET vcMsg = '800321' || ',' || 'ctr820_egresado' || ',' || sql_err || ' - '  || error_info ; 	
     RETURN iStatus, vcMsg ;
   END EXCEPTION;        

BEGIN

   -- seteo los valores default
   -- No es egresado o es egresado y no ha solicitado el titulo de grado
   -- No Permito Imprimir la Tasa
   LET iStatus		= -1;
   LET vcMsg		= '820015' || ',' ||  pLegajo;

   
  -- Verifico el estado de la solicitud del titulo de Grado
  LET estado_sol_titulo = NULL;
  SELECT sga_titulos_otorg.estado
	INTO estado_sol_titulo
	FROM sga_alumnos, 
	           sga_titulos_plan,
	           sga_titulos,
	           sga_titulos_otorg
	WHERE sga_alumnos.unidad_academica = pUnidadAcademica
	AND sga_alumnos.carrera = pCarrera
	AND sga_alumnos.legajo = pLegajo
	-- AND sga_alumnos.calidad = 'E'

	AND sga_titulos_plan.unidad_academica = sga_alumnos.unidad_academica
	AND sga_titulos_plan.carrera = sga_alumnos.carrera
	AND sga_titulos_plan.plan = sga_alumnos.plan

	AND sga_titulos.unidad_academica  = sga_titulos_plan.unidad_academica
	AND sga_titulos.titulo  = sga_titulos_plan.titulo
	-- AND sga_titulos.nivel = 'GRADO'

	AND sga_titulos_otorg.unidad_academica = sga_alumnos.unidad_academica
	AND sga_titulos_otorg.nro_inscripcion = sga_alumnos.nro_inscripcion
	AND sga_titulos_otorg.titulo = sga_titulos_plan.titulo;


  IF estado_sol_titulo IS NOT NULL THEN

  	-- El alumno tiene solicitud de titulo
   	LET iStatus = 1;
	LET vcMsg = 'OK' 	;

  END IF;
	
RETURN iStatus, vcMsg; 

END;
END PROCEDURE;
-- ************************ Fin Control "dba".ctr820_egresado ***********************

-- *****************************************************************************
-- Permisos del Control "dba".ctr820_egresado 
-- *****************************************************************************
revoke execute on "dba".ctr820_egresado from public;
grant execute on "dba".ctr820_egresado to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ctr820_egresado to internet; -- Rol de usuario de Internet

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_encuesta_gr') THEN
		DROP PROCEDURE ctr820_encuesta_gr;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- **************************************************************************
-- Control: ctr820_encuesta_gr
-- Version 2.7.0
--
-- Verifica si el egresado (precondición) completó la encuesta al recien graduado. 
-- **************************************************************************

CREATE PROCEDURE "dba".ctr820_encuesta_gr(pUnidadAcademica		LIKE sga_alumnos.unidad_academica,
					pCarrera		 	LIKE sga_alumnos.carrera,
					pLegajo		 	LIKE sga_alumnos.legajo)
	RETURNING 	smallint, 		-- status
			varchar(255);	-- <mensaje, parametros>

  /*  Controla si el alumno es egresado
       devuelve:  1 - si está OK            
	       -1 - No OK.
  */

  -- vars para la respuesta
  DEFINE iStatus 		smallint		;	-- status
  DEFINE vcMsg 		varchar(255)	;	-- mensaje y parametros

  -- var's para el manejo de excepciones
   DEFINE sql_err,isam_err 		integer		;
   DEFINE error_info 	varchar(76)	;
   DEFINE vcUserError	varchar(10) 	;

  --vars locales
  DEFINE estado_egresado		LIKE sga_param_sistema.valor;
  DEFINE estado_encuesta		char(1);

   -- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info                                        
     LET iStatus = -1 ;
     LET vcMsg = '800321' || ',' || 'ctr820_encuesta_gr' || ',' || sql_err || ' - '  || error_info ; 	
     RETURN iStatus, vcMsg ;
   END EXCEPTION;        

BEGIN

   -- seteo los valores default
   -- No es egresado o es egresado y no ha solicitado el titulo de grado
   -- No Permito Imprimir la Tasa
   LET iStatus		= -1;
   LET vcMsg		= '820016' || ',' ||  pLegajo;

   
  -- Verifico el estado de cumplimiento de la encuesta al recien graduado.
  LET estado_encuesta = NULL;
  SELECT u820_encuesta_egr.cumplida
	INTO estado_encuesta
	FROM sga_alumnos, 
	           sga_titulos_plan,
	           sga_titulos,
	           sga_titulos_otorg,
		   u820_encuesta_egr
	WHERE sga_alumnos.unidad_academica = pUnidadAcademica
	AND sga_alumnos.carrera = pCarrera
	AND sga_alumnos.legajo = pLegajo
	-- AND sga_alumnos.calidad = 'E'

	AND sga_titulos_plan.unidad_academica = sga_alumnos.unidad_academica
	AND sga_titulos_plan.carrera = sga_alumnos.carrera
	AND sga_titulos_plan.plan = sga_alumnos.plan


	AND sga_titulos.unidad_academica  = sga_titulos_plan.unidad_academica
	AND sga_titulos.titulo  = sga_titulos_plan.titulo
	-- AND sga_titulos.nivel = 'GRADO'

	AND sga_titulos_otorg.unidad_academica = sga_alumnos.unidad_academica
	AND sga_titulos_otorg.nro_inscripcion = sga_alumnos.nro_inscripcion
	AND sga_titulos_otorg.titulo = sga_titulos_plan.titulo

	AND sga_titulos_otorg.unidad_academica = u820_encuesta_egr.unidad_academica
	AND sga_titulos_otorg.nro_inscripcion = u820_encuesta_egr.nro_inscripcion
	AND sga_titulos_otorg.titulo = u820_encuesta_egr.titulo;

  IF estado_encuesta = 'S' THEN

  	-- El alumno tiene la encuesta cumplimentada
   	LET iStatus = 1;
	LET vcMsg = 'OK' 	;

  END IF;
	
RETURN iStatus, vcMsg; 

END;
END PROCEDURE;
-- ************************ Fin Control "dba".ctr820_encuesta_gr ***********************
-- execute PROCEDURE "dba".ctr820_encuesta_gr('FICH', '03', '30171912-2');

-- *****************************************************************************
-- Permisos del Control "dba".ctr820_encuesta_gr
-- *****************************************************************************
revoke execute on "dba".ctr820_encuesta_gr from public;
grant execute on "dba".ctr820_encuesta_gr to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ctr820_encuesta_gr to internet; -- Rol de usuario de Internet
