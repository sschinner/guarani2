Begin;
set constraints all deferred;

-- Agregar evento 8205 Tramitar Egreso
DELETE FROM par_eventos WHERE evento = 8205;

-- Configurar los Puntos de Control por Evento:
DELETE FROM par_puntos_x_event WHERE evento = 8205;

DELETE FROM par_eventos_x_oper WHERE evento = 8205 AND operacion in ('neteg100') ;
DELETE FROM par_eventos_x_oper WHERE evento = 8205 AND operacion in ('neteg200') ;

-- Configurar los controles por evento

DELETE FROM par_cont_x_evento WHERE evento = 8205;
DELETE FROM par_puntos_x_oper WHERE operacion in ('neteg100');
DELETE FROM par_puntos_x_oper WHERE operacion in ('neteg200');
-- DELETE FROM par_puntos_x_oper WHERE operacion in ('820egr20');
DELETE FROM par_cont_x_oper WHERE operacion in ('neteg100');
DELETE FROM par_cont_x_oper WHERE operacion in ('neteg200');
-- DELETE FROM par_cont_x_oper WHERE operacion in ('820egr20');
DELETE FROM sga_conf_controles WHERE operacion in ('neteg100');
DELETE FROM sga_conf_controles WHERE operacion in ('neteg200');
-- DELETE FROM sga_conf_controles WHERE operacion in ('820egr20');
Commit;

-- execute procedure  sp_ConfPuntoOper ( '820egr20', 8205, 37);

-- Agrega el Punto de control 37 (Alumno - Egresado) Controles sobre el alumno egresado.
-- Agregar los controles a realizar en cada Operacion/Pagina
begin;
Set constraints all deferred;
DELETE FROM par_puntos_x_pag WHERE operacion in ('neteg100');
DELETE FROM par_puntos_x_pag WHERE operacion in ('neteg200');

commit;


-- *************************************************************************************************************
-- Control para verificar que el alumno es egresado y se encuentra en un estado particular.
-- *************************************************************************************************************

begin;

-- El control es sobre el alumno
delete from sga_conf_controles where control = 82040;
delete from sga_conf_controles where control = 82041;

delete from par_cont_x_oper where punto_de_control = 37 and control = 82040;
delete from par_cont_x_oper where punto_de_control = 37 and control = 82041;

delete from par_cont_x_evento where punto_de_control = 37 and control = 82040;
delete from par_cont_x_evento where punto_de_control = 37 and control = 82041;

delete from par_cont_x_punto where punto_de_control = 37 and control = 82040;
delete from par_cont_x_punto where punto_de_control = 37 and control = 82041;

delete from par_implem_control where stored_procedure = "ctr820_egresado";
delete from par_implem_control where stored_procedure = "ctr820_encuesta_gr";

delete from par_controles where control = 82040;
delete from par_controles where control = 82041;

-- select * from par_controles;
commit;


-- Activar el control por defecto
begin;

delete from sga_conf_controles where unidad_academica not in (select unidad_academica from sga_valor_inicial); -- Debo hacer esto para no modificar el procedimiento de soporte que toma como tabla sga_unidades_acad.
commit;

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_egresado') THEN
		DROP PROCEDURE "dba".ctr820_egresado;
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
	AND sga_alumnos.calidad = 'E'

	AND sga_titulos_plan.unidad_academica = sga_alumnos.unidad_academica
	AND sga_titulos_plan.carrera = sga_alumnos.carrera
	AND sga_titulos_plan.plan = sga_alumnos.plan

	AND sga_titulos.unidad_academica  = sga_titulos_plan.unidad_academica
	AND sga_titulos.titulo  = sga_titulos_plan.titulo
	AND sga_titulos.nivel = 'GRADO'

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
-- ************************ Fin Control ctr820_egresado ***********************
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
-- Se agrega condición de que la carrera pertenezca al grupo de carreras de gestionada por la UA (00001)
-- También se controla por Tipo de Título.
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

   LET iStatus		= 1;
   LET vcMsg		= 'OK';


IF pCarrera in (Select carrera from sga_carreras_grupo where grupo_carrera = '00001' )  THEN

  -- Verifico el estado de cumplimiento de la encuesta al recien graduado.
  LET estado_encuesta = NULL;
  IF EXISTS (SELECT *

	FROM sga_alumnos alu
		join sga_titulos_plan tp
			on tp.unidad_academica = alu.unidad_academica
			AND tp.carrera = alu.carrera
			AND tp.plan = alu.plan

		join sga_titulos tit
			on tit.unidad_academica  = tp.unidad_academica
			AND tit.titulo  = tp.titulo
			AND tit.tipo_de_titulo = 'G'

		join  sga_titulos_otorg titot
			on titot.unidad_academica = alu.unidad_academica
			AND titot.nro_inscripcion = alu.nro_inscripcion
			AND titot.titulo = tp.titulo

		left join u820_encuesta_egr enc
			on titot.nro_inscripcion = enc.nro_inscripcion
			and titot.titulo = enc.titulo

	WHERE alu.unidad_academica = pUnidadAcademica
	AND alu.carrera = pCarrera
	AND alu.legajo = pLegajo
	AND enc.cumplida is NULL) THEN

  	-- El egresado no tiene la encuesta cumplimentada
	   LET iStatus		= -1;
	   LET vcMsg		= '820016' || ',' ||  pLegajo;

  END IF;

END IF;  	-- La carrera del alumno no es de Grado y no tiene obligación de contestar la encuesta, ya que por el momento no ha sido definido
	
RETURN iStatus, vcMsg; 

END;
END PROCEDURE;
-- ************************ Fin Control ctr820_encuesta_gr ***********************
-- execute PROCEDURE ctr820_encuesta_gr('EUAA', '1106', '21411816-8');
revoke execute on "dba".ctr820_encuesta_gr from public;
grant execute on "dba".ctr820_encuesta_gr to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ctr820_encuesta_gr to internet; -- Rol de usuario de Internet

