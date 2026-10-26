-- *************************************************************************************************
-- LLAMADOR DE CORRELATIVAS ESPECIALES
-- UNIDAD ACADEMICA SIU
-- *************************************************************************************************

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
--  IF lcFuncionVal = 'u835rg_almenos12ap' THEN 
--  	EXECUTE PROCEDURE u835rg_almenos12ap (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
--  	LET cEncontroSP = 'S';
--  END IF;

--Profesorado de Música con Orientación en Guitarra
IF (lcFuncionVal = 'pm_guitarra_c_2t') or (lcFuncionVal = 'pm_guitarra_a_2t')  THEN 
	EXECUTE PROCEDURE u820_pm_guitarra_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'pm_guitarra_c_2t80p2') or (lcFuncionVal = 'pm_guitarra_a_2t80p2')  THEN 
	EXECUTE PROCEDURE u820_pm_guitarra_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	IF vnRetorno = 1 THEN
		EXECUTE PROCEDURE u820_guitarra_2anio_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
	END IF;
END IF;

IF (lcFuncionVal = 'pm_guitarra_c_2t80p3') or (lcFuncionVal = 'pm_guitarra_a_2t80p3')  THEN 
	EXECUTE PROCEDURE u820_pm_guitarra_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	IF vnRetorno = 1 THEN
		EXECUTE PROCEDURE u820_guitarra_3anio_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
	END IF;
END IF;

--Profesorado de Música con Orientación en Piano
IF (lcFuncionVal = 'pm_piano_c_2t') or (lcFuncionVal = 'pm_piano_a_2t')  THEN 
	EXECUTE PROCEDURE u820_pm_piano_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'pm_piano_c_2t80p2') or (lcFuncionVal = 'pm_piano_a_2t80p2')  THEN 
	EXECUTE PROCEDURE u820_pm_piano_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	IF vnRetorno = 1 THEN
		EXECUTE PROCEDURE u820_piano_2anio_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
	END IF;
END IF;

IF (lcFuncionVal = 'pm_piano_c_2t80p3') or (lcFuncionVal = 'pm_piano_a_2t80p3')  THEN 
	EXECUTE PROCEDURE u820_pm_piano_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	IF vnRetorno = 1 THEN
		EXECUTE PROCEDURE u820_piano_3anio_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
	END IF;
END IF;

--Profesorado de Música con Orientación en Órgano
IF (lcFuncionVal = 'pm_organo_c_2t') or (lcFuncionVal = 'pm_organo_a_2t')  THEN 
	EXECUTE PROCEDURE u820_pm_organo_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'pm_organo_c_2t80p2') or (lcFuncionVal = 'pm_organo_a_2t80p2')  THEN 
	EXECUTE PROCEDURE u820_pm_organo_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	IF vnRetorno = 1 THEN
		EXECUTE PROCEDURE u820_organo_2anio_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
	END IF;
END IF;

IF (lcFuncionVal = 'pm_organo_c_2t80p3') or (lcFuncionVal = 'pm_organo_a_2t80p3')  THEN 
	EXECUTE PROCEDURE u820_pm_organo_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	IF vnRetorno = 1 THEN
		EXECUTE PROCEDURE u820_organo_3anio_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
	END IF;
END IF;

--Profesorado de Música con Orientación en Clarinete
IF (lcFuncionVal = 'pm_clarinete_c_2t') or (lcFuncionVal = 'pm_clarinete_a_2t')  THEN 
	EXECUTE PROCEDURE u820_pm_clarinete_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'pm_clarinete_c_2t80p2') or (lcFuncionVal = 'pm_clarinete_a_2t80p2')  THEN 
	EXECUTE PROCEDURE u820_pm_clarinete_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	IF vnRetorno = 1 THEN
		EXECUTE PROCEDURE u820_clarinete_2anio_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
	END IF;
END IF;

IF (lcFuncionVal = 'pm_clarinete_c_2t80p3') or (lcFuncionVal = 'pm_clarinete_a_2t80p3')  THEN 
	EXECUTE PROCEDURE u820_pm_clarinete_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	IF vnRetorno = 1 THEN
		EXECUTE PROCEDURE u820_clarinete_3anio_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
	END IF;
END IF;

--Profesorado de Música con Orientación en Flauta
IF (lcFuncionVal = 'pm_flauta_c_2t') or (lcFuncionVal = 'pm_flauta_a_2t')  THEN 
	EXECUTE PROCEDURE u820_pm_flauta_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'pm_flauta_c_2t80p2') or (lcFuncionVal = 'pm_flauta_a_2t80p2')  THEN 
	EXECUTE PROCEDURE u820_pm_flauta_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	IF vnRetorno = 1 THEN
		EXECUTE PROCEDURE u820_flauta_2anio_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
	END IF;
END IF;

IF (lcFuncionVal = 'pm_flauta_c_2t80p3') or (lcFuncionVal = 'pm_flauta_a_2t80p3')  THEN 
	EXECUTE PROCEDURE u820_pm_flauta_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	IF vnRetorno = 1 THEN
		EXECUTE PROCEDURE u820_flauta_3anio_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
	END IF;
END IF;

--Profesorado de Música con Orientación en Saxo
IF (lcFuncionVal = 'pm_saxo_c_2t') or (lcFuncionVal = 'pm_saxo_a_2t')  THEN 
	EXECUTE PROCEDURE u820_pm_saxo_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'pm_saxo_c_2t80p2') or (lcFuncionVal = 'pm_saxo_a_2t80p2')  THEN 
	EXECUTE PROCEDURE u820_pm_saxo_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	IF vnRetorno = 1 THEN
		EXECUTE PROCEDURE u820_saxo_2anio_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
	END IF;
END IF;

IF (lcFuncionVal = 'pm_saxo_c_2t80p3') or (lcFuncionVal = 'pm_saxo_a_2t80p3')  THEN 
	EXECUTE PROCEDURE u820_pm_saxo_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	IF vnRetorno = 1 THEN
		EXECUTE PROCEDURE u820_saxo_3anio_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
	END IF;
END IF;

--Profesorado de Música con Orientación en Violin
IF (lcFuncionVal = 'pm_violin_c_2t') or (lcFuncionVal = 'pm_violin_a_2t')  THEN 
	EXECUTE PROCEDURE u820_pm_violin_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'pm_violin_c_2t80p2') or (lcFuncionVal = 'pm_violin_a_2t80p2')  THEN 
	EXECUTE PROCEDURE u820_pm_violin_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	IF vnRetorno = 1 THEN
		EXECUTE PROCEDURE u820_violin_2anio_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
	END IF;
END IF;

IF (lcFuncionVal = 'pm_violin_c_2t80p3') or (lcFuncionVal = 'pm_violin_a_2t80p3')  THEN 
	EXECUTE PROCEDURE u820_pm_violin_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	IF vnRetorno = 1 THEN
		EXECUTE PROCEDURE u820_violin_3anio_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
	END IF;
END IF;

--Profesorado de Música con Orientación en Violonchelo
IF (lcFuncionVal = 'pm_violonchelo_c_2t') or (lcFuncionVal = 'pm_violonchelo_a_2t')  THEN 
	EXECUTE PROCEDURE u820_pm_violonchelo_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'pm_violonchelo_c_2t80p2') or (lcFuncionVal = 'pm_violonchelo_a_2t80p2')  THEN 
	EXECUTE PROCEDURE u820_pm_violonchelo_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	IF vnRetorno = 1 THEN
		EXECUTE PROCEDURE u820_violonchelo_2anio_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
	END IF;
END IF;

IF (lcFuncionVal = 'pm_violonchelo_c_2t80p3') or (lcFuncionVal = 'pm_violonchelo_a_2t80p3')  THEN 
	EXECUTE PROCEDURE u820_pm_violonchelo_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	IF vnRetorno = 1 THEN
		EXECUTE PROCEDURE u820_violonchelo_3anio_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
	END IF;
END IF;

--Profesorado de Música con Orientación en Composición
IF (lcFuncionVal = 'pm_ocomp_c_2t') or (lcFuncionVal = 'pm_ocomp_a_2t')  THEN 
	EXECUTE PROCEDURE u820_pm_ocomp_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'pm_ocomp_c_2t80p2') or (lcFuncionVal = 'pm_ocomp_a_2t80p2')  THEN 
	EXECUTE PROCEDURE u820_pm_ocomp_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	IF vnRetorno = 1 THEN
		EXECUTE PROCEDURE u820_ocomp_2anio_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
	END IF;
END IF;

IF (lcFuncionVal = 'pm_ocomp_c_2t80p3') or (lcFuncionVal = 'pm_ocomp_a_2t80p3')  THEN 
	EXECUTE PROCEDURE u820_pm_ocomp_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	IF vnRetorno = 1 THEN
		EXECUTE PROCEDURE u820_ocomp_3anio_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
	END IF;
END IF;

--Profesorado de Música con Orientación en Canto
IF (lcFuncionVal = 'pm_ocanto_c_2t') or (lcFuncionVal = 'pm_ocanto_a_2t')  THEN 
	EXECUTE PROCEDURE u820_pm_ocanto_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'pm_ocanto_c_2t80p2') or (lcFuncionVal = 'pm_ocanto_a_2t80p2')  THEN 
	EXECUTE PROCEDURE u820_pm_ocanto_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	IF vnRetorno = 1 THEN
		EXECUTE PROCEDURE u820_ocanto_2anio_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
	END IF;
END IF;

IF (lcFuncionVal = 'pm_ocanto_c_2t80p3') or (lcFuncionVal = 'pm_ocanto_a_2t80p3')  THEN 
	EXECUTE PROCEDURE u820_pm_ocanto_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	IF vnRetorno = 1 THEN
		EXECUTE PROCEDURE u820_ocanto_3anio_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
	END IF;
END IF;

--Profesorado de Música con Orientación en Dirección Coral
IF (lcFuncionVal = 'pm_odircoral_c_2t') or (lcFuncionVal = 'pm_odircoral_a_2t')  THEN 
	EXECUTE PROCEDURE u820_pm_odircoral_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'pm_odircoral_c_2t80p2') or (lcFuncionVal = 'pm_odircoral_a_2t80p2')  THEN 
	EXECUTE PROCEDURE u820_pm_odircoral_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	IF vnRetorno = 1 THEN
		EXECUTE PROCEDURE u820_odircoral_2anio_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
	END IF;
END IF;

IF (lcFuncionVal = 'pm_odircoral_c_2t80p3') or (lcFuncionVal = 'pm_odircoral_a_2t80p3')  THEN 
	EXECUTE PROCEDURE u820_pm_odircoral_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	IF vnRetorno = 1 THEN
		EXECUTE PROCEDURE u820_odircoral_3anio_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
	END IF;
END IF;

--Profesorado de Música con Orientación en Dirección Orquestal
IF (lcFuncionVal = 'pm_odirorquestal_c_2t') or (lcFuncionVal = 'pm_odirorquestal_a_2t')  THEN 
	EXECUTE PROCEDURE u820_pm_odirorquestal_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'pm_odirorquestal_c_2t80p2') or (lcFuncionVal = 'pm_odirorquestal_a_2t80p2')  THEN 
	EXECUTE PROCEDURE u820_pm_odirorquestal_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	IF vnRetorno = 1 THEN
		EXECUTE PROCEDURE u820_odirorquestal_2anio_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
	END IF;
END IF;

IF (lcFuncionVal = 'pm_odirorquestal_c_2t80p3') or (lcFuncionVal = 'pm_odirorquestal_a_2t80p3')  THEN 
	EXECUTE PROCEDURE u820_pm_odirorquestal_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	IF vnRetorno = 1 THEN
		EXECUTE PROCEDURE u820_odirorquestal_3anio_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
	END IF;
END IF;

--Licenciatura en Música con Orientación en Guitarra
IF (lcFuncionVal = 'lm_guitarra_c_2t') or (lcFuncionVal = 'lm_guitarra_a_2t')  THEN 
	EXECUTE PROCEDURE u820_lm_guitarra_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'lm_guitarra_c_2t_2018') or (lcFuncionVal = 'lm_guitarra_a_2t_2018')  THEN 
	EXECUTE PROCEDURE u820_lm_guitarra_dostercios_2018 (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

--Licenciatura en Música con Orientación en Piano
IF (lcFuncionVal = 'lm_piano_c_2t') or (lcFuncionVal = 'lm_piano_a_2t')  THEN 
	EXECUTE PROCEDURE u820_lm_piano_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

--Licenciatura en Música con Orientación en Órgano
IF (lcFuncionVal = 'lm_organo_c_2t') or (lcFuncionVal = 'lm_organo_a_2t')  THEN 
	EXECUTE PROCEDURE u820_lm_organo_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

--Licenciatura en Música con Orientación en Clarinete
IF (lcFuncionVal = 'lm_clarinete_c_2t') or (lcFuncionVal = 'lm_clarinete_a_2t')  THEN 
	EXECUTE PROCEDURE u820_lm_clarinete_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'lm_clarinete_c_2t_2018') or (lcFuncionVal = 'lm_clarinete_a_2t_2018')  THEN 
	EXECUTE PROCEDURE u820_lm_clarinete_dostercios_2018 (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

--Licenciatura en Música con Orientación en Flauta
IF (lcFuncionVal = 'lm_flauta_c_2t') or (lcFuncionVal = 'lm_flauta_a_2t')  THEN 
	EXECUTE PROCEDURE u820_lm_flauta_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

--Licenciatura en Música con Orientación en Saxo
IF (lcFuncionVal = 'lm_saxo_c_2t') or (lcFuncionVal = 'lm_saxo_a_2t')  THEN 
	EXECUTE PROCEDURE u820_lm_saxo_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

--Licenciatura en Música con Orientación en Violonchelo
IF (lcFuncionVal = 'lm_violonchelo_c_2t') or (lcFuncionVal = 'lm_violonchelo_a_2t')  THEN 
	EXECUTE PROCEDURE u820_lm_violonchelo_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

--Licenciatura en Música con Orientación en Composición
IF (lcFuncionVal = 'lm_ocomp_c_2t') or (lcFuncionVal = 'lm_ocomp_a_2t')  THEN 
	EXECUTE PROCEDURE u820_lm_ocomp_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

--Licenciatura en Música con Orientación en Composición plan 2018
IF (lcFuncionVal = 'lm_composicion_c_2t_2018') or (lcFuncionVal = 'lm_composicion_a_2t_2018')  THEN 
	EXECUTE PROCEDURE u820_lm_ocomp_dostercios_2018 (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

--Licenciatura en Música con Orientación en Canto
IF (lcFuncionVal = 'lm_ocanto_c_2t') or (lcFuncionVal = 'lm_ocanto_a_2t')  THEN 
	EXECUTE PROCEDURE u820_lm_ocanto_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

--Licenciatura en Música con Orientación en Dirección Coral
IF (lcFuncionVal = 'lm_odircoral_c_2t') or (lcFuncionVal = 'lm_odircoral_a_2t')  THEN 
	EXECUTE PROCEDURE u820_lm_odircoral_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

--Licenciatura en Música con Orientación en Dirección Orquestal
IF (lcFuncionVal = 'lm_odirorquestal_c_2t') or (lcFuncionVal = 'lm_odirorquestal_a_2t')  THEN 
	EXECUTE PROCEDURE u820_lm_odirorquestal_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

--Tecnicatura en Composición Musical con Medios Electroacústicos
IF (lcFuncionVal = 'tecnicatura_c_80p') or (lcFuncionVal = 'tecnicatura_a_80p')  THEN 
	EXECUTE PROCEDURE u820_tecnicatura_80porciento (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

--Licenciatura en Música con Orientación en Violin
IF (lcFuncionVal = 'lm_violin_c_2t') or (lcFuncionVal = 'lm_violin_a_2t')  THEN 
	EXECUTE PROCEDURE u820_lm_violin_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

--Licenciatura en Música con Orientación en Composición plan 2018
IF (lcFuncionVal = 'lm_viola_c_2t_2018') or (lcFuncionVal = 'lm_viola_a_2t_2018')  THEN 
	EXECUTE PROCEDURE u820_lm_viola_dostercios_2018 (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

--Licenciatura en Música con Orientación en Trombón
IF (lcFuncionVal = 'lm_trombon_c_2t') or (lcFuncionVal = 'lm_trombon_a_2t')  THEN 
	EXECUTE PROCEDURE u820_lm_trombon_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

-- Profesorado de Música

IF (lcFuncionVal = 'pm_c_2t') or (lcFuncionVal = 'pm_a_2t')  THEN 
	EXECUTE PROCEDURE u820_pm_dostercios (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'pm_c_2t_2018') or (lcFuncionVal = 'pm_a_2t_2018')  THEN 
	EXECUTE PROCEDURE u820_pm_dostercios_2018 (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'lm_syg_c_2t_2018') or (lcFuncionVal = 'lm_syg_a_2t_2018')  THEN 
	EXECUTE PROCEDURE u820_lm_syg_dostercios_2018 (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'lm_saxofon_c_2t_2018') or (lcFuncionVal = 'lm_saxofon_a_2t_2018')  THEN 
	EXECUTE PROCEDURE u820_lm_saxofon_dostercios_2018 (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'lm_piano_c_2t_2018') or (lcFuncionVal = 'lm_piano_a_2t_2018')  THEN 
	EXECUTE PROCEDURE u820_lm_piano_dostercios_2018 (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'lm_percusion_c_2t_2018') or (lcFuncionVal = 'lm_percusion_a_2t_2018')  THEN 
	EXECUTE PROCEDURE u820_lm_percusion_dostercios_2018 (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'lm_canto_c_2t_2018') or (lcFuncionVal = 'lm_canto_a_2t_2018')  THEN 
	EXECUTE PROCEDURE u820_lm_ocanto_dostercios_2018 (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'lm_violin_c_2t_2018') or (lcFuncionVal = 'lm_violin_a_2t_2018')  THEN 
	EXECUTE PROCEDURE u820_lm_violin_dostercios_2018 (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'lm_flauta_c_2t_2018') or (lcFuncionVal = 'lm_flauta_a_2t_2018')  THEN 
	EXECUTE PROCEDURE u820_lm_flauta_dostercios_2018 (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'lm_dirorquestal_c_2t_2018') or (lcFuncionVal = 'lm_dirorquestal_a_2t_2018')  THEN 
	EXECUTE PROCEDURE u820_lm_odirorquestal_dostercios_2018 (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'lm_dircoral_c_2t_2018') or (lcFuncionVal = 'lm_dircoral_a_2t_2018')  THEN 
	EXECUTE PROCEDURE u820_lm_odircoral_dostercios_2018 (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;

IF (lcFuncionVal = 'lmp_2t_2018') or (lcFuncionVal = 'lmp_2t_2018')  THEN 
	EXECUTE PROCEDURE u820_lmp_dostercios_2018 (pUnidadAcademica, pCarrera, pLegajo, pMateria, pPlan , pVersion ) INTO vnRetorno, vcMensaje;
	LET cEncontroSP = 'S';
END IF;


-- Si no encontro el procedure devuelve error
IF cEncontroSP = 'N' Then
	RETURN -1, '800104,' || lcFuncionVal ;
END IF;

IF vnRetorno = 1 THEN
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


