-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 1.10.0
-- Tabla sga_det_acta_curs
-- Procedure spd_det_acta_curs (asociado al trigger de DELETE)
-- *******************************************************************************
DROP PROCEDURE spd_det_acta_curs ;
CREATE PROCEDURE spd_det_acta_curs (
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
       o_estado like sga_det_acta_curs.estado)
BEGIN

   -- No se puede borrar de sga_det_acta_curs si existe en sga_inscrip_reval
   -- (PARENT DELETE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede borrar de sga_det_acta_curs si existe en sga_det_acta_reval
   -- (PARENT DELETE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede borrar de sga_det_acta_curs si existe en sga_cursadas_equiv
   -- (PARENT DELETE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede borrar de sga_det_acta_curs si existe en sga_hist_acta_curs
   -- (PARENT DELETE RESTRICT) Este control lo lleva el CONSTRAINT


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
     o_unidad_academica,
     o_carrera,
     o_legajo,
     o_acta,
     o_folio,
     o_renglon,
     o_fecha_regularida,
     o_fin_vigencia_reg,
     o_cond_regularidad,
     o_resultado,
     o_nota,
     o_pct_asistencia,
     o_plan,
     o_version,
     o_rectificado,
     o_estado,
     User,
     Current year to Second,
     'D');
END;
END PROCEDURE;
-- ********** Fin del procedure asociado al trigger de DELETE de sga_det_acta_curs **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Tabla sga_det_acta_curs
-- Procedure personalizado spd820_det_acta_curs (asociado al trigger de DELETE)
-- *******************************************************************************
 DROP PROCEDURE spd820_det_acta_curs ;
 CREATE PROCEDURE spd820_det_acta_curs (
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
        o_estado like sga_det_acta_curs.estado)
 BEGIN

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

 END;
 END PROCEDURE;
-- **** Fin del procedure personalizado asociado al trigger de DELETE de sga_det_acta_curs ****
-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.00.0
-- Tabla sga_det_acta_curs
-- Trigger de Delete td_det_acta_curs
-- *******************************************************************************
DROP TRIGGER td_det_acta_curs ;
CREATE TRIGGER td_det_acta_curs DELETE on sga_det_acta_curs
referencing old as old
FOR EACH ROW (
   EXECUTE PROCEDURE spd_det_acta_curs (
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
     old.estado)
,

   EXECUTE PROCEDURE spd820_det_acta_curs (
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
     old.estado)
);
-- ********** Fin del trigger de Delete td_det_acta_curs **********
