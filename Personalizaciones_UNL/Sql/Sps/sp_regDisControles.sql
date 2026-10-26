CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_regdiscontroles') THEN
		DROP PROCEDURE sp_regdiscontroles;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.3.0
-- Procedure sp_regDisControles
-- Personalizable
-- Proceso que dispara los controles de regularidad. Cada nuevo control que se
-- defina, debe ser declarado en este proceso
-- Si en el futuro se puede usar SQL dinámico, este proceso se puede reemplazar.
-- U820 Se agrega causa (82001) UNL de pérdida de regularidad en la carrera
-- *******************************************************************************
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
	ELSE
		-- ERROR, La causa no está configurada
	END IF;

	IF pCausa <> vCausa THEN
		-- ERROR, Las causas están mal mapeadas
	END IF;

	RETURN vResultado;
END;
END PROCEDURE;
-- ******************** Fin del procedure "dba".sp_regdiscontroles ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_regdiscontroles 
-- *****************************************************************************
revoke execute on "dba".sp_regdiscontroles from public;
grant execute on "dba".sp_regdiscontroles to guarani;  -- Rol de usuarios de Gestion
grant execute on "dba".sp_regdiscontroles to internet; -- Rol de usuario de Internet