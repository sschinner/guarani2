CREATE PROCEDURE "dba".verifica_datos()
BEGIN

-- ANTE CUALQUIER ERROR CONTINUO

ON EXCEPTION 
END EXCEPTION WITH RESUME;

-- Controla si tiene las correlativas para rendir aún si sigura en acta abierta
-- El control esta asociado al Punto de Control Nro 8 (Alumno - Materia (Exámenes)
insert into par_implem_control (stored_procedure, parametros) values ("ctr_corre_iex_par", 's,s,s,s');

insert into par_controles (control, stored_procedure, desc_abreviada, descripcion, param_adicionales) values (82008, "ctr_corre_iex_par", "Correlativas en Insc a Examen (Acta Abierta)", "Controla las correlativas en insc a examen, teniendo en cuenta las notas cargadas en actas abiertas.", null);
insert into par_cont_x_punto (punto_de_control, control) values (8, 82008);

execute procedure sp_confcont_cont (8, 82008);


END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_datos();
DROP PROCEDURE "dba".verifica_datos();


CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr_corre_iex_par') THEN
		DROP PROCEDURE ctr_corre_iex_par;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Control: ctr_corre_iex_par
-- Ultima modificacion: Version 1.9, 1.10.0, 1.11.0
--
-- Controla las correlativas a Examen de una Materia. Segun parametro del sistema, controla con
-- el Plan-Version actual del Alumno, o con el Plan-Version con que curso la materia el Alumno.
-- Retorno:   *  1: OK    -1: Fallo Correlativa
--	     * Mensaje de Error.
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

 --DROP PROCEDURE ctr_corre_iex_par;

CREATE PROCEDURE "dba".ctr_corre_iex_par(
	pUnidadAcademica 	LIKE sga_alumnos.unidad_academica,
	pCarrera	 		LIKE sga_alumnos.carrera,
	pLegajo  			LIKE sga_alumnos.legajo,
	pMateria 			LIKE sga_materias.materia)
	RETURNING smallint, varchar(255);



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
   DEFINE vcRendirPlanAnt	LIKE sga_param_sistema.valor;
   DEFINE falloCorrelativa char(1);

 -- blk de excepciones
 ON EXCEPTION SET sql_err, isam_err, error_info                                        
   LET iStatus = -1 ;
   LET vcMsg = '800321' || ',' || 'correlativaiex_par' || ',' || sql_err || ' - '  || error_info ; 	
   RETURN iStatus, vcMsg ;
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


   LET falloCorrelativa = 'N';
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- controlo las correlatividades
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 FOREACH EXECUTE PROCEDURE sp820_correlativas(pUnidadAcademica, pCarrera, pLegajo, pMateria, vcPlan, vcVersion, 'A')
	 INTO iFalloControlcorr,  vcMsg
     IF iFalloControlcorr = 1 THEN	-- si esta OK salgo y continua con correlativas especiales
	Return iStatus, vcMsg WITH RESUME;
     ELIF iFalloControlcorr = -1 THEN 	-- No cumple con las correlativas
	LET falloCorrelativa = 'S';
	LET iStatus =  -1 ;
	LET vcMsg = '-746,' || vcMsg; 
	RETURN iStatus, vcMsg  WITH RESUME ;  
     END IF ;	
  END FOREACH;

   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- veo si se acepta controlar correlativas con el plan, version con el que curso  la materia
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   EXECUTE PROCEDURE sp_param_sistema('controla_correlativas_actuales') INTO sValorParam ;
   IF sValorParam = 'N' THEN
   -- sino cumple con las correlativas en el (plan, version) actual, recupero todos los versiones 
   -- en las que el alumno regularizo la materia ordenadas desde la mas reciente.
      FOREACH
         SELECT cur.version, cur.fecha_regularidad
              INTO vcVersion, dFecRegularidad

     FROM  sga_cursadas cur
         WHERE cur.unidad_academica 	= pUnidadAcademica  
               AND cur.carrera 		= pCarrera  
               AND cur.plan		= vcPlan 		
               AND cur.legajo 		= pLegajo
               AND cur.materia 		= pMateria  
               AND cur.fecha_regularidad 	IS NOT NULL 
               AND cur.estado 		= 'A'  
               AND (cur.resultado = 'A'  or cur.resultado = 'P')
          ORDER BY  cur.fecha_regularidad DESC
      

	 FOREACH EXECUTE PROCEDURE sp820_correlativas(pUnidadAcademica, pCarrera, pLegajo, pMateria, vcPlan, vcVersion, 'A')
		 INTO iFalloControlcorr,  vcMsg
	  IF iFalloControlcorr = -1 THEN 	-- No cumple con las correlativas
		LET falloCorrelativa = 'S';
		LET iStatus =  -1 ;
		
LET vcMsg = '-746,' || vcMsg; 
		RETURN iStatus, vcMsg  WITH RESUME ;  
	  END IF ;	
	END FOREACH

      END FOREACH ; -- Lectura de las cursadas

 
   END IF;  

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Controlo las correlativas Especiales.
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
IF falloCorrelativa = 'N' THEN
    EXECUTE PROCEDURE sp_correlativa_esp(pUnidadAcademica, pCarrera, pLegajo, pMateria, vcPlan, vcVersion, null, 'A') 
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
-- *************** Fin del procedimiento "dba".ctr_corre_iex_par *******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".ctr_corre_iex_par 
-- *****************************************************************************
revoke execute on "dba".ctr_corre_iex_par from public;
grant execute on "dba".ctr_corre_iex_par to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ctr_corre_iex_par to internet; -- Rol de usuario de Internet