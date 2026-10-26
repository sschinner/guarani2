CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'spd_detalle_acta') THEN
		DROP PROCEDURE spd_detalle_acta;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 1.9.0
-- Tabla sga_detalle_acta
-- Procedure spd_detalle_acta (asociado al trigger de DELETE)
-- *******************************************************************************
 
CREATE PROCEDURE "dba".spd_detalle_acta(
       o_unidad_academica like sga_detalle_acta.unidad_academica,
       o_tipo_acta like sga_detalle_acta.tipo_acta,
       o_acta like sga_detalle_acta.acta,
       o_carrera like sga_detalle_acta.carrera,
     o_legajo like sga_detalle_acta.legajo,
       o_folio like sga_detalle_acta.folio,
       o_renglon like sga_detalle_acta.renglon,
       o_tipo_inscripcion like sga_detalle_acta.tipo_inscripcion,
       o_equiv_parcial like sga_detalle_acta.equiv_parcial,
       o_fecha_de_examen like sga_detalle_acta.fecha_de_examen,
       o_resultado like sga_detalle_acta.resultado,
       o_nota like sga_detalle_acta.nota,
       o_resultado_2 like sga_detalle_acta.resultado_2,
       o_nota_2 like sga_detalle_acta.nota_2,
       o_vigencia like sga_detalle_acta.vigencia,
       o_plan like sga_detalle_acta.plan,
       o_version like sga_detalle_acta.version,
       o_controlado like sga_detalle_acta.controlado,
       o_rectificado like sga_detalle_acta.rectificado,
       o_estado like sga_detalle_acta.estado)
BEGIN

   -------------------------------------------------------------------------------- 
   -- Borra en cascada los registros de la tabla  (PARENT DELETE CASCADE)
   -- Evaluar que pasa si el registro tiene cambios de estados!!! sga_mov_examenes
   -------------------------------------------------------------------------------- 
   IF (SELECT COUNT(*) FROM sga_mov_examen
               WHERE unidad_academica = o_unidad_academica

               AND tipo_acta = o_tipo_acta
                 AND acta = o_acta
                 AND carrera = o_carrera
	AND legajo = o_legajo)  > 0 THEN
      raise exception -746, 0, 'No puede borrarse porque el Alumno ' || o_legajo || ' tiene cambios de Hist Acad.';
   END IF;
  

   -------------------------------------------------------------------------------- 
   -- Borra en cascada los registros de la tabla sga_examenes_equiv (PARENT DELETE CASCADE)
   --------------------------------------
------------------------------------------ 
   DELETE FROM sga_examenes_equiv
    WHERE sga_examenes_equiv.unidad_academica = o_unidad_academica
      AND sga_examenes_equiv.tipo_acta = o_tipo_acta
      AND sga_examenes_equiv.acta = o_acta
      AND sga_examenes_equiv.carrera_original = o_carrera
      AND sga_examenes_equiv.legajo_original = o_legajo;

   -- Impide que se borren registros del detalle de un acta cerrada
   IF EXISTS (SELECT '' FROM sga_actas_examen
              WHERE sga_actas_examen.unidad_academica = o_unidad_academica
                 AND sga_actas_examen.tipo_acta = o_tipo_acta
                 AND sga_actas_examen.acta = o_acta
                 AND sga_actas_examen.estado = 'C') THEN
      raise exception -746, 0, 'No se puede borrar el detalle de un acta cerrada.';
   END IF;


   -- Carga la tabla de log para auditoria
   INSERT INTO log_detalle_acta (
     unidad_academica,
     tipo_acta,
     acta,
     carrera,
     legajo,
     folio,
     renglon,
   tipo_inscripcion,
     equiv_parcial,
     fecha_de_examen,
     resultado,
     nota,
     resultado_2,
     nota_2,
     vigencia,
     plan,
     version,
     controlado,
     rectificado,
     estado,
     usuario,
     fecha_act,
   operacion)
   VALUES (
     o_unidad_academica,
     o_tipo_acta,
     o_acta,
     o_carrera,
     o_legajo,
     o_folio,
     o_renglon,
     o_tipo_inscripcion,
     o_equiv_parcial,
     o_fecha_de_examen,
     o_resultado,
     o_nota,
     o_resultado_2,
     o_nota_2,
     o_vigencia,
     o_plan,
     o_version,
     o_controlado,
     o_rectificado,
     o_estado,
     User,
     Current year to Second,
     'D');
END;
END PROCEDURE;

-- ********** Fin del procedure asociado al trigger de DELETE de sga_detalle_acta **********

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'spd820_det_acta') THEN
		DROP PROCEDURE spd820_det_acta;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Tabla sga_detalle_acta
-- Procedure personalizado spd820_det_acta (asociado al trigger de DELETE)
-- *******************************************************************************
-- U820 ***********************************************************************************************************************
-- procedimiento para actualizar la condición de regularidad en la tabla u820_sga_det_acta
-- U820 ***********************************************************************************************************************
 

CREATE PROCEDURE "dba".spd820_det_acta(
        o_unidad_academica like sga_detalle_acta.unidad_academica,
        o_tipo_acta like sga_detalle_acta.tipo_acta,
        o_acta like sga_detalle_acta.acta,
        o_carrera like sga_detalle_acta.carrera,
        o_legajo like sga_detalle_acta.legajo,
        o_folio like sga_detalle_acta.folio,
        o_renglon like sga_detalle_acta.renglon,
        o_tipo_inscripcion like sga_detalle_acta.tipo_inscripcion,
        o_equiv_parcial like sga_detalle_acta.equiv_parcial,
        o_fecha_de_examen like sga_detalle_acta.fecha_de_examen,
        o_resultado like sga_detalle_acta.resultado,
        o_nota like sga_detalle_acta.nota,
        o_resultado_2 like sga_detalle_acta.resultado_2,
        o_nota_2 like sga_detalle_acta.nota_2,
        o_vigencia like sga_detalle_acta.vigencia,
        o_plan like sga_detalle_acta.plan,
        o_version like sga_detalle_acta.version,
        o_controlado like sga_detalle_acta.controlado,
        o_rectificado like sga_detalle_acta.rectificado,
        o_estado like sga_detalle_acta.estado)
BEGIN

--   -------------------------------------------------------------------------------- 
--   -- CODIGO PERSONALIZADO

-- U820 ***********************************************************************************************************************
-- Borra el la condición del alumno en la tabla u820_sga_det_acta
-- U820 ***********************************************************************************************************************

   DELETE FROM u820_sga_det_acta
    WHERE unidad_academica = o_unidad_academica AND
         	tipo_acta = o_tipo_acta AND
			acta = o_acta AND
          	legajo = o_legajo ;


--   ----------------------------------------
---------------------------------------- 

END;
END PROCEDURE;

-- **** Fin del procedure personalizado asociado al trigger de DELETE de sga_detalle_acta ****

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigid
			FROM systriggers
			WHERE trigname = 'td_detalle_acta') THEN
		DROP TRIGGER td_detalle_acta;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 1.8.0
-- Tabla sga_detalle_acta
-- Trigger de Delete td_detalle_acta
-- *******************************************************************************

CREATE TRIGGER td_detalle_acta DELETE on sga_detalle_acta
referencing old as old
FOR EACH ROW (
   EXECUTE PROCEDURE spd_detalle_acta (
     old.unidad_academica,
     old.tipo_acta,
     old.acta,
     old.carrera,
     old.legajo,
     old.folio,
     old.renglon,
     old.tipo_inscripcion,
     old.equiv_parcial,
     old.fecha_de_examen,
     old.resultado,
     old.nota,
     old.resultado_2,
     old.nota_2,
     old.vigencia,
     old.plan,
     old.version,
     old.controlado,
     old.rectificado,
     old.estado)
,
-- U820 ***********************************************************************************************************************
-- Llama al procedimiento para actualizar la condición de regularidad en la tabla u820_sga_det_acta
-- U820 ***********************************************************************************************************************
   EXECUTE PROCEDURE spd820_det_acta (
     old.unidad_academica,
     old.tipo_acta,
     old.acta,
     old.carrera,
     old.legajo,
     old.folio,
     old.renglon,
     old.tipo_inscripcion,
     old.equiv_parcial,
     old.fecha_de_examen,
     old.resultado,
     old.nota,
     old.resultado_2,
     old.nota_2,
     old.vigencia,
     old.plan,
     old.version,
     old.controlado,
     old.rectificado,
     old.estado)
);
-- ********** Fin del trigger de Delete td_detalle_acta **********
