CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_cuposubcom') THEN
		DROP PROCEDURE ctr820_cupoSubCom;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();
 
-- Creating procedure
CREATE PROCEDURE "dba".ctr820_cupoSubCom( pComision 	LIKE sga_comisiones.comision,
					pSubcomision	LIKE sga_subcomisiones.subcomision)
					
	RETURNING 	smallint, 		-- status
			varchar(255);	-- <mensaje, parametros>

/* La capacidad de la Subcomisión debe ser mayor que la cantidad de inscripciones para admitir una nueva inscripción 

CORR 1: fue modificado para que en vez de retornar el id de la comision retorne el nombre de la misma  (29/05/2000) */

  -- vars para la respuesta
  DEFINE iStatus 		smallint			;	-- status
  DEFINE vcMsg 		varchar(255)		;	-- mensaje y parametros

  -- var's para el manejo de excepciones
   DEFINE sql_err 		integer		;
   DEFINE isam_err 		integer		;
   DEFINE error_info 	varchar(76)	;
   DEFINE vcUserError	varchar(10) 	;

  DEFINE iCupo		LIKE  sga_comisiones.capacidad 	;
  DEFINE vcMateria		LIKE  sga_materias.materia 		;
  DEFINE vcNombreMat	LIKE  sga_materias.nombre 		;
  DEFINE vcNombreCom	LIKE  sga_comisiones.nombre 	;
  DEFINE iCantInscriptos	integer 				;

   -- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info                                        
     LET iStatus = -1 ;
     LET vcMsg = '800321' || ',' || 'cupoComision' || ',' || sql_err || ' - '  || error_info ; 	
     RETURN iStatus, vcMsg ;
   END EXCEPTION;        

BEGIN
   -- inicializo con OK, porque puede ser que termine sin llegar al final
   LET iStatus = 1 		;
   LET vcMsg = '800320' 	;

   -- recupero la cantidad maxima de inscripciones de la comision 
   SELECT c.capacidad, 
	  c.nombre
   INTO iCupo, 
	vcNombreCom 
      FROM sga_subcomisiones c
   WHERE c.comision                 = pComision
	 and c.subcomision = pSubcomision; 	

   -- si no existe la comision...
   IF DBINFO("SQLCA.SQLErrD2") <= 0 THEN
     LET iStatus = -1 ;
     LET vcMsg = '800365' || ',' || pComision ; 	
     RETURN iStatus, vcMsg ;
   END IF;

   -- si el cupo de la comision es NULL no restringe nada
   IF iCupo IS NULL THEN
      RETURN iStatus, vcMsg ;
   END IF;

   -- cuento la cantidad de alumnos inscriptos para cursar en esa comision
   SELECT COUNT(i.legajo)
       INTO iCantInscriptos
      FROM sga_insc_subcom i
   WHERE i.comision = pComision
	 and i.subcomision= pSubcomision; 	 
	
   -- comparo la cantidad de inscriptos con el cupo	
   IF iCantInscriptos >= iCupo THEN
     LET iStatus = -1 ;
     LET vcMsg = '800369' || ',' || vcNombreCom || ',' || iCupo; 	
     RETURN iStatus, vcMsg ;
   END IF;

      RETURN iStatus, vcMsg ;
END;

END PROCEDURE;
-- ******************** Fin del control "dba".ctr820_cupoSubCom *********************

-- *****************************************************************************
-- Permisos del Control "dba".ctr820_cupoSubCom
-- *****************************************************************************
revoke execute on "dba".ctr820_cupoSubCom from public;
grant execute on "dba".ctr820_cupoSubCom to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_cupo_subcomi to internet; -- Rol de usuario de Internet