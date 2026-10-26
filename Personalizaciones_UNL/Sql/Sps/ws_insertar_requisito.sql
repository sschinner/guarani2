CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ws_insertar_requisito') THEN
		DROP PROCEDURE ws_insertar_requisito;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP PROCEDURE "dba".ws_insertar_requisito;
CREATE PROCEDURE "dba".ws_insertar_requisito(
    p_unidad_academica      LIKE sga_unidades_acad.unidad_academica,
    p_carrera               LIKE sga_carreras.carrera,
    p_pais_documento        LIKE sga_personas.pais_documento,
    p_tipo_documento        LIKE sga_personas.tipo_documento,
    p_nro_documento         LIKE sga_personas.nro_documento,
    p_requisito             LIKE sga_requisitos.requisito,
    p_fecha_presentacion    LIKE sga_req_cumplidos.fecha_presentacion
)
    RETURNING INT,VARCHAR(255);

-- Descripcion de Parámetros:

-- Descripcion de Return:
-- INT: 	0 - OK
--	-1 - Error
-- VARCHAR(255): string con la descripcion del error
	
DEFINE _nro_inscripcion     LIKE sga_personas.nro_inscripcion;
DEFINE _legajo              LIKE sga_alumnos.legajo;
DEFINE _anio_academico      VARCHAR(20);
DEFINE _prorroga            VARCHAR (250);

DEFINE _fecha_presentacion  LIKE sga_req_cumplidos.fecha_presentacion;
DEFINE _exceptuado          LIKE sga_req_cumplidos.exceptuado;
DEFINE _situacion_asp       LIKE sga_situacion_asp.situacion_asp;

DEFINE vc_resultado         VARCHAR (15);
DEFINE vi_cod_uno           INTEGER;
DEFINE vi_cod_dos           INTEGER;
DEFINE vc_mensaje           VARCHAR (250);

DEFINE sql_err, isam_err  	int;
DEFINE error_info         	varchar(80);
DEFINE vcUserError          varchar(10);
DEFINE iStatus              int;
DEFINE vcMsg                varchar(255);
DEFINE _requisito_a_prorrogar LIKE sga_requisitos.requisito;
DEFINE vd_fecha_cier_reqp, vd_fecha_cier_ree, vd_f_prorroga_hasta, vd_prorroga_hasta	DATE;

  -- si hay algun error
ON EXCEPTION SET sql_err, isam_err, error_Info                                        

      LET vcUserError  = 'Error de procedimiento.';
      LET iStatus 	  = 4; 
      LET vcMsg 	  =  vcUserError || ', ' || sql_err || ' - ' || error_Info;
      RETURN iStatus, vcMsg;
END EXCEPTION;
--------------------------------------------------

LET _nro_inscripcion = NULL;
LET _requisito_a_prorrogar = NULL;
LET _fecha_presentacion = NULL;
LET error_info = NULL;
LET sql_err = 0;
LET isam_err = 0;
LET iStatus = 0;
LET vcMsg =  'OK - Requisito insertado correctamente';
LET vd_f_prorroga_hasta = NULL;

------------------------------------------------------------------------------------ 

SELECT per.nro_inscripcion, sit.resultado_asp, insc.anio_academico, insc.fecha_cierre_req, sfer.fecha_cierre_req
    INTO _nro_inscripcion, _situacion_asp, _anio_academico, vd_fecha_cier_reqp, vd_fecha_cier_ree
FROM sga_personas per
JOIN sga_carrera_aspira asp ON per.nro_inscripcion = asp.nro_inscripcion
JOIN sga_situacion_asp sit ON sit.situacion_asp = asp.situacion_asp
JOIN sga_periodo_insc insc ON insc.periodo_inscripcio = asp.periodo_inscripcio
LEFT JOIN sga_fec_excep_req as sfer ON sfer.periodo_inscripcio = asp.periodo_inscripcio AND (sfer.requisito = p_requisito OR sfer.requisito is null)

WHERE 
    per.tipo_documento          = p_tipo_documento 
    AND per.nro_documento       = p_nro_documento
    AND per.pais_documento      = p_pais_documento
    AND per.unidad_academica    = p_unidad_academica
    AND asp.carrera             = p_carrera
			
    AND asp.fecha_inscripcion   = (
                SELECT max(asp.fecha_inscripcion) 
                FROM sga_personas per
                JOIN sga_carrera_aspira asp ON per.nro_inscripcion = asp.nro_inscripcion
                WHERE per.tipo_documento = p_tipo_documento 
                    AND per.nro_documento = p_nro_documento
                    AND per.pais_documento = p_pais_documento
                    AND per.unidad_academica = p_unidad_academica
                    AND asp.carrera = p_carrera);

IF _situacion_asp = 'R'
THEN
    -- Error
	LET vcMsg = 'La persona se encuentra rechazada en esta carrera';
	LET iStatus = -4;
	RETURN iStatus, vcMsg;
END IF;

IF _nro_inscripcion IS NULL
THEN
    -- Error
    LET vcMsg = 'La persona no se encuentra inscripta en esta carrera';
    LET iStatus = -1;
    RETURN iStatus, vcMsg;
END IF;

IF NOT EXISTS (SELECT requisito FROM sga_requisitos WHERE requisito = p_requisito)
THEN
    -- Error
    LET vcMsg = 'El requisito es inexistente';
    LET iStatus = -3;
    RETURN iStatus, vcMsg;
END IF;

    ------------------------------------------------------------------------------------ 
    -- Verifico si lo tiene asociado y/o presentado
    ------------------------------------------------------------------------------------ 
    IF EXISTS (
            SELECT requisito 
            FROM sga_req_cumplidos
            WHERE 
                unidad_academica = p_unidad_academica
                AND nro_inscripcion = _nro_inscripcion
                AND carrera = p_carrera
                AND requisito = p_requisito
        ) 
    THEN
        -- Verifico si ya esta presentado
        SELECT fecha_presentacion, exceptuado, f_prorroga_hasta INTO _fecha_presentacion, _exceptuado, vd_prorroga_hasta
        FROM sga_req_cumplidos
        WHERE unidad_academica = p_unidad_academica
            AND nro_inscripcion = _nro_inscripcion
            AND carrera = p_carrera
            AND requisito = p_requisito;

        IF  (_fecha_presentacion IS NOT NULL) OR (_exceptuado = 'S')
        THEN
            -- Error
            LET vcMsg = 'La persona ya posee presentado el requisito de ingreso';
            LET iStatus = -2;
            RETURN iStatus, vcMsg;
        END IF;


	-- Aqui debo verificar si esta presentado fuera de fecha: 
	-- Presento el requisito fuera del termino de la fecha definida para su presentacion (Períodos, excepciones..) y no esta prorrogado? (No se modifica la prorroga en caso de estar cargada)
	-- Si es así, colocar el requisito como prorrogado al dia de la presentación


	IF vd_fecha_cier_ree IS NOT NULL THEN
		IF p_fecha_presentacion > vd_fecha_cier_ree THEN	
			LET vd_f_prorroga_hasta = p_fecha_presentacion;
		END IF;
	ELSE
		IF p_fecha_presentacion > vd_fecha_cier_reqp THEN
			LET vd_f_prorroga_hasta = p_fecha_presentacion;
		END IF;
	END IF;


        -- Actualizo datos de cumplimiento del requisito
        UPDATE  sga_req_cumplidos 
        SET     fecha_presentacion = p_fecha_presentacion, exceptuado = 'N', f_prorroga_hasta = vd_f_prorroga_hasta
        WHERE   
            unidad_academica = p_unidad_academica
            AND nro_inscripcion = _nro_inscripcion
            AND carrera = p_carrera
            AND requisito = p_requisito;
    
    ELSE 
    
    	-- Aqui debo volver a verificar si esta presentado fuera de fecha, porque tambien se controlan requisitos no obligatorios para cambiar la condicionalidad: 
	-- Presento el requisito fuera del termino de la fecha definida para su presentacion (Períodos, excepciones..) y no esta prorrogado? No se modifica la prorroga en caso de estar cargada.
	-- Si es así, colocar el requisito como prorrogado al dia de la presentación


	IF vd_fecha_cier_ree IS NOT NULL THEN
		IF p_fecha_presentacion > vd_fecha_cier_ree THEN	
			LET vd_f_prorroga_hasta = p_fecha_presentacion;
		END IF;
	ELSE
		IF p_fecha_presentacion > vd_fecha_cier_reqp THEN
			LET vd_f_prorroga_hasta = p_fecha_presentacion;
		END IF;
	END IF;

	
        -- Si no lo tiene asociado (solo deberia suceder con requisitos que NO son de ingreso)
        INSERT INTO sga_req_cumplidos (unidad_academica, nro_inscripcion, requisito, carrera, obligatoriedad, fecha_presentacion, f_prorroga_hasta)
        VALUES (p_unidad_academica, _nro_inscripcion, p_requisito, p_carrera, 'N', p_fecha_presentacion, vd_f_prorroga_hasta);

    END IF;

------------------------------------------------------------------------------------
-- Gestion de Supletorios
------------------------------------------------------------------------------------

    IF 
        -- UNL03 - Certificado de Estudios Secundarios legalizado en la UNL
        p_requisito = 'UNL15' OR    -- Fotocopia del titulo no legalizado
        p_requisito = 'UNL16' OR    -- Fotocopia del titulo legaliz. y conv. por el Min. de Ed.
        p_requisito = 'UNL17' OR    -- Fotocopia del titulo legalizado y no convalidado
        p_requisito = 'UNL18' OR    -- Fotocopia del titulo leg. y con rev. asig. form. nac.
        p_requisito = 'UNL19'       -- Fotocopia del titulo legalizado y no revalidado
    THEN
        LET _requisito_a_prorrogar = 'UNL03';
    END IF;

    IF 
        -- POS01 - Fotocopia del titulo Universitario
        p_requisito = 'POS02' OR    -- Constancia de titulo Universitario en TrÃ¡mite
        p_requisito = 'POS08'       -- Fotocopia del titulo Universitario no legalizado por UNL
    THEN
        LET _requisito_a_prorrogar = 'POS01';
    END IF;

    IF 
        -- UNL22 - Certificado de Estudios Terciarios legalizado en la UNL
        p_requisito = 'UNL20' OR    -- Fotocopia del Título Terciario
        p_requisito = 'UNL21'       -- Constancia de Título Terciario en Trámite
    THEN
        LET _requisito_a_prorrogar = 'UNL22';
    END IF;

    IF _requisito_a_prorrogar IS NOT NULL
    THEN
        -- y tiene asociado el requisito a prorrogar, pero no presentado
        IF EXISTS (
            SELECT requisito 
            FROM sga_req_cumplidos 
            WHERE requisito = _requisito_a_prorrogar AND fecha_presentacion IS NULL
        )
        THEN
            -- Prorrogar el requisito hasta el 01/06 del anio siguiente.
            LET _anio_academico = CAST(_anio_academico AS INTEGER) + 1;
            LET _prorroga = _anio_academico || '-06-01';
            
            UPDATE  sga_req_cumplidos
            SET     f_prorroga_hasta = to_date(_prorroga, "%Y-%m-%d"), observaciones = 'Presentó supletorio ' || p_requisito
            WHERE   requisito = _requisito_a_prorrogar AND nro_inscripcion = _nro_inscripcion AND carrera = p_carrera;
        END IF;
    END IF;

------------------------------
-- Fin gestion de supletorios
------------------------------

RETURN iStatus, vcMsg;

END PROCEDURE;
-- *************** FIN DEL PROCEDURE "dba".ws_insertar_requisito ***************

revoke execute ON "dba".ws_insertar_requisito from public;
grant execute ON "dba".ws_insertar_requisito to guarani; -- Rol de usuarios de Gestion
grant execute ON "dba".ws_insertar_requisito to internet; -- Rol de usuario de Internet

