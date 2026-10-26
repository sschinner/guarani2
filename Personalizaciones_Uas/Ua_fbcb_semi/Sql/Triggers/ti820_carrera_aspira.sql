CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'spi_carrera_aspira') THEN
		DROP PROCEDURE spi_carrera_aspira;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.05.0
-- Tabla sga_carrera_aspira
-- Procedure spi_carrera_aspira (asociado al trigger de INSERT) 
-- *******************************************************************************

CREATE PROCEDURE "dba".spi_carrera_aspira (
       n_unidad_academica like sga_carrera_aspira.unidad_academica,
       n_carrera like sga_carrera_aspira.carrera,
       n_nro_inscripcion like sga_carrera_aspira.nro_inscripcion,
       n_periodo_inscripc like sga_carrera_aspira.periodo_inscripcio,
       n_fecha_inscripcio like sga_carrera_aspira.fecha_inscripcion,
       n_sede like sga_carrera_aspira.sede,
       n_curso_ingreso like sga_carrera_aspira.curso_ingreso,
       n_forma_cumpli_cur like sga_carrera_aspira.forma_cumpli_curso,
       n_fecha_finalizaci like sga_carrera_aspira.fecha_finalizacion,
       n_alternativa_curs like sga_carrera_aspira.alternativa_cursad,
       n_situacion_asp like sga_carrera_aspira.situacion_asp,
       n_observaciones like sga_carrera_aspira.observaciones,
       n_tipo_ingreso like sga_carrera_aspira.tipo_ingreso,
       n_resolucion_ingre like sga_carrera_aspira.resolucion_ingreso,
       n_motivo_excep_cur like sga_carrera_aspira.motivo_excep_curso)

    -- Variables de retorno
    DEFINE iStatus     smallint;
    DEFINE vcMsg       varchar(255);
    DEFINE vc_Identif LIKE aca_usuarios_ag.identificacion;
    DEFINE vcPerfil       varchar(5);

BEGIN

--/////////////////////////////////////////////////////////////////////////////////////////
-- La bandera siguiente se utiliza para ver si la carrera se le exije que tenga requisitos.
-- Si es una carrera de integracion no pide requisitos para generar legajos.
  DEFINE aCar_sin_req char(1);
  LET aCar_sin_req = 'N';
  LET vcPerfil = 'ALU';

-- Cambio la bandera en caso de que la carrera pertenezca al grupo de carreras de integracion
  IF (n_carrera IN (SELECT carrera FROM sga_carreras_grupo WHERE grupo_carrera = 'i0001')) THEN
	LET aCar_sin_req = 'S';	
  END IF;
--/////////////////////////////////////////////////////////////////////////////////////////


   -- No se puede insertar en sga_carrera_aspira si no existe en sga_sedes_ua
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_carrera_aspira si no existe en sga_situacion_asp
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_carrera_aspira si no existe en sga_periodo_insc
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_carrera_aspira si no existe en sga_alter_cur_ing
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

  --------------------------------------------------------------------------- 
  -- Controlo que ya no este inscripto en esta Carrera en  otro periodo y 
  -- exista como alumno. (puede estar inscripto en otro periodo pero no debe existir como alumno)
  --------------------------------------------------------------------------- 
  IF EXISTS (SELECT ' ' FROM sga_carrera_aspira, sga_alumnos, sga_situacion_asp
              WHERE sga_carrera_aspira.unidad_academica = N_UNIDAD_ACADEMICA
                AND sga_carrera_aspira.nro_inscripcion = N_NRO_INSCRIPCION
                AND sga_carrera_aspira.carrera = N_CARRERA
                AND sga_situacion_asp.resultado_asp <> 'R'
                AND sga_carrera_aspira.periodo_inscripcio <> n_periodo_inscripc 
                AND sga_carrera_aspira.situacion_asp = sga_situacion_asp.situacion_asp
                AND sga_alumnos.unidad_academica = sga_carrera_aspira.unidad_academica
                AND sga_alumnos.carrera = sga_carrera_aspira.carrera
                AND sga_alumnos.nro_inscripcion = sga_carrera_aspira.nro_inscripcion) THEN

                -- Error
                raise exception -746,0,'La persona ya es Alumno en esta Carrera.';
  END IF;

  --------------------------------------------------------------------------- 
  -- Inserta en sga_req_cumplidos los requisitos (Obligatorios) de la Unidad Academica
  -- Debo verificar si ya no tiene requisitos en la tabla sga_req_cump_para esta carrera
  --------------------------------------------------------------------------- 
  begin
     on exception in (-206)
     end exception with resume; 
     drop table temp_req_ua;
     drop table temp_req_carrera;
  end;
  
  -- Inserto los requisitos por UA, si existe da error, va al on exception
  -- pero sigue el proceso porque tiene el with resume
  SELECT sga_requisitos_ua.unidad_academica unidad_academica,
         sga_requisitos_ua.requisito requisito,
         sga_requisitos_ua.obligatoriedad obligatoriedad
    FROM sga_requisitos_ua
   WHERE sga_requisitos_ua.unidad_academica = N_UNIDAD_ACADEMICA

-- **************************************************************************************************************************************************************************************************************************
-- u820 esto es para agregar los requisiton no obligatorios que estén en la tabla u820_req_no_oblig
-- **************************************************************************************************************************************************************************************************************************
--     AND sga_requisitos_ua.obligatoriedad = 'S'
     AND (sga_requisitos_ua.obligatoriedad = 'S' or (sga_requisitos_ua.obligatoriedad = 'N' and sga_requisitos_ua.requisito in (select requisito from u820_req_no_oblig where carrera = N_CARRERA)))
-- **************************************************************************************************************************************************************************************************************************

     AND NOT EXISTS ( SELECT sga_req_cumplidos.requisito
                        FROM sga_req_cumplidos
                       WHERE sga_req_cumplidos.unidad_academica = sga_requisitos_ua.unidad_academica
                         AND sga_req_cumplidos.nro_inscripcion = n_nro_inscripcion
                         AND sga_req_cumplidos.requisito = sga_requisitos_ua.requisito
                         AND sga_req_cumplidos.carrera = n_carrera )
         INTO TEMP temp_req_ua;

  IF DBINFO("sqlca.sqlerrd2") > 0 AND (aCar_sin_req = 'N') THEN
     INSERT INTO sga_req_cumplidos ( unidad_academica, nro_inscripcion, requisito, carrera, obligatoriedad )
          SELECT unidad_academica, n_nro_inscripcion, requisito, n_carrera, obligatoriedad
            FROM temp_req_ua;
  END IF;

  --------------------------------------------------------------------------- 
  -- Inserta en sga_req_ua_cump los requisitos en la Carrera
  --------------------------------------------------------------------------- 
  SELECT sga_requisitos_car.unidad_academica,
         sga_requisitos_car.requisito,
         sga_requisitos_car.carrera,
         sga_requisitos_car.obligatoriedad
    FROM sga_requisitos_car
   WHERE sga_requisitos_car.unidad_academica = N_UNIDAD_ACADEMICA
     AND sga_requisitos_car.carrera = N_CARRERA
-- **************************************************************************************************************************************************************************************************************************
-- u820 esto es para agregar los requisiton no obligatorios que estén en la tabla u820_req_no_oblig
-- **************************************************************************************************************************************************************************************************************************
--     AND sga_requisitos_car.obligatoriedad = 'S'
     AND (sga_requisitos_car.obligatoriedad = 'S' or (sga_requisitos_car.obligatoriedad = 'N' and sga_requisitos_car.requisito in (select requisito from u820_req_no_oblig where carrera = N_CARRERA)))
-- **************************************************************************************************************************************************************************************************************************
     AND NOT EXISTS ( SELECT sga_req_cumplidos.requisito
                        FROM sga_req_cumplidos
                       WHERE sga_req_cumplidos.unidad_academica = sga_requisitos_car.unidad_academica
                         AND sga_req_cumplidos.nro_inscripcion = n_nro_inscripcion
                         AND sga_req_cumplidos.requisito = sga_requisitos_car.requisito
                         AND sga_req_cumplidos.carrera = n_carrera )
         INTO TEMP temp_req_carrera ;

  IF DBINFO("sqlca.sqlerrd2") > 0 AND (aCar_sin_req = 'N') THEN
     INSERT INTO sga_req_cumplidos ( unidad_academica, nro_inscripcion, requisito, carrera, obligatoriedad )
          SELECT unidad_academica, N_NRO_INSCRIPCION, requisito,carrera, obligatoriedad
            FROM temp_req_carrera ;
  END IF;

  begin
    on exception in (-206)
    end exception with resume; 
    drop table temp_req_ua;
    drop table temp_req_carrera;
  end;
-- ************************************************************************************************************
-- ************************************************************************************************************

  --------------------------------------------------------------------------- 
  -- Inserta un registro en movimientos
  --------------------------------------------------------------------------- 

  INSERT INTO sga_movimientos ( unidad_academica, carrera, nro_inscripcion, tipo_movimiento, fecha_inicio, fecha_fin )
       VALUES ( N_UNIDAD_ACADEMICA, N_CARRERA, N_NRO_INSCRIPCION , 'AIC', CURRENT YEAR TO SECOND, NULL );


  --------------------------------------------------------------------------- 
  -- Genera el usuario de AutoGestion para el alumno si aun no esta generado.
  ---------------------------------------------------------------------------
-- ********************************************************************************************************
-- u820 se debe cambiar el perfil del usuario según la sede:
-- Sede ATILRA: 00001 (se especifica que sede tiene que perfil de alumno)
-- Simplificación: el alumno de ATILRA esta solo en esa carrera
-- ********************************************************************************************************

IF n_sede = '00001' THEN 
	LET vcPerfil = 'ALU1';
END IF;

  IF NOT EXISTS ( SELECT '' 
                    FROM aca_usuarios_ag 
                   WHERE aca_usuarios_ag.unidad_academica = N_UNIDAD_ACADEMICA
                     AND aca_usuarios_ag.nro_inscripcion = N_NRO_INSCRIPCION
                     AND aca_usuarios_ag.tipo_usuar_inicial = vcPerfil ) THEN
  
     EXECUTE PROCEDURE sp_identDefaultAg ( N_UNIDAD_ACADEMICA, N_NRO_INSCRIPCION ) INTO iStatus, vc_Identif;
     EXECUTE PROCEDURE sp_CrearUsuarioAG( N_UNIDAD_ACADEMICA, N_NRO_INSCRIPCION, vc_Identif, vcPerfil) INTO iStatus, vcMsg;
     IF iStatus < 0 THEN
        -- Error
        raise exception -746,0,'Problemas con la creación del usuario de AutoGestión del Alumno';
     ELSE
        EXECUTE PROCEDURE sp_bloquearUsuario ( N_UNIDAD_ACADEMICA, vc_Identif ) INTO iStatus, vcMsg;
     END IF;
  END IF;

   -- No se puede insertar en sga_carrera_aspira si no existe en sga_cursos_ingreso
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_carrera_aspira si no existe en sga_personas
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_carrera_aspira si no existe en sga_carreras
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT


   -- Carga la tabla de log para auditoria
   INSERT INTO log_carrera_aspira (
     unidad_academica,
     carrera,
     nro_inscripcion,
     periodo_inscripcio,
     fecha_inscripcion,
     sede,
     curso_ingreso,
     forma_cumpli_curso,
     fecha_finalizacion,
     alternativa_cursad,
     situacion_asp,
     observaciones,
     tipo_ingreso,
     resolucion_ingreso,
     motivo_excep_curso,
     usuario,
     fecha_act,
     oper)
   VALUES (
     n_unidad_academica,
     n_carrera,
     n_nro_inscripcion,
     n_periodo_inscripc,
     n_fecha_inscripcio,
     n_sede,
     n_curso_ingreso,
     n_forma_cumpli_cur,
     n_fecha_finalizaci,
     n_alternativa_curs,
     n_situacion_asp,
     n_observaciones,
     n_tipo_ingreso,
     n_resolucion_ingre,
     n_motivo_excep_cur,
     User,
     Current year to Second,
     'I');
END;
END PROCEDURE;
-- ********** Fin del procedure asociado al trigger de INSERT de sga_carrera_aspira **********

-- *****************************************************************************
-- Permisos del procedimiento "dba".spi_carrera_aspira 
-- *****************************************************************************
revoke execute on "dba".spi_carrera_aspira from public;
grant execute on "dba".spi_carrera_aspira to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".spi_carrera_aspira to internet; -- Rol de usuario de Internet

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Tabla sga_carrera_aspira
-- Procedure personalizado uai_carrera_aspira (asociado al trigger de INSERT)
-- *******************************************************************************
-- DROP PROCEDURE uai_carrera_aspira ;
-- CREATE PROCEDURE uai_carrera_aspira (
--        n_unidad_academica like sga_carrera_aspira.unidad_academica,
--        n_carrera like sga_carrera_aspira.carrera,
--        n_nro_inscripcion like sga_carrera_aspira.nro_inscripcion,
--        n_periodo_inscripc like sga_carrera_aspira.periodo_inscripcio,
--        n_fecha_inscripcio like sga_carrera_aspira.fecha_inscripcion,
--        n_sede like sga_carrera_aspira.sede,
--        n_curso_ingreso like sga_carrera_aspira.curso_ingreso,
--        n_forma_cumpli_cur like sga_carrera_aspira.forma_cumpli_curso,
--        n_fecha_finalizaci like sga_carrera_aspira.fecha_finalizacion,
--        n_alternativa_curs like sga_carrera_aspira.alternativa_cursad,
--        n_situacion_asp like sga_carrera_aspira.situacion_asp,
--        n_observaciones like sga_carrera_aspira.observaciones,
--        n_tipo_ingreso like sga_carrera_aspira.tipo_ingreso,
--        n_resolucion_ingre like sga_carrera_aspira.resolucion_ingreso,
--        n_motivo_excep_cur like sga_carrera_aspira.motivo_excep_curso)
-- BEGIN
--
--   -------------------------------------------------------------------------------- 
--   -- CODIGO PERSONALIZADO
--   -------------------------------------------------------------------------------- 
--
-- END;
-- END PROCEDURE;
-- **** Fin del procedure personalizado asociado al trigger de INSERT de sga_carrera_aspira ****

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigid
			FROM systriggers 
			WHERE trigname = 'ti_carrera_aspira') THEN
		DROP TRIGGER ti_carrera_aspira;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.05.0
-- Tabla sga_carrera_aspira
-- Trigger de Insert ti_carrera_aspira
-- *******************************************************************************

CREATE TRIGGER "dba".ti_carrera_aspira INSERT on sga_carrera_aspira
referencing new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spi_carrera_aspira (
     new.unidad_academica,
     new.carrera,
     new.nro_inscripcion,
     new.periodo_inscripcio,
     new.fecha_inscripcion,
     new.sede,
     new.curso_ingreso,
     new.forma_cumpli_curso,
     new.fecha_finalizacion,
     new.alternativa_cursad,
     new.situacion_asp,
     new.observaciones,
     new.tipo_ingreso,
     new.resolucion_ingreso,
     new.motivo_excep_curso)

-- ,

{
 EXECUTE PROCEDURE sp_qui_insc_carr (
     new.unidad_academica,
     new.carrera,
     new.nro_inscripcion,
     new.fecha_inscripcion,
     new.observaciones,
     'I')
--,
}


--   EXECUTE PROCEDURE uai_carrera_aspira (
--     new.unidad_academica,
--     new.carrera,
--     new.nro_inscripcion,
--     new.periodo_inscripcio,
--     new.fecha_inscripcion,
--     new.sede,
--     new.curso_ingreso,
--     new.forma_cumpli_curso,
--     new.fecha_finalizacion,
--     new.alternativa_cursad,
--     new.situacion_asp,
--     new.observaciones,
--     new.tipo_ingreso,
--     new.resolucion_ingreso,
--     new.motivo_excep_curso)
);
-- ********** Fin del trigger de Insert ti_carrera_aspira **********
