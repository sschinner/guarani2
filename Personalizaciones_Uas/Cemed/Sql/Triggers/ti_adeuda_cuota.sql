CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'spi820_ad_cuota') THEN
		DROP PROCEDURE spi820_ad_cuota;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.0.0
-- Tabla u820_adeuda_cuota
-- Procedure spi820_ad_cuota (asociado al trigger de INSERT)
-- *******************************************************************************
-- DROP PROCEDURE spi820_ad_cuota ;
CREATE PROCEDURE "dba".spi820_ad_cuota (
       n_unidad_academica like sga_carrera_aspira.unidad_academica,
       n_tipo_documento  like sga_personas.tipo_documento,
       n_nro_documento like sga_personas.nro_documento,
       n_materia like sga_materias.materia,
       n_periodo_lectivo like sga_comisiones.periodo_lectivo,
       n_anio_academico like sga_comisiones.anio_academico,
       n_fecha_imputacion like u820_adeuda_cuota.fecha_imputacion,
       n_tipo_modalidad like u820_adeuda_cuota.tipo_modalidad,
       n_observaciones like sga_carrera_aspira.observaciones)

    -- Variables de retorno
    DEFINE iStatus     smallint;
    DEFINE vcMsg       varchar(255);
    DEFINE vc_Identif LIKE aca_usuarios_ag.identificacion;

BEGIN

   -- No se puede insertar en sga_carrera_aspira si no existe en sga_situacion_asp
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_carrera_aspira si no existe en sga_periodo_insc
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_carrera_aspira si no existe en sga_alter_cur_ing
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_carrera_aspira si no existe en sga_cursos_ingreso
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_carrera_aspira si no existe en sga_personas
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_carrera_aspira si no existe en sga_carreras

  -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT




   -- Carga la tabla de log para auditoria
   INSERT INTO log_adeuda_cuota(
       UNIDAD_ACADEMICA,
       TIPO_DOCUMENTO,
       NRO_DOCUMENTO,
       MATERIA,
       PERIODO_LECTIVO,
       ANIO_ACADEMICO,
       FECHA_IMPUTACION,
       TIPO_MODALIDAD,
       OBSERVACIONES,
     usuario,
     fecha_act,
     operacion)

   VALUES (
	n_unidad_academica,
	n_tipo_documento,
	n_nro_documento,
	n_materia,
	n_periodo_lectivo,
	n_anio_academico,
	n_fecha_imputacion,
        n_tipo_modalidad,
	n_observaciones,
	User,
	Current year to Second,
	'I');
END;
END PROCEDURE;
-- ********** Fin del procedure asociado al trigger de INSERT de u820_adeuda_cuota **********



-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Tabla u820_adeuda_cuota 
-- Procedure personalizado uai_adeuda_cuota (asociado al trigger de INSERT)
-- *******************************************************************************
-- DROP PROCEDURE uai_adeuda_cuota ;
-- CREATE PROCEDURE uai_adeuda_cuota (

--       n_unidad_academica like sga_carrera_aspira.unidad_academica,
--       n_tipo_documento  like sga_personas.tipo_documento,
--       n_nro_documento like sga_personas.nro_documento,
--       n_materia like sga_materias.materia,
--       n_fecha_imputacion like u820_adeuda_cuota.fecha_imputacion,
--       n_observaciones like sga_carrera_aspira.observaciones)

-- BEGIN
--
--   -------------------------------------------------------------------------------- 
--   -- CODIGO PERSONALIZADO
--   -------------------------------------------------------------------------------- 
--
-- END;
-- END PROCEDURE;
-- **** Fin del procedure personalizado asociado al trigger de INSERT de u820_adeuda_cuota****

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 1.8.0
-- Tabla u820_adeuda_cuota
-- Trigger de Insert ti_adeuda_cuota
-- *******************************************************************************
DROP TRIGGER ti_adeuda_cuota;
CREATE TRIGGER ti_adeuda_cuota INSERT on u820_adeuda_cuota
referencing new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spi820_ad_cuota (
     new.unidad_academica,
     new.tipo_documento,
     new.nro_documento,
     new.materia,
     new.periodo_lectivo,
     new.anio_academico,
     new.fecha_imputacion,
     new.tipo_modalidad,
     new.observaciones)
--,

--   EXECUTE PROCEDURE uai_adeuda_cuota (
--      new.unidad_academica,
--     new.tipo_documento,
--     new.nro_documento,
--     new.materia,
--     new.fecha_imputacion,
--     new.observaciones)
);
-- ********** Fin del trigger de Insert ti_adeuda_cuota **********
