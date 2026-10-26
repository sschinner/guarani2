CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_correlativa_esp') THEN
		DROP PROCEDURE sp_correlativa_esp;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

--drop procedure "dba".sp_correlativa_esp;
CREATE PROCEDURE "dba".sp_correlativa_esp(
	pUnidadAcademica	LIKE sga_alumnos.unidad_academica,
	pCarrera		LIKE sga_alumnos.carrera,
	pLegajo			LIKE sga_alumnos.legajo,
	pMateria		LIKE sga_materias.materia,
	pPlan			LIKE sga_alumnos.plan,
	pVersion		LIKE sga_planes.version_actual,
	pFecha			date,
	pTipoCorrelativa	char(1)                             -- C= Cursar , A= Rendir
)
    RETURNING smallint, varchar(255);

--- Correlatividades especiales para rendir !!! 

	
DEFINE  lcFuncionVal		LIKE sga_correlativ_esp.funcion_validacion ;

DEFINE sql_err, isam_err, iStatus, vnRetorno	integer;
DEFINE error_info 			varchar(76);
DEFINE vcUserError  		varchar(10);
DEFINE vcMsg, vcMensaje  		varchar(255);
DEFINE cEncontroSP          char(1);


-- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info                                        
     LET iStatus = -1 ;
     LET vcMsg = '800321' || ',' || 'sp_correlativa_esp' || ',' || sql_err || ' - '  || error_info ;  
     RETURN iStatus, vcMsg ;

END EXCEPTION;        


BEGIN
    -- Inicializo de forma que si no hay algun control de error !!!
    LET iStatus = 1 ;
    LET vcMsg = '800320' ;
    LET vnRetorno = 1 ;
    LET cEncontroSP = 'N';


    SELECT sga_correlativ_esp.funcion_validacion INTO lcFuncionVal
		FROM sga_correlativ_esp
		WHERE ( sga_correlativ_esp.unidad_academica = pUnidadAcademica ) 
			AND ( sga_correlativ_esp.carrera = pCarrera ) 
            AND ( sga_correlativ_esp.plan = pPlan )
            AND ( sga_correlativ_esp.version = pVersion )
			AND ( sga_correlativ_esp.materia = pMateria )
            AND ( sga_correlativ_esp.cursar_aprobar = pTipoCorrelativa ) ;

	IF ( lcFuncionVal IS NULL ) OR ( lcFuncionVal = '' ) THEN 
	                RETURN 1, vcMsg ;	  
	

	END IF;

LET lcFuncionVal = TRIM (lcFuncionVal );


-- *************************************************************************************************
-- EN ESTE LUGAR AGREGAR LLAMADAS A SP DE CORRELATIVAS ESPECIALES 
-- *************************************************************************************************

--  Ejemplo de como se deben llamar a los SP 
--  12 materias aprobadas !!!
--    IF lcFuncionVal = 'u835rg_almenos12ap' THEN 
--        EXECUTE PROCEDURE u835rg_almenos12ap ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
--         LET cEncontroSP = 'S';
--    END IF;

	-- PROFESORADO EN MATEMATICA

	IF lcFuncionVal = 'u820_012000_esp' THEN 
		EXECUTE PROCEDURE u820_012000_esp ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;
	
	IF lcFuncionVal = 'u820_012000_ped' THEN 
		EXECUTE PROCEDURE u820_012000_ped ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	-- PROFESORADO EN BIOLOGIA

	IF lcFuncionVal = 'u820_022001_esp' THEN 
		EXECUTE PROCEDURE u820_022001_esp ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;
	
	IF lcFuncionVal = 'u820_022008_esp' THEN 
		EXECUTE PROCEDURE u820_022008_esp ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_022001_db' THEN 
		EXECUTE PROCEDURE u820_022001_blo ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_022001_fd' THEN 
		EXECUTE PROCEDURE u820_022001_fd ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;



	-- LICENCIATURA EN BIODIVERSIDAD

	IF lcFuncionVal = 'u820_062000_esp' THEN 
		EXECUTE PROCEDURE u820_062000_esp ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_062008_esp' THEN 
		EXECUTE PROCEDURE u820_062008_esp ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	-- LICENCIATURA EN SOCIOLOGIA

	IF lcFuncionVal = 'u820_132000_esp' THEN 
		EXECUTE PROCEDURE u820_132000_esp ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	
	IF lcFuncionVal = 'u820_062000_opb' THEN 
		EXECUTE PROCEDURE u820_062000_opb ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	-- PROFESORADO DE GEOGRAFIA

	IF lcFuncionVal = 'u820_032000_esp2' THEN 
		EXECUTE PROCEDURE u820_032000_esp2 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_032000_esp3' THEN 
		EXECUTE PROCEDURE u820_032000_esp3 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_032000_esp3_pdoc' THEN 
		EXECUTE PROCEDURE u820_032000_esp3_pdoc ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_Prof_geo_8_mat_PG1' THEN 
		EXECUTE PROCEDURE u820_Prof_geo_8_mat ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	-- LICENCIATURA EN GEOGRAFIA

	IF lcFuncionVal = 'u820_072000_esp2' THEN 
		EXECUTE PROCEDURE u820_072000_esp2 (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_072000_esp3' THEN 
		EXECUTE PROCEDURE u820_072000_esp3 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	-- PROFESORADO EN LETRAS

	IF lcFuncionVal = 'u820_Porf_let_let51_esp' THEN 
		EXECUTE PROCEDURE u820_Porf_let_let51_esp ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;


	IF lcFuncionVal = 'u820_042001_esp' THEN 
		EXECUTE PROCEDURE u820_042001_esp ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan, pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_042001_let51' THEN 
		EXECUTE PROCEDURE u820_042001_let51 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_042001_pdoc' THEN 
		EXECUTE PROCEDURE u820_042001_pdoc ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	
	IF lcFuncionVal = 'u820_04200102_PDOC_esp' THEN 
		EXECUTE PROCEDURE u820_04200102_PDOC_esp ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;


	-- LICENCIATURA EN LETRAS

	IF lcFuncionVal = 'u820_082001_esp' THEN 
		EXECUTE PROCEDURE u820_082001_esp ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	-- PROFESORADO EN HISTORIA

	IF lcFuncionVal = 'u820_052001_esp' THEN 
		EXECUTE PROCEDURE u820_052001_esp ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	-- LICENCIATURAEN HISTORIA

	IF lcFuncionVal = 'u820_092001_esp' THEN 
		EXECUTE PROCEDURE u820_092001_esp ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	-- PROFEORADO DE FILOSOFIA

	IF lcFuncionVal = 'u820_172005_esp' THEN 
		EXECUTE PROCEDURE u820_172005_esp ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	-- LICENCIATURA EN FILOSOFIA

	IF lcFuncionVal = 'u820_Prof_fil_8_mat_LF1' THEN 
		EXECUTE PROCEDURE u820_prof_fil_8_mat ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	-- LICENCIATURA EN CIENCIAS POLITICAS

	IF lcFuncionVal = 'u820_182005_esp' THEN 
		EXECUTE PROCEDURE u820_182005_esp ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_CP044_esp' THEN 
		EXECUTE PROCEDURE u820_CP044_esp ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	

	-- LICENCIATURA EN BIODIVERSIDAD PLAN 2014

	IF lcFuncionVal = 'u820_lic_bio14_17_mat' THEN 
		EXECUTE PROCEDURE u820_lic_bio14_17_mat ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;


    -- Si no encontro elprocedure devuelve error
    If cEncontroSP = 'N' Then
        RETURN -1, '800104,' || lcFuncionVal ;
    End If

    IF  vnRetorno = 1 THEN
        -- esta ok
        RETURN iStatus, vcMsg ;
    ELSE
        RETURN -1, vcMensaje ;
    END IF;
END;
END PROCEDURE;

-- *************** Fin del procedimiento "dba".sp_correlativa_esp ********************

REVOKE execute ON "dba".sp_correlativa_esp FROM public;
GRANT execute ON "dba".sp_correlativa_esp to guarani; -- Rol de usuarios de Gestion
GRANT execute ON "dba".sp_correlativa_esp to internet; -- Rol de usuario de Internet
