-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.7.0. Ultima version de modificacion: 2.0.0
--
-- SP: sp820_d_inscpas
-- Anula una Inscripcion a Pasantía. 
-- Por el momento no se registra la baja en una tabla de bajas como se hace para examenes.
-- La fecha en que se está dando de baja la
-- inscripción debe ser menor que la fecha tope para bajas en esa pasantia.
-- Recibe: - UA, nro_inscripcion, id_pasantia, interfaz -
-- 
-- Retorna: Estado del DELETE
-- *****************************************************************************
-- DROP PROCEDURE sp820_d_inscpas;

CREATE PROCEDURE sp820_d_inscpas( pUnidadAcademica LIKE sga_alumnos.unidad_academica,
					pNroInscripcion LIKE sga_personas.nro_inscripcion,
					pIdPasantia LIKE u820_pasantias.id_pasantia,
					pInterfase LIKE sga_insc_examen.interfaz )

 RETURNING  	smallint,		-- status -1 Error/ 1 OK
	           	varchar(255);	-- mensaje 

   -- vars para el manejo de excepciones
   DEFINE 	SQLErr, ISAMError	integer		;
   DEFINE 	errorInfo 		varchar(76)	;
   DEFINE	vcUserError	varchar(10)	;

   -- vars locales
   DEFINE 	iStatus 		smallint		;
   DEFINE 	vcMsg 		varchar(255)	;
   DEFINE 	iOK		smallint		;


DEFINE	vcNroTransacbaja	LIKE u820_insc_pas.nro_transaccion	; 
DEFINE	vcNroTransaccion	LIKE u820_insc_pas.nro_transaccion	; 
DEFINE	iInterfaz		LIKE u820_insc_pas.interfaz;	
DEFINE vcLegajo LIKE u820_insc_pas.legajo;
DEFINE	vcCarrera LIKE u820_insc_pas.carrera;
DEFINE	vcPlan LIKE u820_insc_pas.Plan;
DEFINE	viIdPasantia LIKE u820_insc_pas.id_pasantia;
DEFINE	  dFecInscripcion datetime year to second;
DEFINE	  vcEstado LIKE u820_insc_pas.estado;
DEFINE 	dFecTopeBajaInsc	LIKE u820_pasantias.FECHA_TOPE_BAJAS;


  -- si hay algun error
  ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
      LET vcUserError  = '800402' ;
      LET iStatus 	  = -1; 
      LET vcMsg 	  =  vcUserError || ',' || SQLErr || ' - ' || errorInfo;
      RETURN iStatus, vcMsg;
--      RAISE EXCEPTION  SQLErr, ISAMError, errorInfo ;
   END EXCEPTION;

BEGIN

let vcNroTransacbaja = null; 
let vcNroTransaccion = null; 
let iInterfaz = null;	
let vcLegajo= null;
let vcCarrera = null;
let vcPlan = null;
let viIdPasantia = null;
let dFecInscripcion = null;
let vcEstado = null;
let dFecTopeBajaInsc = null;

  -- Recupero datos de la inscripcion a pasantia a eliminar
   SELECT legajo, 				  
	carrera, 
	plan, 
	id_pasantia,
	fecha_inscripcion,
	NRO_TRANSACCION,
	INTERFAZ,
	ESTADO
       INTO  vcLegajo,
	vcCarrera,
	vcPlan,
	viIdPasantia,
	 dFecInscripcion,
	  vcNroTransaccion,
	  iInterfaz,
	  vcEstado
      FROM u820_insc_pas
   WHERE unidad_academica = pUnidadAcademica
         AND nro_inscripcion = pNroInscripcion
         AND id_pasantia = pIdPasantia;

    -- verifico que haya recuperado solo una inscripcion a cursada
    IF DBINFO("SQLCA.SQLErrd2") <> 1 THEN
       LET vcUserError  = '800403' ;
       LET iStatus 	  = -1; 
       LET vcMsg 	  =  vcUserError || ',' || pIdPasantia  || ',' || pIdPasantia || ',' || pIdPasantia ;
       RETURN iStatus, vcMsg;
    END IF ;	

   -- *****************   Controles Obligatorios !!! **********************************************
   -- TODAY debe ser menor o igual a la Fecha Tope para Bajas de inscripciones
   -- recupero la fecha tope de bajas de inscripciones para la comision
   -- **************************************************************************************

        -- Busca la fecha de tope de baja en la definicion de la pasantia

        SELECT fecha_tope_bajas
          INTO  dFecTopeBajaInsc
          FROM u820_pasantias
         WHERE unidad_academica = pUnidadAcademica
           AND  id_pasantia = pIdPasantia ;

      -- si ya paso la fecha tope de bajas para esa comision para cuando fue realizada la inscripcion
      IF TODAY >  dFecTopeBajaInsc THEN
         LET vcUserError  = '800404' ;
         LET iStatus 	  = -1; 
         LET vcMsg 	  =  vcUserError  || ',' || pIdPasantia  || ',' || pIdPasantia || ',' || dFecTopeBajaInsc;
         RETURN iStatus, vcMsg;
      END IF ;



   -- ************************* FIN CONTROLES OBLIGATORIOS *************************************************************

  --  El manejo de la transaccion lo hace la interface
   -- elimino la inscripcion.
   DELETE FROM u820_insc_pas
               WHERE unidad_academica 	= pUnidadAcademica
		AND nro_inscripcion = pNroInscripcion
		AND id_pasantia = pIdPasantia;
   -- obtengo el Nro. de Transaccion para la anulacion de la inscripcion
   EXECUTE PROCEDURE sp_nroTransaccAG( ) INTO vcNroTransacBaja ;

   -- agrego la baja de la inscripcion
   INSERT INTO u820_insc_baja_pas (unidad_academica, 
				nro_inscripcion,
				legajo, 				  
				carrera, 
				plan, 
				id_pasantia,
				fecha_inscripcion,
				NRO_TRANSACCION,
				INTERFAZ,
				ESTADO,
				FECHA_BAJA,
				NRO_TRANSAC_BAJA,
				INTERFAZ_BAJA )
			
               		VALUES (pUnidadAcademica, 
				pNroInscripcion, 
				vcLegajo,
				vcCarrera, 
				vcPlan,
				viIdPasantia,
				dFecInscripcion, 
				vcNroTransaccion, 
				iInterfaz,
				vcEstado,
				CURRENT year TO second, 
				vcNroTransacBaja,
				pInterfase ) ;

   -- si llego hasta aca, esta todo OK
   LET vcUserError  = '820005' ;
   LET iStatus 	= 1; 
   LET vcMsg 	=  vcUserError || ',' || vcNroTransacBaja ;

   -- devuelvo el resultado
   RETURN iStatus, vcMsg;

END;
END PROCEDURE;
-- ****************** FIN PROCEDURE sp820_d_inscpas ******************


-- execute procedure sp820_d_inscpas ('FICH', '820', 1, 3);

