CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
    IF EXISTS (SELECT procid
            FROM sysprocedures
            WHERE procname = 'sp_carga_enc_crea') THEN
        DROP PROCEDURE sp_carga_enc_crea;
    END IF;     
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ***********************************************************************************
-- SIU-GUARANI
-- Version 2.07.0
-- Modificacion 2.8.0, 2.8.X (parche)
-- Procedure sp_carga_enc_crea
-- crea los items para pasar a kolla
-- da de baja los items para el alcance del argumento
-- setea el campo kolla_sincronizar = 'S' 
-- ***********************************************************************************
-- DROP PROCEDURE sp_carga_enc_crea;
CREATE PROCEDURE "dba".sp_carga_enc_crea(pAlcance LIKE gde_encues_alcance.alcance)

                             RETURNING INTEGER, -- cantidad de personas
                                       INTEGER, -- minimo id
                                       INTEGER; -- maximo id


DEFINE vcUA VARCHAR(5);
DEFINE vcNroInsc varchar(10);
DEFINE i_anio_academico integer;
DEFINE vc_periodo_lect  LIKE sga_comisiones.periodo_lectivo;

DEFINE vi_min_id integer;
DEFINE vi_max_id integer;
DEFINE vi_cant_personas integer;

--*****************************
DEFINE c_generar LIKE gde_encues_alcance.generar;
DEFINE c_responderan LIKE gde_encues_alcance.responderan;
DEFINE c_todos CHAR(1);
DEFINE i_alcance_car        INTEGER;
DEFINE i_alcance_mat        INTEGER;
DEFINE i_alcance_com        INTEGER;
DEFINE i_alcance_doc        INTEGER;
DEFINE i_alcance_rol        INTEGER;
DEFINE vc_titulo LIKE gde_encues_alcance.titulo;
DEFINE iCantItemsNuevos INTEGER;
--*****************************

BEGIN

    LET i_alcance_mat = 0;
    LET i_alcance_car = 0;
    LET i_alcance_doc = 0;
    LET i_alcance_com = 0;
    LET i_alcance_rol = 0;
    LET vi_cant_personas = 0;
    LET vi_min_id = 0;
    LET vi_max_id = 0;
    LET iCantItemsNuevos = 0;
  -- Bloque para crear tablas temporales.
    BEGIN

        ON EXCEPTION IN (-958, -316) -- Temp table  already exists in session 
          -- Si existe la tabla continua en la siguiente sentencia...
        END EXCEPTION WITH RESUME;

        -- Creo la tabla temporal de las personas que deberan responder
        CREATE TEMP TABLE tmp_inscrip_enc11 (
          unidad_academica  VARCHAR(5),   
          carrera  VARCHAR(5),
          legajo   VARCHAR(15),
          comision INTEGER,
          materia VARCHAR(5),
          plan_alu VARCHAR(5),
          version_alu VARCHAR(5),
          nro_inscripcion VARCHAR(10)
        ) WITH NO LOG;

        CREATE INDEX tmp_inscrip_alu ON tmp_inscrip_enc11 (unidad_academica, carrera, legajo, comision);
        CREATE INDEX tmp_inscrip_per ON tmp_inscrip_enc11 (unidad_academica, nro_inscripcion);

       CREATE TEMP TABLE tmp_total_personas(
        ID serial,
        unidad_academica varchar(5),
        nro_inscripcion varchar(10)
       ) WITH NO LOG;

       CREATE TEMP TABLE tmp_items_orig(item integer);

    END;
    -- Borro los datos si la tabla temporal existia...    
    DELETE FROM tmp_inscrip_enc11;
    DELETE FROM tmp_total_personas;

    -- Inserto los items que ya existen para el alcance    
    DELETE FROM tmp_items_orig;
    INSERT INTO tmp_items_orig (item)
      SELECT item FROM gde_items WHERE alcance = pAlcance;
       
 
    SELECT unidad_academica, anio_academico, periodo_lectivo, generar, responderan, titulo
        INTO vcUA, i_anio_academico, vc_periodo_lect, c_generar, c_responderan, vc_titulo
        FROM gde_encues_alcance
        WHERE alcance = pAlcance;

    IF vc_periodo_lect IS NULL THEN 
        LET vc_periodo_lect = 'TODOS';
    END IF;

--    UPDATE gde_items
--        SET estado = 'B'
--        WHERE alcance = pAlcance;

    ---*****UNICA ENCUESTA
    IF c_generar = 'U' THEN

        EXECUTE PROCEDURE sp_carga_enc_u(pAlcance);

    END IF;
    ---*****FIN UNICA ENCUESTA

    --****UNA ENCUESTA POR CARRERA DEL ALUMNO
    IF c_generar = 'C' THEN
        
        EXECUTE PROCEDURE sp_carga_enc_c(pAlcance);

    END IF;
    --****FIN UNA ENCUESTA POR CARRERA DEL ALUMNO
    --****UNA ENCUESTA POR MATERIA CURSADA O INSCRIPTO*****
    IF c_generar = 'I' THEN

        EXECUTE PROCEDURE sp_carga_enc_i(pAlcance);

    END IF;
    --****FIN UNA ENCUESTA POR MATERIA CURSADA O INSCRIPTO*****
    --***UNA ENCUESTA POR MATERIA APROBADA O REPROBADA*****
    IF c_generar = 'A' THEN

        EXECUTE PROCEDURE sp_carga_enc_a(pAlcance);

    END IF;
    --***FIN UNA ENCUESTA POR MATERIA APROBADA O REPROBADA*****
    --***UNA ENCUESTA POR DOCENTE*****
    IF c_generar = 'D' THEN

        EXECUTE PROCEDURE sp_carga_enc_d(pAlcance);

    END IF;
    --***FIN UNA ENCUESTA POR DOCENTE*****

    INSERT INTO tmp_total_personas (unidad_academica, nro_inscripcion)
    SELECT DISTINCT unidad_academica, nro_inscripcion
        FROM tmp_inscrip_enc11;

    LET vi_cant_personas = DBINFO("SQLCA.sqlerrd2") ;

    SELECT MIN(id)
        INTO vi_min_id
        FROM tmp_total_personas;

    SELECT max(id)
        INTO vi_max_id
        FROM tmp_total_personas;

    IF vi_min_id IS NULL THEN
        
        LET vi_min_id = 0;
        
    END IF;
    IF vi_max_id IS NULL THEN
        
        LET vi_max_id = 0;
        
    END IF;

    -- Verifico si hay items nuevos
    SELECT COUNT(*) INTO iCantItemsNuevos
      FROM gde_items  
     WHERE alcance = pAlcance
       AND item NOT IN (SELECT item FROM tmp_items_orig);
    IF iCantItemsNuevos > 0 THEN
	  UPDATE gde_encues_alcance SET kolla_sincronizar = 'S' WHERE alcance = pAlcance;
	END IF;  


    -- Retorno del procedure.
    RETURN vi_cant_personas, vi_min_id, vi_max_id;
	
END;
END PROCEDURE;
-- +++++++++++++++++++++++++ Fin procedure sp_carga_enc_crea ++++++++++++++++++
revoke execute on sp_carga_enc_crea from public;

grant execute on sp_carga_enc_crea to guarani; -- Rol de usuarios de Gestión
grant execute on sp_carga_enc_crea to internet; -- Usuario de internet
