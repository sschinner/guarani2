DROP PROCEDURE "dba".sp_regdiscontroles;
CREATE PROCEDURE "dba".sp_regdiscontroles(
	pUnidadAcademica   LIKE sga_alumnos.unidad_academica,
	pCarrera           LIKE sga_alumnos.carrera,
	pLegajo            LIKE sga_alumnos.legajo,
	pAnioAcademico     LIKE sga_anio_academico.anio_academico,
	pCausa             LIKE sga_causa_perd_reg.causa_perdida_reg)

	RETURNING integer;           -- Resultado

	-- Variables locales
	DEFINE vCausa             LIKE sga_causa_perd_reg.causa_perdida_reg;
	DEFINE vResultado         integer;

	-- Variables para el manejo de excepciones
	DEFINE SQLErr             integer;
	DEFINE ISAMError          integer;
	DEFINE errorInfo          varchar(76);

	-- Si hay algun error
	ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
		RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
	END EXCEPTION;
BEGIN
	IF pCausa = 1 THEN
		-- Controla que el alumno tenga la cantidad mínima de materias aprobadas
		EXECUTE PROCEDURE sp_regCantMatAprob (pUnidadAcademica, pCarrera, pLegajo, pAnioAcademico) INTO vResultado, vCausa;

	ELIF pCausa = 100 THEN
		-- Controla que pase el control de prueba de regularidades
		EXECUTE PROCEDURE sp_regPruebaRegul (pUnidadAcademica, pCarrera, pLegajo, pAnioAcademico) INTO vResultado, vCausa;
	ELIF pCausa = 82001 THEN
		-- Controla que pase el control de prueba de regularidades
		EXECUTE PROCEDURE sp820_reg5Anios (pUnidadAcademica, pCarrera, pLegajo, pAnioAcademico) INTO vResultado, vCausa;
                 ELIF pCausa = 82100 THEN
		-- Controla que pase el control de expiración de plazo carrera
		EXECUTE PROCEDURE sp820_expiracionplazo(pUnidadAcademica, pCarrera, pLegajo, pAnioAcademico) INTO vResultado, vCausa;
	ELSE
		-- ERROR, La causa no está configurada
	END IF;

	IF pCausa <> vCausa THEN
		-- ERROR, Las causas están mal mapeadas
	END IF;

	RETURN vResultado;
END;
END PROCEDURE;
                                                                                                                                                                 
