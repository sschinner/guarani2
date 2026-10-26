CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ws_insertar_aspirante') THEN
		DROP PROCEDURE ws_insertar_aspirante;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *************** COMIENZO DEL PROCEDURE ws_insertar_aspirante ***************
-- ************************************************************************
-- SP que genera una inscripcion a carrera, a partir de datos de INGRESO
-- en un período dado
-- ************************************************************************
-- DROP PROCEDURE "dba".ws_insertar_aspirante;
      
CREATE PROCEDURE "dba".ws_insertar_aspirante(
    p_unidad_academica  LIKE sga_unidades_acad.unidad_academica,
	p_anio_academico    LIKE sga_periodo_insc.anio_academico,
	p_carrera           LIKE sga_carreras.carrera,
	p_sede              LIKE sga_carrera_aspira.sede,
	p_tipo_ingreso      INT,-- 1 - Titulo Secundario;	2 - Proveniente de ciclo básico común; 3 - Mayor de 25 años ; etc... ver combo De inscripcion Tipo ingreso en Guaraní.
	p_fecha_inscripcion LIKE sga_datos_censales.fecha_relevamiento,
	p_apellido          LIKE sga_personas.apellido,
	p_nombres           LIKE sga_personas.nombres,
	p_pais_documento    LIKE sga_personas.pais_documento,
	p_tipo_documento    LIKE sga_personas.tipo_documento,
	p_nro_documento     LIKE sga_personas.nro_documento,
	p_nro_cuil          LIKE sga_personas.numero_cuil,
	p_fecha_nacimiento  LIKE sga_personas.fecha_nacimiento,
	p_sexo              LIKE sga_personas.sexo,
	p_clave             LIKE aca_usuarios_ag.clave,
	p_nacionalidad      LIKE sga_personas.nacionalidad,	
	p_pais_origen       LIKE sga_personas.pais_emisor_pasap,		
	p_email             LIKE sga_datos_censales.e_mail
	)
	RETURNING INT, VARCHAR(255);

-- Descripcion de Parámetros:

-- p_anio_academico: año academico de la inscripcion a carrera (Integer)
-- p_carrera: carrera a la que se va a inscribir (VARCHAR(5))
-- p_tipo_ingreso: (Integer)
-- p_fecha_inscripcion: fecha de la inscripcion como aspirante a la carrera (mm/dd/yyyy)


-- Descripcion de Return:
-- INT: 	0 - OK
--	-1 - Error
-- VARCHAR(255): string con la descripcion del error
	
DEFINE _unidad_academica    LIKE sga_datos_censales.unidad_academica;
DEFINE _periodo_inscripcio  LIKE sga_periodo_insc.periodo_inscripcio;
DEFINE _nro_inscripcion     LIKE sga_personas.nro_inscripcion;
DEFINE _legajo              LIKE sga_alumnos.legajo;

DEFINE sql_err, isam_err  	INT;
DEFINE error_info         	VARCHAR(80);
DEFINE vcUserError          VARCHAR(10);
DEFINE iStatus              INT;
DEFINE vcMsg                VARCHAR(100);

DEFINE vc_resultado         VARCHAR (15);
DEFINE vi_cod_uno           INTEGER;
DEFINE vi_cod_dos           INTEGER;
DEFINE vc_mensaje           VARCHAR (250);

-- si hay algun error
ON EXCEPTION SET sql_err, isam_err, error_Info                                        

      LET vcUserError  = 'Error de procedimiento.';
      LET iStatus 	  = 4; 
      LET vcMsg 	  =  vcUserError || ', ' || sql_err || ' - ' || error_Info;
      SET TRIGGERS FOR sga_datos_censales enabled;
      ROLLBACK WORK;
      RETURN iStatus, vcMsg;
END EXCEPTION;
--------------------------------------------------

LET _unidad_academica = NULL;
LET _periodo_inscripcio = NULL;
LET _nro_inscripcion = NULL;
LET _legajo = NULL;

LET error_info = NULL;
LET sql_err = 0;
LET isam_err = 0;
LET iStatus = 0;
LET vcMsg = 'OK aspirante inscripto correctamente';

-- Obtengo la Unidad Academica.
SELECT unidad_academica INTO _unidad_academica 
FROM sga_unidades_acad
WHERE unidad_academica = p_unidad_academica;

IF p_sede IS NULL or p_sede = ""
THEN
	LET p_sede = '00000';
END IF;

LET p_nro_cuil = REPLACE (p_nro_cuil, '-', '');

IF NOT EXISTS (SELECT * FROM sga_carreras WHERE carrera = p_carrera) 
THEN
	LET vcMsg = 'La carrera ' || p_carrera || ' es inexistente - Verifique';
	LET iStatus = -4;
    RETURN iStatus, vcMsg;	
END IF;

-- Se modifica para no restringir inscripciones al período activo
SELECT max(periodo_inscripcio) INTO _periodo_inscripcio
FROM sga_periodo_insc 
WHERE anio_academico = p_anio_academico
	AND tipo IN ('I', 'A');
	-- AND TODAY between fecha_inicio AND fecha_fin;
	
IF _periodo_inscripcio IS NULL 
THEN
    LET vcMsg = 'No existe un período de inscripción a carreras vigente para el año academico ' || p_anio_academico;
	LET iStatus = -1;
    RETURN iStatus, vcMsg;
END IF;

------------------------------------------------------------------------------------ 
-- Verifico si existe la persona
------------------------------------------------------------------------------------
SELECT nro_inscripcion INTO _nro_inscripcion
FROM sga_personas
WHERE 
    tipo_documento          = p_tipo_documento 
    AND nro_documento       = p_nro_documento
	AND unidad_academica    = _unidad_academica;

IF _nro_inscripcion IS NULL 
THEN
    -- NO EXISTE LA PERSONA, genero un numero de inscripcion.
    EXECUTE PROCEDURE sp_nro_inscripcion(_unidad_academica) INTO _nro_inscripcion;

    BEGIN WORK;

    INSERT INTO sga_personas 
        (UNIDAD_ACADEMICA,  NRO_INSCRIPCION, FECHA_INSCRIPCION,  APELLIDO, NOMBRES, PAIS_DOCUMENTO, TIPO_DOCUMENTO, NRO_DOCUMENTO, NUMERO_CUIL, SEXO, FECHA_NACIMIENTO, NACIONALIDAD, PAIS_EMISOR_PASAP) 
    VALUES 
        (_unidad_academica, _nro_inscripcion, p_fecha_inscripcion, p_apellido, p_nombres, p_pais_documento, p_tipo_documento, p_nro_documento, p_nro_cuil, p_sexo, p_fecha_nacimiento, p_nacionalidad, p_pais_origen);

    INSERT INTO sga_carrera_aspira
    VALUES (_unidad_academica, p_carrera, _nro_inscripcion, _periodo_inscripcio, p_fecha_inscripcion, p_sede, NULL, 'I', p_fecha_inscripcion, NULL, 'AC', NULL, p_tipo_ingreso, NULL, NULL);

    EXECUTE PROCEDURE "dba".sp_crear_alumno (TRIM(_unidad_academica), _nro_inscripcion, TRIM(p_carrera), NULL, NULL) 
    INTO vc_resultado,  vi_cod_uno, vi_cod_dos, vc_mensaje;

    -- UPDATE DE CLAVE
    UPDATE  aca_usuarios_ag 
    SET     clave = p_clave
    WHERE   nro_inscripcion = _nro_inscripcion
    AND identificacion = p_nro_documento;

    -- UPDATE DE DATOS CENSALES
    UPDATE  sga_datos_censales 
    SET     e_mail = p_email		
    WHERE   nro_inscripcion = _nro_inscripcion
    AND fecha_relevamiento = p_fecha_inscripcion;

    -- Articulo 7: Mayores de 25 se exceptuan de 921
    IF p_tipo_ingreso = 3
    THEN
        UPDATE sga_req_cumplidos 
        SET exceptuado = 'S', fecha_presentacion = p_fecha_inscripcion, motivo_excep_req = 'Art7'
        WHERE nro_inscripcion = _nro_inscripcion AND carrera = p_carrera AND requisito = 'UNL03';
    END IF;

    COMMIT WORK;

    RETURN iStatus, vcMsg;	

END IF;

------------------------------------------------------------------------------------ 
-- Si tiene una inscripción a la carrera rechaza en el periodo de inscripcion.
------------------------------------------------------------------------------------ 
IF EXISTS (
    SELECT ' ' 
    FROM sga_carrera_aspira CA, sga_situacion_asp SA
    WHERE 
    CA.periodo_inscripcio       = _periodo_inscripcio
    AND CA.nro_inscripcion      = _nro_inscripcion            
    AND CA.unidad_academica     = _unidad_academica
    AND CA.carrera              = p_carrera
    AND SA.resultado_asp        = 'R'
    AND CA.situacion_asp        = SA.situacion_asp
    ) 
THEN
    -- Error
    LET vcMsg = 'La persona posee una inscripción rechazada a la carrera en el año académico ' || p_anio_academico;
    LET iStatus = -2;
    RETURN iStatus, vcMsg;	

END IF;

IF EXISTS (
    SELECT ' ' 
    FROM sga_carrera_aspira CA, sga_alumnos A, sga_situacion_asp SA
    WHERE 
        CA.nro_inscripcion      = _nro_inscripcion
        AND CA.unidad_academica = _unidad_academica
        AND CA.carrera          = p_carrera
        AND SA.resultado_asp    <> 'R'
        AND CA.situacion_asp    = SA.situacion_asp
        AND A.unidad_academica  = CA.unidad_academica
        AND A.carrera           = CA.carrera
        AND A.nro_inscripcion   = CA.nro_inscripcion
    ) 
THEN
    -- Error
    LET vcMsg = 'La persona ya es alumno en esta carrera. Ingreso año académico ' || p_anio_academico;
    LET iStatus = -3;
    RETURN iStatus, vcMsg;	
END IF;
	
-- No posee inscripcion (rechazadas no cuentan)
IF NOT EXISTS (
    SELECT ' ' 
    FROM sga_carrera_aspira CA, sga_situacion_asp SA
    WHERE 
        CA.nro_inscripcion      = _nro_inscripcion
        AND CA.unidad_academica = _unidad_academica
        AND CA.carrera          = p_carrera
        AND SA.resultado_asp    <> 'R'
        AND CA.situacion_asp    = SA.situacion_asp
    ) 
THEN
    BEGIN WORK;
		
    -- Inserto la inscripcion
    INSERT INTO sga_carrera_aspira 
    VALUES (_unidad_academica, p_carrera, _nro_inscripcion, _periodo_inscripcio, p_fecha_inscripcion, p_sede, NULL, 'I', p_fecha_inscripcion, NULL, 'AC', NULL, p_tipo_ingreso, NULL, NULL);

    -- Actualizo solo los datos de CUIL (que es de carga obligatoria para argentinos)
    UPDATE sga_personas SET numero_cuil = p_nro_cuil
    WHERE nro_inscripcion = _nro_inscripcion
    AND unidad_academica = p_unidad_academica;

    SELECT LIMIT 1 legajo INTO _legajo FROM sga_alumnos WHERE nro_inscripcion = _nro_inscripcion AND legajo IS NOT NULL;

    EXECUTE PROCEDURE "dba".sp_crear_alumno (TRIM(_unidad_academica), _nro_inscripcion, TRIM(p_carrera), _legajo, NULL) 
    INTO vc_resultado,  vi_cod_uno, vi_cod_dos, vc_mensaje;

    -- Articulo 7: Mayores de 25 se exceptuan de 921
    IF p_tipo_ingreso = 3
    THEN
        UPDATE sga_req_cumplidos 
        SET exceptuado = 'S', fecha_presentacion = p_fecha_inscripcion, motivo_excep_req = 'Art7'
        WHERE nro_inscripcion = _nro_inscripcion AND carrera = p_carrera AND requisito = 'UNL03';
    END IF;

    COMMIT WORK;

    RETURN iStatus, vcMsg;

END IF;

END PROCEDURE;

-- *************** FIN DEL PROCEDURE "dba".ws_insertar_aspirante ***************
REVOKE EXECUTE ON "dba".ws_insertar_aspirante FROM public;
GRANT EXECUTE ON "dba".ws_insertar_aspirante TO guarani; -- Rol de usuarios de Gestion
GRANT EXECUTE ON "dba".ws_insertar_aspirante TO internet; -- Rol de usuario de Internet

