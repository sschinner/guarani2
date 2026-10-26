CREATE PROCEDURE verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr_corrinscurfech') THEN
		DROP PROCEDURE ctr_corrInsCurFech;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE verifica_objeto();
DROP PROCEDURE verifica_objeto();

-- **************************************************************************
-- Control: ctr_corrInsCurFech
-- Version de creacion: 2.05.0
-- Ultima version de modificacion:
--
-- Controla las correlativas para cursar una Materia
-- Si no cumple con alguna correlativa, devuelve todas las materias que no 
-- cumple con las correlativas, sino devuelve 1 - OK
-- **************************************************************************
-- DROP PROCEDURE ctr_corrInsCurFech;
CREATE PROCEDURE ctr_corrInsCurFech ( 	pUnidadAcademica 	LIKE sga_alumnos.unidad_academica,
					pCarrera	 		LIKE sga_alumnos.carrera,
					pLegajo  			LIKE sga_alumnos.legajo,
					pMateria 			LIKE sga_materias.materia,
					pfecha			varchar(10))
	RETURNING 	smallint, 		-- status
			varchar(255);	-- <mensaje, parametros>

  /*  controla correlativas comunes de la materia para inscribirse a cursar la materia
       devuelve:  1 - si esta OK            y msg
	        -1 - en otro caso        y msg con la materia anterior no aprobada 
       NOTA: es una lista de materias en el caso que no tenga todas las correlatividades */	

  -- vars para la respuesta
  DEFINE iStatus 		smallint		;	-- status
  DEFINE cHayError      Char(1)         ;   
  DEFINE vcMsg 		varchar(255)	;	-- mensaje y parametros

  -- var's para el manejo de excepciones
   DEFINE sql_err 		integer		;
   DEFINE isam_err 		integer		;
   DEFINE error_info 	varchar(76)	;
   DEFINE vcUserError	varchar(10) 	;

  --vars locales
   DEFINE  vcValorParam 		varchar(40)			 ;
   DEFINE  vcPlan			LIKE sga_planes.plan 		 ;
   DEFINE  vcVersion		LIKE sga_planes.version_actual 	 ;
   DEFINE  vcMateriaAnterior		LIKE sga_materias.materia  ;
   DEFINE  vcFalloEnCorre        varchar(255) ;  
--   DEFINE  vcFalloEn		varchar(10)  ;  -- mantiene si sp_correlativasOK fallo en la cursada o en la aprobacion
   DEFINE   dFecha   date;   

   -- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info                                        
     LET iStatus = -1 ;
     LET vcMsg = '800321' || ',' || 'corrInscCurs' || ',' || sql_err || ' - '  || error_info ; 	
     RETURN iStatus, vcMsg;
   END EXCEPTION;        


BEGIN
   -- seteo los valores default
   LET vcPlan		= NULL	;
   LET vcVersion		= NULL	;
   LET vcMateriaAnterior	= NULL	;
   LET vcMsg		= NULL 	;
   LET cHayError           =  'N'    ;
   -- Variables de Retorno
   LET iStatus  = 1;
   LET vcMsg  =   '800320'  ;
   Let dFecha = to_date( pFecha, "%d-%m-%Y");

   -- recupero el (plan, version) actual de la carrera
   EXECUTE PROCEDURE sp_plan_de_alumno (pUnidadAcademica, pCarrera, pLegajo, dFecha ) INTO vcPlan, vcVersion;
   IF (vcPlan IS NULL OR vcVersion IS NULL) THEN
      LET iStatus 	= -1; 
      LET vcMsg 	= '800361' || ',' || pLegajo ;   
      RETURN iStatus, vcMsg;
   END IF ;


   
  FOREACH EXECUTE PROCEDURE sp_correlativasd(pUnidadAcademica, pCarrera, pLegajo, pMateria, vcPlan, vcVersion,dFecha, 'C')  INTO iStatus,  vcMsg
    IF iStatus = 1 THEN	-- si esta OK salgo y continua con correlativas especiales
	LET vcMsg =   '800320'  ;
    ELSE		-- sino, devuelvo todas las materias que le faltan
	LET vcMsg = '-746,' || vcMsg; 
	LET cHayError =  'S' ;
	RETURN iStatus, vcMsg WITH RESUME; 
    END IF ;	
   END FOREACH;

   If cHayError = 'N' Then
	-- Ejecutar SP correlativas especiales
	EXECUTE PROCEDURE sp_correlativa_esp(pUnidadAcademica, pCarrera, pLegajo, pMateria, vcPlan, vcVersion, dFecha, 'C') 
                INTO iStatus,  vcFalloEnCorre ;

	IF iStatus = 1 THEN	-- si esta OK salgo
              LET vcMsg =   '800320'  ;
        ELSE		-- sino, devuelvo todas las materias que le faltan
              LET vcMsg = vcFalloEnCorre ;
        END IF ;	

        RETURN iStatus, vcMsg;
   End If;

END;
END PROCEDURE;
-- ************************* Fin Proceso ctr_corrInsCurFech ************************* 

