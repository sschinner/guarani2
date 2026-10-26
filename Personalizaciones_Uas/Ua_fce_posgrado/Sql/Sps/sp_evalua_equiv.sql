-------- Agregado para ejecución automática
CREATE PROCEDURE verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_evalua_equiv') THEN
		DROP PROCEDURE sp_evalua_equiv;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE verifica_objeto();
DROP PROCEDURE verifica_objeto();
---------------------------------------------------------------------------------------------------

CREATE PROCEDURE "dba".sp_evalua_equiv(
	pUnidadAcademica   LIKE sga_alumnos.unidad_academica,
	pCarrera           LIKE sga_alumnos.carrera,
	pLegajo            LIKE sga_alumnos.legajo,
	pCarreraOrigen     LIKE sga_carreras.carrera,
	pPlanOrigen        LIKE sga_planes.plan )

	RETURNING integer;
                --RETURNING char, char;

	-- Variables locales
	DEFINE vMateria           LIKE sga_equiv_otorgada.materia;
    DEFINE vMateriaAnt        LIKE sga_equiv_otorgada.materia;
	DEFINE vFecha             LIKE sga_equiv_otorgada.fecha;
	DEFINE vAlcance           LIKE sga_equiv_otorgada.alcance;
    DEFINE vAlcanceAnt        LIKE sga_equiv_otorgada.alcance;
	DEFINE vEscalaNotas       LIKE sga_equiv_otorgada.escala_notas;
	DEFINE vResultado         LIKE sga_equiv_otorgada.resultado;
    DEFINE vResultadoAnt      LIKE sga_equiv_otorgada.resultado;
	DEFINE vNota              LIKE sga_equiv_otorgada.nota;
	DEFINE vVencimiento       LIKE sga_equiv_otorgada.vencimiento;
	DEFINE vTemasARendir      LIKE sga_equiv_otorgada.temas_a_rendir;
	DEFINE vPlan              LIKE sga_equiv_otorgada.plan;
	DEFINE vVersion           LIKE sga_equiv_otorgada.version;

	DEFINE vCarreraOrigen     LIKE sga_equiv_relacion.carrera;
	DEFINE vLegajoOrigen      LIKE sga_equiv_relacion.legajo;
	DEFINE vMateriaOrigen     LIKE sga_equiv_relacion.materia;
	DEFINE vFechaOrigen       LIKE sga_equiv_relacion.fecha;
	DEFINE vCondicionOrigen   LIKE sga_eqdef_materias.condicion;

	DEFINE vOperacionEquiv    LIKE sga_equiv_operac.operacion_equiv;
	DEFINE vMatriz            LIKE sga_eqdef_matrices.matriz_equiv;
	DEFINE vOficial           LIKE sga_eqdef_matrices.oficial;
	DEFINE vNroResolMatriz    LIKE sga_equiv_operac.nro_resolucion;
	DEFINE vNroResolucion     LIKE sga_eqdef_matrices.nro_resolucion;

	DEFINE vParAplicAuto      LIKE sga_param_sistema.valor;
	DEFINE vParResolucion     LIKE sga_param_sistema.valor;
	DEFINE vParTramites       LIKE sga_param_sistema.valor;
	DEFINE vParCorrelativas   LIKE sga_param_sistema.valor;

	DEFINE vCabecera          varchar(15);
	DEFINE vCorrelativasOK    char(1);
	DEFINE vFechaOper         LIKE sga_equiv_operac.fecha;
	DEFINE vFechaCierre       LIKE sga_equiv_operac.fecha_cierre;
	DEFINE vOrigen            LIKE sga_equiv_operac.origen;
	DEFINE vTipo              LIKE sga_equiv_operac.tipo_equiv;
	DEFINE vNUA               LIKE sga_equiv_operac.nua;
	DEFINE vOperador          LIKE sga_equiv_operac.operador;
	DEFINE vMatrizOficial     LIKE sga_equiv_operac.matriz_oficial;
	DEFINE vAplicAutomatica   LIKE sga_equiv_operac.aplic_automatica;
	DEFINE vEstado            LIKE sga_equiv_operac.estado;
	DEFINE vEquivalencia      LIKE sga_equiv_otorgada.equivalencia;

	DEFINE vPlanAlumno        LIKE sga_equiv_otorgada.plan;
	DEFINE vVersionAlumno     LIKE sga_equiv_otorgada.version;

	DEFINE vPara, cabecera_generada              char(1);
	DEFINE viAux, vicnt_equiv            integer;
	DEFINE vsAux              varchar(255);
	DEFINE v_equiv_parcial, v_equiv_total	LIKE sga_param_sistema.valor;
	DEFINE vdt_FechaHora	DATETIME YEAR TO SECOND;

	-- Variables para el manejo de excepciones
	DEFINE SQLErr             integer;
	DEFINE ISAMError          integer;
	DEFINE errorInfo          varchar(76);

---------------
                DEFINE vtotal_materiasorigen      varchar(150);
                DEFINE vtotal_actas   varchar(150);
----------------------------------
	-- Si hay algun error
	ON EXCEPTION SET SQLErr, ISAMError, errorInfo
		-- Borra la tabla temporal
		BEGIN
			-- Si no existía, continúa
			ON EXCEPTION IN  (-206)
			END EXCEPTION WITH RESUME ;
			-- Borra la tabla temporal
			DROP TABLE tmp_equiv_todo;
		END

		RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
	END EXCEPTION;
BEGIN
	-- Determina si los parámetros del sistema indican que la instalación usa o no euivalencias automáticas
	 LET vtotal_materiasorigen = ' ' ;
                  let vtotal_actas  = ' ' ;

               EXECUTE PROCEDURE sp_param_sistema('equiv_automaticas') INTO vParAplicAuto;
	IF vParAplicAuto <> 'S' THEN
		-- Si no las usa, sale sin hacer nada
		Return 0;
                                --Return ' ',' ' ;
	END IF;

	LET vicnt_equiv = 0;


	-- Recupero el Plan y Version del Alumno
	LET vdt_FechaHora = CURRENT YEAR TO SECOND;
	EXECUTE PROCEDURE sp_plan_de_alumno(pUnidadAcademica, pCarrera, pLegajo, vdt_FechaHora) INTO vPlanAlumno, vVersionAlumno;

	-- Determina el origen del trámite de equivalencia
	IF pCarrera = pCarreraOrigen THEN
		IF vPlanAlumno = pPlanOrigen THEN
			LET vOrigen = 'V';
		ELSE
			LET vOrigen = 'P';
		END IF;
	ELSE
		LET vOrigen = 'C';
	END IF;

	LET vFechaOper        = TODAY;         -- La fecha es siempre la del motor  ---- VER ACA
	LET vFechaCierre       = vFechaOper;  -- Como las operaciones se guardan cerradas, la fecha de cierre es la misma que la de alta
	LET vTipo = 'N';                -- Normal
	LET vNUA = null;                -- POR AHORA, ESTAS OPERACIONES NO GENERAN NUA
	LET vOperador = USER;           -- El operador es siempre el usuario indicado por el motor
	LET vMatrizOficial = 'S';       -- Este proceso siempre aplica las matrices oficiales
	LET vAplicAutomatica = 'S';     -- Si se utiliza este proceso, es siempre para correr equivalencias en forma automatica
	LET vEstado = 'C';              -- Estas operaciones siempre se graban cerradas

	-- Parametros del Sistema de materias comunes.
	LET v_equiv_parcial = 'N';
	LET v_equiv_total   = 'N';

	EXECUTE PROCEDURE sp_param_sistema('equiv_controla_correlativas') INTO vParCorrelativas;
--	EXECUTE PROCEDURE sp_param_sistema('Equiv. automaticas - Contr. correlativas') INTO vParCorrelativas;

	-- Equivalencia Equivalente Total
	EXECUTE PROCEDURE sp_param_sistema ('equiv_vale_en_todas_las_carreras') INTO v_equiv_total;
	-- Equivalencia Equivalente Parcial. No las equivalencias parciales solo para correlativas...
	EXECUTE PROCEDURE sp_param_sistema ('equivparcial_vale_en_todas_las_carreras') INTO v_equiv_parcial;

	-- Determina qué resolución debe reflejar en el trámite de equivalencias
	EXECUTE PROCEDURE sp_param_sistema('Equiv. automaticas - Resol. a registrar') INTO vParResolucion; --VER ACA
	-- Si usa la del cambio de plan, la busca (solo si se trata de un cambio de plan, es decir, igual carrera pero distinto plan, ya que igual plan y carrera significa cambio de version)
	IF pCarrera = pCarreraOrigen AND vPlanAlumno <> pPlanOrigen AND vParResolucion = 'Cambio de plan' THEN
		-- Como esta buscando el cambio de plan recien generado, busca el cambio que tenga fecha_hasta en nulo
		-- (Recordar que si no se miran las fecha, podría haber mas de un registro, por los alumnos que vuelven
		-- a un plan anterior
		SELECT sga_cambios_plan.nro_resolucion
		  INTO vNroResolucion
		  FROM sga_cambios_plan
		 WHERE sga_cambios_plan.unidad_academica = pUnidadAcademica
		   AND sga_cambios_plan.carrera = pCarrera
		   AND sga_cambios_plan.legajo = pLegajo
		   AND sga_cambios_plan.plan = vPlanAlumno
		   AND sga_cambios_plan.fecha_hasta IS NULL;

		-- Si no la encuentra, fuerza una exepcion
		-- GENERAR UN MENSAJE DE ERROR

		BEGIN
			-- Si existía, continúa
			ON EXCEPTION IN  (-268)
			END EXCEPTION WITH RESUME ;
			-- Si trabaja con la resolución del cambio de plan, la carga en la tabla de resoluciones de equivalencias
			INSERT INTO sga_equiv_resol (nro_resolucion, fecha, observaciones)     --- VER ACA
			VALUES (vNroResolucion, vFechaOper , 'Resolución de cambio de plan');
		END
	END IF;

	-- Crea una tabla temporal para cargar las equivalencias que debe otorgar
	CREATE TEMP TABLE tmp_equiv_todo (
	       materia            varchar(5),        -- sga_equiv_otorgada.materia
	       fecha              date,              -- sga_equiv_otorgada.fecha
	       alcance            char(1),           -- sga_equiv_otorgada.alcance
	       resultado          char(1),           -- sga_equiv_otorgada.resultado
	       escala_notas       integer,           -- sga_equiv_otorgada.escala_notas
	       nota               varchar(5),        -- sga_equiv_otorgada.nota
	       vencimiento        date,              -- sga_equiv_otorgada.vencimiento
	       temas_a_rendir     varchar(255),      -- sga_equiv_otorgada.temas_a_rendir
	       plan               varchar(5),        -- sga_equiv_otorgada.plan
	       version            varchar(5),        -- sga_equiv_otorgada.version
	       carrera_origen     varchar(5),        -- sga_equiv_relacion.carrera
	       legajo_origen      varchar(15),       -- sga_equiv_relacion.legajo
	       materia_origen     varchar(5),        -- sga_equiv_relacion.materia
	       fecha_origen       date,              -- sga_equiv_relacion.fecha
	       condicion_origen   char(1),           -- sga_equiv_relacion.origen
	       cabecera           varchar(15),       -- número interno para distinguir trámites. No es igual a sga_equiv_otorgada.operacion_equiv (varchar(5))
	       matriz_equiv       integer,           -- sga_eqdef_matrices.matriz_equiv
	       nro_resolucion     varchar(15))     -- sga_eqdef_matrices.nro_resolucion
	WITH NO LOG;

	-- Recorre las matrices que debe aplicar
	FOREACH EXECUTE PROCEDURE sp_busca_matriz(pUnidadAcademica, pCarrera, vPlanAlumno, vVersionAlumno, pCarreraOrigen, pPlanOrigen)
	   INTO vMatriz, vOficial, vNroResolMatriz

		-- Para cada matriz oficial
		IF vOficial = 'S' THEN
			-- Si en la operacion de equivalencias utiliza la resolucion de la matriz, la guarda
			-- En los cambios de carrera, siempre se utiliza la resolucion de la matriz, ya que no hay otra (como en el cambio de plan)
			-- En los cambios de versíon, tambien usa la de la matriz, porque actualmente no hay resolucion de creacion de la version
			IF vParResolucion = 'Matriz de equivalencias' OR pCarrera <> pCarreraOrigen
			   OR ( pCarrera = pCarreraOrigen AND vPlanAlumno = pPlanOrigen ) THEN
				LET vNroResolucion = vNroResolMatriz;
			END IF;

			-- Evalua la matriz y devuelve las materias que le puede otorgar como equivalencia al alumno.
			FOREACH EXECUTE PROCEDURE sp_evalua_matriz(pUnidadAcademica, pCarrera, pLegajo, vMatriz)
				INTO vMateria, vFecha, vAlcance, vResultado, vEscalaNotas,
				     vNota, vVencimiento, vTemasARendir, vPlan, vVersion,
				     vCarreraOrigen, vLegajoOrigen, vMateriaOrigen, vFechaOrigen, vCondicionOrigen
                                                                   --- VER ACA
				-- Las carga en la tabla temporal
                  BEGIN
-------------------------------------------------14-10-2008 busca el acta original del alumno y lo carga como temas a rendir, si no tiene acta busca nro de resolución 
------------------------------------------------- (caso de equivalencias)
        LET  vTemasARendir = null;                        
        SELECT distinct v820.acta into vTemasARendir
                FROM  vw820_hist_academ v820
               WHERE v820.unidad_academica = pUnidadAcademica
                 AND v820.carrera = pCarreraOrigen
                 AND v820.plan = pPlanOrigen
                 AND v820.legajo  = pLegajo
                 AND v820.materia = vMateriaOrigen
                 AND v820.fecha =vFechaOrigen;
          if vTemasARendir is null OR vTemasARendir = '' then
             SELECT distinct v820.nro_resolucion into vTemasARendir
                FROM  vw820_hist_academ v820
               WHERE v820.unidad_academica = pUnidadAcademica
                 AND v820.carrera = pCarreraOrigen
                 AND v820.plan = pPlanOrigen
                 AND v820.legajo  = pLegajo
                 AND v820.materia = vMateriaOrigen
                 AND v820.fecha =vFechaOrigen;
          end if;
          Let vtotal_materiasorigen = vtotal_materiasorigen || ' ' ||  vMateriaOrigen;
          Let vtotal_actas = vtotal_actas ||  ' ' ||  vTemasARendir;
   --  RETURN vtotal_materiasorigen, vtotal_actas;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				INSERT INTO tmp_equiv_todo (materia, fecha, alcance, resultado, escala_notas,
				                            nota, vencimiento, temas_a_rendir, plan, version,
				                            carrera_origen, legajo_origen, materia_origen, fecha_origen, condicion_origen,
				                            matriz_equiv, nro_resolucion)
				VALUES (vMateria, vFecha, vAlcance, vResultado, vEscalaNotas,
				        vNota, vVencimiento, vTemasARendir, vPlan, vVersion,
				        vCarreraOrigen, vLegajoOrigen, vMateriaOrigen, vFechaOrigen, vCondicionOrigen,
				        vMatriz, vNroResolucion);
                      END;
			END FOREACH;
		END IF; -- vOficial = 'S'
              
	END FOREACH;


	-- ESTE BLOQUE PODRÍA SER REFORMULADO EN SUCESIVAS VERSIONES, SEGUN LOS CRITERIOS QUE SE QUIERAN ADOPTAR PARA AGRUPAR LOS TRÁMITES DE EQUIVALENCIA
	-- INICIO DE BLOQUE ----------------------------------------------------------------------------------------------
	-- Una vez identificadas todas las equivalencias a otorgar, identifica las cabeceras de los trámites
	EXECUTE PROCEDURE sp_param_sistema('Equiv. automaticas - Trámites a generar') INTO vParTramites;

	IF vParTramites = 'Uno por alumno' THEN
		-- CASO 1 - Una cabecera para todas las equivalencias del alumno (En realidad, una por alumno y resolución)
		--          (Si se usa la resolución del cambio de plan, la temporal ya tendrá cargada una única resolución
		--          y habrá una sola cabecera)
		UPDATE tmp_equiv_todo
		   SET cabecera = nro_resolucion;

	ELIF vParTramites = 'Uno por matriz' THEN
		-- CASO 2 - Un trámite por matriz (y alumno)
		--          (Para una matriz, en cualquiera de los casos conocidos, -resolución de cambio de plan o de matriz-
		--          siempre habrá una única resolución en la temporal)
		UPDATE tmp_equiv_todo
		   SET cabecera = matriz_equiv;

	ELIF vParTramites = 'Uno por materia' THEN
		-- CASO 3 - Un trámite por materia (y alumno). Genera una cabecera por materia, quedando un trámite por materia-resolución)
		UPDATE tmp_equiv_todo
		   SET cabecera = materia;
--	ELIF
		-- CASO N -
	END IF;
	-- FIN DE BLOQUE -------------------------------------------------------------------------------------------------

	-- Para cada operación de equivalencia (para cada cabecera)
	FOREACH  SELECT DISTINCT cabecera, nro_resolucion
		INTO vCabecera, vNroResolucion
		FROM tmp_equiv_todo

		-- DE GENERARSE EL NUA, ESTE SERÍA EL LUGAR (UN NUA POR CABECERA)

		   LET cabecera_generada = 'N';

		-- Por cada detalle de la equivalencia
		-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		-- FOREACH SELECT DISTINCT materia, fecha, alcance, resultado, escala_notas, nota, vencimiento, temas_a_rendir, plan, version
		-- se saco el "distinct" para que recupere las reprobaciones con igual nota de una materia (cuando se otorgan equivalencias por las reprobaciones)
        LET vResultadoAnt = '';
        LET vMateriaAnt = '';
        LET vAlcanceAnt = '';
		FOREACH SELECT materia, fecha, alcance, resultado, escala_notas, nota, vencimiento, temas_a_rendir, plan, version
			  INTO vMateria, vFecha, vAlcance, vResultado, vEscalaNotas, vNota, vVencimiento, vTemasARendir, vPlan, vVersion
			  FROM tmp_equiv_todo
			 WHERE cabecera = vCabecera
             ORDER BY materia, resultado, alcance

             IF vMateriaAnt = vMateria AND
                vResultadoAnt = 'A' AND vResultado = 'A' AND
                vAlcanceAnt   =  vAlcance THEN
                -- vAlcanceAnt = 'T' AND vAlcance = 'T' THEN

                -- Si ya se otorogo una Equivalencia Total (vAlanceAnt = T) y
                -- es una equivalencia Aprobada (vResultadoAnt = A) y es la misma materia
                -- entonces continuo con el select para que no otorgue dos veces las equivalencias Aprobadas
                -- Esto se da cuando el grupo de equivalencias es N a 1 o N a M (mas de una materia en el origen)
                -- y se pasan los reprobados...
                CONTINUE FOREACH;
             ELSE
                LET vResultadoAnt = vResultado;
                LET vMateriaAnt  = vMateria;
                LET vAlcanceAnt  = vAlcance;
             END IF;

			-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			-- Verifico si ya no se otorgo la equivalencia de este tipo al alumno en la carrera
			-- Equivalencia parcial solo para permitir seguir cursando en la carrera.
			-- Estas equivalencias no estan en la tabla temporal de cursadas y equivalencias que tiene un alumno.
			-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			IF vAlcance = 'C' THEN
				EXECUTE PROCEDURE sp_evalua_materia (pUnidadAcademica, pCarrera, pLegajo,vMateria,vPlanAlumno, vVersionAlumno,'C' ) INTO  viAux, vsAux;
				IF viAux = 1 THEN
					-- Si ya tiene asignada una equivalencia parcial que sirve solo para correlativas, no la permito generar nuevamente.
					CONTINUE FOREACH;
				END IF;
			END IF;  -- vAlcance = C

			-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			-- Si corresponde, controla correlativas
			-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			IF vParCorrelativas = 'S' Then
				-- Recodifica el alcance para llamar al control de correlativas
				IF vAlcance = 'P' OR vAlcance = 'C' Then
					LET vPara = 'C';
				ELSE
					LET vPara = 'A';
				END IF;


				LET vCorrelativasOK = 'S';

				-- ++++++++++++++++++++++++++++++++++++++++++++++++
				-- Correlativa Normal
				-- ++++++++++++++++++++++++++++++++++++++++++++++++
				FOREACH  EXECUTE PROCEDURE sp_correlativas(pUnidadAcademica, pCarrera, pLegajo, vMateria, vPlanAlumno, vVersionAlumno, vPara) INTO viAux, vsAux
					-- Si fallan las correlativas
					IF viAux = -1 Then
						LET vCorrelativasOK = 'N';
					ELSE
						LET vCorrelativasOK = 'S';
					END IF;
					EXIT FOREACH;
				END FOREACH;

				-- ++++++++++++++++++++++++++++++++++++++++++++++++
				-- Correlativas Especiales
				-- ++++++++++++++++++++++++++++++++++++++++++++++++
				IF vCorrelativasOK = 'S' THEN
				   FOREACH  EXECUTE PROCEDURE sp_correlativa_esp(pUnidadAcademica, pCarrera, pLegajo, vMateria, vPlanAlumno, vVersionAlumno, today, vPara) INTO viAux, vsAux
					-- Si fallan las correlativas
					IF viAux = -1 Then
						LET vCorrelativasOK = 'N';
					ELSE
						LET vCorrelativasOK = 'S';
					END IF;
					EXIT FOREACH;
				   END FOREACH;
				END IF;
			ELSE
				-- Si no se controlan correlativas, asume que no hay problemas
				LET vCorrelativasOK = 'S';
			END IF;

			-- Si no hay problemas de correlativas, o no se controlan correlativas
			IF vCorrelativasOK = 'S' Then

				-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				-- Inserta el registro de cabecera. Se puso aqui porque puede ser que no se genere tramite
				-- de equivalencia si las materias a otorgar en la misma no cumplen con correlativas
				-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				IF cabecera_generada = 'N' THEN
				   INSERT INTO sga_equiv_operac (fecha, fecha_cierre, nro_resolucion, origen, tipo_equiv, nua,
			                              operador, matriz_oficial, aplic_automatica, unidad_academica, carrera_origen, estado)
				   VALUES (vFechaOper, vFechaCierre, vNroResolucion, vOrigen, vTipo, vNUA,
				        vOperador, vMatrizOficial, vAplicAutomatica, pUnidadAcademica, pCarreraOrigen, vEstado);

				   -- Captura el autonumérico
				   LET vOperacionEquiv = DBINFO("sqlca.sqlerrd1");

				   LET cabecera_generada = 'S';
				END IF;

				LET vicnt_equiv = vicnt_equiv + 1;

				-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				-- Inserta el registro de equivalencia otorgada
				-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

				INSERT INTO sga_equiv_otorgada (operacion_equiv, unidad_academica, carrera, legajo,
				                                materia, fecha, alcance, resultado, escala_notas,
				                                nota, vencimiento, temas_a_rendir, plan, version, rectificado, estado)
				VALUES (vOperacionEquiv, pUnidadAcademica, pCarrera, pLegajo,
				        vMateria, vFecha, vAlcance, vResultado, vEscalaNotas,
				        vNota, vVencimiento, vTemasARendir, vPlan, vVersion, 'N', 'A'); 

				-- Captura el autonumérico
				LET vEquivalencia = DBINFO("sqlca.sqlerrd1");

				-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				-- Inserta los registros relacionados
				-- Se puso el DISTINCT si como origen el alumno tiene aprobada o reprobada la materia mas de una vez en la misma fecha.
				-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				INSERT INTO sga_equiv_relacion (equivalencia, unidad_academica, carrera, legajo, materia, fecha, origen)
				SELECT DISTINCT vEquivalencia, pUnidadAcademica, carrera_origen, legajo_origen, materia_origen, fecha_origen, condicion_origen
				  FROM tmp_equiv_todo
				 WHERE cabecera = vCabecera
				   AND materia = vMateria
				   AND fecha = vFecha
				   AND alcance = vAlcance
				   AND resultado = vResultado
				   AND escala_notas = vEscalaNotas
				   AND nota = vNota
				   AND plan = vPlan
				   AND version = vVersion;

				-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				-- Equivalencia equivalente en otras Carreras del alumno. Esto es porque el tramite
				-- de Equivalenciase genera cerrado (estado = C) y es en el cierre donde se generan las equivalentes.
				-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				-- Equivalencias Totales (vAlcance = T) o Equivalencias Parciales (vAlcance = P)
				IF (vAlcance = 'T' AND v_equiv_total = 'S') OR (vAlcance = 'P' AND v_equiv_parcial = 'S') THEN
					-- Inserto la Equivalencia Equivalente.
					EXECUTE PROCEDURE sp_u_equiv_equiv(pUnidadAcademica, pCarrera, pLegajo, vFecha, vEquivalencia, vMateria, 'I');
				END IF;
			END IF;
		END FOREACH;
	END FOREACH;

	DROP TABLE tmp_equiv_todo;

     RETURN vicnt_equiv;
   -- RETURN 'fin','fin';
--RETURN vtotal_materiasorigen, vtotal_actas;

END;
END PROCEDURE            
