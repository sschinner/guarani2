-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version Alfa 6.0
-- Ultima modificacion: version 1.9, 2.0.0
--
-- Tabla sga_detalle_acta
-- Procedure spu_detalle_acta (asociado al trigger de UPDATE)
-- *******************************************************************************

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'spu_detalle_acta ') THEN
		DROP PROCEDURE spu_detalle_acta ;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP PROCEDURE spu_detalle_acta;
 
CREATE PROCEDURE "dba".spu_detalle_acta(
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
       o_estado like sga_detalle_acta.estado,
       n_unidad_academica like sga_detalle_acta.unidad_academica,
       n_tipo_acta like sga_detalle_acta.tipo_acta,
       n_acta like sga_detalle_acta.acta,
       n_carrera like sga_detalle_acta.carrera,
       n_legajo like sga_detalle_acta.legajo,
       n_folio like sga_detalle_acta.folio,
       n_renglon like sga_detalle_acta.renglon,
       n_tipo_inscripcion like sga_detalle_acta.tipo_inscripcion,
       n_equiv_parcial like sga_detalle_acta.equiv_parcial,
       n_fecha_de_examen like sga_detalle_acta.fecha_de_examen,
       n_resultado like sga_detalle_acta.resultado,
       n_nota like sga_detalle_acta.nota,
       n_resultado_2 like sga_detalle_acta.resultado_2,
       n_nota_2 like sga_detalle_acta.nota_2,
       n_vigencia like sga_detalle_acta.vigencia,
       n_plan like sga_detalle_acta.plan,
       n_version like sga_detalle_acta.version,
       n_controlado like sga_detalle_acta.controlado,
       n_rectificado like sga_detalle_acta.rectificado,
       n_estado like sga_detalle_acta.estado)
BEGIN
   -- Impide que se modifique la clave primaria de un registro 
   IF o_unidad_academica <> n_unidad_academica OR
      o_tipo_acta <> n_tipo_acta OR
	  o_acta <> n_acta OR
      o_carrera <> n_carrera OR
      o_legajo <> n_legajo  THEN
      raise exception -746,0,'No se puede modificar la clave primaria de un registro.';
   END IF;

   -- No se puede insertar en sga_detalle_acta si no existe en sga_folios
   -- (CHILD UPDATE RESTRICT) Este control lo lleva el CONSTRAINT

   -------------------------------------------------------------------------------- 
   -- Impide que se modifique el detalle de un acta cerrada
   ---------------------------
----------------------------------------------------- 
   IF EXISTS (SELECT '' FROM sga_actas_examen
               WHERE sga_actas_examen.unidad_academica = o_unidad_academica
                 AND sga_actas_examen.tipo_acta = o_tipo_acta
				AND sga_actas_examen.acta = o_acta
                 AND sga_actas_examen.estado = 'C') THEN
      IF o_tipo_inscripcion <> n_tipo_inscripcion OR
         o_fecha_de_examen <> n_fecha_de_examen OR
         o_equiv_parcial <> n_equiv_parcial OR
		(o_equiv_parcial IS NULL AND n_equiv_parcial IS NOT NULL) OR
           (o_equiv_parcial IS NOT NULL AND n_equiv_parcial IS NULL) OR
         o_resultado <> n_resultado OR
           (o_resultado IS NULL AND n_resultado IS NOT NULL) OR
		(o_resultado IS NOT NULL AND n_resultado IS NULL) OR
         o_nota <> n_nota OR
           (o_nota IS NULL AND n_nota IS NOT NULL) OR
           (o_nota IS NOT NULL AND n_nota IS NULL) OR
         o_resultado_2 <> n_resultado_2 OR
           (o_resultado_2 IS NULL AND n_resultado_2 IS NOT NULL) OR
           (o_resultado_2 IS NOT NULL AND n_resultado_2 IS NULL) OR
         o_nota_2 <> n_nota_2 OR
           (o_nota_2 IS NULL AND n_nota_2 IS NOT NULL) OR
           (o_nota_2 IS NOT NULL AND n_nota_2 IS NULL) OR
         o_plan <> n_plan OR
         o_version <> n_version OR
         o_controlado <> n_controlado  THEN

         RAISE EXCEPTION -746, 0, 'No se pueden modificar los registros de un acta cerrada.';

	-- Si cambia el estado de un registro del acta, que permita cambiarlo a I (Invalido) o N (Anulado)	
	-- OR  ((o_estado <> n_estado)  AND n_estado NOT  IN ( 'N','I','B','A')) THEN

      END IF;
   END IF;
   
   
   ------------------------------------------------------------
-------------------- 
   -- Si cambia la fecha, cambia las fechas de los examenes equivalentes
   -- que tenian declarada la fecha anterior
   -- Tanto para actas Rectificativas y Actas Normales
   ------------------------------------------------------
-------------------------- 
    IF  o_fecha_de_examen <> n_fecha_de_examen THEN
      UPDATE sga_examenes_equiv
         SET sga_examenes_equiv.fecha = n_fecha_de_examen
		 WHERE sga_examenes_equiv.unidad_academica = o_unidad_academica
		   AND sga_examenes_equiv.tipo_acta = o_tipo_acta
		   AND sga_examenes_equiv.acta = o_acta
         AND sga_examenes_equiv.carrera_original = o_carrera
         AND sga_examenes_equiv.legajo_original = o_legajo
         AND sga_examenes_equiv.fecha = o_fecha_de_examen;
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
     n_unidad_academica,
     n_tipo_acta,
     n_acta,
     n_carrera,
     n_legajo,
     n_folio,
     n_renglon,
     n_tipo_inscripcion,
     n_equiv_parcial,
     n_fecha_de_examen,
     n_resultado,
     n_nota,
     n_resultado_2,
     n_nota_2,
 n_vigencia,
     n_plan,
     n_version,
     n_controlado,
     n_rectificado,
     n_estado,
     User,
     Current year to Second,
     'U');
end;
end procedure;

-- ********** Fin del procedure asociado al trigger de UPDATE de sga_detalle_acta **********


-- U820 ***********************************************************************************************************************
-- Procedimiento para actualizar la condición de regularidad en la tabla u820_sga_det_acta
-- U820 ***********************************************************************************************************************
CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'spu820_det_acta') THEN
		DROP PROCEDURE spu820_det_acta;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP PROCEDURE spu820_det_acta ;

CREATE PROCEDURE "dba".spu820_det_acta(
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
        o_estado like sga_detalle_acta.estado,
        n_unidad_academica like sga_detalle_acta.unidad_academica,
        n_tipo_acta like sga_detalle_acta.tipo_acta,
        n_acta like sga_detalle_acta.acta,
		n_carrera like sga_detalle_acta.carrera,
        n_legajo like sga_detalle_acta.legajo,
        n_folio like sga_detalle_acta.folio,
        n_renglon like sga_detalle_acta.renglon,
        n_tipo_inscripcion like sga_detalle_acta.tipo_inscripcion,
        n_equiv_parcial like sga_detalle_acta.equiv_parcial,
        n_fecha_de_examen like sga_detalle_acta.fecha_de_examen,
        n_resultado like sga_detalle_acta.resultado,
        n_nota like sga_detalle_acta.nota,
        n_resultado_2 like sga_detalle_acta.resultado_2,
        n_nota_2 like sga_detalle_acta.nota_2,
        n_vigencia like sga_detalle_acta.vigencia,
        n_plan like sga_detalle_acta.plan,
        n_version like sga_detalle_acta.version,
        n_controlado like sga_detalle_acta.controlado,
        n_rectificado like sga_detalle_acta.rectificado,
        n_estado like sga_detalle_acta.estado)

--   -------------------------------------------------------------------------------- 
--   -- CODIGO PERSONALIZADO

DEFINE n_condicion_reg integer;

BEGIN
-- U820 ***********************************************************************************************************************
-- Calcula la condición actual del alumno
-- U820 ***********************************************************************************************************************
EXECUTE PROCEDURE sp820_cond_reg (n_tipo_acta, n_acta, n_legajo) INTO n_condicion_reg;
IF (n_tipo_inscripcion = "L" and n_condicion_reg in (1, 2, 8)) or (n_tipo_inscripcion = "R" and n_condicion_reg in (4, 7, 9, 10))
THEN
	update u820_sga_det_acta
	set condicion_reg = n_condicion_reg
	where unidad_academica = n_unidad_academica
		and tipo_acta = n_tipo_acta
		and acta = n_acta
		and carrera = n_carrera
		and legajo = n_legajo;
ELSE
	update u820_sga_det_acta
	set condicion_reg = case when n_tipo_inscripcion = "L" then 1 else 4 end
	where unidad_academica = n_unidad_academica
		and tipo_acta = n_tipo_acta
		and acta = n_acta
		and carrera = n_carrera
		and legajo = n_legajo;
END IF;

--   -------------------------------------------------------------------------------- 

END;
END PROCEDURE; 

-- **** Fin del procedure personalizado asociado al trigger de UPDATE de sga_detalle_acta ****
-- *******************************************************************************

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 1.8.0
-- Tabla sga_detalle_acta
-- Trigger de Update tu_detalle_acta
-- *******************************************************************************
CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
  IF EXISTS (SELECT trigid
      FROM systriggers
      WHERE trigname = 'tu_detalle_acta') THEN
    DROP TRIGGER tu_detalle_acta;
  END IF;   
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

CREATE TRIGGER tu_detalle_acta UPDATE on sga_detalle_acta
referencing old as old new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spu_detalle_acta (
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
     old.estado,
     new.unidad_academica,
     new.tipo_acta,
     new.acta,
     new.carrera,
     new.legajo,
     new.folio,
     new.renglon,
     new.tipo_inscripcion,
     new.equiv_parcial,
     new.fecha_de_examen,
     new.resultado,
     new.nota,
     new.resultado_2,
     new.nota_2,
     new.vigencia,
     new.plan,
     new.version,
     new.controlado,
     new.rectificado,
     new.estado)
,
-- U820 ***********************************************************************************************************************
-- Llama al procedimiento para actualizar la condición de regularidad en la tabla u820_sga_det_acta
-- U820 ***********************************************************************************************************************

   EXECUTE PROCEDURE spu820_det_acta (
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
     old.estado,
     new.unidad_academica,
     new.tipo_acta,
     new.acta,
     new.carrera,
     new.legajo,
     new.folio,
     new.renglon,
     new.tipo_inscripcion,
     new.equiv_parcial,
     new.fecha_de_examen,
     new.resultado,
     new.nota,
     new.resultado_2,
     new.nota_2,
     new.vigencia,
     new.plan,
     new.version,
     new.controlado,
     new.rectificado,
     new.estado)
);
-- ********** Fin del trigger de Update tu_detalle_acta **********
