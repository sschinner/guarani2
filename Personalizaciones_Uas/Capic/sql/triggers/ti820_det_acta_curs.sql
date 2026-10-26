-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 1.10.0
-- Tabla sga_det_acta_curs
-- Procedure spi_det_acta_curs (asociado al trigger de INSERT)
-- *******************************************************************************
DROP PROCEDURE spi_det_acta_curs ;
CREATE PROCEDURE spi_det_acta_curs (
       n_unidad_academica like sga_det_acta_curs.unidad_academica,
       n_carrera like sga_det_acta_curs.carrera,
       n_legajo like sga_det_acta_curs.legajo,
       n_acta like sga_det_acta_curs.acta,
       n_folio like sga_det_acta_curs.folio,
       n_renglon like sga_det_acta_curs.renglon,
       n_fecha_regularida like sga_det_acta_curs.fecha_regularidad,
       n_fin_vigencia_reg like sga_det_acta_curs.fin_vigencia_regul,
       n_cond_regularidad like sga_det_acta_curs.cond_regularidad,
       n_resultado like sga_det_acta_curs.resultado,
       n_nota like sga_det_acta_curs.nota,
       n_pct_asistencia like sga_det_acta_curs.pct_asistencia,
       n_plan like sga_det_acta_curs.plan,
       n_version like sga_det_acta_curs.version,
       n_rectificado like sga_det_acta_curs.rectificado,
       n_estado like sga_det_acta_curs.estado)
BEGIN

   -- No se puede insertar en sga_det_acta_curs si no existe en sga_versiones_plan
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_det_acta_curs si no existe en sga_cond_regular
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_det_acta_curs si no existe en sga_actas_cursado
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_det_acta_curs si no existe en sga_alumnos
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT


   -- Carga la tabla de log para auditoria
   INSERT INTO log_det_acta_curs (
     unidad_academica,
     carrera,
     legajo,
     acta,
     folio,
     renglon,
     fecha_regularidad,
     fin_vigencia_regul,
     cond_regularidad,
     resultado,
     nota,
     pct_asistencia,
     plan,
     version,
     rectificado,
     estado,
     usuario,
     fecha_act,
     oper)
   VALUES (
     n_unidad_academica,
     n_carrera,
     n_legajo,
     n_acta,
     n_folio,
     n_renglon,
     n_fecha_regularida,
     n_fin_vigencia_reg,
     n_cond_regularidad,
     n_resultado,
     n_nota,
     n_pct_asistencia,
     n_plan,
     n_version,
     n_rectificado,
     n_estado,
     User,
     Current year to Second,
     'I');
END;
END PROCEDURE;
-- ********** Fin del procedure asociado al trigger de INSERT de sga_det_acta_curs **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Tabla sga_det_acta_curs
-- Procedure personalizado spi820_det_acta_curs (asociado al trigger de INSERT)
-- *******************************************************************************
 DROP PROCEDURE spi820_det_acta_curs ;
 CREATE PROCEDURE spi820_det_acta_curs (
        n_unidad_academica like sga_det_acta_curs.unidad_academica,
        n_carrera like sga_det_acta_curs.carrera,
        n_legajo like sga_det_acta_curs.legajo,
        n_acta like sga_det_acta_curs.acta,
        n_folio like sga_det_acta_curs.folio,
        n_renglon like sga_det_acta_curs.renglon,
        n_fecha_regularida like sga_det_acta_curs.fecha_regularidad,
        n_fin_vigencia_reg like sga_det_acta_curs.fin_vigencia_regul,
        n_cond_regularidad like sga_det_acta_curs.cond_regularidad,
        n_resultado like sga_det_acta_curs.resultado,
        n_nota like sga_det_acta_curs.nota,
        n_pct_asistencia like sga_det_acta_curs.pct_asistencia,
        n_plan like sga_det_acta_curs.plan,
        n_version like sga_det_acta_curs.version,
        n_rectificado like sga_det_acta_curs.rectificado,
        n_estado like sga_det_acta_curs.estado)
 BEGIN

--   -------------------------------------------------------------------------------- 
--   -- CODIGO PERSONALIZADO


DEFINE vc_acta_estado like sga_actas_cursado.estado;
DEFINE vc_acta_comision like sga_actas_cursado.comision;

LET vc_acta_estado = NULL;
LET vc_acta_comision = NULL;

SELECT estado, comision INTO vc_acta_estado, vc_acta_comision 
FROM sga_actas_cursado
WHERE acta = n_acta;

   IF vc_acta_estado = 'C' and exists (select 'comision_capic' from capic_comisiones where comision = vc_acta_comision ) THEN
	raise exception -746,0,'No puede rectificar el Acta. El Acta ha sido cerrada y es de una Comision de Integración';
   END IF;

--   -------------------------------------------------------------------------------- 

 END;
 END PROCEDURE;
-- **** Fin del procedure personalizado asociado al trigger de INSERT de sga_det_acta_curs ****
-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.00.0
-- Tabla sga_det_acta_curs
-- Trigger de Insert ti_det_acta_curs
-- *******************************************************************************
DROP TRIGGER ti_det_acta_curs ;
CREATE TRIGGER ti_det_acta_curs INSERT on sga_det_acta_curs
referencing new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spi_det_acta_curs (
     new.unidad_academica,
     new.carrera,
     new.legajo,
     new.acta,
     new.folio,
     new.renglon,
     new.fecha_regularidad,
     new.fin_vigencia_regul,
     new.cond_regularidad,
     new.resultado,
     new.nota,
     new.pct_asistencia,
     new.plan,
     new.version,
     new.rectificado,
     new.estado)
/*
,

   EXECUTE PROCEDURE spi820_det_acta_curs (
     new.unidad_academica,
     new.carrera,
     new.legajo,
     new.acta,
     new.folio,
     new.renglon,
     new.fecha_regularidad,
     new.fin_vigencia_regul,
     new.cond_regularidad,
     new.resultado,
     new.nota,
     new.pct_asistencia,
     new.plan,
     new.version,
     new.rectificado,
     new.estado)*/
);
-- ********** Fin del trigger de Insert ti_det_acta_curs **********
