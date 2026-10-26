-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 1.9.0
-- Tabla sga_detalle_acta
-- Procedure spi_detalle_acta (asociado al trigger de INSERT)
-- *******************************************************************************

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'spi_detalle_acta') THEN
		DROP PROCEDURE spi_detalle_acta;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP PROCEDURE spi_detalle_acta ;
CREATE PROCEDURE "dba".spi_detalle_acta(
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
      DEFINE v_materia like sga_actas_examen.materia;
      DEFINE v_estado_acta LIKE sga_actas_examen.estado; 

   -- No se puede insertar en sga_detalle_acta si no existe en sga_folios
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- Selecciono el estado y la materia de la cabecera del Acta
   SELECT estado, materia 
     INTO v_estado_acta, v_materia 
     FROM sga_actas_examen
    WHERE unidad_academica = n_unidad_academica
      AND tipo_acta = n_tipo_acta
      AND acta = n_acta;

   -- Impide que se agreguen registros en el detalle de un acta cerrada
   IF v_estado_acta = 'C' THEN
      raise exception -746, 0, 'No se pueden insertar registros en el detalle de un acta cerrada.';
   END IF;

   -- No se puede insertar en sga_detalle_acta si no existe en sga_alumnos
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_detalle_acta si no existe en sga_versiones_plan
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- Si las materias rendidas son validas para todas las carreras que cursa el alumno,
   -- genera un registro para cada carrera en la tabla sga_examenes_equiv
   BEGIN
      DEFINE v_equiv like sga_param_sistema.valor;
      DEFINE v_acta_referencia like sga_actas_examen.acta_referencia;
      DEFINE v_nuevo char(1);
      DEFINE v_cantidad integer;

--      LET v_nuevo = 'N';
--      -- Si se trata de un acta rectificativa, se fija si el alumno ya estaba en el acta original o no
--      IF n_tipo_acta <> 'N' THEN
--         -- Busca el acta de referencia
--         SELECT sga_actas_examen.acta_referencia
--           INTO v_acta_referencia
--       FROM sga_actas_examen
--          WHERE sga_actas_examen.unidad_academica = n_unidad_academica
--            AND sga_actas_examen.tipo_acta = n_tipo_acta
--            AND sga_actas_examen.acta = n_acta;
--
--         -- Se fija si el alumno ya estaba en el acta
--         SELECT count(*)  INTO v_cantidad
--           FROM sga_detalle_acta
--          WHERE sga_detalle_acta.unidad_academica = n_unidad_academica
--            AND sga_detalle_acta.tipo_acta = 'N'
--            AND sga_detalle_acta.acta = v_acta_referencia
--            AND sga_detalle_acta.carrera = n_carrera
--            AND sga_detalle_acta.legajo = n_legajo;
--
--         IF v_cantidad = 0 THEN
--            LET v_nuevo = 'S';
--         END IF;
--      END IF;


     Execute procedure sp_param_sistema ('examen_vale_en_todas_las_carreras') INTO v_equiv;
      LET v_equiv = UPPER(v_equiv);
     -- Antes solo insertaba si era un acta normal o en el caso de que sea rectificativa solo si era un registro nuevo:  (n_tipo_acta = 'N' OR v_nuevo = 'S') 
     -- Agrega un registro en la tabla sga_examenes_equiv, por cada carrera en que el alumno esta inscripto, sea un acta normal o rectificativa.
     -- siempre y cuando la materia exista en los planes actuales del Alumno en las otras carreras....
     IF v_equiv = 'S'  THEN
         BEGIN
            DEFINE v_unidad_academica like sga_atrib_mat_plan.unidad_academica;
            DEFINE v_carrera like sga_atrib_mat_plan.carrera;
            DEFINE v_legajo like sga_alumnos.legajo;
            DEFINE v_plan like sga_atrib_mat_plan.plan;
            DEFINE v_version like sga_atrib_mat_plan.version;
            DEFINE v_aux like sga_carreras.nombre;
            DEFINE v_cantidad integer;
              


 FOREACH EXECUTE PROCEDURE sp_alucarrerasinsc (n_unidad_academica, n_legajo, n_carrera)
               INTO v_unidad_academica, v_carrera, v_legajo, v_plan, v_version, v_aux
               BEGIN
                  IF v_carrera <> n_carrera THEN

             -- Verifica si la materia existe en el plan
                     SELECT count(*)  INTO v_cantidad
                       FROM sga_atrib_mat_plan
                      WHERE sga_atrib_mat_plan.unidad_academica = v_unidad_academica

               AND sga_atrib_mat_plan.carrera = v_carrera
                        AND sga_atrib_mat_plan.plan = v_plan
                        AND sga_atrib_mat_plan.version = v_version
                        AND sga_atrib_mat_plan.materia = v_materia;


                     IF v_cantidad = 1 THEN
                        -- Si existe, crea el registro en sga_examenes_equiv
                        INSERT INTO sga_examenes_equiv
		(unidad_academica, tipo_acta, acta, carrera, legajo, carrera_original,legajo_original,
		 fecha, plan, version, origen, estado) 
                        VALUES (v_unidad_academica, n_tipo_acta, n_acta, v_carrera, v_legajo, n_carrera, n_legajo,
                                n_fecha_de_examen, v_plan, v_version, 'S', 'A');
                     END IF ;
                  END IF ;
               END;
            END FOREACH;
         END;
      END IF;
   END;

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
     'I');
END;
END PROCEDURE;

-- ********** Fin del procedure asociado al trigger de INSERT de sga_detalle_acta **********


-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Personalización UNL Version 1.00
-- Tabla sga_detalle_acta
-- Procedure spi820_det_acta (asociado al trigger de INSERT)
-- *******************************************************************************
-- U820 ***********************************************************************************************************************
-- Procedimiento para actualizar la condición de regularidad en la tabla u820_sga_det_acta
-- U820 ***********************************************************************************************************************

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'spi820_det_acta') THEN
		DROP PROCEDURE spi820_det_acta;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP PROCEDURE spi820_det_acta ;
CREATE PROCEDURE "dba".spi820_det_acta(
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

IF n_tipo_inscripcion = "L" THEN
	INSERT INTO u820_sga_det_acta VALUES (n_unidad_academica, n_tipo_acta, n_acta, n_carrera, n_legajo, 1);
ELSE
	-- U820 ***********************************************************************************************************************
	-- Calcula la condición actual del alumno
	-- U820 ***********************************************************************************************************************
	EXECUTE PROCEDURE sp820_cond_reg (n_tipo_acta, n_acta, n_legajo) INTO n_condicion_reg;
	INSERT INTO u820_sga_det_acta VALUES (n_unidad_academica, n_tipo_acta,  n_acta, n_carrera,n_legajo, n_condicion_reg);

END IF;

--   -------------------------------------------------------------------------------- 

 END;
 END PROCEDURE;

-- **** Fin del procedure personalizado asociado al trigger de INSERT de sga_detalle_acta ****

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 1.8.0
-- Ultima Modificacion : Version 1.9
--
-- Tabla sga_detalle_acta
-- Trigger de Insert ti_detalle_acta
-- *******************************************************************************

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigid
			FROM systriggers
			WHERE trigname = 'ti_detalle_acta') THEN
		DROP TRIGGER ti_detalle_acta;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP TRIGGER ti_detalle_acta ;
CREATE TRIGGER ti_detalle_acta INSERT on sga_detalle_acta
referencing new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spi_detalle_acta (
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

   EXECUTE PROCEDURE spi820_det_acta (
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
-- ********** Fin del trigger de Insert ti_detalle_acta **********
