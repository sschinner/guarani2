-- *****************************************************************************
-- PERSONALIZACION UNLPAM
-- Version 2.8.0
-- Setear la fecha de vigencia de la equivalencia de regularidad con la misma
-- fecha de vigencia de la cursada/equivalencia parcial original.
-- *****************************************************************************

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.10.0
-- Procedure sp_evalua_grupo
-- Ultima version de modificacion: 2.04.0, 2.6.4, 2.9.0 (vencimiento de las eq. parciales)
--
--  1) REPROBACIONES: Parámetro "equiv_pasar_reprobados". Pasa las notas REPROBADOS solo si es una relacion 1 a N  (una sola materia en el ORIGEN) y el parametro del sistema = S
--      Si existe reprobaciones de la materia, se pasan igual, asi no se cumpla el grupo de origen, pero solo si hay una materia en el origen.
--      y solo se pasa cuando en el Destino, la condicion de la materia es "Aprobada" es, decir, dar una Equivalencia Total (condicion = A).
--      Se calcula la escala de notas y nota correspondient a la materia destino si se traslada la nota.
--
--  2) Pasa 1 vez la materia Destino por cada materia Origen que exista. Es decir si la relacion es 2 a 1, la materia destino se pasa dos veces
--      una por cada materia Origen... 
--      Es para completar la tabla "sga_equiv_relacion" que es en la que se registra las materias origen del grupo de equivalencia.
--
--  3) Si traslada nota, se setea la ESCALA DE NOTAS que tenga definida la materia destino.
--      La NOTA se calculara como PROMEDIO de las notas de las materias origen. Ver que pasa si la nota resultante para esa escala de notas no existe...
--
--  4) Parámetro "equiv_parcial_aplic_automatica". Significa que se dan equivalencias parciales, según valor del parámetro se dan equivalencias parciales (valor P)
--     o equiv parciales que solo cuentan para control de correlativas en el plan (Valor C) - estas no se recuperan en la vista de cursadas.
--     Solo se otorga la equivalencia parcial de las materias destino si:
--      a. No estan aprobadas por examen final/Promoción/Equivalencia Total o estan regularizadas
--      b. Solo de las materias del DESTINO cuya condición es una Aprobacion  (condicion = A)
--
--     Si se definió que la equivalencia tiene vencimiento, entonces se recupera del proceso "sp_fe_fin_vig_equi"
--     La fecha de la equivalencia se recupera del proceso "sp_eq_calculafecha"
--
--     4.1 - Si el grupo ORIGEN NO esta cumplido y solo consta de una materia (grupo de equivalencias 1 a N). 
--           Es decir, si la la materia del origen no esta aprobada, pero si existe la cursada de esa materia y esta aprobada, entonces se pasa
--           la equivalencia parcial de las materias del grupo DESTINO .
--     4.1 - Si el grupo ORIGEN SI esta cumplido y solo consta de una materia (grupo de equivalencias 1 a N) y el parámetro "equiv_parcial_grupo_origen_cumplido" esta Activo,
--           Es decir, si la la materia del origen esta aprobada y si existe la cursada de esa materia y esta aprobada, entonces se pasa
--           la equivalencia parcial de las materias del grupo DESTINO.
-- *****************************************************************************

DROP PROCEDURE sp_evalua_grupo;
CREATE PROCEDURE sp_evalua_grupo(
	pUnidadAcademica   LIKE sga_alumnos.unidad_academica,
	pCarrera           LIKE sga_alumnos.carrera,
	pLegajo            LIKE sga_alumnos.legajo,
	pMatrizEquiv       LIKE sga_eqdef_grupos.matriz_equiv,
	pGrupoEquiv        LIKE sga_eqdef_grupos.grupo_equiv )

	RETURNING varchar(5),        -- sga_equiv_otorgada.materia
	          date,              -- sga_equiv_otorgada.fecha
	          char(1),           -- sga_equiv_otorgada.alcance (T - Equiv Total / P - Equiv Parcial  / C - Equiv Parcial solo para correlativas)
	          char(1),           -- sga_equiv_otorgada.resultado
	          integer,           -- sga_equiv_otorgada.escala_notas
	          varchar(5),        -- sga_equiv_otorgada.nota
	          date,              -- sga_equiv_otorgada.vencimiento
	          varchar(255),      -- sga_equiv_otorgada.temas_a_rendir
	          varchar(5),        -- sga_equiv_otorgada.plan
	          varchar(5),        -- sga_equiv_otorgada.version
	          varchar(5),        -- sga_equiv_relacion.carrera
	          varchar(15),       -- sga_equiv_relacion.legajo
	          varchar(5),        -- sga_equiv_relacion.materia
	          date,              -- sga_equiv_relacion.fecha
	          char(1);           -- sga_equiv_relacion.origen

	-- Variables locales
	DEFINE vTrasladaNota LIKE  sga_eqdef_grupos.traslada_nota;
	DEFINE vUnidadAcademica	LIKE 	sga_eqdef_materias.unidad_academica;
	DEFINE vMateria	LIKE sga_eqdef_materias.materia;
	DEFINE vOrigenDestino	LIKE sga_eqdef_materias.origen_destino;
	DEFINE vCondicionOrigen, vCondicionDestino, auxCondDestino	LIKE sga_eqdef_materias.condicion;
	DEFINE vTemas	LIKE sga_eqdef_materias.temas_a_rendir;
	DEFINE vTieneVencimiento	LIKE sga_eqdef_materias.vencimiento;
	DEFINE vRetornarMateria, vCumpleMatOrigen CHAR(1);
	DEFINE cntMatOrigen	SMALLINT;
	DEFINE vPlan	LIKE  sga_equiv_otorgada.plan;
	DEFINE vVersion	LIKE  sga_equiv_otorgada.version;
	DEFINE vCarreraOrigen	LIKE  sga_equiv_relacion.carrera;
	DEFINE vLegajoOrigen	LIKE  sga_equiv_relacion.legajo;
	DEFINE vMateriaOrigen	LIKE  sga_equiv_relacion.materia;
	DEFINE vFechaOrigen	LIKE  sga_equiv_relacion.fecha;
	DEFINE vPasarReprobados, vEquivParcial, vPasarEqP_OrigApr, vEqP_VencOrigen	LIKE sga_param_sistema.valor;
	DEFINE vVencimientoAux DATE;
  
	DEFINE vauxFecha			varchar(10);
	DEFINE vFecha, vVencimiento, vFechaActual DATE;
	DEFINE vNota, vNotaRep, vNotaCurs	 LIKE sga_det_escala.nota;
	DEFINE vEscalaNotas, vEscalaNotasCurs, vEscalaNotasRep LIKE sga_det_escala.escala_notas;
	DEFINE vResultado LIKE sga_det_escala.resultado;
    

	-- Variables para el manejo de excepciones
	DEFINE SQLErr             integer;
	DEFINE ISAMError          integer;
	DEFINE errorInfo          varchar(76);

	-- Si hay algun error
	ON EXCEPTION SET SQLErr, ISAMError, errorInfo
		RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
	END EXCEPTION;
BEGIN
	
	LET vPasarReprobados = 'N';
	LET cntMatOrigen = 0;
	LET vCumpleMatOrigen = 'S';
	LET vEquivParcial = NULL;
	LET vEqP_VencOrigen = 'N';
	LET vFechaActual = TODAY;
	LET vTrasladaNota = NULL;
	LET vPasarEqP_OrigApr = NULL;

	-- Evaluo si debo pasar los reprobados. Solo para grupos de tipo 1 a N.
	EXECUTE PROCEDURE sp_param_sistema('equiv_pasar_reprobados') INTO vPasarReprobados;

	-- Evaluo si usa las Equivalencias Parciales que solo sirven para control de correlativas y no como una Equivalencia Parcial...
	EXECUTE PROCEDURE sp_param_sistema('equiv_parcial_aplic_automatica') INTO vEquivParcial;

	-- Define si pasa las cursadas de las materias origen cuando el grupo de materias origen se cumplen
	EXECUTE PROCEDURE sp_param_sistema('equiv_parcial_grupo_origen_cumplido') INTO vPasarEqP_OrigApr;
	EXECUTE PROCEDURE sp_param_sistema('equiv_parcial_vencimiento_origen') INTO vEqP_VencOrigen;
	
	-- Recupero el Plan y Version actual del Alumno
	EXECUTE PROCEDURE sp_plan_de_alumno(pUnidadAcademica, pCarrera, pLegajo, vFechaActual) INTO vPlan, vVersion;
	
	
	-- Verifico si debo trasladar la nota o no...
	SELECT sga_eqdef_grupos.traslada_nota
	INTO  vTrasladaNota
	FROM sga_eqdef_grupos
	WHERE sga_eqdef_grupos.matriz_equiv = pMatrizEquiv
	AND sga_eqdef_grupos.grupo_equiv = pGrupoEquiv;
	
	IF vTrasladaNota IS NULL THEN
	  LET vTrasladaNota = 'N';
	ELSE
	  LET vTrasladaNota = UPPER(vTrasladaNota);
	END IF;
	
	-- Recupero la cantidad de materias en el origen..
	SELECT count(*) INTO cntMatOrigen
	FROM sga_eqdef_materias
	WHERE sga_eqdef_materias.matriz_equiv = pMatrizEquiv
	AND sga_eqdef_materias.grupo_equiv = pGrupoEquiv
	AND sga_eqdef_materias.origen_destino = 'O';
	
	-- ***********************************************************************************************************************
	--  EVALUAR MATERIAS DEL GRUPO ORIGEN.
	--	Recupero las materias ORIGEN de la matriz/grupo
	-- ***********************************************************************************************************************
	 FOREACH SELECT unidad_academica, materia, condicion
	 	INTO  vUnidadAcademica, vMateria, vCondicionOrigen
	  FROM sga_eqdef_materias
	  WHERE sga_eqdef_materias.matriz_equiv = pMatrizEquiv
	  AND sga_eqdef_materias.grupo_equiv = pGrupoEquiv
	  AND sga_eqdef_materias.origen_destino = 'O'
	
		-- Verifico si el alumno (la PERSONA) aprobo o tiene la cursada de la materia destino:
		-- Si no tengo aprobada la materia
		IF (SELECT COUNT(*) FROM tmp_equiv_hacad
			WHERE  materia = vMateria
			AND resultado = 'A') <= 0 THEN
	
			-- carrera = pCarrera AND legajo = pLegajo   
	
			IF vCondicionOrigen = 'R' THEN
				-- Si tengo Cursada la materia la materia
				IF (SELECT COUNT(*) FROM tmp_equiv_cursadas
					WHERE  materia = vMateria) <= 0 THEN
	
					-- No tiene ni aprobada ni cursada la materia... no cumple con el origen
					-- Salgo del proceso
					LET vCumpleMatOrigen = 'N';
					EXIT FOREACH;
				END IF;
			ELSE
				-- No tiene aprobada la materia... no cumple con el origen
				-- Salgo del proceso
				LET vCumpleMatOrigen = 'N';
				EXIT FOREACH;
			END IF;
	  END IF;
	END FOREACH;  -- Materias Origen.


	-- ***********************************************************************************************************************
	-- SIN CUMPLIR ORIGEN. Verifica si debe PASAR REPROBADOS (solo hay una materia en el origen)
	-- Parámetro: equiv_pasar_reprobados
	-- ***********************************************************************************************************************
	IF vPasarReprobados = 'S' AND cntMatOrigen = 1 AND vCumpleMatOrigen = 'N' THEN
		-- Inicializo variables...
		LET vMateriaOrigen = NULL;
		LET vFecha = vFechaActual;
		LET vNota = NULL;
		LET vEscalaNotas = NULL;
		LET vResultado = 'R'; -- Reprobado
	
		LET vVencimiento  = NULL;
		LET vVencimientoAux  = NULL;
		LET vCarreraOrigen = NULL;
		LET vLegajoOrigen = NULL;
		LET vFechaOrigen = NULL;

	-- Recupero la Materia Origen y la Condicion de la misma
	SELECT materia, condicion
		INTO vMateriaOrigen, vCondicionOrigen
		FROM sga_eqdef_materias
		WHERE sga_eqdef_materias.matriz_equiv = pMatrizEquiv
		AND sga_eqdef_materias.grupo_equiv = pGrupoEquiv
		AND sga_eqdef_materias.origen_destino = 'O';

	-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Recupero las materias DESTINO de la matriz/grupo
	-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	FOREACH SELECT sga_eqdef_materias.unidad_academica,
		sga_eqdef_materias.materia,
		sga_eqdef_materias.origen_destino,
		sga_eqdef_materias.condicion,
		sga_eqdef_materias.temas_a_rendir,
		sga_eqdef_materias.vencimiento
		INTO  vUnidadAcademica, vMateria, vOrigenDestino, vCondicionDestino, vTemas, vTieneVencimiento
		FROM sga_eqdef_materias
		WHERE sga_eqdef_materias.matriz_equiv = pMatrizEquiv
		AND sga_eqdef_materias.grupo_equiv = pGrupoEquiv
		AND sga_eqdef_materias.origen_destino = 'D'

		IF vCondicionDestino <> 'A' THEN
			-- Si la materia destino no es una Equiv Total, entonces continuo.
			-- Solo paso las reprobadas para Equivalencias Totales...
			CONTINUE FOREACH;
		END IF;

		-- Recupero la Escala de Notas de la materia en el Plan
		IF vTrasladaNota = 'S'  THEN
			IF vCondicionDestino = 'A' THEN
				-- Equivalencia Total
				SELECT escala_examen
				INTO vEscalaNotas
				FROM  dba.sga_materias,
					dba.sga_tipos_materia
				WHERE dba.sga_materias.unidad_academica = vUnidadAcademica
				AND dba.sga_materias.materia = vMateria
				AND dba.sga_tipos_materia.tipo_de_materia    = dba.sga_materias.tipo_de_materia ;
			-- ELSE
			--	-- Equivalencia Parcial
			--	SELECT escala_cursada
			--	 INTO vEscalaNotas
			--	FROM  dba.sga_materias,
			--		dba.sga_tipos_materia
			--	WHERE dba.sga_materias.unidad_academica = vUnidadAcademica
			--	AND dba.sga_materias.materia = vMateria
			--	AND dba.sga_tipos_materia.tipo_de_materia    = dba.sga_materias.tipo_de_materia ;
			END IF;

		END IF;

		LET vVencimiento = NULL;
		IF vTieneVencimiento = 'S' THEN
			-- Calculo la Fecha de Vencimiento de la Equiv Parcial
			LET vauxFecha = to_char(vFechaActual,"%d-%m-%Y");
			EXECUTE PROCEDURE sp_fe_fin_vig_equi(vauxFecha) INTO vVencimiento;
		END IF;

		IF vCondicionDestino = 'A' Then
			LET auxCondDestino = 'T' ;   -- Equivalencia Total
		ELIF  vCondicionDestino = 'R' Then
			LET  auxCondDestino = 'P';   -- Equivalencia Parcial
		ELSE
			LET  auxCondDestino = 'C';   -- Equivalencia Parcial solo para Correlativas
		END IF;

		-- Equivalencias TOTALES
		IF vCondicionDestino = 'A' THEN

			-- Paso la Reprobacion de la materia (Equivalencia Total).
			-- paso todos los examenes reprobados de esa materia...
			FOREACH SELECT carrera, legajo, fecha , escala_notas, nota
				INTO vCarreraOrigen, vLegajoOrigen, vFechaOrigen, vEscalaNotasRep, vNotaRep
				FROM  tmp_equiv_hacad
				WHERE  materia = vMateriaOrigen
				AND resultado = 'R'

				IF vTrasladaNota = 'S' THEN
				   -- Calculo la nota que corresponde a la Reprobación de la Materia Destino.
					 EXECUTE PROCEDURE sp_eq_nota_equiv(vEscalaNotasRep, vNotaRep, pUnidadAcademica, vMateria, 'A') INTO vEscalaNotasRep, vNotaRep;				   
				ELSE
					LET vNotaRep = NULL;
					LET vEscalaNotasRep = NULL;
				END IF;

				-- Recupera la Fecha que le asignara en la Equivalencia!!!
---------------------------------------- Modificado por cambio original de nuestro proc al pasar a versi 2.09 --17/05/16
				-----EXECUTE PROCEDURE sp_eq_calculafecha(pUnidadAcademica ,pCarrera, pLegajo, pMatrizEquiv,pGrupoEquiv, auxCondDestino, 'R') INTO vFecha;
				
				--- EN LA FECHA PONE LA FECHA DE LA MATERIA ORIGEN SI NO ES NULA, SI NO PONE LA FECHA ACTUAL 
                                                                -----(ES LA MISMA QUE DEVUELVE EL PROCEDIMIENTO ANTERIOR)--
                                                                 IF vFechaOrigen is NULL THEN
					LET vFecha = TODAY;
				ELSE
                                                                                LET vFecha = vFechaOrigen;

				END IF;
				
	----------------------------------------------------------------------------------------------------------		       
				RETURN  vMateria, vFecha, auxCondDestino, 'R', vEscalaNotasRep, vNotaRep, vVencimiento, vTemas, vPlan, vVersion, vCarreraOrigen, vLegajoOrigen, vMateriaOrigen, vFechaOrigen, vCondicionOrigen  WITH RESUME;

			END FOREACH;

		ELIF  vCondicionDestino = 'R' THEN  -- EQUIVALENCIAS PARCIALES (Regularidades)
			-- ** NO SE PASAN LAS REPROBACIONES DE EQUIVALENCIAS PARCIALES !!! **
		END IF;

	 END FOREACH;  -- Materias Destino, del grupo.

	END IF;      --  vPasarReprobados = 'S' AND cntMatOrigen = 1 AND vCumpleMatOrigen = 'N'

	-- ***********************************************************************************************************************
	-- SIN CUMPLIR ORIGEN. Entonces veo que sucede con el parametro de equivalencia parcial
	-- Solo cuando hay una sola materia en el Origen. Es para los casos que no utilizaron materia comun!!!!
	-- Parámetro: equiv_parcial_aplic_automatica
	-- ***********************************************************************************************************************
	IF vCumpleMatOrigen = 'N' and cntMatOrigen = 1 and (vEquivParcial = 'C' or vEquivParcial = 'P' ) THEN
	  -- Si tiene la curada de la materia Origen, debo pasar la Equiv Parcial o la Equiv Parcial para Correlativas de la materia destino..
	
	  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	  -- Recupero las materias ORIGEN, aquellas que tienen como condicion, estar aprobadas (condicion = A)!!!
	  -- Deberia solo entrar una vez, en esta consulta...
	  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	  FOREACH SELECT unidad_academica, materia
	   INTO  vUnidadAcademica, vMateriaOrigen
	   FROM sga_eqdef_materias
	   WHERE sga_eqdef_materias.matriz_equiv = pMatrizEquiv
	   AND sga_eqdef_materias.grupo_equiv = pGrupoEquiv
	   AND sga_eqdef_materias.origen_destino = 'O'
	   AND sga_eqdef_materias.condicion = 'A'

		-- Verifico si tiene la cursada de la materia (no importa en que carrera)
		IF (SELECT COUNT(*) FROM tmp_equiv_cursadas
			WHERE materia = vMateriaOrigen) = 0 THEN

			-- WHERE carrera = pCarrera
			-- AND legajo = pLegajo

			CONTINUE FOREACH;
		END IF;

		LET vVencimiento = NULL;
		LET vVencimientoAux = NULL;
		LET vNotaCurs = NULL;
		LET vEscalaNotasCurs = NULL;
		LET vNota = NULL;
		LET vEscalaNotas = NULL;

		-- Debo recuperar la ultima cursada con su fecha de vencimiento, nota y escala de notas...
		FOREACH SELECT carrera, legajo, fecha, fecha_vencimiento, nota, escala_notas
		    INTO vCarreraOrigen, vLegajoOrigen, vFechaOrigen, vVencimientoAux, vNotaCurs, vEscalaNotasCurs
		    FROM  tmp_equiv_cursadas
		    WHERE  materia = vMateriaOrigen
		    ORDER BY fecha DESC
			 -- Por si recuepra mas de una cursada, solo recupero la última!!!
			EXIT FOREACH;
		END FOREACH;


		-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		-- Recupero las materias DESTINO, pero solo aquellas que tienen la condicion de Equivalencia Total (condicion = A).
		-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		FOREACH SELECT sga_eqdef_materias.unidad_academica,
			sga_eqdef_materias.materia,
			sga_eqdef_materias.origen_destino,
			sga_eqdef_materias.condicion,
			sga_eqdef_materias.temas_a_rendir,
			sga_eqdef_materias.vencimiento
			INTO  vUnidadAcademica, vMateria, vOrigenDestino, vCondicionDestino, vTemas, vTieneVencimiento
			FROM sga_eqdef_materias
			WHERE sga_eqdef_materias.matriz_equiv = pMatrizEquiv
			AND sga_eqdef_materias.grupo_equiv = pGrupoEquiv
			AND sga_eqdef_materias.origen_destino = 'D'
			AND sga_eqdef_materias.condicion = 'A'

			-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			-- Si tiene Aprobada la materia destino o la tiene Cursada (en la carrera destino)
			-- NO se le otorga la Equivalencia Parcial
			-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			IF (SELECT COUNT(*) FROM tmp_equiv_hacad
				WHERE carrera = pCarrera
				AND legajo = pLegajo
				AND materia = vMateria
				AND resultado = 'A') > 0 THEN

				-- No asigno la equivalencia Parcial
  				CONTINUE FOREACH;
			END IF;
			
			IF (SELECT count(*) FROM  tmp_equiv_cursadas
				WHERE  materia = vMateria
				AND  carrera = pCarrera
				AND legajo = pLegajo) > 0 THEN

				-- No asigno la equivalencia Parcial
				CONTINUE FOREACH;
			END IF;
			-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

			-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			-- Recupero la escala de Notas y Nota correspondiente a la Materia Destino
			-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			IF vTrasladaNota = 'S' AND vNotaCurs IS NOT NULL THEN
				-- Debo recuperar la nota correspondiente a la Escala de Notas de la materia destino segun Nota de cursada de la Materia Origen.
				-- Solo porque hay una materia en el Origen del Grupo de Equivalencias. 
				EXECUTE PROCEDURE sp_eq_nota_equiv(vEscalaNotasCurs, vNotaCurs, pUnidadAcademica, vMateria, 'C') INTO vEscalaNotas, vNota;				   
			ELSE
				-- No se pasa la nota ni escala de notas.
				LET vEscalaNotas = NULL;
				LET vNota = NULL;
			END IF;

			-- Fecha de Vencimiento para Equivalencias Parciales que tienen Vencimiento !!!
			LET vVencimiento = NULL;
			-- IF vTieneVencimiento = 'S' THEN  -- Comentado en 2.9. Si el destino es equivlaencia Total, no se puede definir si lleva o no vencimiento.
				IF vEqP_VencOrigen = 'S' THEN 
				   LET vVencimiento = vVencimientoAux; -- Otorga el vencimiento de la regularizada origen.
				ELSE
				   -- Calculo la Fecha de Vencimiento de la Equiv Parcial
				  LET vauxFecha = to_char(vFechaActual,"%d-%m-%Y");
				  EXECUTE PROCEDURE sp_fe_fin_vig_equi (vauxFecha) INTO vVencimiento;
				END IF;  
			-- END IF;

			-- Recupera la Fecha que le asignara en la Equivalencia!!!
			EXECUTE PROCEDURE sp_eq_calculafecha(pUnidadAcademica ,pCarrera, pLegajo, pMatrizEquiv,pGrupoEquiv, vEquivParcial, 'A') INTO vFecha;

			-- Devuelvo la Equivalencia Parcial o la otra, depende del Parametro...
			RETURN vMateria, vFecha, vEquivParcial, 'A', vEscalaNotas, vNota, vVencimiento, vTemas, vPlan, vVersion, vCarreraOrigen, vLegajoOrigen, vMateriaOrigen, vFechaOrigen, 'A'  WITH RESUME;

		END FOREACH; -- Materias Destino
	END FOREACH; -- Materias Origen
 END IF;  -- vCumpleMatOrigen = 'N' and cntMatOrigen = 1 and (vEquivParcial = 'C' or vEquivParcial = 'P' )


	-- ***********************************************************************************************************************
	-- MATERIAS ORIGEN CUMPLIDAS. Entonces veo que se le da como destino (Equiv parciales o totales)
	-- ***********************************************************************************************************************
	IF vCumpleMatOrigen = 'S' THEN

	  -- Inicializo variables...
	  LET vFecha = vFechaActual;
	  LET vNota = NULL;
	  LET vEscalaNotas = NULL;

	  LET vResultado = 'A'; -- Aprobado..

	  -- -- Recupera la Fecha que le asignara en la Equivalencia!!!
	  -- EXECUTE PROCEDURE sp_eq_calculafecha(pUnidadAcademica ,pCarrera, pLegajo, pMatrizEquiv,pGrupoEquiv) INTO vFecha;

	  IF vTrasladaNota = 'S' THEN
	  	-- Son mas de una materia en el origen...
	  	-- Calculo la nota que se asignara a las materias destino...
	  	-- La escala de Notas se calcula por cada materia destino mas abajo.
	  	EXECUTE PROCEDURE sp_eq_calculanota(pUnidadAcademica ,pCarrera, pLegajo, pMatrizEquiv,pGrupoEquiv) INTO vNota;
	  END IF;

	-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Recupero las materias DESTINO de la matriz/grupo
	-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	FOREACH SELECT sga_eqdef_materias.unidad_academica,
		sga_eqdef_materias.materia,
		sga_eqdef_materias.origen_destino,
		sga_eqdef_materias.condicion,
		sga_eqdef_materias.temas_a_rendir,
		sga_eqdef_materias.vencimiento
		INTO  vUnidadAcademica, vMateria, vOrigenDestino, vCondicionDestino, vTemas, vTieneVencimiento
		FROM sga_eqdef_materias
		WHERE sga_eqdef_materias.matriz_equiv = pMatrizEquiv
		AND sga_eqdef_materias.grupo_equiv = pGrupoEquiv
		AND sga_eqdef_materias.origen_destino = 'D'

		IF vCondicionDestino = 'A' Then
			LET auxCondDestino = 'T';    -- Equivalencia Total
		ELIF  vCondicionDestino = 'R' Then
			LET  auxCondDestino = 'P';   -- Equivalencia Parcial
		ELSE
			LET  auxCondDestino = 'C';   -- Equivalencia Parcial solo para Correlativas
		END IF;



		-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		-- Verifico si el alumno aprobo o tiene la cursada de la materia destino:
		-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		LET vRetornarMateria = 'S';
		-- Si tengo aprobada la materia, no retorno ni la Equiv total, ni la Parcial
		IF (SELECT COUNT(*) FROM tmp_equiv_hacad
			WHERE carrera = pCarrera
			AND legajo = pLegajo
			AND materia = vMateria
			AND resultado = 'A') > 0 THEN
			LET vRetornarMateria = 'N';
		END IF;

		IF vCondicionDestino = 'R' and vRetornarMateria = 'S' THEN
			-- Si tengo Cursada la materia la materia
			IF (SELECT COUNT(*) FROM tmp_equiv_cursadas
				WHERE carrera = pCarrera
				AND legajo = pLegajo
				AND materia = vMateria) > 0 THEN

				LET vRetornarMateria = 'N';

			END IF;
		END IF;

		IF  vRetornarMateria = 'N' THEN
			CONTINUE FOREACH;
		END IF;
		-- ++++++++++ Materia Destino Aprobada o Regularizada +++++++++++++

		-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		-- Recupero la escala de Notas de la Materia Destino
		-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		IF vTrasladaNota = 'S' THEN
			IF vCondicionDestino = 'A' THEN
				-- Equivalencia Total
				SELECT escala_examen
				INTO vEscalaNotas
				FROM  dba.sga_materias,
					dba.sga_tipos_materia
				WHERE dba.sga_materias.unidad_academica = vUnidadAcademica
				AND dba.sga_materias.materia = vMateria
				AND dba.sga_tipos_materia.tipo_de_materia    = dba.sga_materias.tipo_de_materia ;
			ELSE
				-- Equivalencia Parcial
				SELECT escala_cursada
				 INTO vEscalaNotas
				FROM  dba.sga_materias,
					dba.sga_tipos_materia
				WHERE dba.sga_materias.unidad_academica = vUnidadAcademica
				AND dba.sga_materias.materia = vMateria
				AND dba.sga_tipos_materia.tipo_de_materia    = dba.sga_materias.tipo_de_materia ;
			END IF;
		END IF;

		   IF vCondicionDestino = 'A' THEN
		     -- Retorno la equivalencia Total
		   ELSE
		     -- Retorno la equivalencia Parcial
		   END IF;


		-- Fecha de Vencimiento para Equivalencias Parciales que tienen Vencimiento !!!
		LET vVencimiento = NULL;
		IF vTieneVencimiento = 'S' THEN
		    
			-- Calculo la Fecha de Vencimiento de la Equiv Parcial
			LET vauxFecha = to_char(vFechaActual,"%d-%m-%Y");
			EXECUTE PROCEDURE sp_fe_fin_vig_equi (vauxFecha) INTO vVencimiento;
		END IF;


		   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		   -- Devuelvo la materia DESTINO tantas veces como materia Origen que tenga definida...
		   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		   FOREACH SELECT unidad_academica, materia, condicion
			INTO  vUnidadAcademica, vMateriaOrigen, vCondicionOrigen
			FROM sga_eqdef_materias
			WHERE sga_eqdef_materias.matriz_equiv = pMatrizEquiv
			AND sga_eqdef_materias.grupo_equiv = pGrupoEquiv
			AND sga_eqdef_materias.origen_destino = 'O'

			LET vCarreraOrigen = NULL;
			LET vLegajoOrigen = NULL;
			LET vFechaOrigen = NULL;


			-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			-- Veo si pasa los REPROBADOS. Solo si es una relacion 1 a N  (una sola materia en el ORIGEN)
			-- Solo los reprobados donde la condicion destino es Equivalencia Total (no para equiv parciales..)
			-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			IF (cntMatOrigen = 1 AND vPasarReprobados = 'S' ) AND auxCondDestino = 'T'  THEN
				-- Paso todos los reprobados...
				IF vCondicionOrigen = 'A' THEN
					--  Equivalencia Total. Se pasan los EXAMENES REPROBADOS
					FOREACH SELECT carrera, legajo, fecha, escala_notas, nota
						INTO vCarreraOrigen, vLegajoOrigen, vFechaOrigen, vEscalaNotasRep, vNotaRep
						FROM  tmp_equiv_hacad
						WHERE  materia = vMateriaOrigen
						AND resultado = 'R'

						IF vTrasladaNota = 'S' THEN
						  -- Calculo la nota que corresponde a la Reprobación de la Materia Destino.
						  EXECUTE PROCEDURE sp_eq_nota_equiv(vEscalaNotasRep, vNotaRep, pUnidadAcademica, vMateria, 'A') INTO vEscalaNotasRep, vNotaRep;				   
						ELSE
						  LET vNotaRep = NULL;
						  LET vEscalaNotasRep = NULL;
						END IF;

						-- Recupera la Fecha que le asignara en la Equivalencia!!!
						EXECUTE PROCEDURE sp_eq_calculafecha(pUnidadAcademica ,pCarrera, pLegajo, pMatrizEquiv,pGrupoEquiv, auxCondDestino, 'R') INTO vFecha;

						-- Paso las Reprobaciones
						RETURN vMateria, vFecha, auxCondDestino, 'R', vEscalaNotasRep, vNotaRep, vVencimiento, vTemas, vPlan, vVersion, vCarreraOrigen, vLegajoOrigen, vMateriaOrigen, vFechaOrigen, vCondicionOrigen  WITH RESUME;

					END FOREACH;

				ELIF vCondicionOrigen = 'R' THEN

					-- ** NO SE PASAN LAS REPROBACIONES DE EQUIVALENCIAS PARCIALES!!! **

				END IF;
			END IF;  -- (cntMatOrigen = 1 AND vPasarReprobados = 'S' ) AND auxCondDestino = 'T'


			-- Recupero la Aprobacion de la Materia Origen
			IF vCondicionOrigen = 'A' THEN
				-- tiene este foreach, porque puede estar mas de una vez la materia(en diferentes carreras, aunque solo debe
				-- estar por la carrera en la que la aprobo, y no por equivalencias equivlentes, examenes equivalentes, etc..)
				FOREACH SELECT carrera, legajo, fecha
					INTO vCarreraOrigen, vLegajoOrigen, vFechaOrigen
					FROM  tmp_equiv_hacad
					WHERE  materia = vMateriaOrigen
					AND resultado = 'A'

					EXIT FOREACH;
				END FOREACH;

			-- Recupero la Cursada de la Materia Origen
			ELIF vCondicionOrigen = 'R' THEN
				-- Debo recuperar la ultima cursada...
				FOREACH SELECT carrera, legajo, fecha, fecha_vencimiento
					INTO vCarreraOrigen, vLegajoOrigen, vFechaOrigen, vVencimientoAux
					FROM  tmp_equiv_cursadas
					WHERE  materia = vMateriaOrigen
					ORDER BY fecha DESC
					
					-- Personalizacion UNLPAM
					IF vEqP_VencOrigen = 'S' THEN 
					   LET vVencimiento = vVencimientoAux;
					END IF;
					
					EXIT FOREACH;
				END FOREACH;
			END IF;

			-- Recupera la Fecha que le asignara en la Equivalencia!!!
			EXECUTE PROCEDURE sp_eq_calculafecha(pUnidadAcademica ,pCarrera, pLegajo, pMatrizEquiv,pGrupoEquiv, auxCondDestino, 'A') INTO vFecha;

			-- Paso la Aprobacion.
			RETURN vMateria, vFecha, auxCondDestino, 'A', vEscalaNotas, vNota, vVencimiento, vTemas, vPlan, vVersion, vCarreraOrigen, vLegajoOrigen, vMateriaOrigen, vFechaOrigen, vCondicionOrigen  WITH RESUME;

			-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			-- Otorgo Equivalencia Parcial o Parcial que sirve solo para Correlativas en el plan...
			-- Solo si es para cuando la materia destino se le da una Equivalencia Total.
			-- Y que NO tenga la cursada de esa materia en la carrera.
			-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			IF vPasarEqP_OrigApr = 'S' THEN
			
				IF (vEquivParcial = 'P' OR vEquivParcial = 'C') AND vCondicionDestino = 'A' AND  cntMatOrigen = 1 AND
				    ((SELECT COUNT(*) FROM tmp_equiv_cursadas WHERE carrera = pCarrera AND legajo = pLegajo	AND materia = vMateria) = 0) THEN   
				  -- vEquivParcial = 'P'   -> Equivalencia Parcial
				  -- vEquivParcial = 'C'   -> Equivalencia Parcial solo para Correlativas...
				  -- Verifico si tiene aprobada la cursada de esta materia, si es asi, le paso la Equivalencia Parcial
						 
				  LET vNotaCurs = NULL;
				  LET vEscalaNotasCurs = NULL;

				  -- Debo recuperar la ultima cursada Aprobada (por Promocion o regularizada)...
				  FOREACH SELECT carrera, legajo, fecha, nota, escala_notas, fecha_vencimiento
				     INTO vCarreraOrigen, vLegajoOrigen, vFechaOrigen, vNotaCurs, vEscalaNotasCurs, vVencimientoAux
				     FROM  tmp_equiv_cursadas
				    WHERE materia = vMateriaOrigen
				    ORDER BY fecha DESC
				

					-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
					-- Recupero la escala de Notas y Nota correspondiente a la Materia Destino
					-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
					IF vTrasladaNota = 'S' AND vNotaCurs IS NOT NULL THEN
						-- Recupero la Escala de Notas y Nota correspondiente a la materia DESTINO, de acuerdo a la Escala de Notas y Nota de la cursada de la materia ORIGEN.
						-- Solo porque hay una materia en el Origen del Grupo de Equivalencias. 
						EXECUTE PROCEDURE sp_eq_nota_equiv(vEscalaNotasCurs, vNotaCurs, pUnidadAcademica, vMateria, 'C') INTO vEscalaNotas, vNota;				   
					ELSE
						-- No se pasa la nota ni escala de notas.
						LET vEscalaNotas = NULL;
						LET vNota = NULL;
					END IF;

					-- Fecha de Vencimiento para Equivalencias Parciales. 
					LET vVencimiento = NULL;
					-- IF vTieneVencimiento = 'S' THEN  -- Comentado en 2.9. Cuando el destino es equiv Total, la opcion tiene vencimiento es siempre NO.
					   IF vEqP_VencOrigen = 'S' THEN  
					      LET vVencimiento = vVencimientoAux;
					   ELSE
						  -- Calculo la Fecha de Vencimiento de la Equiv Parcial
					      LET vauxFecha = to_char(vFechaActual,"%d-%m-%Y");
					      EXECUTE PROCEDURE sp_fe_fin_vig_equi (vauxFecha) INTO vVencimiento;
					   END IF;  
					-- END IF;

					-- Recupera la Fecha que le asignara en la Equivalencia!!!
					-- EXECUTE PROCEDURE sp_eq_calculafecha(pUnidadAcademica ,pCarrera, pLegajo, pMatrizEquiv,pGrupoEquiv, vEquivParcial, 'A') INTO vFecha;
	
					-- La Fecha que le asignara en la Equivalencia Parcial es la misma que la fecha de la Equivalencia Total (vFecha)
					RETURN vMateria, vFecha, vEquivParcial, 'A', vEscalaNotas, vNota, vVencimiento, vTemas, vPlan, vVersion, vCarreraOrigen, vLegajoOrigen, vMateriaOrigen, vFechaOrigen, vCondicionOrigen  WITH RESUME;

				-- Por si recuepra mas de una cursada, solo recupero la 1era que encuentra y sale!!!
				EXIT FOREACH;  -- Cursadas
			  END FOREACH; -- Cursadas de la Materia Origen.   

		END IF; -- (vEquivParcial = 'P' OR vEquivParcial = 'C') AND vCondicionDestino = 'A' AND  cntMatOrigen = 1  
	  END IF; -- vPasarEqP_OrigApr = 'S'

	END FOREACH;  -- Materias ORIGEN del Grupo

	END FOREACH;  -- Materias DESTINO del grupo.
 
 END IF;  -- vCumpleMatOrigen = 'S'. Si cumplio con el ORIGEN.

END;
END PROCEDURE;
-- ******************************************* Fin del procedure sp_evalua_grupo **************************************************


