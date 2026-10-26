drop PROCEDURE "dba".b_regcontrolar;
CREATE PROCEDURE "dba".b_regcontrolar(
	pAnioAcademico LIKE sga_anio_academico.anio_academico,
	pUnidadAcademica LIKE sga_alumnos.unidad_academica,
	pCarrera LIKE sga_alumnos.carrera,
	pLegajo LIKE sga_alumnos.legajo DEFAULT NULL)

	RETURNING varchar(5),        -- sga_alumnos.unidad_academica
	          varchar(5),        -- sga_alumnos.carrera
	          varchar(15),       -- sga_alumnos.legajo
	          integer;           -- sga_causa_perd_reg.causa_perdida_reg

	-- Variables locales
	DEFINE vUnidadAcademica   LIKE sga_alumnos.carrera;
	DEFINE vCarrera           LIKE sga_alumnos.carrera;
	DEFINE vLegajo            LIKE sga_alumnos.legajo;
	DEFINE vRegular           LIKE sga_alumnos.regular;
	DEFINE vCausa             LIKE sga_causa_perd_reg.causa_perdida_reg;
	DEFINE vResultado         integer;
	DEFINE vExisteCausa       integer;

	-- Variables para el manejo de excepciones
	DEFINE SQLErr             integer;
	DEFINE ISAMError          integer;
	DEFINE errorInfo          varchar(76);

	-- Si hay algun error
	ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
		-- Borra la tabla temporal
		BEGIN
			-- Si no existía, continúa
			ON EXCEPTION IN  (-206)
			END EXCEPTION WITH RESUME ;
			-- Borra la tabla temporal
			DROP TABLE tmp_aluAControlar;
		END

		RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
	END EXCEPTION;
BEGIN
	-- Crea una tabla temporal para cargar los alumnos que debe controlar
	CREATE TEMP TABLE tmp_aluAControlar (
	            unidad_academica   varchar(5),  -- sga_alumnos.unidad_academica
	            carrera            varchar(5),  -- sga_alumnos.carrera
	            legajo             varchar(15), -- sga_alumnos.legajo
	            regular            char(1));    -- sga_alumnos.regular

	IF pLegajo IS NULL THEN
		FOREACH
			-- Lee los alumnos de la carrera a los que debe controlar
			EXECUTE PROCEDURE b_regAluAControl(pUnidadAcademica, pCarrera, pAnioAcademico)
			   INTO vUnidadAcademica,
			        vCarrera,
			        vLegajo,
			        vRegular

				-- Lo inserta en la tabla temporal
				INSERT INTO tmp_aluAControlar
				VALUES (vUnidadAcademica,
				        vCarrera,
				        vLegajo,
				        vRegular);
		END FOREACH;
	ELSE
		-- Recupera los datos del alumno pedido
		INSERT INTO tmp_aluAControlar
		SELECT sga_alumnos.unidad_academica,
		       sga_alumnos.carrera,
		       sga_alumnos.legajo,
		       sga_alumnos.regular
		  FROM sga_alumnos
		 WHERE sga_alumnos.unidad_academica = pUnidadAcademica
		   AND sga_alumnos.carrera = pCarrera
		   AND sga_alumnos.legajo = pLegajo;
	END IF;

	-- Recupera la lista de alumnos a los que debe controlar
	FOREACH
		-- Para cada uno, corre los controles y va guardando el resultado de cada control
		SELECT unidad_academica,
		       carrera,
		       legajo,
		       regular
		  INTO vUnidadAcademica,
		       vCarrera,
		       vLegajo,
		       vRegular
		  FROM tmp_aluAControlar

		-- En este proceso, solo se corren los controles para los alumnos regulares y las controla una por una
		IF vRegular = 'S' THEN
			FOREACH
				-- Lee las causas de pérdida de regularidad activas
				SELECT sga_causa_perd_reg.causa_perdida_reg
				  INTO vCausa
				  FROM sga_causa_perd_reg
				 WHERE sga_causa_perd_reg.estado = 'A'

				-- Dispara el control
				EXECUTE PROCEDURE sp_regDisControles(vUnidadAcademica, vCarrera, vLegajo, pAnioAcademico, vCausa) INTO vResultado;
				-- Verifica que no tenga ya una excepción para esta causa en el año (si había, el proceso devuelve 1)
				EXECUTE PROCEDURE sp_regCausaExcep (vUnidadAcademica, vCarrera, vLegajo, pAnioAcademico, vCausa) INTO vExisteCausa;

				-- Si el alumno no pasó el control, y no tiene esta causa ya grabada (es decir, exceptuada, porque
				-- si es regular y tiene la causa, debe estar exceptuada, ya que los readmitidos no se están controlando)
				IF vResultado = -1 AND vExisteCausa = -1 THEN
					-- Reporta el caso
					RETURN vUnidadAcademica, vCarrera, vLegajo, vCausa WITH RESUME;
				END IF;
			END FOREACH;
		END IF;
	END FOREACH;
	DROP TABLE tmp_aluAControlar;
END;
END PROCEDURE;                                                                                                                                                                                                                                                          
