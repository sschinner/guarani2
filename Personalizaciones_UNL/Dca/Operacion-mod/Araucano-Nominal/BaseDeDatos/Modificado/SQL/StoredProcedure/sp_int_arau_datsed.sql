-- ******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.07.0, 2.9.3
-- Procedure sp_int_arau_datsed
-- 
-- Proceso que recupera la sede de los alumnos para el proceso de Araucano.
-- Recupera la sede que estaba el alumno al inicio del año acadèmico a informar.
-- Si no lo encuentra devuelve la sede actual.
-- 
-- Recibe: UA, Carrera, Legajo, Anio Académico informado
-- Retorna: sede.
-- ******************************************************************************

DROP PROCEDURE sp_int_arau_datsed;
CREATE PROCEDURE sp_int_arau_datsed( 
   pUA      LIKE dba.sga_alumnos.unidad_academica,
   pCarrera LIKE dba.sga_alumnos.carrera,
   pLegajo  LIKE dba.sga_alumnos.legajo,
   pAnio    LIKE dba.sga_anio_academico.anio_academico )

 RETURNING VARCHAR(5);


-- Variables Internas.
DEFINE vc_Sede        VARCHAR(5);
DEFINE vd_Fecha, vd_FechaFinAcad      DATE;
DEFINE l_cmb_sede, l_cmb_sede2 INTEGER;


-- VARIABLES PARA EL MANEJO DE EXCEPCIONES.
DEFINE SQLErr               INTEGER;
DEFINE ISAMError            INTEGER;
DEFINE errorInfo            VARCHAR(76);


-- SI HAY ALGÚN ERROR.
ON EXCEPTION SET SQLErr, ISAMError, errorInfo
   RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;

BEGIN

LET vc_sede = NULL;
LET l_cmb_sede = NULL;
LET vd_FechaFinAcad = NULL;
LET vd_Fecha = NULL;

  -- -- tomo la fecha final del año academico
  -- SELECT fecha_fin INTO vd_FechaFinAcad FROM sga_anio_academico	WHERE anio_academico = pAnio;

  -- Se recupera la sede del alumno en la fecha de inicio del año academico a informar.
  LET vd_Fecha = to_date('0104'|| pAnio, '%d%m%Y');
   


  -- busco la sede en la tabla de cambios de sede

	SELECT MAX(cambio_sede)
	INTO  l_cmb_sede
	FROM sga_sedes_hist_cmb
	WHERE unidad_academica = pUA
	AND carrera = pCarrera
	AND legajo = pLegajo
	AND vd_Fecha BETWEEN fecha_desde and fecha_hasta;
	--   AND vd_FechaFinAcad between fecha_desde and fecha_hasta;


	-- si es no existe busco la que tenga fecha en null (ultimo cambio de sede)
	IF l_cmb_sede IS NULL then

		SELECT MAX(cambio_sede)
		INTO  l_cmb_sede
		FROM sga_sedes_hist_cmb
		WHERE unidad_academica = pUA
		AND carrera = pCarrera
		AND legajo = pLegajo
		AND fecha_desde <= vd_Fecha and fecha_hasta is null;
		-- AND fecha_desde <= vd_FechaFinAcad and fecha_hasta is null;

	END IF;

	IF l_cmb_sede IS NOT NULL then
		SELECT sede
		INTO vc_sede
		FROM sga_sedes_hist_cmb
		WHERE cambio_sede = l_cmb_sede;
	END IF

	IF vc_sede IS NULL THEN
		-- Sede Actual del Alumno
		SELECT sede
		INTO vc_sede
		FROM sga_alumnos
		WHERE unidad_academica = pUA
		AND carrera = pCarrera
		AND legajo = pLegajo;

	END IF;

	RETURN vc_sede;

END;
END PROCEDURE;
-- ********************* FIN DEL PROCESO sp_int_arau_datsed *********************

