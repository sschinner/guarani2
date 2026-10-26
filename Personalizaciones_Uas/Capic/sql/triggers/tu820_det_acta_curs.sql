-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 1.10.0
-- Tabla sga_det_acta_curs
-- Procedure spu_det_acta_curs (asociado al trigger de UPDATE)
-- *******************************************************************************
DROP PROCEDURE spu_det_acta_curs ;
CREATE PROCEDURE spu_det_acta_curs (
       o_unidad_academica like sga_det_acta_curs.unidad_academica,
       o_carrera like sga_det_acta_curs.carrera,
       o_legajo like sga_det_acta_curs.legajo,
       o_acta like sga_det_acta_curs.acta,
       o_folio like sga_det_acta_curs.folio,
       o_renglon like sga_det_acta_curs.renglon,
       o_fecha_regularida like sga_det_acta_curs.fecha_regularidad,
       o_fin_vigencia_reg like sga_det_acta_curs.fin_vigencia_regul,
       o_cond_regularidad like sga_det_acta_curs.cond_regularidad,
       o_resultado like sga_det_acta_curs.resultado,
       o_nota like sga_det_acta_curs.nota,
       o_pct_asistencia like sga_det_acta_curs.pct_asistencia,
       o_plan like sga_det_acta_curs.plan,
       o_version like sga_det_acta_curs.version,
       o_rectificado like sga_det_acta_curs.rectificado,
       o_estado like sga_det_acta_curs.estado,
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
   -------------------------------------------------------------------------------- 
   -- Impide que se modifique la clave primaria de un registro 
   -------------------------------------------------------------------------------- 
   IF o_unidad_academica <> n_unidad_academica OR
      o_carrera <> n_carrera OR
      o_legajo <> n_legajo OR
      o_acta <> n_acta  THEN
      raise exception -746,0,'No se puede modificar la clave primaria de un registro.';
   END IF;

   -- No se puede insertar en sga_det_acta_curs si no existe en sga_versiones_plan
   -- (CHILD UPDATE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_det_acta_curs si no existe en sga_cond_regular
   -- (CHILD UPDATE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_det_acta_curs si no existe en sga_alumnos
   -- (CHILD UPDATE RESTRICT) Este control lo lleva el CONSTRAINT


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
     'U');
END;
END PROCEDURE;
-- ********** Fin del procedure asociado al trigger de UPDATE de sga_det_acta_curs **********

-- U820 ***********************************************************************************************************************
-- Procedimiento para restringir la actualizacion de actas CAPIC
-- No se deberia permitir rectificar una acta si esta es de capic
-- U820 ***********************************************************************************************************************

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Tabla sga_det_acta_curs
-- Procedure personalizado spu820_det_acta_curs (asociado al trigger de UPDATE)
-- *******************************************************************************
 DROP PROCEDURE spu820_det_acta_curs ;
 CREATE PROCEDURE spu820_det_acta_curs (
        o_unidad_academica like sga_det_acta_curs.unidad_academica,
        o_carrera like sga_det_acta_curs.carrera,
        o_legajo like sga_det_acta_curs.legajo,
        o_acta like sga_det_acta_curs.acta,
        o_folio like sga_det_acta_curs.folio,
        o_renglon like sga_det_acta_curs.renglon,
        o_fecha_regularida like sga_det_acta_curs.fecha_regularidad,
        o_fin_vigencia_reg like sga_det_acta_curs.fin_vigencia_regul,
        o_cond_regularidad like sga_det_acta_curs.cond_regularidad,
        o_resultado like sga_det_acta_curs.resultado,
        o_nota like sga_det_acta_curs.nota,
        o_pct_asistencia like sga_det_acta_curs.pct_asistencia,
        o_plan like sga_det_acta_curs.plan,
        o_version like sga_det_acta_curs.version,
        o_rectificado like sga_det_acta_curs.rectificado,
        o_estado like sga_det_acta_curs.estado,
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
--
--   -------------------------------------------------------------------------------- 
--   -- CODIGO PERSONALIZADO

DEFINE vc_acta_estado like sga_actas_cursado.estado;
DEFINE vc_acta_comision like sga_actas_cursado.comision;

LET vc_acta_estado = NULL;
LET vc_acta_comision = NULL;

SELECT estado, comision INTO vc_acta_estado, vc_acta_comision 
FROM sga_actas_cursado
WHERE acta = o_acta;

   IF vc_acta_estado = 'C' and exists (select 'comision_capic' from capic_comisiones where comision = vc_acta_comision ) THEN
	raise exception -746,0,'No puede rectificar el Acta. El Acta ha sido cerrada y es de una Comision de Integración';
   END IF;

--   -------------------------------------------------------------------------------- 
--
 END;
 END PROCEDURE;
-- **** Fin del procedure personalizado asociado al trigger de UPDATE de sga_det_acta_curs ****
-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.00.0
-- Tabla sga_det_acta_curs
-- Trigger de Update tu_det_acta_curs
-- *******************************************************************************
DROP TRIGGER tu_det_acta_curs ;
CREATE TRIGGER tu_det_acta_curs UPDATE on sga_det_acta_curs
referencing old as old new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spu_det_acta_curs (
     old.unidad_academica,
     old.carrera,
     old.legajo,
     old.acta,
     old.folio,
     old.renglon,
     old.fecha_regularidad,
     old.fin_vigencia_regul,
     old.cond_regularidad,
     old.resultado,
     old.nota,
     old.pct_asistencia,
     old.plan,
     old.version,
     old.rectificado,
     old.estado,
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

   EXECUTE PROCEDURE spu820_det_acta_curs (
     old.unidad_academica,
     old.carrera,
     old.legajo,
     old.acta,
     old.folio,
     old.renglon,
     old.fecha_regularidad,
     old.fin_vigencia_regul,
     old.cond_regularidad,
     old.resultado,
     old.nota,
     old.pct_asistencia,
     old.plan,
     old.version,
     old.rectificado,
     old.estado,
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
     new.estado) */

);
-- ********** Fin del trigger de Update tu_det_acta_curs **********
