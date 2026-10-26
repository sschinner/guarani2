
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Interfaz con SPU - Calidad - Plan de Formacion de Ingenieros.
-- Procedure: sp_int_pfi_ra (plan de formacion de ingenieros rendimiento academico)
-- Version: 2.05.0 o superior
--
-- Informa el rendimiento acadomico de los alumnos en la carrera desde el ingreso a la misma y en un anio en particular. Si la carrera tiene definido un Ciclo Basico, entonces
-- tambien informa las materias cursadas y rendidas del ciclo bosico.
-- Informa datos censales
-- Recibe:
--    Legajo del Alumno (UA + Carrera + Legajo) y anio academico.

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_int_pfi_ra') THEN
		DROP PROCEDURE sp_int_pfi_ra;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


CREATE PROCEDURE "dba".sp_int_pfi_ra (pUnidadAcademica LIKE sga_alumnos.unidad_academica, pCarrera LIKE sga_alumnos.carrera, pLegajo LIKE sga_alumnos.legajo,pAnio INTEGER)
  RETURNING 
VARCHAR(60), -- vcNombreInstitArau 1
INTEGER,-- iInstitucionArau 2
VARCHAR(60),-- vcNombreUA 3
INTEGER,-- iInstitucionArau 4
VARCHAR(255),-- vcNomreCarrera 5
INTEGER,-- iTitArau 6
VARCHAR(30),-- vcApellido 7
VARCHAR(30),-- vcNombres 8
INTEGER,-- cGenero 9
CHAR(8), --vc_fecha_nac 10
CHAR(3),-- vcTipoDoc 11
VARCHAR(15),-- vcNroDoc 12
INTEGER,-- iAnioIngreso 13
INTEGER,-- cant_aprobadas 14
INTEGER,-- Integer  cant_cursadas 15
INTEGER,-- cant_mat_plan 16
INTEGER,-- cant_aprobadas_anio_actual 17
CHAR(8),-- vcFechaUltAct 18
CHAR(1),-- cTrabaja 19
CHAR(1),-- vcTrabHace 20
CHAR(1),-- vcTrabOcupa 21
CHAR(1),-- vcCantHorSemTrab 22
CHAR(1),-- vcRelTrabCar 23
CHAR(1), --beca_servicio 24
CHAR(1), --beca_investigacion 25
CHAR(1), --beca_ayuda_eco 26
CHAR(1), --beca_uni 27
CHAR(1), --beca_inter 28
CHAR(1), --beca_nac 29
CHAR(1), --beca_prov 30
CHAR(1), --beca_muni 31
CHAR(1), --beca_otra 32
CHAR(1), --tiene_hijos 33
CHAR(1), --cant_hijos 34
CHAR(1), --fam_a_cargo 35
CHAR(1), --estado_civil 36
CHAR(2), --nivel_inst_padre 37
CHAR(1), --sit_lab_padre 38
CHAR(1), --tipo_trab_padre 39
CHAR(1), --notrabaja_quehace 40 ESTO REVISAR
CHAR(1), --padre_trabajo_ocupa 41
CHAR(2), --nivel_inst_madre 42
CHAR(1), --sit_lab_madre 43
CHAR(1), --tipo_trab_madre 44
CHAR(1), --madre_trab_ocupa 45
CHAR(1), --notrabaja_quehace 46
INTEGER, --loc_per_lec 47
INTEGER, --loc_proc 48
CHAR(8); --vc_fec_ult_act_dc 49


DEFINE vc_carrera_cc LIKE sga_alumnos.carrera;
DEFINE vc_legajo_cc  LIKE sga_alumnos.legajo;
DEFINE vc_plan_cc    VARCHAR(5);
DEFINE vc_version_cc VARCHAR(5);
DEFINE iAnioIngreso  INTEGER;
DEFINE cnt           INTEGER;
DEFINE vPlan         VARCHAR(5);
DEFINE vVersionPlan	 VARCHAR(5);
DEFINE ExisteCC      CHAR(1);

DEFINE cant_aprobadas         INTEGER;
DEFINE cant_aprobadas_anio_actual    INTEGER;
DEFINE cantaprobanioact    INTEGER;

DEFINE cant_cursadas          INTEGER;
DEFINE cant_mat_plan          INTEGER;
DEFINE dFechaUltAct           DATE;
DEFINE vcFechaUltAct          CHAR(8);
DEFINE dFechaUltActDatCen     DATE;
DEFINE vcNroInscripcion       LIKE sga_alumnos.nro_inscripcion;
DEFINE cTrabaja               CHAR(1);
DEFINE cTrabajaPadre          CHAR(1);
DEFINE cTrabajaMadre          CHAR(1);
DEFINE vcTrabHace             CHAR(1);
DEFINE vcTrabHacePadre        CHAR(1);
DEFINE vcTrabHaceMadre        CHAR(1);
DEFINE vcTrabOcupa            CHAR(1);
DEFINE vcTrabOcupaPadre       CHAR(1);
DEFINE vcTrabOcupaMadre       CHAR(1);
DEFINE vcCantHorSemTrab       CHAR(1);
DEFINE vcRelTrabCar           CHAR(1);
DEFINE cGenero                CHAR(1);
DEFINE vcTipoDoc              VARCHAR(5);
DEFINE vcNroDoc               VARCHAR(15);
DEFINE vcApellido             VARCHAR(30);
DEFINE vcNombres              VARCHAR(30);
DEFINE iTitArau               INTEGER;
DEFINE vcNomreCarrera         VARCHAR(100);
DEFINE iInstitucionArau       INTEGER;
DEFINE vcNombreUA             VARCHAR(60);
DEFINE vcNombreInstitArau     VARCHAR(60);

DEFINE cAluTieneBeca          CHAR(1);
DEFINE cAluBecaTipoEco        CHAR(1);
DEFINE cAluBecaTipoSer        CHAR(1);
DEFINE cAluBecaTipoInv        CHAR(1);
DEFINE cAluBecaProv        CHAR(1);
DEFINE cAluBecaMuni        CHAR(1);
DEFINE cAluBecaOtra        CHAR(1);
DEFINE cAluBecaUni        CHAR(1);
DEFINE cAluBecaNac        CHAR(1);
DEFINE cAluBecaInt        CHAR(1);
DEFINE cAluTieneHijos     CHAR(1);
DEFINE cAluCantHijos      CHAR(1);
DEFINE cAluCantACargo     CHAR(1);
DEFINE cAluEstadoCivil    CHAR(1);
DEFINE cAuxEstadoCivil    CHAR(1);
DEFINE cPadreNivelEst     CHAR(2);
DEFINE cMadreNivelEst     CHAR(2);
DEFINE cPadreNoTrabaja    CHAR(1);
DEFINE cMadreNoTrabaja    CHAR(1);

DEFINE iLocPerLec         INTEGER;
DEFINE iLocProc           INTEGER;
DEFINE vc_fecha_nac CHAR(8);
DEFINE vc_fec_ult_act_dc CHAR(8);
DEFINE vdFechaInicio      DATE;
DEFINE vdFechaFin         DATE;

BEGIN
   
   -- inicializo valores default
    LET vcNombreInstitArau = NULL;
    LET iInstitucionArau = NULL;
    LET vcNombreUA = NULL;
    LET cGenero = NULL;
    LET vcTipoDoc = NULL;
    LET vcNroDoc = NULL;
    LET vcApellido = NULL;
    LET vcNombres = NULL;
    LET iTitArau = 0;
    LET vcCantHorSemTrab = NULL;
    LET vcRelTrabCar = NULL;
    LET vcTrabOcupa = NULL;
    LET vcTrabOcupaPadre = NULL;
    LET vcTrabOcupaMadre = NULL;
    LET vcTrabHace = NULL;
    LET vcTrabHaceMadre = NULL;
    LET vcTrabHacePadre = NULL;
    LET cTrabaja       = NULL;
    LET cTrabajaPadre  = NULL;
    LET cTrabajaMadre  = NULL;
    LET vcNroInscripcion = NULL;
    LET dFechaUltActDatCen = NULL;
    LET dFechaUltAct = NULL;
    LET vcFechaUltAct = '';
    LET cant_mat_plan = 0;
    LET cant_cursadas = 0;
    LET cant_aprobadas_anio_actual = 0;
    LET cantaprobanioact = 0;
    LET cant_aprobadas = 0;

    LET cAluBecaTipoEco        =NULL;
    LET cAluBecaTipoInv        =NULL;
    LET cAluBecaTipoSer        =NULL;

    LET cAluTieneBeca       = NULL;
    LET cAluBecaProv        = NULL;
    LET cAluBecaMuni        = NULL;
    LET cAluBecaOtra        = NULL;
    LET cAluBecaUni        = NULL;
    LET cAluBecaNac        = NULL;
    LET cAluBecaInt        = NULL;
    LET cAluTieneHijos     = NULL;
    LET cAluCantHijos      = NULL;
    LET cAluCantACargo     = NULL;
    LET cAluEstadoCivil    = NULL;
    LET cAuxEstadoCivil    = NULL;
    LET cMadreNivelEst     = NULL;
    LET cPadreNivelEst     = NULL;
    LET cMadreNoTrabaja    = NULL;
    LET cPadreNoTrabaja    = NULL;

    LET iLocPerLec = 0;
    LET iLocProc = 0;

    LET vc_carrera_cc  = NULL;
    LET vc_legajo_cc   = NULL;
    LET vc_plan_cc     = NULL;
    LET vc_version_cc  = NULL;
    LET vPlan        = NULL;
    LET vVersionPlan        = NULL;
    LET cant_aprobadas  = NULL;
    LET cant_cursadas  = NULL;
    LET cnt  = 0;
    LET ExisteCC = 'N';
    LET iAnioIngreso = 0;
    LET vc_fecha_nac = '00000000';
    LET vc_fec_ult_act_dc = '00000000';
--set debug file to 'c:\debug_spu.txt';
--trace on;
  BEGIN 
   ON EXCEPTION IN (-206)
     -- Tabla no existe. Continuo.
   END EXCEPTION WITH RESUME;
    -- Borro las tablas por si existen.
    DROP TABLE t_spu_calidad_reg;
    DROP TABLE t_spu_calidad_apr;
    DROP TABLE t_spu_calidad_act;
    CREATE TEMP TABLE t_spu_calidad_reg (materia VARCHAR(5)) WITH NO LOG;
    CREATE TEMP TABLE t_spu_calidad_apr (materia VARCHAR(5), fecha DATE) WITH NO LOG;
    CREATE TEMP TABLE t_spu_calidad_act (actividad CHAR(2), fecha DATETIME YEAR TO SECOND) WITH NO LOG;
  END;

    SELECT ua.nombre, ua.instituc_araucano,  inst_arau.nombre
            INTO vcNombreUA, iInstitucionArau, vcNombreInstitArau
        FROM sga_unidades_acad ua, int_arau_instituc inst_arau
        WHERE ua.instituc_araucano = inst_arau.instituc_araucano;

    SELECT desc_abreviada, nro_documento, apellido, nombres, DECODE(sexo,'1','2','2','1') genero, alu.nro_inscripcion, to_char(fecha_nacimiento, "%Y%m%d")
            INTO vcTipoDoc, vcNroDoc, vcApellido, vcNombres, cGenero, vcNroInscripcion, vc_fecha_nac
        FROM sga_alumnos alu,
            sga_personas per,
            mdp_tipo_documento tdoc
        WHERE alu.unidad_academica  = pUnidadAcademica
        AND alu.carrera = pcarrera
        AND alu.legajo = plegajo
        AND alu.unidad_academica = per.unidad_academica
        AND alu.nro_inscripcion = per.nro_inscripcion
        AND per.tipo_documento = tdoc.tipo_documento;

    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- Verifico si esta en 2.6.1 o superior 
    -- En esta version se incluyo la tabla int_arau_car_cc (Relaciona la Carrera con el Ciclo Basico)
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    SELECT count(*) INTO cnt
    FROM app_versiones as v 
    WHERE (v.version like '%2.06.1%' OR 
           v.version like '%2.06.2%' OR 
           v.version like '%2.06.3%' OR 
           v.version like '%2.06.4%' OR 
           v.version like '%2.06.5%' OR 
           v.version like '%2.07.%' OR 
           v.version like '%2.08.%' );

    IF cnt > 0 THEN

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Ciclo Comun asociado a la Carrera del Alumno
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        SELECT legajo_cc.carrera, legajo_cc.legajo
            INTO vc_carrera_cc, vc_legajo_cc
        FROM sga_alumnos, 
            int_arau_car_cc, 
            sga_alumnos as legajo_cc
        WHERE sga_alumnos.unidad_academica = pUnidadAcademica
        AND sga_alumnos.carrera		= pCarrera
        AND sga_alumnos.legajo 		= pLegajo
        AND int_arau_car_cc.unidad_academica = sga_alumnos.unidad_academica
        AND int_arau_car_cc.carrera          = sga_alumnos.carrera
        AND legajo_cc.unidad_academica       = int_arau_car_cc.unidad_academica
        AND legajo_cc.carrera                = int_arau_car_cc.carrera_ciclocomun
        AND legajo_cc.nro_inscripcion        = sga_alumnos.nro_inscripcion;

        -- La carrera del Alumno tiene un ciclo basico asociado.       
        IF vc_carrera_cc IS NOT NULL THEN
         LET ExisteCC = 'S';
        END IF;

    END IF; -- Existe la tabla int_arau_car_cc

    -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                       CICLO COMUN DE LA CARRERA DEL ALUMNO
    -- 
    -- 
    -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    IF ExisteCC = 'S' THEN
    --anio ingreso
        SELECT pi.anio_academico
                INTO iAnioIngreso
            FROM sga_carrera_aspira ca, sga_periodo_insc pi, sga_alumnos alu
            WHERE alu.unidad_academica = pUnidadAcademica
            AND alu.carrera = vc_carrera_cc
            AND alu.legajo = vc_legajo_cc
            AND ca.unidad_academica = alu.unidad_academica
            AND ca.carrera = alu.carrera
            AND ca.nro_inscripcion = alu.nro_inscripcion
            AND ca.periodo_inscripcio = pi.periodo_inscripcio
            AND ca.situacion_asp in ('IL', 'IC');
            -- Plan y Version actual del alumno en la carrera Ciclo Comun asociada con la carrera informada en la beca.
        EXECUTE PROCEDURE sp_plan_de_alumno(pUnidadAcademica, vc_carrera_cc, vc_legajo_cc, TODAY) INTO vc_plan_cc, vc_version_cc;

        INSERT INTO t_spu_calidad_act (actividad, fecha)
            SELECT 'IC', MAX(fecha_inscripcion)
            FROM sga_insc_cursadas
            WHERE unidad_academica = pUnidadAcademica
            AND carrera = vc_carrera_cc
            AND legajo = vc_legajo_cc
            AND estado IN ('A', 'E')
            GROUP BY 1;

        INSERT INTO t_spu_calidad_act (actividad, fecha)
            SELECT 'IE', MAX(fecha_inscripcion)
            FROM sga_insc_examen
            WHERE unidad_academica = pUnidadAcademica
            AND carrera = vc_carrera_cc
            AND legajo = vc_legajo_cc
            AND estado  IN ('A', 'E')
            GROUP BY 1;

        INSERT INTO t_spu_calidad_act (actividad, fecha)
            SELECT 'CC', MAX(fecha_regularidad)
            FROM sga_cursadas
            WHERE unidad_academica = pUnidadAcademica
            AND carrera = vc_carrera_cc
            AND legajo = vc_legajo_cc
            GROUP BY 1;

        INSERT INTO t_spu_calidad_act (actividad, fecha)
            SELECT 'EE', MAX(fecha)
            FROM vw_hist_academica
            WHERE unidad_academica = pUnidadAcademica
            AND carrera = vc_carrera_cc
            AND legajo = vc_legajo_cc
            AND forma_aprobacion IN ('Examen', 'Examen equivalente', 'Promoción', 'Promoción en otra carrera', 'Equivalencia', 'Equivalencia equivalente')  
            GROUP BY 1;

        INSERT INTO t_spu_calidad_apr (materia, fecha)
         SELECT vw_hist_academica.materia, fecha
          FROM  vw_hist_academica,
                sga_atrib_mat_plan
         WHERE vw_hist_academica.unidad_academica = pUnidadAcademica
           AND vw_hist_academica.carrera          = vc_carrera_cc
           AND vw_hist_academica.legajo           = vc_legajo_cc
           AND vw_hist_academica.resultado = 'A' -- Aprobadas
           AND sga_atrib_mat_plan.unidad_academica = vw_hist_academica.unidad_academica	 
           AND sga_atrib_mat_plan.carrera          = vw_hist_academica.carrera 
           AND sga_atrib_mat_plan.plan             = vc_plan_cc --vw_hist_academica.plan 
           AND sga_atrib_mat_plan.version          = vc_version_cc  --vw_hist_academica.version 
           AND sga_atrib_mat_plan.materia          = vw_hist_academica.materia;
           
        -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        -- Cursadas Aprobadas/Reprobadas
        -- ORIGEN:    'P'  = Acta de Promocion / 
        --            'C'  = Acta de Cursados (Regulares)    
        --            'CE' = Equivalencia de Regularidades en otras Carreras     
        --            'EE' = Equivalencia Parcial equivalente
        --            'E'  = Equivalencia Parcial 
        -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        INSERT INTO t_spu_calidad_reg (materia)
        SELECT sga_cursadas.materia
         FROM  sga_cursadas, 
               sga_atrib_mat_plan
         WHERE sga_cursadas.unidad_academica = pUnidadAcademica
           AND sga_cursadas.carrera          = vc_carrera_cc
           AND sga_cursadas.legajo           = vc_legajo_cc
           AND sga_atrib_mat_plan.unidad_academica = sga_cursadas.unidad_academica 
           AND sga_atrib_mat_plan.carrera          = sga_cursadas.carrera        
           AND sga_atrib_mat_plan.plan             = vc_plan_cc           
           AND sga_atrib_mat_plan.version          = vc_version_cc    
           AND sga_atrib_mat_plan.materia          = sga_cursadas.materia
           AND (sga_cursadas.fin_vigencia_regul  >= TODAY OR sga_cursadas.fin_vigencia_regul IS NULL)
           AND sga_cursadas.resultado IN ('A','P')
           AND sga_cursadas.origen in ('C', 'CE','E', 'EE','P');

    END IF; 
    -- ********************************* CICLO BASICO ************************************


    -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                           CARRERA DEL ALUMNO
    -- 
    -- 
    -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


    IF (iAnioIngreso = 0) THEN
        SELECT pi.anio_academico
                INTO iAnioIngreso
            FROM sga_carrera_aspira ca, sga_periodo_insc pi, sga_alumnos alu
            WHERE alu.unidad_academica = pUnidadAcademica
            AND alu.carrera = pCarrera
            AND alu.legajo = pLegajo
            AND ca.unidad_academica = alu.unidad_academica
            AND ca.carrera = alu.carrera
            AND ca.nro_inscripcion = alu.nro_inscripcion
            AND ca.periodo_inscripcio = pi.periodo_inscripcio
            AND ca.situacion_asp in ('IL', 'IC');
    END IF;

    -- Plan y Version actual del alumno
    EXECUTE PROCEDURE sp_plan_de_alumno(pUnidadAcademica, pCarrera, pLegajo, TODAY) INTO vPlan, vVersionPlan;
    --EXECUTE PROCEDURE sp_int_spucal_plan (pUnidadAcademica, pCarrera, vPlan, vVersionPlan) INTO cant_mat_plan;
    SELECT cnt_materias 
     INTO cant_mat_plan
     FROM sga_planes
     WHERE unidad_academica = pUnidadAcademica
     AND carrera = pCarrera
     AND plan = vPlan;

    SELECT car.nombre, tit_arau.titulo_araucano
        INTO vcNomreCarrera, iTitArau
        FROM sga_carreras car,
        int_arau_titulos tit_arau,
        sga_titulos_plan tp,
        sga_titulos tit
    WHERE tp.unidad_academica = pUnidadAcademica
    AND tp.carrera = pcarrera
    AND tp.plan = vPlan
    AND tp.unidad_academica = car.unidad_academica
    AND tp.carrera = car.carrera
    AND tp.unidad_academica = tit.unidad_academica
    AND tp.titulo = tit.titulo
    AND tit.titulo_araucano = tit_arau.titulo_araucano
    AND tit.nivel = 'GRADO';


    INSERT INTO t_spu_calidad_apr (materia, fecha)
    SELECT vw_hist_academica.materia, fecha
      FROM  vw_hist_academica,
            sga_atrib_mat_plan
     WHERE vw_hist_academica.unidad_academica = pUnidadAcademica
       AND vw_hist_academica.carrera          = pCarrera
       AND vw_hist_academica.legajo           = pLegajo
       AND vw_hist_academica.resultado = 'A' -- Aprobadas
       AND sga_atrib_mat_plan.unidad_academica = vw_hist_academica.unidad_academica	 
       AND sga_atrib_mat_plan.carrera          = vw_hist_academica.carrera 		       
       AND sga_atrib_mat_plan.plan             = vPlan                    
       AND sga_atrib_mat_plan.version          = vVersionPlan 	       
       AND sga_atrib_mat_plan.materia          = vw_hist_academica.materia;   

    -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- Cursadas Aprobadas/Reprobadas
    -- ORIGEN:    P =  Acta de Promocion / C = Acta de Cursados (Regulares) / CE =  Equivalencia de Regularidades en otras Carreras  /  EE = Equivalencia Parcial equivalente /  E = Equivalencia Parcial 
    -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    INSERT INTO t_spu_calidad_reg (materia)
    SELECT sga_cursadas.materia
      FROM  sga_cursadas,
            sga_atrib_mat_plan
     WHERE sga_cursadas.unidad_academica = pUnidadAcademica
       AND sga_cursadas.carrera          = pCarrera
       AND sga_cursadas.legajo           = pLegajo
       AND sga_atrib_mat_plan.unidad_academica = sga_cursadas.unidad_academica	 
       AND sga_atrib_mat_plan.carrera          = sga_cursadas.carrera 		       
       AND sga_atrib_mat_plan.plan             = vPlan 	           
       AND sga_atrib_mat_plan.version          = vVersionPlan 	       
       AND sga_atrib_mat_plan.materia          = sga_cursadas.materia
       AND (sga_cursadas.fin_vigencia_regul  >= TODAY OR sga_cursadas.fin_vigencia_regul IS NULL)
       AND sga_cursadas.resultado IN ('A','P')
       AND sga_cursadas.origen in ('C', 'CE','E', 'EE','P');

    DELETE FROM t_spu_calidad_reg WHERE materia IN (SELECT materia FROM t_spu_calidad_apr);

    -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- Actividad IC = Inscripcion a cursada aceptada
    --           IE = Inscripcion a examen aceptada
    --           CC = Cursada
    --           EE = Examen o equivalencia
    -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    INSERT INTO t_spu_calidad_act (actividad, fecha)
    SELECT 'IC', MAX(fecha_inscripcion)
    FROM sga_insc_cursadas
    WHERE unidad_academica = pUnidadAcademica
    AND carrera = pCarrera
    AND legajo = plegajo
    AND estado IN ('A','E')
    GROUP BY 1;

    INSERT INTO t_spu_calidad_act (actividad, fecha)
    SELECT 'IE', MAX(fecha_inscripcion)
    FROM sga_insc_examen
    WHERE unidad_academica = pUnidadAcademica
    AND carrera = pCarrera
    AND legajo = plegajo
    AND estado IN ('A','E')
    GROUP BY 1;

    INSERT INTO t_spu_calidad_act (actividad, fecha)
    SELECT 'CC', MAX(fecha_regularidad)
    FROM sga_cursadas
    WHERE unidad_academica = pUnidadAcademica
    AND carrera = pCarrera
    AND legajo = plegajo
    GROUP BY 1;

    INSERT INTO t_spu_calidad_act (actividad, fecha)
    SELECT 'EE', MAX(fecha)
    FROM vw_hist_academica
    WHERE unidad_academica = pUnidadAcademica
    AND carrera = pCarrera
    AND legajo = plegajo
    AND forma_aprobacion IN ('Examen', 'Examen equivalente', 'Promoción', 'Promoción en otra carrera', 'Equivalencia', 'Equivalencia equivalente')  
    GROUP BY 1;

    SELECT MAX(fecha)
    INTO dFechaUltAct
    FROM t_spu_calidad_act;

    LET vcFechaUltAct =  to_char(dFechaUltAct,"%Y%m%d");

    SELECT COUNT(DISTINCT materia) INTO cant_cursadas FROM t_spu_calidad_reg;
    SELECT COUNT(DISTINCT materia) INTO cant_aprobadas FROM t_spu_calidad_apr;
	LET vdFechaInicio = to_date( pAnio || '0401', "%Y%m%d");
    LET vdFechaFin    = to_date( pAnio + 1 || '0331', "%Y%m%d");
    SELECT COUNT(DISTINCT materia) INTO cant_aprobadas_anio_actual FROM t_spu_calidad_apr
    --WHERE YEAR(fecha) = pAnio;
    WHERE fecha BETWEEN vdFechaInicio AND vdFechaFin;

    DROP TABLE t_spu_calidad_reg;
    DROP TABLE t_spu_calidad_apr;
    DROP TABLE t_spu_calidad_act;

/*    SELECT MAX(fecha_relevamiento)
      INTO dFechaUltActDatCen
      FROM sga_datos_censales
     WHERE unidad_academica = pUnidadAcademica
       AND nro_inscripcion    = vcNroInscripcion;
*/
--trace on;
    SELECT MAX(fecha_relevamiento)
    INTO dFechaUltActDatCen
    FROM sga_datos_cen_aux
    WHERE unidad_academica = pUnidadAcademica
    AND nro_inscripcion    = vcNroInscripcion;

    SELECT NVL(DECODE(existe_trab_alum, 1, '2', 2, '1', 3,'0'),'3')
    , NVL(tiene_beca_univ, '')
    , NVL(tiene_beca_nacio, '')
    , NVL(tiene_beca_inter, '')
    , NVL(DECODE(cant_hijos_alum,0,'N',1,'S',2,'S',3,'S',''), '')
    , NVL(cant_hijos_alum, '')
    , NVL(cant_fami_cargo, '') 
    , NVL(tiene_beca, '')
    INTO cTrabaja, cAluBecaUni, cAluBecaNac, cAluBecaInt, cAluTieneHijos, cAluCantHijos, cAluCantACargo, cAluTieneBeca
    FROM sga_datos_cen_aux
    WHERE unidad_academica = pUnidadAcademica
    AND nro_inscripcion    = vcNroInscripcion
    AND fecha_relevamiento = dFechaUltActDatCen;

    IF (cAluTieneBeca = 'N') THEN

        LET cAluBecaUni = '';
        LET cAluBecaNac = '';
        LET cAluBecaInt = '';

    END IF;

    SELECT MAX(fecha_relevamiento)
    INTO dFechaUltActDatCen
    FROM sga_datos_cen_aux2
    WHERE unidad_academica = pUnidadAcademica
    AND nro_inscripcion    = vcNroInscripcion;

    SELECT NVL(DECODE(alu_trab_hace, '1', '0', '2', '1', '3', '2', '4', '3', ''),'')
    , NVL(DECODE(padre_trab_hace, '1', '0', '2', '1', '3', '2', '4', '3', ''),'')
    , NVL(DECODE(madre_trab_hace, '1', '0', '2', '1', '3', '2', '4', '3', ''),'')
    , NVL(DECODE(alu_trab_ocup,'1','0','2','1',''),'')
    , NVL(DECODE(padre_trab_ocup,'1','0','2','1',''),'')
    , NVL(DECODE(madre_trab_ocup,'1','0','2','1',''),'')
    , NVL(alu_beca_tipo_eco,'') 
    , NVL(alu_beca_tipo_ser,'') 
    , NVL(alu_beca_tipo_inv,'') 
    , NVL(alu_beca_muni, '')  
    , NVL(alu_beca_otra, '')  
    , NVL(alu_beca_prov, '')
    , NVL(DECODE(alu_est_civil_uh, 'S', '1', '9'), '')
    , NVL(DECODE(madre_trab_otro,'1', '0', '2', '1', '3', '2', '4', '3', '5', '4', '6', '5',''), '') 
    , NVL(DECODE(padre_trab_otro,'1', '0', '2', '1', '3', '2', '4', '3', '5', '4', '6', '5',''), '') 
    INTO vcTrabHace, vcTrabHacePadre, vcTrabHaceMadre, vcTrabOcupa, vcTrabOcupaPadre, vcTrabOcupaMadre
        , cAluBecaTipoEco, cAluBecaTipoSer, cAluBecaTipoInv, cAluBecaMuni, cAluBecaOtra, cAluBecaProv
        , cAuxEstadoCivil, cMadreNoTrabaja, cPadreNoTrabaja

    FROM sga_datos_cen_aux2
    WHERE unidad_academica = pUnidadAcademica
    AND nro_inscripcion    = vcNroInscripcion
    AND fecha_relevamiento = dFechaUltActDatCen;

    IF (cAluTieneBeca = 'N') THEN

        LET cAluBecaTipoEco = 'N';
        LET cAluBecaTipoSer = 'N';
        LET cAluBecaTipoInv = 'N';
        LET cAluBecaMuni = '';
        LET cAluBecaOtra = '';
        LET cAluBecaProv = '';

    END IF;

    --SELECT NVL(DECODE(alu_trab_ocup, '1', 'Permanente', '2', 'Temporaria', 'ND'),'ND')
    --INTO vcTrabOcupa
    --FROM sga_datos_cen_aux2
    --WHERE unidad_academica = pUnidadAcademica
    --AND nro_inscripcion    = vcNroInscripcion
    --AND fecha_relevamiento = dFechaUltActDatCen;

    SELECT MAX(fecha_relevamiento), to_char(MAX(fecha_relevamiento), "%Y%m%d")
    INTO dFechaUltActDatCen, vc_fec_ult_act_dc
    FROM sga_datos_censales
    WHERE unidad_academica = pUnidadAcademica
    AND nro_inscripcion    = vcNroInscripcion;

    SELECT NVL(DECODE(hora_sem_trab_alum, 1, '0', 2, '1', 3, '2', 4, '3', '' ),'')
    , NVL(DECODE(rel_trab_carrera, 1, '0', 2, '1', 3, '2', 4, '9' ),'')
    , NVL(DECODE(sit_laboral_padre, 1, '2', 2, '1', 3,'0', 4, '3'),'')
    , NVL(DECODE(sit_laboral_madre, 1, '2', 2, '1', 3,'0', 4, '3'),'')
    , NVL(DECODE(estado_civil, 1, '0', 2, '3', 3, '4', 4, '5', 5, '1', 6, '6', '' ),'')
    , NVL(DECODE(ult_est_cur_madre, 1, '0', 2, '1', 3, '2', 4, '3', 5, '4', 8, '5', 9, '6', 10, '7', 11, '8', 12, '9', 13, '10' ), '')
    , NVL(DECODE(ult_est_cur_padre, 1, '0', 2, '1', 3, '2', 4, '3', 5, '4', 8, '5', 9, '6', 10, '7', 11, '8', 12, '9', 13, '10' ), '')
    , NVL(loc_proc, 0)
    , NVL(loc_per_lect, 0)

    INTO vcCantHorSemTrab, vcRelTrabCar, cTrabajaPadre, cTrabajaMadre, cAluEstadoCivil, cMadreNivelEst, cPadreNivelEst, iLocProc, iLocPerLec
    FROM sga_datos_censales
    WHERE unidad_academica = pUnidadAcademica
    AND nro_inscripcion    = vcNroInscripcion
    AND fecha_relevamiento = dFechaUltActDatCen;

    IF ( cAuxEstadoCivil = '1' ) THEN
        LET cAluEstadoCivil = '1';
    END IF;
    RETURN vcNombreInstitArau --1
    ,iInstitucionArau --2
    ,vcNombreUA --3
    ,iInstitucionArau --4
    ,vcNomreCarrera --5
    ,iTitArau --6
    ,vcApellido  --7
    ,vcNombres --8
    ,cGenero --9
    ,vc_fecha_nac --10
    ,vcTipoDoc --11
    ,vcNroDoc --12
    ,iAnioIngreso --13
    ,cant_aprobadas --14
    ,cant_cursadas --15
    ,cant_mat_plan --16
    ,cant_aprobadas_anio_actual --17
    ,vcFechaUltAct --18
    ,cTrabaja --19
    ,vcTrabHace --20
    ,vcTrabOcupa --21 
    ,vcCantHorSemTrab --22
    ,vcRelTrabCar --23
    ,cAluBecaTipoSer --24
    ,cAluBecaTipoInv --25
    ,cAluBecaTipoEco --26
    ,cAluBecaUni --27
    ,cAluBecaInt --28
    ,cAluBecaNac --29 
    ,cAluBecaProv --30
    ,cAluBecaMuni --31
    ,cAluBecaOtra --32
    ,cAluTieneHijos --33
    ,cAluCantHijos --34
    ,cAluCantACargo --35
    ,cAluEstadoCivil --36
    ,cPadreNivelEst --37
    ,cTrabajaPadre --38
    ,vcTrabHacePadre --39
    ,vcTrabOcupaPadre --40
    ,cPadreNoTrabaja --41
    ,cMadreNivelEst --42
    ,cTrabajaMadre --43
    ,vcTrabHaceMadre --44
    ,vcTrabOcupaMadre --45
    ,cMadreNoTrabaja --46
    ,iLocPerLec --47
    ,iLocProc --48
    ,vc_fec_ult_act_dc; --49
END;
--trace off;
END PROCEDURE;

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_int_pfi_ra
-- *****************************************************************************
revoke execute on "dba".sp_int_pfi_ra from public;
grant execute on "dba".sp_int_pfi_ra to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_int_pfi_ra to internet; -- Rol de usuario de Internet



----fin del procedimiento---------

DELETE FROM acc_operacion_mod
 WHERE submodulo = 'SPU-Cali';

DELETE FROM acc_submodulos
 WHERE submodulo = 'SPU-Cali';

INSERT INTO acc_submodulos (submodulo, nombre) VALUES ('SPU-Calidad','SPU-Calidad');

EXECUTE PROCEDURE sui_ventanas('w_selectdir');

EXECUTE PROCEDURE sui_ventanas('w_spu_calidad_2013');

EXECUTE PROCEDURE dba.sui_operaciones( 'ifz00038', 'SPU-Calidad PEFI 2012-2016', 'SPU-Calidad Plan de Formación de Ingenieros 2012-2016', null );

INSERT INTO dba.acc_parametros ( operacion, orden, ventana, parametros, cierra_anterior ) VALUES ( 'ifz00038', 1, 'w_spu_calidad_2013', 'uo_dw, dp_carrera_anio_academico_ref, uo_dw, dsto_alumnos_de_carrera', 'N' );

INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( 'ifz00038', 'C' );

INSERT INTO dba.acc_operacion_mod ( modulo, operacion, submodulo, orden ) VALUES ( '00000070', 'ifz00038', 'SPU-Calidad', 30);

