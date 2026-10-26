CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_fhuc_reg5anios') THEN
		DROP PROCEDURE sp820_fhuc_reg5anios;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

--Procedimiento determinar si un alumno es regular, es decir si tuvo alguna actividad academica, examen o cursada, en un periodo de 5 años anterior a la fecha actual

--DROP PROCEDURE sp820_fhuc_reg5anios;
--execute procedure sp820_fhuc_reg5anios('FHUC','25126856-4',2014)


CREATE PROCEDURE "dba".sp820_fhuc_reg5anios( 

	pUnidadAcademica LIKE sga_alumnos.unidad_academica,

	pLegajo LIKE sga_alumnos.legajo,

	pAnioAcademico LIKE sga_anio_academico.anio_academico)



	RETURNING integer, integer;



	-- Variables locales



	-- Constantes

	DEFINE cCausa		integer;

	DEFINE fechaIngreso	date;

	DEFINE ultimoExamen	date;
	DEFINE ultimaCursada	date;

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

	WHERE a.legajo = pLegajo;





	SELECT MAX(fecha) into ultimoExamen

	FROM vw_hist_academica

	WHERE unidad_academica = pUnidadAcademica

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


	SELECT MAX(fecha_inscripcion) INTO ultimaCursada FROM sga_insc_cursadas
		WHERE unidad_academica = pUnidadAcademica

		AND legajo = pLegajo
		AND estado="A";

	IF ultimaCursada IS NULL THEN

		LET ultimaCursada = "01/01/1900";

	END IF;

	IF MONTH(ultimaCursada ) = 2 and DAY(ultimaCursada ) = 29 THEN

		LET ultimaCursada = ultimaCursada  - 1;

	END IF;



	-- Si no hay actividad en los ultimos 5 años

	IF (MDY( MONTH(fechaBase),DAY(fechaBase), YEAR(fechaBase)+5) < TODAY) 

		AND not exists (select "" from sga_perdidas_regul 

				where unidad_academica = pUnidadacademica

				and legajo = pLegajo

				and fecha_vencim_rehab is not null

				and fecha_vencim_rehab > today)
		 AND (MDY(MONTH(ultimaCursada), DAY(ultimaCursada), YEAR(ultimaCursada)+5) < today)THEN

		-- Hay un registro

		RETURN -1, cCausa;

	END IF;



	RETURN 1, cCausa;

END;

END PROCEDURE;

-- ********************************** FIN PROCESO sp820_fhuc_reg5anios **********************************

REVOKE execute ON "dba".sp820_fhuc_reg5anios FROM public;
GRANT execute ON "dba".sp820_fhuc_reg5anios to guarani; -- Rol de usuarios de Gestion
GRANT execute ON "dba".sp820_fhuc_reg5anios to internet; -- Rol de usuario de Internet





