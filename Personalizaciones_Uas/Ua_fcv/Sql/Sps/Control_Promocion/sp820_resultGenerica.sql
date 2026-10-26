CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_resultgenerica') THEN
		DROP PROCEDURE sp820_resultgenerica;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.11.0, 2.9.1
-- Version Origen: 1.8.0
--
-- Procedure sp820_resultGenerica
-- 
-- Verifica si una Materia Generica esta aprobada. 
-- Retorna:  A - Aprobo
--           R - No Aprobo la Mat. Generica
-- *******************************************************************************
CREATE PROCEDURE "dba".sp820_resultgenerica( pUA like "dba".sga_alumnos.unidad_academica, pCarrera like "dba".sga_alumnos.carrera, pLegajo like "dba".sga_alumnos.legajo, pTitulo like "dba".sga_titulos.titulo, pOrient like "dba".sga_orientaciones.orientacion, pMateriaGenerica like "dba".sga_materias.materia  )
       RETURNING char (1); -- sga_cond_regular.resultado

   DEFINE vcResultado		like sga_cond_regular.resultado; 
   DEFINE vcPlan			like sga_versiones_plan.plan;
   DEFINE vcVersion			like sga_versiones_plan.version;
   DEFINE vcMateriaOptativa	like sga_materias.materia;
   DEFINE lPuntos			like sga_mat_genericas.valor_materia;
   DEFINE lTotalPuntos		like sga_mat_genericas.valor_materia;
   DEFINE lPuntosRequeridos	like sga_materias.puntaje_requerido ;
   DEFINE existe_hist		char(1);

BEGIN
   EXECUTE PROCEDURE sp_plan_de_alumno (pUA, pCarrera, pLegajo, today) INTO vcPlan, vcVersion ;

-- Verifico si existen materias Aprobadas por el Alumno

IF (SELECT COUNT(*)
	    FROM vw_hist_academica h
	       WHERE  h.unidad_academica = pUA  
	         AND h.carrera = pCarrera 
	         AND h.legajo = pLegajo
		AND h.resultado <> 'R' ) > 0 THEN

   -- *********************************************************************************************************
   --
   -- Lee las optativas seleccionadas para la generica a nivel de alumno y orientacion ...
   --
   -- *********************************************************************************************************

   LET lTotalPuntos = 0;
   LET lPuntos = 0;
   LET lPuntosRequeridos = 0 ;
   LET vcResultado = 'R';

   SELECT mat.puntaje_requerido
     INTO lPuntosRequeridos
     FROM "dba".sga_materias mat
    WHERE mat.materia = pMateriaGenerica ;

   IF lPuntosRequeridos IS NULL THEN
      LET lPuntosRequeridos = 100;
   END IF ;
 
   FOREACH 
    SELECT ge.valor_materia, op.materia_optativa
      INTO lPuntos, vcMateriaOptativa
      FROM sga_opt_gen_orie_a op,
           sga_mat_genericas ge
     WHERE op.unidad_academica = pUA
       AND op.carrera = pCarrera
       AND op.legajo = pLegajo
       AND op.plan = vcPlan
       AND op.version = vcVersion
       AND op.titulo = pTitulo
       AND op.orientacion = pOrient
       AND op.materia_generica = pMateriaGenerica
       AND op.unidad_academica = ge.unidad_academica
       AND op.materia_generica = ge.materia_generica
       AND op.materia_optativa = ge.materia_optativa

      -- Busco las optativas de la generica y veo la nota del alumno para luego sumar los putnos ....
	IF (SELECT COUNT(*)
	    FROM vw_hist_academica h
	       WHERE  h.unidad_academica = pUA  
	         AND h.carrera = pCarrera 
	         AND h.legajo = pLegajo
		AND h.materia =  vcMateriaOptativa
		AND h.resultado <> 'R' ) > 0 THEN
		LET lTotalPuntos = lTotalPuntos + lPuntos ;
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
      FROM sga_opt_gen_alumno op, 
           sga_mat_genericas ge
     WHERE op.unidad_academica = pUA
       AND op.carrera = pCarrera
       AND op.legajo = pLegajo
       AND op.plan = vcPlan
       AND op.version = vcVersion
       AND op.materia_generica = pMateriaGenerica
       AND op.unidad_academica = ge.unidad_academica
       AND op.materia_generica = ge.materia_generica
       AND op.materia_optativa = ge.materia_optativa
       AND NOT EXISTS ( -- Que no exista la politica para el alumno en la orientacion
          SELECT op_alu.materia_optativa
            FROM sga_opt_gen_orie_a op_alu
           WHERE op_alu.unidad_academica = op.unidad_academica
             AND op_alu.carrera = op.carrera
             AND op_alu.legajo = pLegajo
             AND op_alu.materia_optativa = op.materia_optativa
--             AND op_alu.materia_generica = op.materia_generica
             AND op_alu.plan = op.plan
             AND op_alu.version = op.version 
             AND op_alu.titulo = pTitulo
             AND op_alu.orientacion = pOrient )

      -- Busco las optativas de la generica y veo la nota del alumno para luego sumar los putnos ....
	IF (SELECT COUNT(*)
	    FROM vw_hist_academica h
	       WHERE  h.unidad_academica = pUA  
	         AND h.carrera = pCarrera 
	         AND h.legajo = pLegajo
		AND h.materia =  vcMateriaOptativa
		AND h.resultado <> 'R' ) > 0 THEN
		LET lTotalPuntos = lTotalPuntos + lPuntos ;
	END IF;



   END FOREACH;

   -- *********************************************************************************************************
   --
   -- Ahora lee las optativas seleccionadas a nivel general por orientacion, que no esten en la de alumnos pero por orientacion
   --
   -- *********************************************************************************************************

   FOREACH 
    SELECT ge.valor_materia, op.materia_optativa
      INTO lPuntos, vcMateriaOptativa
      FROM sga_opt_gen_orie op, 
           sga_mat_genericas ge
     WHERE op.unidad_academica = pUA
       AND op.carrera = pCarrera
       AND op.plan = vcPlan
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
            FROM sga_opt_gen_orie_a op_alu1
           WHERE op_alu1.unidad_academica = op.unidad_academica
             AND op_alu1.carrera = op.carrera
             AND op_alu1.legajo  = pLegajo
             AND op_alu1.materia_optativa = op.materia_optativa
--             AND op_alu1.materia_generica = op.materia_generica
             AND op_alu1.plan    = op.plan
             AND op_alu1.version = op.version 
             AND op_alu1.titulo  = pTitulo
             AND op_alu1.orientacion = pOrient )
       AND NOT EXISTS ( 
          -- Que no exista la polítita para el alumno en la carrera, plan, version
          SELECT op_alu2.materia_optativa
            FROM sga_opt_gen_alumno op_alu2
           WHERE op_alu2.unidad_academica = op.unidad_academica
             AND op_alu2.carrera = op.carrera
             AND op_alu2.legajo = pLegajo
             AND op_alu2.materia_optativa = op.materia_optativa
--             AND op_alu2.materia_generica = op.materia_generica
             AND op_alu2.plan = op.plan
             AND op_alu2.version = op.version )

      -- Busco las optativas de la generica y veo la nota del alumno para luego sumar los putnos ....
	IF (SELECT COUNT(*)
	    FROM vw_hist_academica h
	       WHERE  h.unidad_academica = pUA  
	         AND h.carrera = pCarrera 
	         AND h.legajo = pLegajo
		AND h.materia =  vcMateriaOptativa
		AND h.resultado <> 'R' ) > 0 THEN
		LET lTotalPuntos = lTotalPuntos + lPuntos ;
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
      FROM sga_opt_generica op, 
	 sga_mat_genericas ge
     WHERE op.unidad_academica = pUA
       AND op.carrera = pCarrera
       AND op.plan = vcPlan
       AND op.version = vcVersion
       AND op.materia_generica = pMateriaGenerica
       AND op.unidad_academica = ge.unidad_academica
       AND op.materia_generica = ge.materia_generica
       AND op.materia_optativa = ge.materia_optativa
       AND NOT EXISTS ( 
          -- Que no exista la politica para el alumno en la carrera, plan, version, titulo, orientacion
          SELECT opg_alu.materia_optativa
            FROM sga_opt_gen_orie_a opg_alu
           WHERE opg_alu.unidad_academica = op.unidad_academica
             AND opg_alu.carrera = op.carrera
             AND opg_alu.legajo = pLegajo
             AND opg_alu.materia_optativa = op.materia_optativa
--             AND opg_alu.materia_generica = op.materia_generica
             AND opg_alu.plan = op.plan
             AND opg_alu.version = op.version 
             AND opg_alu.titulo = pTitulo
             AND opg_alu.orientacion = pOrient )
       AND NOT EXISTS ( 
          -- Que no exista la polítita para el alumno en la carrera, plan, version
          SELECT op_alu3.materia_optativa
            FROM sga_opt_gen_alumno op_alu3
           WHERE op_alu3.unidad_academica = op.unidad_academica
             AND op_alu3.carrera = op.carrera
             AND op_alu3.legajo = pLegajo
             AND op_alu3.materia_optativa = op.materia_optativa
  --           AND op_alu3.materia_generica = op.materia_generica
             AND op_alu3.plan = op.plan
             AND op_alu3.version = op.version )
       AND NOT EXISTS ( 


          -- Que no exista la politica para la UA en la carrera, plan, version, titulo, orientacion
          SELECT op1.materia_optativa
            FROM sga_opt_gen_orie op1
           WHERE op1.unidad_academica = op.unidad_academica
             AND op1.carrera = op.carrera
             AND op1.materia_optativa = op.materia_optativa
  --           AND op1.materia_generica = op.materia_generica
             AND op1.plan    = op.plan
             AND op1.version = op.version 
             AND op1.titulo  = pTitulo
             AND op1.orientacion = pOrient )

      -- Busco las optativas de la generica y veo la nota del alumno para luego sumar los putnos ....
	IF (SELECT COUNT(*)
	    FROM vw_hist_academica h
	       WHERE  h.unidad_academica = pUA  
	         AND h.carrera = pCarrera 
	         AND h.legajo = pLegajo
		AND h.materia =  vcMateriaOptativa
		AND h.resultado <> 'R' ) > 0 THEN
		LET lTotalPuntos = lTotalPuntos + lPuntos ;
	END IF;
         
   END FOREACH;

   -- Analiza si la genercia esta aprobada en funcion de los puntos.

   IF lTotalPuntos >= lPuntosRequeridos THEN 
      LET vcResultado = 'A';
   END IF;

END IF;

   RETURN vcResultado;
END;
END PROCEDURE;
-- ++++++++++++++++++++++++ FIN PROCEDURE sp820_resultGenerica ++++++++++++++++++++++++ 

revoke execute on "dba".sp820_resultGenerica from public;
grant execute on "dba".sp820_resultGenerica to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_resultGenerica to internet; -- Rol de usuario de Internet

