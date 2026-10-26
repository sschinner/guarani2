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


CREATE PROCEDURE "dba".sp_correlativa_esp(
	pUnidadAcademica	LIKE sga_alumnos.unidad_academica,
	pCarrera		LIKE sga_alumnos.carrera,
	pLegajo		LIKE sga_alumnos.legajo,
	pMateria		LIKE sga_materias.materia,
	pPlan		LIKE sga_alumnos.plan,
	pVersion		LIKE sga_planes.version_actual,
	pFecha			DATE,
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
--        EXECUTE PROCEDURE u835rg_almenos12ap (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
--         LET cEncontroSP = 'S';
--    END IF;

-- ****************** Correlativas de cursado ******************************

	IF lcFuncionVal = 'u820_cur_A0108' THEN 
		EXECUTE PROCEDURE u820_cur_A0108 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;
	
	IF lcFuncionVal = 'u820_cur_A0111' THEN 
		EXECUTE PROCEDURE u820_cur_A0111 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_cur_A0114' THEN 
		EXECUTE PROCEDURE u820_cur_A0114 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_cur_A0115' THEN 
		EXECUTE PROCEDURE u820_cur_A0115 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;
    
	IF lcFuncionVal = 'u820_cur_A0116' THEN 
		EXECUTE PROCEDURE u820_cur_A0116 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP ='S';
	END IF;

	IF lcFuncionVal = 'u820_cur_A0117' THEN 
		EXECUTE PROCEDURE u820_cur_A0117 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_cur_A0121' THEN 
		EXECUTE PROCEDURE u820_cur_A0121 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_cur_A0122' THEN 
		EXECUTE PROCEDURE u820_cur_A0122 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_cur_A0124' THEN 
		EXECUTE PROCEDURE u820_cur_A0124 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_cur_A0125' THEN 
		EXECUTE PROCEDURE u820_cur_A0125 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_cur_A0126' THEN 
		EXECUTE PROCEDURE u820_cur_A0126 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_cur_A0127' THEN 
		EXECUTE PROCEDURE u820_cur_A0127 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_cur_A0128' THEN 
		EXECUTE PROCEDURE u820_cur_A0128 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_cur_A0130' THEN 
		EXECUTE PROCEDURE u820_cur_A0130 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_cur_A0131' THEN 
		EXECUTE PROCEDURE u820_cur_A0131 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_cur_A0132' THEN 
		EXECUTE PROCEDURE u820_cur_A0132 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_cur_A0133' THEN 
		EXECUTE PROCEDURE u820_cur_A0133 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_cur_A0134' THEN 
		EXECUTE PROCEDURE u820_cur_A0134 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_cur_A0201' THEN 
		EXECUTE PROCEDURE u820_cur_A0201 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_cur_A0202' THEN 
		EXECUTE PROCEDURE u820_cur_A0202 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_cur_A0206' THEN 
		EXECUTE PROCEDURE u820_cur_A0206 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_cur_A0207' THEN 
		EXECUTE PROCEDURE u820_cur_A0207 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_creditos' THEN 
		EXECUTE PROCEDURE u820_creditos ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_creditos_3n' THEN 
		EXECUTE PROCEDURE u820_creditos_3n ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_nivel_2_regularizado' THEN 
		EXECUTE PROCEDURE u820_nivel_2_regularizado ( pLegajo, pCarrera, pPlan, pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_ayu_100b_50m' THEN 
		EXECUTE PROCEDURE u820_ayu_100pc_basico ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		EXECUTE PROCEDURE u820_ayu_50pc_medio ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_ayu_100b_75m' THEN 
		EXECUTE PROCEDURE u820_ayu_100pc_basico ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		EXECUTE PROCEDURE u820_ayu_75pc_medio ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_ldcv_75b' THEN 
		EXECUTE PROCEDURE u820_ldcv_75pc_basico ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_ldi_75b' THEN 
		EXECUTE PROCEDURE u820_ldi_75pc_basico ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_ldi_100b' THEN 
		EXECUTE PROCEDURE u820_ldi_100pc_basico ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_ayu_100b' THEN 
		EXECUTE PROCEDURE u820_ayu_100pc_basico ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_ayu_75b' THEN 
		EXECUTE PROCEDURE u820_ayu_75pc_basico ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;


-- ***************** Fin Correlativas de cursado *****************

-- ***************** Correlativas de examen **********************


	IF lcFuncionVal = 'u820_exa_A0111' THEN 
		EXECUTE PROCEDURE u820_exa_A0111 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;
	
	IF lcFuncionVal = 'u820_exa_A0115' THEN 
		EXECUTE PROCEDURE u820_exa_A0115 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

   
	IF lcFuncionVal = 'u820_exa_A0116' THEN 
		EXECUTE PROCEDURE u820_exa_A0116 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_exa_A0117' THEN 
		EXECUTE PROCEDURE u820_exa_A0117 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal ='u820_exa_A0121' THEN 
		EXECUTE PROCEDURE u820_exa_A0121 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_exa_A0122' THEN 
		EXECUTE PROCEDURE u820_exa_A0122 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_exa_A0124' THEN 
		EXECUTE PROCEDURE u820_exa_A0124 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;


	IF lcFuncionVal = 'u820_exa_A0126' THEN 
		EXECUTE PROCEDURE u820_exa_A0126 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_exa_A0127' THEN 
		EXECUTE PROCEDURE u820_exa_A0127 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_exa_A0128' THEN 
		EXECUTE PROCEDURE u820_exa_A0128 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;


	IF lcFuncionVal= 'u820_exa_A0130' THEN 
		EXECUTE PROCEDURE u820_exa_A0130 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal= 'u820_exa_A0131' THEN 
		EXECUTE PROCEDURE u820_exa_A0131 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_exa_A0132' THEN 
		EXECUTE PROCEDURE u820_exa_A0132 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_exa_A0133' THEN 
		EXECUTE PROCEDURE u820_exa_A0133 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan ,pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_exa_A0134' THEN 
		EXECUTE PROCEDURE u820_exa_A0134 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_exa_A0201' THEN 
		EXECUTE PROCEDURE u820_exa_A0201 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_exa_A0202' THEN 
		EXECUTE PROCEDURE u820_exa_A0202 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal ='u820_exa_A0206' THEN 
		EXECUTE PROCEDURE u820_exa_A0206 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_exa_A0207' THEN 
		EXECUTE PROCEDURE u820_exa_A0207 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_exa_a0336' THEN 
		EXECUTE PROCEDURE u820_exa_a0336 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;
	IF lcFuncionVal = 'u820_exa_d0320' THEN 
		EXECUTE PROCEDURE u820_exa_d0320 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_exa_C0311' THEN 
		EXECUTE PROCEDURE u820_exa_C0311 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_exa_C0308' THEN 
		EXECUTE PROCEDURE u820_exa_C0308 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_exa_C0304' THEN 
		EXECUTE PROCEDURE u820_exa_C0304 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;


-- ***************** Fin Correlativas de examen*****************

    -- Si no encontro el procedure devuelve error
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
-- *************** Fin del procedimiento "dba".sp_correlativa_esp ******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_correlativa_esp
-- *****************************************************************************
revoke execute on "dba".sp_correlativa_esp from public;
grant execute on "dba".sp_correlativa_esp to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_correlativa_esp to internet; -- Rol de usuario de Internet
