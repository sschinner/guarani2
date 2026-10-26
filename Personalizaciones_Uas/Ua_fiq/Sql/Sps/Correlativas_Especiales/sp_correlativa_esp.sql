{
carrera	plan	materia	correlativa
00005	1999	A0066	no adeudar mas de 6 asignaturas (cursar y aprobar) - u820_26_aprobadas--> Cambiar por u820_faltan6_mat
				Q0143	tener aprobadas 8 materias (cursar y aprobar) - u820_8_aprobadas
00011	2006	IM019	no adeudar mas de 6 asignaturas (cursar y aprobar) - u820_32_aprobadas--> Cambiar por u820_faltan6_mat
00006	1999			u820_RES_CD037 (cursar)
						Ser o haber sido regular en Sist. de Información para Manufacturas - u820_I0059
				I0067	tener todas las asignaturas aprobadas - u820_34_o_35_aprob --> Cambiar por u820_faltan0_mat
		1999R			no adeudar mas de 6 asignaturas - u820_29_aprobadas --> Cambiar por u820_faltan6_mat
		2008			Tener aprobadas 27 asignaturas... - u820_27_aprobadas

		
begin;

update sga_correlativ_esp set funcion_validacion = 'u820_faltan6_mat'
where carrera||plan||version in (select carrera||plan||version_actual from sga_planes)
and funcion_validacion = 'u820_26_aprobadas';


update sga_correlativ_esp set funcion_validacion = 'u820_faltan6_mat'
where carrera||plan||version in (select carrera||plan||version_actual from sga_planes)
and funcion_validacion = 'u820_32_aprobadas';

update sga_correlativ_esp set funcion_validacion = 'u820_faltan0_mat'
where carrera||plan||version in (select carrera||plan||version_actual from sga_planes)
and funcion_validacion = 'u820_34_o_35_aprob';

update sga_correlativ_esp set funcion_validacion = 'u820_I0059'
where carrera||plan||version in (select carrera||plan||version_actual from sga_planes)
and funcion_validacion = ' u820_I0059';

update sga_correlativ_esp set funcion_validacion = 'u820_faltan6_mat'
where carrera||plan||version in (select carrera||plan||version_actual from sga_planes)
and funcion_validacion = 'u820_29_aprobadas';

commit;
}

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
	pUnidadAcademica		LIKE sga_alumnos.unidad_academica,
	pCarrera			LIKE sga_alumnos.carrera,
	pLegajo			LIKE sga_alumnos.legajo,
	pMateria			LIKE sga_materias.materia,
	pPlan			LIKE sga_alumnos.plan,
	pVersion			LIKE sga_planes.version_actual,
	pFecha	DATE,
	pTipoCorrelativa		char(1)                             -- C= Cursar, A= Rendir
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

-- OK -  Aprobadas al menos 8 materias obligatorias del plan
IF lcFuncionVal = 'u820_8_aprobadas' THEN 
	EXECUTE PROCEDURE u820_8_aprobadas ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan ,pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;

-- OK -  Aprobadas al menos 9 materias obligatorias del plan
IF lcFuncionVal = 'u820_9_aprobadas' THEN 
	EXECUTE PROCEDURE u820_9_aprobadas ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan ,pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;

-- OK -  Aprobadas al menos 14 materias obligatorias del plan
IF lcFuncionVal = 'u820_14_aprobadas' THEN 
	EXECUTE PROCEDURE u820_14_aprobadas ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan ,pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;

-- OK -  Aprobadas al menos 12 materias obligatorias del plan
IF lcFuncionVal = 'u820_12_aprobadas' THEN 
	EXECUTE PROCEDURE u820_12_aprobadas ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan ,pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;

-- OK -  Aprobadas al menos 6 materias obligatorias del plan
IF lcFuncionVal = 'u820_6_aprobadas' THEN 
	EXECUTE PROCEDURE u820_6_aprobadas ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan ,pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;

-- OK - No adeudar mas de 6 materias: u820_faltan6_mat

IF lcFuncionVal = 'u820_faltan6_mat' THEN 
	EXECUTE PROCEDURE  u820_faltan6_mat ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;

-- OK - No adeudar mas de 6 materias: u820_faltan7_mat

IF lcFuncionVal = 'u820_faltan7_mat' THEN 
	EXECUTE PROCEDURE  u820_faltan7_mat ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;

-- OK - Tener todas las materias aprobadas: u820_faltan0_mat

IF lcFuncionVal = 'u820_faltan0_mat' THEN 
	EXECUTE PROCEDURE u820_faltan0_mat ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;    


-- OK - Resolucion CD037/05
IF lcFuncionVal = 'u820_RES_CD037' THEN 
	EXECUTE PROCEDURE u820_RES_CD037 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;

-- OK - Ser o haber sido regular en Sist. de Información para Manufacturas
IF lcFuncionVal = 'u820_I0059' THEN 
	EXECUTE PROCEDURE  u820_I0059 ( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;    

-- OK - Tener aprobadas 27 asignaturas con los Cursos de Ingreso
IF lcFuncionVal = 'u820_27_aprobadas' THEN 
	EXECUTE PROCEDURE  u820_27_aprobadas( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
	LET cEncontroSP = 'S';
END IF;    

-- OK - Ciclo Inicial de Ingeniería
IF lcFuncionVal = 'u820_ciclo_60001' THEN 
	EXECUTE PROCEDURE  u820_ciclo_60001( pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje ;
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


-- *************** Fin del procedimiento  ******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_correlativa_esp
-- *****************************************************************************
revoke execute on "dba".sp_correlativa_esp from public;
grant execute on "dba".sp_correlativa_esp to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_correlativa_esp to internet; -- Rol de usuario de Internet