CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_resultgenerica') THEN
		DROP PROCEDURE sp_resultgenerica;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Procedure sp_resultGenerica
-- Version Origen: 1.8.0
-- Version modificacion: 1.11.0, 2.6.0
--
-- Verifica si una Materia Generica esta aprobada.
-- Suma los créditos de las materias optativas aprobadas (Para títulos por Créditos)
--
-- Retorna:  char(1) = A - Aprobo / R - No Aprobo la Mat. Generica
--           integer = sumatoria de los créditos de las optativas aprobadas
--  Tablas: sga_opt_gen_alumno y sga_opt_gen_orie_a  son las tablas relacionadas con el 
--  alumno y que indican que la optativa que aprobo el alumno cumple para otra generica y no la 
--  que esta por default en el plan (sga_opt_generica, sga_opt_gen_orie. 
--
-- *******************************************************************************

CREATE PROCEDURE "dba".sp_resultGenerica(
	pUA like "dba".sga_alumnos.unidad_academica,
	pCarrera like "dba".sga_alumnos.carrera,
	pLegajo like "dba".sga_alumnos.legajo,
	pTitulo like "dba".sga_titulos.titulo,
	pOrient like "dba".sga_orientaciones.orientacion,
	pMateriaGenerica like "dba".sga_materias.materia  )
       RETURNING char(1), INTEGER;
/* Retorna:
        - Resultado: A - Aprobo, R - No aprobo la mat generica
        - Sumatoria de los creditos de las materias optativas
 */

   DEFINE vcResultado		like sga_cond_regular.resultado;
   DEFINE vcPlan			like sga_versiones_plan.plan;
   DEFINE vcVersion		like sga_versiones_plan.version;
   DEFINE vcMateriaOptativa	like sga_materias.materia;
   DEFINE lPuntos			like sga_mat_genericas.valor_materia;
   DEFINE lTotalPuntos		like sga_mat_genericas.valor_materia;
   DEFINE lPuntosRequeridos	like sga_materias.puntaje_requerido ;
   DEFINE iCreditosMatOpt, iTotCreditos      like sga_atrib_mat_plan.credito;
   DEFINE dFechaActual      DATE;

BEGIN
   LET dFechaActual = TODAY;
   EXECUTE PROCEDURE sp_plan_de_alumno (pUA, pCarrera, pLegajo, dFechaActual) INTO vcPlan, vcVersion ;

   BEGIN
	ON EXCEPTION IN (-206)
	    -- Tabla no existe continuo el proceso
	END EXCEPTION WITH RESUME;
	DROP TABLE tmp_hist_acad;
   END;

    -- Creo tabla temporal
    CREATE TEMP TABLE tmp_hist_acad (materia varchar(5), resultado char(1)) WITH NO LOG;

    -- Recupero las materias Aprobadas por el Alumno
    INSERT INTO tmp_hist_acad (materia, resultado)
      SELECT h.materia, h.resultado
    FROM vw_hist_academica as h
	WHERE  h.unidad_academica = pUA
	AND h.carrera = pCarrera
	AND h.legajo = pLegajo ;

   -- *********************************************************************************************************
   --
   -- Lee las optativas seleccionadas para la generica a nivel de alumno y orientacion ...
   --
   -- *********************************************************************************************************

   LET lTotalPuntos = 0;
   LET lPuntos = 0;
   LET lPuntosRequeridos = 0 ;
   LET iTotCreditos = 0;
   LET iCreditosMatOpt = 0;

   SELECT puntaje_requerido
     INTO lPuntosRequeridos
     FROM sga_materias
     WHERE  unidad_academica = pUA
     AND materia = pMateriaGenerica ;

   IF lPuntosRequeridos IS NULL THEN
      LET lPuntosRequeridos = 100;
   END IF ;

   FOREACH
    SELECT ge.valor_materia, op.materia_optativa
      INTO lPuntos, vcMateriaOptativa
      FROM sga_opt_gen_orie_a as op,
           sga_mat_genericas as ge
     WHERE op.unidad_academica = pUA
       AND op.carrera = pCarrera
       AND op.legajo   = pLegajo
-- ++++++++++++++++++++++++++++++++++
-- sacado en version 2.6.0
--       AND op.plan = vcPlan
--       AND op.version = vcVersion
-- ++++++++++++++++++++++++++++++++++
       AND op.titulo = pTitulo
       AND op.orientacion = pOrient
       AND op.materia_generica = pMateriaGenerica
       AND op.unidad_academica = ge.unidad_academica
       AND op.materia_generica = ge.materia_generica
       AND op.materia_optativa = ge.materia_optativa

      -- Busco las optativas de la generica y veo la nota del alumno para luego sumar los puntos ....
      IF (SELECT COUNT(*) FROM tmp_hist_acad
	WHERE materia = vcMateriaOptativa
	AND resultado = 'A' ) > 0 THEN

	LET lTotalPuntos = lTotalPuntos + lPuntos ;

        -- Recupero los creditos de la materia en el Plan-Version
        LET 	iCreditosMatOpt = 0;
        SELECT credito INTO iCreditosMatOpt
            FROM sga_atrib_mat_plan
            WHERE unidad_academica = pUA
            AND carrera = pCarrera
            AND plan = vcPlan
            AND version = vcVersion
            AND materia = vcMateriaOptativa;
        LET iTotCreditos = iTotCreditos + iCreditosMatOpt;
      END IF;

   END FOREACH;

   -- *********************************************************************************************************
   --
   -- Lee las optativas seleccionadas para la generica a nivel de alumno (para cualquier orientación)
   -- Siempre que no exista la regla específica para la orientación.
   --
   -- *********************************************************************************************************

   FOREACH
    SELECT ge.valor_materia, op.materia_optativa
      INTO lPuntos, vcMateriaOptativa
      FROM sga_opt_gen_alumno as op,
           sga_mat_genericas as ge
     WHERE op.unidad_academica = pUA
       AND op.carrera = pCarrera
       AND op.legajo = pLegajo
-- ++++++++++++++++++++++++++++++++++
-- sacado en version 2.6.0
--       AND op.plan = vcPlan
--       AND op.version = vcVersion
-- ++++++++++++++++++++++++++++++++++
       AND op.materia_generica = pMateriaGenerica
       AND op.unidad_academica = ge.unidad_academica
       AND op.materia_generica = ge.materia_generica
       AND op.materia_optativa = ge.materia_optativa

       -- Que no exista la politica para el alumno en la orientacion
       AND NOT EXISTS (
          SELECT op_alu.materia_optativa
            FROM sga_opt_gen_orie_a as op_alu
           WHERE op_alu.unidad_academica = op.unidad_academica
             AND op_alu.carrera = op.carrera
             AND op_alu.legajo = pLegajo
             AND op_alu.materia_optativa = op.materia_optativa
-- ++++++++++++++++++++++++++++++++++
-- sacado en version 2.6.0
--            AND op_alu.plan = op.plan
--            AND op_alu.version = op.version
-- ++++++++++++++++++++++++++++++++++
             AND op_alu.titulo = pTitulo
             AND op_alu.orientacion = pOrient )

      -- Busco las optativas de la generica y veo la nota del alumno para luego sumar los putnos ....
      IF (SELECT COUNT(*) FROM tmp_hist_acad
	WHERE materia = vcMateriaOptativa
	AND resultado = 'A' ) > 0 THEN

	LET lTotalPuntos = lTotalPuntos + lPuntos ;
	-- Recupero los creditos de la materia en el Plan-Version
	LET iCreditosMatOpt = 0;
	SELECT credito INTO iCreditosMatOpt
	   FROM sga_atrib_mat_plan
	   WHERE unidad_academica = pUA
	   AND carrera = pCarrera
	   AND plan = vcPlan
	   AND version = vcVersion
	   AND materia = vcMateriaOptativa;
	LET iTotCreditos = iTotCreditos + iCreditosMatOpt;
     END IF;

   END FOREACH; -- Optativas Alumno

   -- *********************************************************************************************************
   --
   -- Ahora lee las optativas seleccionadas a nivel general por orientacion, que no esten en la de alumnos pero por orientacion
   --
   -- *********************************************************************************************************

   FOREACH
    SELECT ge.valor_materia, op.materia_optativa
      INTO lPuntos, vcMateriaOptativa
      FROM sga_opt_gen_orie as op,
           sga_mat_genericas as ge
     WHERE op.unidad_academica = pUA
       AND op.carrera = pCarrera
       AND op.plan      = vcPlan
       AND op.version = vcVersion
       AND op.materia_generica = pMateriaGenerica
       AND op.unidad_academica = ge.unidad_academica
       AND op.materia_generica = ge.materia_generica
       AND op.materia_optativa = ge.materia_optativa
       AND op.titulo = pTitulo
       AND op.orientacion = pOrient

       AND NOT EXISTS (
           -- Que no exista la politica para el alumno en la carrera, plan, version, titulo, orientacion
          SELECT op_alu1.materia_optativa
            FROM sga_opt_gen_orie_a as op_alu1
           WHERE op_alu1.unidad_academica = op.unidad_academica
             AND op_alu1.carrera  = op.carrera
             AND op_alu1.legajo    = pLegajo
             AND op_alu1.materia_optativa = op.materia_optativa
-- ++++++++++++++++++++++++++++++++++
-- Sacado en version 2.6.0
--             AND op_alu1.plan    = op.plan
--             AND op_alu1.version = op.version
-- ++++++++++++++++++++++++++++++++++
             AND op_alu1.titulo  = pTitulo
             AND op_alu1.orientacion = pOrient )

       AND NOT EXISTS (
          -- Que no exista la polítita para el alumno en la carrera, plan, version
          SELECT op_alu2.materia_optativa
            FROM sga_opt_gen_alumno as op_alu2
           WHERE op_alu2.unidad_academica = op.unidad_academica
             AND op_alu2.carrera = op.carrera
             AND op_alu2.legajo = pLegajo
             AND op_alu2.materia_optativa = op.materia_optativa
-- ++++++++++++++++++++++++++++++++++
-- Sacado en version 2.6.0
--             AND op_alu2.plan = op.plan
--             AND op_alu2.version = op.version)
-- ++++++++++++++++++++++++++++++++++
                    )

      -- Busco las optativas de la generica y veo la nota del alumno para luego sumar los putnos ....
      IF (SELECT COUNT(*) FROM tmp_hist_acad
	WHERE materia = vcMateriaOptativa
	AND resultado = 'A' ) > 0 THEN

	LET lTotalPuntos = lTotalPuntos + lPuntos ;

	-- Recupero los creditos de la materia en el Plan-Version
	LET iCreditosMatOpt = 0;
	SELECT credito INTO iCreditosMatOpt
	   FROM sga_atrib_mat_plan
	   WHERE unidad_academica = pUA
	   AND carrera = pCarrera
	   AND plan = vcPlan
	   AND version = vcVersion
	   AND materia = vcMateriaOptativa;

	LET iTotCreditos = iTotCreditos + iCreditosMatOpt;
     END IF;

   END FOREACH;

   -- *********************************************************************************************************
   --
   -- Ahora lee las optativas seleccionadas a nivel general, que no esten en la de alumnos
   --
   -- *********************************************************************************************************

   FOREACH
    SELECT ge.valor_materia, op.materia_optativa
      INTO lPuntos, vcMateriaOptativa
      FROM sga_opt_generica as op,
     sga_mat_genericas as ge
     WHERE op.unidad_academica = pUA
       AND op.carrera = pCarrera
       AND op.plan      = vcPlan
       AND op.version = vcVersion
       AND op.materia_generica = pMateriaGenerica
       AND op.unidad_academica = ge.unidad_academica
       AND op.materia_generica = ge.materia_generica
       AND op.materia_optativa = ge.materia_optativa
       AND NOT EXISTS (
          -- Que no exista la politica para el alumno en la carrera, plan, version, titulo, orientacion
          SELECT opg_alu.materia_optativa
            FROM sga_opt_gen_orie_a as opg_alu
           WHERE opg_alu.unidad_academica = op.unidad_academica
             AND opg_alu.carrera = op.carrera
             AND opg_alu.legajo = pLegajo
             AND opg_alu.materia_optativa = op.materia_optativa
-- ++++++++++++++++++++++++++++++++++
-- Sacado en version 2.6.0
--             AND opg_alu.plan = op.plan
--             AND opg_alu.version = op.version
-- ++++++++++++++++++++++++++++++++++
             AND opg_alu.titulo = pTitulo
             AND opg_alu.orientacion = pOrient )
       AND NOT EXISTS (
          -- Que no exista la política para el alumno en la carrera, plan, version
          SELECT op_alu3.materia_optativa
            FROM sga_opt_gen_alumno as op_alu3
           WHERE op_alu3.unidad_academica = op.unidad_academica
             AND op_alu3.carrera = op.carrera
             AND op_alu3.legajo = pLegajo
             AND op_alu3.materia_optativa = op.materia_optativa
-- ++++++++++++++++++++++++++++++++++
-- Sacado en version 2.6.0
--             AND op_alu3.plan = op.plan
--             AND op_alu3.version = op.version)
-- ++++++++++++++++++++++++++++++++++
                )
       AND NOT EXISTS (

          -- Que no exista la politica para la UA en la carrera, plan, version, titulo, orientacion
          SELECT op1.materia_optativa
            FROM sga_opt_gen_orie as op1
           WHERE op1.unidad_academica = op.unidad_academica
             AND op1.carrera = op.carrera
             AND op1.materia_optativa = op.materia_optativa
             AND op1.plan      = op.plan
             AND op1.version = op.version
             AND op1.titulo  = pTitulo
             AND op1.orientacion = pOrient )

      -- Busco las optativas de la generica y veo la nota del alumno para luego sumar los putnos ....
      IF (SELECT COUNT(*) FROM tmp_hist_acad
	WHERE materia = vcMateriaOptativa
	AND resultado = 'A' ) > 0 THEN

	LET lTotalPuntos = lTotalPuntos + lPuntos ;

	-- Recupero los creditos de la materia en el Plan-Version
	LET iCreditosMatOpt = 0;
	SELECT credito INTO iCreditosMatOpt
	   FROM sga_atrib_mat_plan
	   WHERE unidad_academica = pUA
	   AND carrera = pCarrera
	   AND plan = vcPlan
	   AND version = vcVersion
	   AND materia = vcMateriaOptativa;

	   LET iTotCreditos = iTotCreditos + iCreditosMatOpt;
     END IF;
   END FOREACH; -- Materia optativas de la Materia Genérica.

   -- Analiza si la generica esta aprobada en funcion de los puntos.
   LET vcResultado = 'R';
   IF lTotalPuntos >= lPuntosRequeridos THEN
      LET vcResultado = 'A';
   END IF;

   BEGIN
	ON EXCEPTION IN (-206)
	    -- Tabla no existe continuo el proceso
	END EXCEPTION WITH RESUME;
	DROP TABLE tmp_hist_acad;
   END;

   -- Retorno el Resultado y el total de puntos de las optativas.
   RETURN vcResultado, lTotalPuntos;
END;
END PROCEDURE;
-- *************** Fin del procedimiento "dba".sp_resultGenerica ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_resultGenerica 
-- *****************************************************************************
revoke execute on "dba".sp_resultGenerica from public;
grant execute on "dba".sp_resultGenerica to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_resultGenerica to internet; -- Rol de usuario de Internet

-- *************************** Pruebas de ejecucion **********************************
-- EXECUTE PROCEDURE "dba".sp_resultGenerica ('FBCB', '0302', '34147851-6', null, null, '25001');