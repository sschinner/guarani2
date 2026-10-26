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

-- *************************************************************************************************
-- LLAMADOR DE CORRELATIVAS ESPECIALES
-- UNIDAD ACADEMICA SIU
-- Ultima modificacion: Version 2.9.1
-- *************************************************************************************************
-- Inserta la correlativa especial
-- set triggers for sga_correlativ_esp  disabled;

-- insert into sga_correlativ_esp  values ('FCV', '01', '2011', 17, '10035', 'A',  'u820_practica_hosp', '');
-- insert into sga_correlativ_esp  values ('FCV', '01', '2011', 17, '10035', 'C',  'u820_practica_hosp', '');

-- insert into sga_correlativ_esp  values ('FCV', '01', '2011', 17, '10036', 'A',  'u820_practica_hosp', '');
-- insert into sga_correlativ_esp  values ('FCV', '01', '2011', 17, '10036', 'C',  'u820_practica_hosp', '');

-- set triggers for sga_correlativ_esp enabled;
-- *************************************************************************************************
-- No esta en condiciones
-- execute procedure sp_correlativa_esp( "FCV", "01", '36054957-2', "10035", 2011, 17, today, 'C');
-- execute procedure sp_correlativa_esp( "FCV", "01", '36054957-2', "10036", 2011, 17, today, 'C');

-- Si esta en condiciones
 
-- execute procedure sp_correlativa_esp( "FCV", "01", '36490237-3', "10035", 2011, 17, today, 'C');
-- execute procedure sp_correlativa_esp( "FCV", "01", '36490237-3', "10036", 2011, 17, today, 'C');
-- *************************************************************************************************


CREATE PROCEDURE "dba".sp_correlativa_esp(

	pUnidadAcademica	LIKE sga_alumnos.unidad_academica,

	pCarrera		LIKE sga_alumnos.carrera,

	pLegajo			LIKE sga_alumnos.legajo,

	pMateria		LIKE sga_materias.materia,

	pPlan			LIKE sga_alumnos.plan,

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



--  Ejemplo de como se deben llamar a los SP 

--  12 materias aprobadas !!!

--    IF lcFuncionVal = 'u835rg_almenos12ap' THEN 

--        EXECUTE PROCEDURE u835rg_almenos12ap ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;

--         LET cEncontroSP = 'S';

--    END IF;


IF lcFuncionVal = 'u820_ce_almenos60p' THEN 

	EXECUTE PROCEDURE u820_ce_almenos60p ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;

	LET cEncontroSP = 'S';

END IF;

IF lcFuncionVal = 'u820_ce_almenos60p_2011' THEN 

	EXECUTE PROCEDURE u820_ce_almenos60p_2011 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;

	LET cEncontroSP = 'S';

END IF;

IF lcFuncionVal = 'u820_acred_idioma' THEN 

	EXECUTE PROCEDURE u820_acred_idioma ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;

	LET cEncontroSP = 'S';

END IF;

IF lcFuncionVal = 'u820_ce_almenos1materia' THEN 

	EXECUTE PROCEDURE u820_ce_almenos1materia ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;

	LET cEncontroSP = 'S';

END IF;

IF lcFuncionVal = 'u820_practica_hosp' THEN 

	EXECUTE PROCEDURE u820_practica_hosp ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;


	LET cEncontroSP = 'S';

END IF;

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

-- ******************** FIN PROCESO sp_correlativa_esp ********************

revoke execute on "dba".sp_correlativa_esp from public;
grant execute on "dba".sp_correlativa_esp to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_correlativa_esp to internet; -- Rol de usuario de Internet
