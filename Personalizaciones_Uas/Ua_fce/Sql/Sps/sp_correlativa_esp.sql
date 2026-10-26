drop procedure sp_correlativa_esp;

CREATE PROCEDURE "dba".sp_correlativa_esp(
	pUnidadAcademica	LIKE sga_alumnos.unidad_academica,
	pCarrera		LIKE sga_alumnos.carrera,
	pLegajo		LIKE sga_alumnos.legajo,
	pMateria		LIKE sga_materias.materia,
	pPlan		LIKE sga_alumnos.plan,
	pVersion		LIKE sga_planes.version_actual,
	pFecha	DATE,
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


-- ****************** Correlativas de Cursado/Examen (Solo carreras del grupo presenciales) ******************************************
/* Se reemplaza por nuevos procedimientos 
	IF lcFuncionVal = 'u820_log_doc'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
		EXECUTE PROCEDURE u820_log_doc ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_lid_org'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
		EXECUTE PROCEDURE u820_lid_org ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;
	
	IF lcFuncionVal = 'u820_inf_apli'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
		EXECUTE PROCEDURE u820_inf_apli ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_2_tercios'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
		EXECUTE PROCEDURE u820_2_tercios ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_exa_hab_con' and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
		EXECUTE PROCEDURE u820_exa_hab_con ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_exa_hab_soc'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
		EXECUTE PROCEDURE u820_exa_hab_soc( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_exa_hab_der'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
		EXECUTE PROCEDURE u820_exa_hab_der( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	
	LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_seminario'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
		EXECUTE PROCEDURE u820_seminario ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_no_3120'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
		EXECUTE PROCEDURE u820_no_3120 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_merc_int'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
		EXECUTE PROCEDURE u820_merc_int ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_merc_proy'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
		EXECUTE PROCEDURE u820_merc_proy ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_Ing_Bas'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
		EXECUTE PROCEDURE u820_ing_bas ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_comp_hab_d2'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
		EXECUTE PROCEDURE u820_comp_hab_d2 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_ctr_mats_aprob'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
		EXECUTE PROCEDURE u820_ctr_mats_aprob ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;


	IF lcFuncionVal = 'u820_ctr_mats_cbc'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
		EXECUTE PROCEDURE u820_ctr_mats_cbc ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

 	 IF lcFuncionVal = 'u820_comp_hab_cursar'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
		EXECUTE PROCEDURE u820_comp_hab_cursar ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;
	 
	IF lcFuncionVal = 'u820_ctr_optativa_0153'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
		EXECUTE PROCEDURE u820_ctr_optativa_0153 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

	IF lcFuncionVal = 'u820_ctr20_aprob'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
		EXECUTE PROCEDURE u820_ctr20_aprob ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';


	END IF;

----  17/01/2009 - se agrega control
	IF lcFuncionVal = 'u820_ctr_trabpract' and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
		EXECUTE PROCEDURE u820_ctr_trabpract ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF;

----  05/03/2009 - se agrega control

IF lcFuncionVal = 'u820_ctr28_aprob'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
		EXECUTE PROCEDURE u820_ctr28_aprob ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
		LET cEncontroSP = 'S';
	END IF; */
--******************* Nuevos procedimientos *******************
IF lcFuncionVal = 'u820_controla_12mat'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
	EXECUTE PROCEDURE u820_controla_12mat ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;


	LET cEncontroSP = 'S';
END IF;
IF lcFuncionVal = 'u820_controla_15mat'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
	EXECUTE PROCEDURE u820_controla_15mat ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;

IF lcFuncionVal = 'u820_controla_20mat'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
	EXECUTE PROCEDURE u820_controla_20mat ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;

IF lcFuncionVal = 'u820_controla_24mat'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 


	EXECUTE PROCEDURE u820_controla_24mat ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;

IF lcFuncionVal = 'u820_controla_28mat'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
	EXECUTE PROCEDURE u820_controla_28mat ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;


IF lcFuncionVal = 'u820_2_tercios' and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
	EXECUTE PROCEDURE u820_2_tercios ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;



IF lcFuncionVal = 'u820_2_tercios_y_28mat'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
	EXECUTE PROCEDURE u820_2_tercios_y_28mat ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;

IF lcFuncionVal = 'u820_exa_hab'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
	EXECUTE PROCEDURE u820_exa_hab ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;

IF lcFuncionVal = 'u820_comp_hab_d2'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
	EXECUTE PROCEDURE u820_comp_hab_d2 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;

IF lcFuncionVal = 'u820_ctr_mats_cbc'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
	EXECUTE PROCEDURE u820_ctr_mats_cbc ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;

IF lcFuncionVal = 'u820_comp_hab_cursar'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
	EXECUTE PROCEDURE u820_comp_hab_cursar ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;

IF lcFuncionVal = 'u820_ctr_optativa_0153'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
	EXECUTE PROCEDURE u820_ctr_optativa_0153 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';

END IF;

IF lcFuncionVal = 'u820_ctr_trabpract'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
	EXECUTE PROCEDURE u820_ctr_trabpract ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;


IF lcFuncionVal = 'u820_controla_25mat'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
	EXECUTE PROCEDURE u820_controla_25mat ( pUnidadAcademica, pCarrera,pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;
--- se agrega 02/2011

IF lcFuncionVal = 'u820_controla_18_30mat'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN
 
	EXECUTE PROCEDURE u820_controla_18_30mat ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;

--- se agrega 02/2011

IF lcFuncionVal = 'u820_controla_1020_1050'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
	EXECUTE PROCEDURE u820_controla_1020_1050 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;



--- se agrega 02/2012

IF lcFuncionVal = 'u820_2_tercios_y_reg4110'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
	EXECUTE PROCEDURE u820_2_tercios_y_reg4110 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;

IF lcFuncionVal = 'u820_reg1020_1040_1050'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
	EXECUTE PROCEDURE u820_reg1020_1040_1050 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;

--- se agrega 02/2013


IF lcFuncionVal = 'u820_controla_19mat'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
	EXECUTE PROCEDURE u820_controla_19mat ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;

--- se agregan el 27/06/2013 

IF lcFuncionVal = 'u820_controla_19mat_reg1081'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
	EXECUTE PROCEDURE u820_controla_19mat_reg1081 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;

IF lcFuncionVal = 'u820_controla_27mat'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
	EXECUTE PROCEDURE u820_controla_27mat ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;

IF lcFuncionVal = 'u820_controla_5mat'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
	EXECUTE PROCEDURE u820_controla_5mat ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;

-- se agrega el 17/12/2015
IF lcFuncionVal = 'u820_controla_21mat'  and pcarrera In (select carrera from sga_carreras_grupo where grupo_carrera = '1')THEN 
	EXECUTE PROCEDURE u820_controla_21mat ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;

-- ***************** Fin Correlativas Especiales ***************

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
                         
                                                                                                                                                                                                                                                              
