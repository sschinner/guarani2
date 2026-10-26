-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.11.0, 
-- Ultima version de modificacion: 2.05.0, 2.6.0
--
-- Procedure sp_ciclo_aprobado
-- 
-- Verifica si un Ciclo esta aprobado. 
-- Este sp usa la tabla temporal "tmp_ha_titulos" que fue creada en el sp que llama a este sp.
-- *******************************************************************************

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_ciclo_aprobado') THEN
		DROP PROCEDURE sp_ciclo_aprobado;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

CREATE PROCEDURE sp_ciclo_aprobado( pUA like sga_alumnos.unidad_academica, pCarrera like sga_alumnos.carrera, pLegajo like sga_alumnos.legajo, pCiclo like sga_materias_ciclo.ciclo , ptitulo LIKE sga_titulos.titulo, porientacion LIKE sga_orientaciones.orientacion, pEgreso LIKE sga_titulos_plan.calculo_egreso, pRespuesta char(1)  )

	-- Este procedure retorna una lista con las materias que el alumno tiene pendientes para completar el ciclo especificado.

  RETURNING 	varchar(5),		-- Ciclo
		varchar(5),		-- Materia
		float;			-- Puntos
		
  DEFINE vcMateria, vMateriaGen		like sga_materias.materia; 
  DEFINE	vcTipoMateria	like sga_materias.tipo_materia; 
  DEFINE	vcCiclo		like sga_ciclos.ciclo ; 
  DEFINE	vcResultGenerica like sga_cond_regular.resultado ;
  DEFINE	fPuntos	float;
  DEFINE lPlan  	like sga_titulos_otorg.plan;
  DEFINE lVersion  	like sga_titulos_otorg.version;
  DEFINE vcredito  	like sga_atrib_mat_plan.credito;
  DEFINE cResultGenerica  char(1);
  DEFINE cTipoMateria     like sga_materias.tipo_materia;
  DEFINE dFecha	date;
  DEFINE iTotalCreditos	INTEGER;

BEGIN

  LET fPuntos    = 0;
  LET vcMateria = NULL;
  LET vcCiclo    = NULL;
  LET dFecha    = TODAY;
  LET iTotalCreditos = 0;

-- Modos de Egreso: 
--	AM - Aprobacion de Materias 
--	CC - Creditos de los ciclos
--	CT - Creditos del Título
--	CO - Creditos de la Orientacion

  -- Obtener el plan y la version del alumno.
  EXECUTE PROCEDURE sp_plan_de_alumno(pUA,pCarrera,pLegajo, dFecha) INTO lPlan, lVersion;

-- +++++++++++++++++++++++++++++++++++++++++
-- Modo de Egreso es por Creditos
-- +++++++++++++++++++++++++++++++++++++++++
IF pEgreso <> 'AM' THEN
	
	LET fPuntos  = 0;
	LET vcredito = 0;

	-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
	-- Sumo los creditos de las materias Normales (no optativas ni genericas)
	-- Recupera todas materias normales aprobadas (obligatorias o no en el plan)
	-- Que la materia no sea una materia optativa en el plan del alumno.
	-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
 	SELECT SUM(atr.credito) 
	INTO fpuntos
	FROM sga_materias_ciclo as m, 
	     sga_atrib_mat_plan as atr
	WHERE  m.unidad_academica = pUA  
	AND  m.ciclo    = pCiclo 
	AND  atr.unidad_academica = m.unidad_academica  
	AND  atr.carrera  = pCarrera 
	AND  atr.plan       = lplan
	AND  atr.version  = lVersion 
	AND  atr.materia = m.materia 	
	AND  atr.tipo_materia <> 'G'  
	AND  m.materia IN (SELECT materia from tmp_ha_titulos)	
	AND  NOT EXISTS (SELECT  1 
			FROM sga_mat_genericas as mg, sga_atrib_mat_plan as atr2
			WHERE mg.unidad_academica = m.unidad_academica
			AND mg.materia_optativa = m.materia
			AND atr2.unidad_academica =  m.unidad_academica
			AND atr2.carrera = pCarrera
			AND atr2.plan = lplan
			AND atr2.version = lVersion
			AND atr2.materia = mg.materia_generica
			AND m.materia = atr2.materia
			AND m.ciclo = pCiclo);	

      	-- AND atr.obligatoria = 'S' 
	-- AND  atr.tipo_materia = 'N'  

	IF fpuntos IS NULL THEN
		LET fpuntos = 0;
	END IF;

	-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
	-- Realizo el calculo para las materias genéricas
	-- Recupera todas las genéricas aprobadas (obligatorias o no en el plan)
	-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
	FOREACH SELECT atr.materia, atr.credito
		 INTO vMateriaGen, vcredito
		FROM sga_materias_ciclo as m, 
		     sga_atrib_mat_plan as atr
		WHERE  m.unidad_academica = pUA  
			AND  m.ciclo = pCiclo 
			AND  atr.unidad_academica = m.unidad_academica  
			AND  atr.carrera = pCarrera 
			AND  atr.plan      = lPlan 
			AND  atr.version = lVersion 
			AND  atr.materia = m.materia 	
			AND  atr.tipo_materia = 'G' 

      	                                -- AND atr.obligatoria = 'S' 

		IF vcredito IS NULL THEN
			LET vcredito = 0;
		END IF;
		
		EXECUTE PROCEDURE sp_resultGenerica(pUA, pCarrera, pLegajo, pTitulo, pOrientacion, vMateriaGen) INTO vcResultGenerica, iTotalCreditos;
		-- Si aprobo la Materia Genérica
		IF vcResultGenerica = 'A' THEN
		   IF vcredito = 0 THEN
			-- Suma los creditos de las optativas aprobadas para la Generica
			LET fpuntos = fpuntos + iTotalCreditos;			
		   ELSE
			-- Suma los creditos de la generica
			LET fpuntos = fpuntos + vcredito;			
		   END IF;
		END IF;
	END FOREACH;
	
	IF fpuntos IS NULL THEN
		LET fpuntos = 0;
	END IF;

	-- Retorno el Ciclo con los puntos del mismo.
	RETURN pCiclo, NULL, fPuntos; 
ELSE

   -- +++++++++++++++++++++++++++++++++++++++++
   -- Modo de Egreso es por completitud de las materias del ciclo
   -- Recupera las materias que no estan aprobadas
   -- +++++++++++++++++++++++++++++++++++++++++

  FOREACH 
     SELECT m.materia, m.ciclo, sga_materias.tipo_materia
     INTO vcMateria, vcCiclo, cTipoMateria
     FROM sga_materias_ciclo as m, 
	  sga_materias,
	  sga_atrib_mat_plan as atr
    WHERE m.unidad_academica = pUA  
      AND m.ciclo = pCiclo 
      AND sga_materias.unidad_academica = m.unidad_academica
      AND sga_materias.materia = m.materia
      AND atr.unidad_academica = m.unidad_academica  
      AND atr.carrera = pCarrera 
      AND atr.plan    = lPlan 
      AND atr.version = lVersion 
      AND atr.materia = m.materia 	
      AND atr.obligatoria = 'S' 
      AND m.materia NOT IN (SELECT materia from tmp_ha_titulos)	
      
	{ -- reemplazado por el temporal tmp_ha_titulos
	 (SELECT h.materia
			  FROM vw_hist_academica as h
			  WHERE  h.unidad_academica = pUA
         		  AND  h.carrera = pCarrera  
             		  AND  h.legajo  = pLegajo  
        		  AND  h.materia = m.materia  
        		  AND  h.resultado = 'A' )
	}

    -- Si es una materia Genérica. Esta no se encuentra en la vista de Historia academica
    IF cTipoMateria = 'G' THEN
          -- Es una materia generica.
          EXECUTE PROCEDURE sp_resultGenerica(pUA, pCarrera, pLegajo, pTitulo, pOrientacion, vcMateria) INTO cResultGenerica, iTotalCreditos;
          
          IF cResultGenerica = 'A' THEN
             CONTINUE FOREACH;
          END IF;
    END IF;


    IF pRespuesta = 'P' THEN
	-- Solo devuelve la 1er materia que no esta aprobada y sale	
	RETURN vcCiclo, vcMateria, fPuntos; -- Fast! (Parcial)
    ELSE
	-- Devuelve todas las materias que no estan aprobadas en el ciclo
	RETURN vcCiclo, vcMateria, fPuntos WITH RESUME;
    END IF;

  END FOREACH ;
END IF;

END;
END PROCEDURE;
-- ++++++++++++++++++++++++++++ Fin Procedure sp_ciclo_aprobado +++++++++++++++++++++++

-- EXECUTE PROCEDURE sp_ciclo_aprobado('FICH', 'DI', '31515806-8', 'DIMC', 'DI', 'DIMC', 'CC',  'T');

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_CertAluReg 
-- *****************************************************************************
revoke execute on "dba".sp_ciclo_aprobado from public;
grant execute on "dba".sp_ciclo_aprobado to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_ciclo_aprobado to internet; -- Rol de usuario de Internet
