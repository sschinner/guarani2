CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_i_reinsc_anio') THEN
		DROP PROCEDURE sp820_i_reinsc_anio;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ***********************************************************************************
-- SIU-GUARANI
-- 
-- Procedure sp820_i_reinsc_anio: 
-- Registra la Re-inscripcion Anual a una Carrera
--
-- Version 1.8
-- 
-- Modificaci�n: 2.5: Ahora retorna el nro de transacci�n generado por sp_nroTransaccAG. 
-- 
-- Modificaci�n: 2.5.1: Se agreg� la fecha de la transaccion. El nro de transaccion 
--                      ahora forma parte del mensaje, para homologar con los demas SPs 
--                      que retornan nros de transaccion.  
-- 
-- U820 SP asociado al WS de reinscripci�n. 
-- Se agregan parametros para registrar datos de fecha y transacci�n enviadas por el origen respecto de la reinscripci�n
-- ***********************************************************************************
-- DROP PROCEDURE "dba".sp820_i_reinsc_anio;
CREATE PROCEDURE "dba".sp820_i_reinsc_anio(pUA       LIKE sga_reinscripcion.unidad_academica,
                                  pCarrera  LIKE sga_reinscripcion.carrera,
                                  pLegajo   LIKE sga_reinscripcion.legajo,
                                  pInterfaz LIKE sga_reinscripcion.interfaz,
                                  pAnioAcad LIKE sga_reinscripcion.anio_academico,
					pFechaHora LIKE sga_reinscripcion.fecha_reinscrip,
					pNroTransaccion varchar(20)
                                 ) 
                RETURNING INTEGER,      -- status -1 Error/ 0 OK
                          VARCHAR(255);  -- mensaje 

-- vars para el manejo de excepciones;
DEFINE SQLErr       INTEGER;
DEFINE ISAMError    INTEGER;
DEFINE errorInfo    VARCHAR(76);
DEFINE vcUserError  VARCHAR(10);

-- vars locales;
DEFINE  iStatus     INTEGER;
DEFINE  iStatusCall SMALLINT;
DEFINE  vcMsg       VARCHAR(255);
DEFINE  iOK         SMALLINT;

-- vars locales;
DEFINE  vcNroTrans  LIKE sga_reinscripcion.nro_transaccion;
DEFINE  vdFecInic   LIKE sga_anio_academico.fecha_inicio;

DEFINE  v_count     INTEGER;
-- DEFINE  dtrans      DATETIME HOUR TO SECOND;

-- si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
  LET vcUserError  = 'Error de procedimiento.';
  LET iStatus      = 4; 
  LET vcMsg        =  vcUserError || ',' || SQLErr || ' - ' || errorInfo;
  RETURN iStatus, vcMsg;
  RAISE EXCEPTION  SQLErr, ISAMError, errorInfo ;
END EXCEPTION;

BEGIN
  LET vdFecInic = NULL;
  LET iStatus   = 0;
  LET vcMsg     = 'OK';
  LET vcUserError  = '800457';
   
  SELECT COUNT(*)
    INTO v_count
    FROM sga_reinscripcion
   WHERE unidad_academica = pUA 
     AND carrera          = pCarrera 
     AND legajo           = pLegajo 
     AND anio_academico   = pAnioAcad;
  
  --Si ya tiene una reiscripcion no hace nada
  IF v_count = 0 then

    -- obtengo Nro. de Transaccion en caso que no venga; Si la Reinscripci�n viene de un sistema externo, se solicita que se env�a una SIGLA del mismo como nro. transacci�n.

    IF pNroTransaccion IS NUll THEN
	    EXECUTE PROCEDURE sp_nroTransaccAG( ) INTO vcNroTrans;
    ELSE 
	    LET vcNroTrans = pNroTransaccion;
    END IF;
    
    -- agrego la inscripcion ;
    INSERT INTO sga_reinscripcion (unidad_academica,
                                   carrera         ,
                                   legajo          ,
                                   anio_academico  ,
                                   fecha_reinscrip ,
                                   nro_transaccion ,
                                   interfaz)
    VALUES (pUA, 
            pCarrera, 
            pLegajo, 
            pAnioAcad,
		pFechaHora,
            vcNroTrans, 
            pInterfaz);

    LET iStatus         = 0;
    LET vcMsg = vcUserError || ',' || vcNroTrans || ',' || pFechaHora;

  END IF 

RETURN iStatus, vcMsg;
END;
END PROCEDURE;
-- ******************** FIN DEL PROCEDURE sp_i_reinsc_anio ******************** 

 --execute PROCEDURE sp820_i_reinsc_anio('FICH','03','23552487-9','3','2014','','254');

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_i_reinsc_anio 
-- *****************************************************************************
revoke execute on "dba".sp820_i_reinsc_anio from public;
grant execute on "dba".sp820_i_reinsc_anio to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_i_reinsc_anio to internet; -- Rol de usuario de Internet