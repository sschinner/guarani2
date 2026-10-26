CREATE PROCEDURE verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr_corre_iex_fech') THEN
		DROP PROCEDURE ctr_corre_iex_fech;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE verifica_objeto();
DROP PROCEDURE verifica_objeto();

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Control: ctr_corre_iex_fech
-- Version de creacion: 2.05.0
-- Ultima modificacion: 2.05.1
--
-- Controla las correlativas a Examen de una Materia en una fecha. Segun parametro del sistema ('controla_correlativas_actuales'), 
-- controla con el Plan-Version actual del Alumno, o con el Plan-Version con que curso la materia el Alumno.
-- Retorno:   *  1: OK    -1: Fallo Correlativa
--	     * Mensaje de Error.
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DROP PROCEDURE ctr_corre_iex_fech;
CREATE PROCEDURE ctr_corre_iex_fech(
	pUnidadAcademica 	LIKE sga_alumnos.unidad_academica,
	pCarrera	 		LIKE sga_alumnos.carrera,
	pLegajo  			LIKE sga_alumnos.legajo,
	pMateria 			LIKE sga_materias.materia,
	pfecha			varchar(10))
	RETURNING smallint, varchar(255);


-- vars para la respuesta
DEFINE iFalloControlcorr, iStatus 	smallint;	-- status
DEFINE vcMsg 		varchar(255);	-- mensaje y parametros

-- var's para el manejo de excepciones
DEFINE sql_err, isam_err 	integer;
DEFINE error_info 	varchar(76);
DEFINE vcUserError	varchar(10);


  --var's locales
   DEFINE  vcValorParam 	varchar(40);
   DEFINE  vcPlan, vcPlanRegular		LIKE sga_planes.plan;
   DEFINE  vcVersion, vcVersionRegular		LIKE sga_planes.version_actual;
   DEFINE  vcMateriaAnterior		LIKE sga_materias.materia  ;
   DEFINE  vcCondicionRendir	char(1);
   DEFINE  sValorParam	varchar(20);
   DEFINE cFallo		varchar(10);
   DEFINE  vcFalloEnCorre      varchar(255);  
   DEFINE vcRendirPlanAnt	LIKE sga_param_sistema.valor;
   DEFINE falloCorrelativa	char(1);
   DEFINE   dFecha   date;

 -- blk de excepciones
 ON EXCEPTION SET sql_err, isam_err, error_info                                        
   LET iStatus = -1 ;
   LET vcMsg = '800321' || ',' || 'correlativaiex' || ',' || sql_err || ' - '  || error_info ; 	
   RETURN iStatus, vcMsg ;
 END EXCEPTION;        

BEGIN
   -- inicializo con OK, porque puede ser que termine sin llegar al final
   LET iStatus = 1 ;
   LET vcMsg = '800320' ;

   Let dFecha = to_date( pFecha, "%d-%m-%Y");

   -- recupero el (plan, version) actual de la carrera
   EXECUTE PROCEDURE sp_plan_de_alumno (pUnidadAcademica, pCarrera, pLegajo, dFecha ) INTO vcPlan, vcVersion;
   IF (vcPlan IS NULL OR vcVersion IS NULL) THEN
	LET iStatus = -1 ;
	LET vcMsg = '800361' || ',' || pLegajo; 	
	RETURN iStatus, vcMsg ;
   END IF ;

   -- Verifico si la materia es del Plan Actual del Alumno, sino recupero plan y versoin con que la cursó
   -- Esto solo si la Unidad Academica permite Rendir materias de Planes Anteriores.
   IF (SELECT COUNT(*) FROM sga_atrib_mat_plan
	WHERE unidad_academica = pUnidadAcademica
	AND carrera = pCarrera
	AND plan      = vcPlan
	AND version = vcVersion
	AND materia = pMateria) = 0 THEN

	LET vcRendirPlanAnt = 'N';
	-- Verifico si el alumno puede rendir materias de planes anteriores.
	EXECUTE PROCEDURE sp_param_sistema('rendir_regul_planes_anteriores') INTO vcRendirPlanAnt;
	IF vcRendirPlanAnt <> 'S' THEN
		-- Error. la materia no es del Plan Actual del Alumno y no puede rendir materias de planes anteriores.
		LET iStatus = -1 ;
		LET vcMsg = '800000, La materia ' || pMateria || ' no es del Plan Actual del Alumno ' || pLegajo; 	
		RETURN iStatus, vcMsg ;
	END IF;

	-- Recupero Plan y Version con que regularizo la materia.
	EXECUTE PROCEDURE sp_planver_uregmat (pUnidadAcademica, pCarrera, pLegajo, pMateria) INTO vcPlan, vcVersion;
                IF vcPlan IS NULL OR vcVersion IS NULL THEN
		LET iStatus = -1 ;
		LET vcMsg = '800000, No se regularizó la Materia en algún Plan anterior del Alumno ' || pLegajo; 	
		RETURN iStatus, vcMsg ;
	END IF;
   END IF;


   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- veo si se acepta controlar correlativas con el plan, version con el que curso  la materia
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   EXECUTE PROCEDURE sp_param_sistema('controla_correlativas_actuales') INTO sValorParam ;
   IF sValorParam = 'N' THEN
	-- No controla con las correlativas del Plan-Version Actual. Busco ultima regularidad de la materia
	EXECUTE PROCEDURE sp_planver_uregmat (pUnidadAcademica, pCarrera, pLegajo, pMateria) INTO vcPlanRegular, vcVersionRegular;
	IF vcPlanRegular IS NOT NULL AND vcVersionRegular IS NOT NULL THEN
		-- No tiene una cursada de la materia en un plan anterior, entonces asigno el plan version actual.
		LET vcPlan  = vcPlanRegular;
		LET vcVersion  = vcVersionRegular;
	END IF;
   END IF;  

 LET falloCorrelativa = 'N';

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Controlo las correlatividades de la materia para Aprobar
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 FOREACH EXECUTE PROCEDURE sp_correlativasd(pUnidadAcademica, pCarrera, pLegajo, pMateria, vcPlan, vcVersion,dFecha, 'A')
	 INTO iFalloControlcorr,  vcMsg
     IF iFalloControlcorr = 1 THEN	-- si esta OK salgo y continua con correlativas especiales
        LET vcMsg =   '800320'  ;
     ELIF iFalloControlcorr = -1 THEN 	-- No cumple con las correlativas
	    LET falloCorrelativa = 'S';
	    LET iStatus =  -1 ;
	    LET vcMsg = '-746,' || vcMsg; 
	    RETURN iStatus, vcMsg  WITH RESUME ;  
     END IF ;	
  END FOREACH;

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Controlo las correlativas Especiales.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  IF falloCorrelativa = 'N' THEN
    EXECUTE PROCEDURE sp_correlativa_esp(pUnidadAcademica, pCarrera, pLegajo, pMateria, vcPlan, vcVersion, dFecha, 'A') 
                INTO iStatus,  vcFalloEnCorre;

	IF iStatus = 1 THEN	-- si esta OK salgo
              LET vcMsg =   '800320'  ;
       ELSE     -- sino, devuelvo mensaje de error
              LET vcMsg = vcFalloEnCorre;
              LET iStatus = -1 ;
              LET falloCorrelativa = 'S';
              Return iStatus, vcMsg WITH RESUME;
       END IF ; 
  END IF;

  IF falloCorrelativa = 'N' THEN
	Return iStatus, vcMsg;
  END IF;
   
END;
END PROCEDURE;
-- +++++++++++++++++++++++++++ FIN PROCEDURE ctr_corre_iex_fech +++++++++++++++++++++++++++

