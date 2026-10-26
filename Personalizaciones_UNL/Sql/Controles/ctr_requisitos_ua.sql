CREATE PROCEDURE verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr_requisitos_ua') THEN
		DROP PROCEDURE ctr_requisitos_ua;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE verifica_objeto();

DROP PROCEDURE verifica_objeto();
-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.0.0, 2.6.1
--
-- Procedure ctr_requisitos_ua
-- 
-- Controla que los requisitos obligatorios por ua(los pegados al inscripto a la carrera)
-- esten presentados y en la fecha correspondiente.
-- **************************************************************************
-- drop procedure ctr_requisitos_ua;
CREATE PROCEDURE ctr_requisitos_ua( pUnidadAcademica  LIKE sga_personas.unidad_academica,
					pCarrera          LIKE sga_carreras.carrera,
					pNroInscripcion   LIKE sga_personas.nro_inscripcion)
RETURNING  smallint,      -- status
           varchar(255);  -- <mensaje, parametros>

/*
devuelve:  1 (OK) / -1 (en otro caso)
           msg
*/

   -- vars para la respuesta
   DEFINE iStatus            	smallint;      -- status
   DEFINE vcMsg              	varchar(255);  -- mensaje y parametros

   -- var's para el manejo de excepciones
   DEFINE sql_err, isam_err  	integer;
   DEFINE error_info         	varchar(76);
   DEFINE vcUserError        	varchar(10);
   
   -- var's para obtener las fechas de vencimiento del período de inscripción
   DEFINE vd_fecha_presentac, vd_prorroga_hasta , vd_fecha_cier_reqp, vd_fecha_cier_ree, vd_fecha_testeo DATE;
   DEFINE ls_periodo_insc	LIKE sga_periodo_insc.periodo_inscripcio;

   -- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET iStatus = -1 ;
      LET vcMsg = '800321,' || 'ctr_requisitos_ua,' || sql_err || ' - '  || error_info ;

      RETURN iStatus, vcMsg;
   END EXCEPTION;

BEGIN

   -- seteo los valores default
   LET iStatus = 1;
   LET vcMsg = '800320';
 
   -- Obtener el período de inscripción del aspirante a carrera. Resultado de aspirante = 'A'.
   SELECT	periodo_inscripcio
   INTO		ls_periodo_insc
   FROM		sga_carrera_aspira casp,
   		sga_situacion_asp sa
   WHERE	casp.unidad_academica = pUnidadAcademica
   AND		casp.carrera = pCarrera
   AND		casp.nro_inscripcion = pNroInscripcion
   AND		casp.situacion_asp = sa.situacion_asp
   AND		sa.resultado_asp = 'A';
 
   -- En caso de no encontrar período de inscripción, por ende no se debería controlar requisitos ya
   -- que no se considera aspirante a carrera.
   IF ls_periodo_insc is null THEN
   	RETURN iStatus, vcMsg ;
   END IF;
 
   ---------------------------------------------------------------------------------------------------------
   -- Controlar si estan todos los requisitos obligatorios del alumno presentados.
   ---------------------------------------------------------------------------------------------------------
FOREACH SELECT fecha_presentacion, f_prorroga_hasta , spi.fecha_cierre_req, date(sfer.fecha_cierre_req)
	INTO vd_fecha_presentac, vd_prorroga_hasta, vd_fecha_cier_reqp, vd_fecha_cier_ree
	FROM sga_carrera_aspira as sca, 
		sga_req_cumplidos as src, 
		sga_periodo_insc as spi, 
		sga_requisitos_ua sru,
		OUTER sga_fec_excep_req as sfer
	WHERE src.unidad_academica = sca.unidad_academica
		and src.nro_inscripcion = sca.nro_inscripcion
		and src.carrera = sca.carrera

		and spi.periodo_inscripcio	= sca.periodo_inscripcio

		and sca.periodo_inscripcio	= sfer.periodo_inscripcio
		and src.requisito 		= sfer.requisito
		-- U820 **********************
		-- El original no consideraba los req. Obligatorios
		and src.obligatoriedad = 'S'
		-- U820 **********************

		and (src.exceptuado IS NULL OR src.exceptuado <>'S')
		and sca.unidad_academica	= punidadacademica
		and sca.nro_inscripcion 	= pnroinscripcion
		and sca.carrera 		= pcarrera
		and sca.periodo_inscripcio	= ls_periodo_insc

		and src.unidad_academica = sru.unidad_academica
		and src.requisito = sru.requisito

	-- Si la prorroga no es nula va la prorroga
	IF vd_prorroga_hasta IS NOT NULL THEN
		LET vd_fecha_testeo = vd_prorroga_hasta;
	ELSE
		-- Recupero la fecha fin de presentacion del requisito
		IF vd_fecha_cier_ree IS NOT NULL THEN
			LET vd_fecha_testeo = vd_fecha_cier_ree;
		ELSE
			LET vd_fecha_testeo = vd_fecha_cier_reqp;
		END IF;
	END IF;

	-- si la fecha a testear es igual o posterior a hoy no hago nada
	IF vd_fecha_testeo >= TODAY then
		continue foreach;
	END IF

	-- aca llego si la fecha de testeo es anterior a hoy
	-- si no lo presentó
	IF vd_fecha_presentac IS NULL THEN
		LET iStatus = -1 ;
		LET vcMsg = '800605';
		exit foreach;
	END IF

	-- si lo presentó fuera de término

	-- Se modifica para controlar solamente si esta o no presentado
	-- U820 **********************
	-- IF vd_fecha_presentac > vd_fecha_testeo  THEN
	--	LET iStatus = -1 ;
	--	LET vcMsg = '800665';
	--	exit foreach;
	-- END IF;
	-- U820 **********************

END FOREACH;

RETURN iStatus, vcMsg ;

END;
END PROCEDURE;
-- ********************** Fin del procedure ctr_requisitos_ua **********************
