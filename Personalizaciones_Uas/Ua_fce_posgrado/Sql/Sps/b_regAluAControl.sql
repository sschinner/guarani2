DROP PROCEDURE b_regAluAControl;
CREATE PROCEDURE b_regAluAControl(
	pUnidadAcademica   LIKE sga_carreras.unidad_academica,
	pCarrera           LIKE sga_carreras.carrera,
	pAnioAcademico     LIKE sga_anio_academico.anio_academico )

	RETURNING varchar(5),        -- sga_alumnos.unidad_academica
	          varchar(5),        -- sga_alumnos.carrera
	          varchar(15),       -- sga_alumnos.legajo
	          char(1);           -- sga_alumnos.regular

	-- Variables locales
	DEFINE vLegajo            LIKE sga_alumnos.legajo;
	DEFINE vFechaIngreso      LIKE sga_alumnos.fecha_ingreso;
	DEFINE vRegular           LIKE sga_alumnos.regular;
--	DEFINE vFechaInicio       LIKE sga_anio_academico.fecha_inicio;
	DEFINE vFiltroPers        integer;

	-- Variables para el manejo de excepciones
	DEFINE SQLErr             integer;
	DEFINE ISAMError          integer;
	DEFINE errorInfo          varchar(76);

	-- Si hay algun error
	ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
		RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
	END EXCEPTION;
BEGIN
	LET vLegajo = NULL;

	-- ******************************************************************************
	-- Este bloque se debe quitar, porque debe mirar el año en la matriculación del alumno
	-- ******************************************************************************
	-- Busca la fecha de fin del año académico
--	SELECT fecha_inicio
--	  INTO vFechaInicio
--	  FROM sga_anio_academico
--	 WHERE sga_anio_academico.anio_academico = pAnioAcademico;
	-- *******************************************************************************

	-- Por cada alumno activo, ingresado en el año a revisar o antes
------------------- Modificado: o Pasivo
	FOREACH
		SELECT sga_alumnos.legajo,
			sga_alumnos.fecha_ingreso,
			sga_alumnos.regular
		INTO vLegajo,
		       vFechaIngreso,
		       vRegular
		FROM sga_periodo_insc,
			sga_carrera_aspira,
			sga_situacion_asp,
			sga_alumnos
		WHERE sga_periodo_insc.anio_academico <= pAnioAcademico
			AND (sga_situacion_asp.resultado_asp = 'I' OR sga_carrera_aspira.situacion_asp = 'IC')
			AND (sga_alumnos.calidad = 'A' or sga_alumnos.calidad = 'P' )
			AND sga_alumnos.unidad_academica = pUnidadAcademica
			AND sga_alumnos.carrera=pCarrera
			AND sga_carrera_aspira.periodo_inscripcio = sga_periodo_insc.periodo_inscripcio
			AND sga_carrera_aspira.situacion_asp = sga_situacion_asp.situacion_asp
			AND sga_carrera_aspira.unidad_academica = sga_alumnos.unidad_academica
			AND sga_carrera_aspira.carrera          = sga_alumnos.carrera
			AND sga_carrera_aspira.nro_inscripcion  = sga_alumnos.nro_inscripcion
		ORDER BY legajo

		-- No toma en cuenta a los readmitidos para años posteriores al que se está controlando
		IF EXISTS (SELECT ''
		             FROM sga_perdidas_regul
		            WHERE sga_perdidas_regul.unidad_academica = pUnidadAcademica
		              AND sga_perdidas_regul.carrera = pCarrera
		              AND sga_perdidas_regul.legajo = vLegajo
		              AND sga_perdidas_regul.anio_rehab > pAnioAcademico
		              AND sga_perdidas_regul.tipo_rehab = 'R') THEN
			CONTINUE FOREACH;
		END IF;
                        
		-- Solo toma en cuenta los alumnos regulares o a los no regulares
		-- cuya pérdida de regularidad es del año que se está revisando
		IF vRegular <> 'S' THEN
			IF NOT EXISTS (SELECT ''
			                 FROM sga_perdidas_regul
			                WHERE sga_perdidas_regul.unidad_academica = pUnidadAcademica
			                  AND sga_perdidas_regul.carrera = pCarrera
			                  AND sga_perdidas_regul.legajo = vLegajo
			                  AND sga_perdidas_regul.anio_academico = pAnioAcademico) THEN
				-- NOTA: No hace falta preguntar si la pérdida de regularidad está activa o no
				--       porque si el alumno figura como no regular y se lo controlo en este año,
				--       quiere decir está irregular por el control en este año, es decir, necesariamente
				--       la pérdida de regularidad activa (que tiene que existir) no puede ser de un
				--       año anterior, porque en ese caso no se le hubiera corrido el control este año.
				CONTINUE FOREACH;
			END IF;
		END IF;

		-- Ejecuta el sp para personalizar filtros
		EXECUTE PROCEDURE pu_regAluAControl(pUnidadAcademica, pCarrera, vLegajo, vRegular, pAnioAcademico) INTO vFiltroPers;
		IF vFiltroPers = -1 THEN
			CONTINUE FOREACH;
		END IF;

		-- Si pasó todos los controles, considera el registro aceptado y lo devuelve
		RETURN pUnidadAcademica, pCarrera, vLegajo, vRegular WITH RESUME;

	END FOREACH;
END;
END PROCEDURE;
                                                                                                                                                                                                          
