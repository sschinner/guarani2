CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_corcur_pro') THEN
		DROP PROCEDURE sp820_corcur_pro;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Control: ctr_correlativaiex
-- Ultima modificacion: Version 1.9
--
-- Controla las correlativas a Examen de una Materia. Segun parametro del sistema, controla con
-- el Plan-Version actual del Alumno, o con el Plan-Version con que curso la materia el Alumno.
-- Retorno:   *  1: OK    -1: Fallo Correlativa
--	     * Mensaje de Error.
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--DROP PROCEDURE "dba".sp820_corCur_Pro;
 
CREATE PROCEDURE "dba".sp820_corCur_Pro(
	pUnidadAcademica 	LIKE sga_alumnos.unidad_academica,
	pCarrera	 		LIKE sga_alumnos.carrera,
	pLegajo  			LIKE sga_alumnos.legajo,
	pMateria 			LIKE sga_materias.materia)
	RETURNING smallint; -- varchar(255);


-- vars para la respuesta
DEFINE iFalloControlcorr, iStatus 	smallint;	-- status
DEFINE vcMsg 		varchar(255);	-- mensaje y parametros

-- var's para el manejo de excepciones
DEFINE sql_err, isam_err 	integer;
DEFINE error_info 	varchar(76);
DEFINE vcUserError	varchar(10);


  --var's locales
   DEFINE  vcValorParam 	varchar(40)			 ;
   DEFINE  vcPlan		LIKE sga_planes.plan 		 ;
   DEFINE  vcVersion	LIKE sga_planes.version_actual 	 ;
   DEFINE  vcMateriaAnterior	LIKE sga_materias.materia  ;
   DEFINE  vcCondicionRendir	char(1);
   DEFINE  dFecRegularidad	LIKE sga_det_acta_curs.fecha_regularidad     ;
   DEFINE  sValorParam	varchar(20);
   DEFINE cFallo		varchar(10);
   DEFINE  vcFalloEnCorre        varchar(255)           ;  

DEFINE falloCorrelativa char(1);

 -- blk de excepciones
 ON EXCEPTION SET sql_err, isam_err, error_info                                        
   LET iStatus = -1 ;
   LET vcMsg = '800321' || ',' || 'correlativaiex' || ',' || sql_err || ' - '  || error_info ; 	
   RETURN iStatus; -- vcMsg ;
 END EXCEPTION;        

BEGIN
   -- inicializo con OK, porque puede ser que termine sin llegar al final
   LET iStatus = 1 ;
   LET vcMsg = '800320' ;

   -- recupero el (plan, version) actual de la carrera
   EXECUTE PROCEDURE sp_plan_de_alumno (pUnidadAcademica, pCarrera, pLegajo, TODAY ) INTO vcPlan, vcVersion;
   IF (vcPlan IS NULL OR vcVersion IS NULL) THEN
	LET iStatus = -1 ;
	LET vcMsg = '800361' || ',' || pLegajo; 	
	RETURN iStatus; -- vcMsg ;
   END IF ;

   LET falloCorrelativa = 'N';
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- controlo las correlatividades
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--   FOREACH EXECUTE PROCEDURE sp_correlativasOK(pUnidadAcademica, pCarrera, pLegajo, pMateria, vcPlan, vcVersion, 'R') INTO iFalloControlcorr, cFallo, vcMateriaAnterior 
--      IF iFalloControlcorr = 1 THEN
--	-- Tiene bien las correlativas. El sp solo devuelve una fila-
--	-- Retorno OK
--	Return iStatus, vcMsg WITH RESUME;
--      ELIF iFalloControlcorr = -1 THEN
--	-- No cumple con alguna correlativa	
--	LET falloCorrelativa = 'S';
--	LET iStatus = -1 ;
--	LET vcMsg = '800362' || ',' || cFallo || ',' || vcMateriaAnterior; 	
--	Return iStatus, vcMsg WITH RESUME;
--       END IF ;	
--   END FOREACH ;

 FOREACH EXECUTE PROCEDURE sp820_correlativas(pUnidadAcademica, pCarrera, pLegajo, pMateria, vcPlan, vcVersion, 'A')
	 INTO iFalloControlcorr,  vcMsg
     IF iFalloControlcorr = 1 THEN	-- si esta OK salgo y continua con correlativas especiales
	Return iStatus; -- vcMsg WITH RESUME;
     ELIF iFalloControlcorr = -1 THEN 	-- No cumple con las correlativas
	LET falloCorrelativa = 'S';
	LET iStatus =  -1 ;
	LET vcMsg = '-746,' || vcMsg; 
	RETURN iStatus; -- vcMsg  WITH RESUME ;  
     END IF ;	
  END FOREACH;

   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- veo si se acepta controlar correlativas con el plan, version con el que curso  la materia
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   EXECUTE PROCEDURE sp_param_sistema('controla_correlativas_actuales') INTO sValorParam ;
   IF sValorParam = 'N' THEN
   -- sino cumple con las correlativas en el (plan, version) actual, recupero todos los versiones en las que el alumno regularizo la materia ordenadas desde la    
   -- mas reciente
      FOREACH
         SELECT cur.version, cur.fecha_regularidad
              INTO vcVersion, dFecRegularidad
            FROM  sga_cursadas cur, sga_comisiones co
         WHERE cur.unidad_academica 	= pUnidadAcademica  
               AND cur.carrera 		= pCarrera  
               AND cur.plan		= vcPlan 		
               AND cur.legajo 		= pLegajo
               AND co.materia 		= pMateria  
               AND cur.comision 	= co.comision 
               AND cur.fecha_regularidad 	IS NOT NULL 
               AND cur.estado 		= 'A'  
               AND (cur.resultado = 'A'  or cur.resultado = 'P')
          ORDER BY  cur.fecha_regularidad DESC
      
--	-- FOREACH EXECUTE PROCEDURE sp_correlativasOK(pUnidadAcademica, pCarrera, pLegajo, pMateria, vcPlan, vcVersion, 'R') INTO iStatus, cFallo, vcMateriaAnterior 
--	-- IF iFalloControlcorr = 2 THEN
--	FOREACH EXECUTE PROCEDURE sp_correlativasOK(pUnidadAcademica, pCarrera, pLegajo, pMateria, vcPlan, vcVersion, 'R') INTO iFalloControlcorr, cFallo, vcMateriaAnterior 
--		IF iFalloControlcorr = -1 THEN
--		  -- No cumple con la correlativa	
--		  LET falloCorrelativa = 'S';
--		  LET iStatus = -1 ;
--		  LET vcMsg = '800362' || ',' || cFallo || ',' || vcMateriaAnterior; 	
--		  Return iStatus, vcMsg WITH RESUME;
--		END IF ;	
--	END FOREACH;

	 FOREACH EXECUTE PROCEDURE sp820_correlativas(pUnidadAcademica, pCarrera, pLegajo, pMateria, vcPlan, vcVersion, 'A')
		 INTO iFalloControlcorr,  vcMsg
	  IF iFalloControlcorr = -1 THEN 	-- No cumple con las correlativas
		LET falloCorrelativa = 'S';
		LET iStatus =  -1 ;
		LET vcMsg = '-746,' || vcMsg; 
		RETURN iStatus; -- vcMsg  WITH RESUME ;  
	  END IF ;	
	END FOREACH

      END FOREACH ; -- Lectura de las cursadas
      
      -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      -- COMIENZO TRATAMIENTO DE EQUIVALENCIA PARCIAL.
      -- verifico si la regularizacion fue por equivalencia parcial.
      -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      SELECT sga_equiv_parcial.version, sga_equiv_parcial.fecha 
        INTO vcVersion, dFecRegularidad
        FROM sga_equiv_parcial
       WHERE sga_equiv_parcial.unidad_academica = pUnidadAcademica
         AND sga_equiv_parcial.carrera = pCarrera
         AND sga_equiv_parcial.legajo  = pLegajo
         AND sga_equiv_parcial.materia  = pMateria
         AND sga_equiv_parcial.resultado = 'A'
         AND sga_equiv_parcial.estado = 'A' ;
	
      IF vcVersion IS NOT NULL THEN
--         -- FOREACH EXECUTE PROCEDURE sp_correlativasOK(pUnidadAcademica, pCarrera, pLegajo, pMateria, vcPlan, vcVersion, 'R') INTO iStatus, cFallo, vcMateriaAnterior 
--         --   IF iFalloControlcorr = 2 THEN
--         FOREACH EXECUTE PROCEDURE sp_correlativasOK(pUnidadAcademica, pCarrera, pLegajo, pMateria, vcPlan, vcVersion, 'R') INTO iFalloControlcorr, cFallo, vcMateriaAnterior 
--            IF iFalloControlcorr = -1 THEN
--               -- No cumple con la correlativa	
--               LET falloCorrelativa = 'S';
--               LET iStatus = -1 ;
--               LET vcMsg = '800362' || ',' || cFallo || ',' || vcMateriaAnterior; 	
--               Return iStatus, vcMsg WITH RESUME;
--            END IF ;	
--        END FOREACH;

	 FOREACH EXECUTE PROCEDURE sp820_correlativas(pUnidadAcademica, pCarrera, pLegajo, pMateria, vcPlan, vcVersion, 'A')
		 INTO iFalloControlcorr,  vcMsg
	    IF iFalloControlcorr = -1 THEN 	-- No cumple con las correlativas
		LET falloCorrelativa = 'S';
		LET iStatus =  -1 ;
		LET vcMsg = '-746,' || vcMsg; 
		RETURN iStatus; -- vcMsg WITH RESUME ; 
	    END IF ;	
	END FOREACH;
      END IF;  
      -- FIN TRATAMIENTO DE EQUIVALENCIA PARCIAL.
      
   END IF;  

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Controlo las correlativas Especiales.
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
IF falloCorrelativa = 'N' THEN
    EXECUTE PROCEDURE sp_correlativa_esp(pUnidadAcademica, pCarrera, pLegajo, pMateria, vcPlan, vcVersion, 'A') 
                INTO iStatus,  vcFalloEnCorre;

	IF iStatus = 1 THEN	-- si esta OK salgo
              LET vcMsg =   '800320'  ;
       ELSE     -- sino, devuelvo mensaje de error
              LET vcMsg = vcFalloEnCorre;
              LET iStatus = -1 ;
              LET falloCorrelativa = 'S';
              Return iStatus; -- vcMsg WITH RESUME;
       END IF ; 
END IF;

IF falloCorrelativa = 'N' THEN
	Return iStatus; -- vcMsg;
END IF;
   
END;
END PROCEDURE;


-- *************** Fin del procedimiento "dba".sp820_corCur_Pro ******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_corCur_Pro
-- *****************************************************************************
revoke execute on "dba".sp820_corCur_Pro from public;
grant execute on "dba".sp820_corCur_Pro to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_corCur_Pro to internet; -- Rol de usuario de Internet