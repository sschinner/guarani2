DROP PROCEDURE "dba". sp820_expiracionplazo;
CREATE PROCEDURE "dba". sp820_expiracionplazo( 
	pUnidadAcademica LIKE sga_alumnos.unidad_academica,
	pCarrera LIKE sga_alumnos.carrera,
	pLegajo LIKE sga_alumnos.legajo,
	pAnioAcademico LIKE sga_anio_academico.anio_academico)

	RETURNING integer, integer;

	-- Variables locales

	-- Constantes
	DEFINE cCausa		integer;
                DEFINE vcduracioncarr	integer;
	DEFINE fechaIngreso	date;
	DEFINE ultimoExamen	date;
	DEFINE fechaBase		date;
                 define  vcPlan, vcVersiontit     varchar(5);

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
	LET cCausa = 82100;
                 ---- Se considera que el alumno que se analiza no es egresado o posible egresado porque se filtra esto en el proceso inicial
                 --- Calcula Fecha de ingreso
	SELECT MDY(4, 1, MAX(anio_academico)) into fechaIngreso
	FROM sga_alumnos a
		JOIN sga_carrera_aspira ca
			JOIN sga_periodo_insc per
			ON ca.periodo_inscripcio = per.periodo_inscripcio
		  ON a.nro_inscripcion = ca.nro_inscripcion
			AND a.carrera = ca.carrera
	WHERE a.carrera = pCarrera
		and a.legajo = pLegajo;


	--- obtengo el plan/version del alumno y duracion de carrera
                  SELECT sga_planes.plan, sga_planes.version_actual, sga_planes.duracion_numerica
                  INTO vcPlan, vcVersiontit, vcduracioncarr
                  FROM sga_planes
                  WHERE sga_planes.unidad_academica = pUnidadAcademica
                  AND sga_planes.carrera = pCarrera
                  AND sga_planes.estado = 'V';

	-- Si se cumplió la cantidad de años de duración de la carrera 
	IF (MDY(MONTH(fechaIngreso), DAY(fechaIngreso), YEAR(fechaIngreso)+vcduracioncarr) < today) 
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
END PROCEDURE                                                                                                                                               
