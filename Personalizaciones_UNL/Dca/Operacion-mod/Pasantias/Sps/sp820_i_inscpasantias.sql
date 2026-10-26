-- *******************************************************************************
-- SP: sp820_i_inscPasantias
-- 
-- Registra una Inscripcion a Pasantias
--
-- *******************************************************************************
DROP PROCEDURE sp820_i_inscPasantias;
CREATE PROCEDURE "dba".sp820_i_inscPasantias(
				pUnidadAcademica		LIKE sga_alumnos.unidad_academica,
				pNroInscripcion		LIKE sga_alumnos.nro_inscripcion,
				pLegajo			LIKE sga_alumnos.legajo,
				pCarrera			LIKE sga_alumnos.carrera,
				pPlan			LIKE sga_alumnos.plan,
				pIdPasantia 		LIKE u820_pasantias.id_pasantia,
				pInterfaz			LIKE  sga_insc_examen.interfaz )

RETURNING	smallint,		-- status -1 Error/ 1 OK
		varchar(255);	-- mensaje 

-- vars para el manejo de excepciones

DEFINE 	ISAMError, SQLErr integer;
DEFINE 	errorInfo 	varchar(76);
DEFINE	vcUserError	varchar(10);

-- vars locales
DEFINE 	iStatus smallint;
DEFINE 	vcMsg varchar(255);

   -- vars locales
DEFINE  vcUnidadAcademica	LIKE sga_insc_examen.unidad_academica;
DEFINE	vcCarrera	LIKE sga_insc_examen.carrera;
DEFINE   vcLegajo	LIKE sga_insc_examen.legajo;
DEFINE   vcVersion		LIKE sga_versiones_plan.version;
DEFINE 	vcEstado	LIKE sga_insc_examen.estado;
DEFINE	vcNroTransaccion	LIKE sga_insc_examen.nro_transaccion; 

  -- si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
	LET vcUserError  = '800401' ;
	LET iStatus 	  = -1; 
	LET vcMsg 	  =  vcUserError || ',' || SQLErr || ' - ' || errorInfo;
	RETURN iStatus, vcMsg;
END EXCEPTION;

BEGIN

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--	                      ¡¡¡ Controles Obligatorios !!!
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- 1) NO esté inscripto en la pasantía
BEGIN
	if exists(	SELECT id_pasantia
		FROM u820_insc_pas
		WHERE unidad_academica = pUnidadAcademica 
			AND  id_pasantia = pIdPasantia
			AND  nro_inscripcion = pNroInscripcion) then

	      LET vcUserError  = '800420' ;
	      LET iStatus 	  = -1; 
	      LET vcMsg 	  =  vcUserError;
	      RETURN iStatus, vcMsg;
	END IF;
END;

-- Estado en que debe quedar la Inscripcion a Examen (Pendiente o Aceptada). 
-- Por el momento quedan en estado Pendiente.

LET vcEstado = "P";

-- defino el estado de la Inscripcion segun lo que recibio el procedure y lo que indica el parametro del sistema
-- IF vcEstado = 'A' THEN	-- si los controles pasaron todos OK
--	-- verifico como deberia quedar la finalmente ls inscripcion si paso todos los controles.
--	EXECUTE PROCEDURE sp_param_sistema(pInterfaz || '_estado_final_insc_examen') INTO vcEstado;
-- END IF ;

-- Obtengo Nro. de Transaccion segun interfase
EXECUTE PROCEDURE sp_nroTransaccAG() INTO vcNroTransaccion ;


-- Agrego la inscripcion de Examen
INSERT INTO u820_insc_pas
		(unidad_academica, nro_inscripcion, legajo, carrera, plan, id_pasantia, fecha_inscripcion, nro_transaccion, interfaz, estado)
	VALUES (pUnidadacademica, pNroInscripcion, pLegajo, pCarrera, pPlan, pIdPasantia, Current Year to Second, vcNroTransaccion, pInterfaz, vcEstado);

-- si llego hasta aca, esta todo OK
LET iStatus 	= 1; 
IF vcEstado = 'A' THEN
	LET vcUserError  = '800400' ;
ELSE
	-- Insc Pendiente
	LET vcUserError  = '820004' ;
END IF;
LET vcMsg 	=  vcUserError || ',' || vcNroTransaccion ;

-- devuelvo el resultado
RETURN iStatus, vcMsg;
END;

END PROCEDURE;
-- ++++++++++++++++++++++++++++++++++++++++++++++ FIN SP sp820_i_inscPasantias +++++++++++++++++++++++++++++++++++++++

