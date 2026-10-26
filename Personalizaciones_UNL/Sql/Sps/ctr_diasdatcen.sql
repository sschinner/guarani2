CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr_diasdatcen') THEN
		DROP PROCEDURE ctr_diasdatcen;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.8.0, 2.09.0
-- Procedure: ctr_diasdatcen
-- 
-- Controla que la persona haya actualizado sus datos censales en funcion del parametro
-- de cantidad minima de dias de antiguedad de los datos censales
-- 
-- *****************************************************************************

CREATE PROCEDURE "dba".ctr_diasdatcen(
	pUnidadAcademica  LIKE sga_personas.unidad_academica,
	pNroInscripcion   LIKE sga_personas.nro_inscripcion,
	pOperacion        LIKE acc_operaciones.operacion )
	RETURNING smallint, varchar(255);

-- vars para la respuesta
DEFINE iStatus             smallint;
DEFINE vcMsg               varchar(255);

-- vars para el manejo de excepciones
DEFINE sql_err             integer;
DEFINE isam_err            integer;
DEFINE error_info          varchar(76);

-- vars locales

DEFINE dFechaAct       like sga_datos_censales.fecha_actualiz;
DEFINE iCantDiasDc        integer;
DEFINE iCantDiasPar       integer;

-- blk de excepciones
ON EXCEPTION SET sql_err, isam_err, error_info
   -- RAISE EXCEPTION  sql_err, isam_err, error_info;
   LET iStatus = -1 ;
   LET vcMsg = '800321' || ',' || 'diasdatcen' || ',' || sql_err || ' - '  || error_info ;
   RETURN iStatus, vcMsg ;
END EXCEPTION;

BEGIN
   
-- Verifico el parametro 
EXECUTE PROCEDURE sp_param_sistema('cantidad_dias_controla_datos_censales') INTO iCantDiasPar;

-- U820: Control para eximir de completar datos censales a alumnos Externos.
-- Verifico si el alumno esta en alguna carrera gestionada por la facultad (grupo: 00001).
IF EXISTS (SELECT '*' FROM
		sga_personas per
			join sga_carrera_aspira car
				on per.nro_inscripcion = car.nro_inscripcion
			join sga_carreras_grupo cg
				on car.carrera = cg.carrera
		WHERE cg.grupo_carrera = '00001'
			AND car.situacion_asp in ('IL', 'IC')
			AND per.nro_inscripcion = pNroInscripcion) THEN

    -- Cantidad de dias desde la última actualizacion de los datos censales.
        SELECT (TODAY - fecha_actualiz)
              INTO iCantDiasDc
              FROM sga_datos_censales
                 WHERE unidad_academica = pUnidadAcademica
                   AND nro_inscripcion = pNroInscripcion
                   AND fecha_relevamiento = (SELECT MAX(fecha_relevamiento)
                                           FROM sga_datos_censales as dc2
                                          WHERE dc2.unidad_academica = sga_datos_censales.unidad_academica
                                            AND dc2.nro_inscripcion = sga_datos_censales.nro_inscripcion
                                         );
        IF iCantDiasDc IS NULL THEN
                LET iCantDiasDc = 1000;
        END IF;

        IF ( iCantDiasDc > iCantDiasPar ) THEN
                LET iStatus = -1;
                LET vcMsg = '800725, ' || iCantDiasDc;
        
        ELSE 
        -- OK
                LET iStatus = 1;
                LET vcMsg = '800320';
        END IF;

ELSE
      -- OK: EL ALUMNO NO PERTENECE A UNA CARRERA GESTIONADA POR LA FACULTAD
      LET iStatus = 1;
      LET vcMsg = '800320';
END IF;
   
RETURN iStatus, vcMsg;
   
END;
END PROCEDURE;
-- ************************* Procedure ctr_diasdatcen *************************

-- *****************************************************************************
revoke execute on "dba".ctr_diasdatcen from public;
grant execute on "dba".ctr_diasdatcen to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ctr_diasdatcen to internet; -- Rol de usuario de Internet
