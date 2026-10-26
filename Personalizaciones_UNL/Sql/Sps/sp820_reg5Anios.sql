CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_reg5anios') THEN
		DROP PROCEDURE sp820_reg5anios;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- PRUEBA - PRUEBA - PRUEBA - PRUEBA - PRUEBA - PRUEBA - PRUEBA - PRUEBA - PRUEBA
-- Procedure sp_regPruebaRegul
-- 
-- Proceso de prueba. Solo sirve para probar el proceso de regularidad con más
-- de un control. Si hay algún registro en la tabla sga_prueba_regul para el
-- alumno en el año, da error.
-- *******************************************************************************
CREATE PROCEDURE "dba".sp820_reg5anios( 
	pUnidadAcademica LIKE sga_alumnos.unidad_academica,
	pCarrera LIKE sga_alumnos.carrera,
	pLegajo LIKE sga_alumnos.legajo,
	pAnioAcademico LIKE sga_anio_academico.anio_academico)

	RETURNING integer, integer;

	-- Variables locales

	-- Constantes
	DEFINE cCausa		integer;
	DEFINE fechaIngreso	date;
	DEFINE ultimoExamen	date;
	DEFINE fechaBase		date;

	-- Variables para el manejo de excepciones
	DEFINE SQLErr             integer;
	DEFINE ISAMError          integer;
	DEFINE errorInfo          varchar(76);

	-- Si hay algun error
	ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
		RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
	END EXCEPTION;
BEGIN
	-- CONSTANTE: Fija la causa que utiliza este control
	LET cCausa = 82001;

	SELECT MDY(4, 1, MAX(anio_academico)) into fechaIngreso
	FROM sga_alumnos a
		JOIN sga_carrera_aspira ca
			JOIN sga_periodo_insc per
			ON ca.periodo_inscripcio = per.periodo_inscripcio
		  ON a.nro_inscripcion = ca.nro_inscripcion
			AND a.carrera = ca.carrera
	WHERE a.carrera = pCarrera
		and a.legajo = pLegajo;


	SELECT MAX(fecha) into ultimoExamen
	FROM vw_hist_academica
	WHERE unidad_academica = pUnidadAcademica
		AND carrera = pCarrera
		AND legajo = pLegajo
		AND forma_aprobacion like "%Examen%";

	IF ultimoExamen IS NULL THEN
		LET ultimoExamen = "01/01/1900";
	END IF;
	IF MONTH(ultimoExamen) = 2 and DAY(ultimoExamen) = 29 THEN
		LET ultimoExamen = ultimoExamen - 1;
	END IF;


	-- calculo la fecha base
	IF ultimoExamen > fechaIngreso THEN
		LET fechaBase = ultimoExamen;
	ELSE
		LET fechaBase = fechaIngreso;
	END IF;

	-- Si no hay actividad en los ultimos 5 años
	IF (MDY(MONTH(fechaBase), DAY(fechaBase), YEAR(fechaBase)+5) < today) 
		and not exists (select "" from sga_perdidas_regul 
				where unidad_academica = pUnidadacademica
				and carrera = pCarrera
				and legajo = pLegajo
				and fecha_vencim_rehab is not null
				and fecha_vencim_rehab > today) THEN
		-- Hay un registro
		RETURN -1, cCausa;
	END IF;

	RETURN 1, cCausa;
END;
END PROCEDURE;
-- ******************** Fin del procedure "dba".sp820_reg5anios *********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_reg5anios 
-- *****************************************************************************
revoke execute on "dba".sp820_reg5anios from public;
grant execute on "dba".sp820_reg5anios to guarani;  -- Rol de usuarios de Gestion
grant execute on "dba".sp820_reg5anios to internet; -- Rol de usuario de Internet