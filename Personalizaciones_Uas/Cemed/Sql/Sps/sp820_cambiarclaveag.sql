CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
  FROM sysprocedures
  WHERE procname = 'sp820_cambiarclaveag') THEN
 DROP PROCEDURE sp820_cambiarclaveag;
	END IF; 
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ***************** COMIENZO DEL PROCEDURE sp820_cambiarClaveAG ***************** 
-- Dropping procedure

-- Creating procedure
CREATE PROCEDURE "dba".sp820_cambiarClaveAG( pUnidadAcademica  LIKE aca_usuarios_ag.unidad_academica, 
                                    pIdentificacion   LIKE aca_usuarios_ag.identificacion,
                                    pClaveNueva       LIKE aca_usuarios_ag.clave,
                                    pInterfaz         LIKE par_interfaces.interfaz )
       RETURNING smallint,      -- status  -1 fallo / 0 OK
                 varchar(255);  -- mensaje 

/* Permite cambiar la clave de un usuario de AutoGestion, previamente la interfase dipara si hay controles configurables */
   -- vars para el manejo de excepciones
   DEFINE  SQLErr  integer;
   DEFINE  ISAMError	integer;
   DEFINE  errorInfo  varchar(76);
   DEFINE	vcUserError	varchar(10);

   -- vars para devolver resultado
   DEFINE  iStatus  smallint ;
   DEFINE  vcMsg  varchar(255) ;

   -- vars locales
   DEFINE  vcPwd LIKE aca_usuarios_ag.clave;
   DEFINE	dFecUltActualiz	date;
   DEFINE	dFecActual	date;
   DEFINE	iIntentos LIKE aca_usuarios_ag.intentos_fallidos;
   DEFINE	cBloqueada	LIKE aca_usuarios_ag.bloqueado;
   DEFINE	cSoloDigitos	char(1);

  -- si hay algun error
ON EXCEPTION SET iStatus , ISAMError, vcMsg
   RETURN  iStatus, vcMsg;
END EXCEPTION;

BEGIN
   -- seteo el status a OK
   LET iStatus	= 0;
   LET vcMsg  = 'OK' ;

IF EXISTS (SELECT '*' FROM aca_usuarios_ag
	   WHERE unidad_academica = pUnidadAcademica
 AND identificacion	 = pIdentificacion) THEN
   -- actualizo. NO LLEVA a 0 la cantidad de intentos fallidos
   UPDATE  aca_usuarios_ag 
           SET clave  = pClaveNueva, 
                fec_ult_actualiz  = CURRENT YEAR TO SECOND,
	    intentos_fallidos = 0

   WHERE unidad_academica = pUnidadAcademica
         AND identificacion	 = pIdentificacion;
ELSE
   LET iStatus	= -1;
   LET vcMsg 	= 'No existe el usuario al cual se desea cambiar la clave' || ' - ' || pUnidadAcademica || ' - ' || pIdentificacion;

END IF;


    -- devueve el status y el msg
   RETURN iStatus, vcMsg ;

END;
END PROCEDURE;
-- ***************** FIN DEL PROCEDURE sp820_cambiarClaveAG ***************** 
-- **********************************************************************

-- *****************************************************************************
-- Permisos del procedimiento
-- *****************************************************************************
revoke execute on "dba".sp820_cambiarClaveAG from public;
grant execute on "dba".sp820_cambiarClaveAG to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_cambiarClaveAG to internet; -- Rol de usuario de Internet
grant execute on "dba".sp820_cambiarClaveAG to siguv_consulta; -- Rol de usuarios de SIGUV
grant execute on "dba".sp820_cambiarClaveAG to ue_siguv_guarani; -- Rol de usuarios de SIGUV

