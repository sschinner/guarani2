-- ***********************************************************************************
-- SIU-GUARANI
-- Version 2.09.0, 2.9.2
-- Procedure sp_enc_crea_i
-- Encuesta para alumnos o para docentes.
-- Crea:
--  - Un concepto por cada comision
--  - Un elemento por cada materia
--  - Un formulario por cada comision con el concepto de la comision.
--    El formulario contiene un solo elemento que es la materia de la comision.
-- 
-- Para alumnos:
-- * A cada alumno le asigna el formulario correspondiente de la comision en la que esta inscripto,etc.
-- * Solo alumnos de las carreras selecciondas.
-- * Solo comisiones seleccionadas de las materias seleccionadas
--
-- Para docentes:
--  * A cada docente el genera una encuesta para cada comision en la que estuvo como docente
-- ***********************************************************************************

--  DROP PROCEDURE sp_enc_crea_i (integer);
CREATE PROCEDURE sp_enc_crea_i(pAlcance LIKE gde_encues_alcance.alcance)

DEFINE vcUA VARCHAR(5);
DEFINE vcNroInsc varchar(10);
DEFINE i_anio_academico, i_encuesta integer;
DEFINE vc_encuestado    LIKE gde_encues_alcance.encuestado;
DEFINE vc_periodo_lect  LIKE gde_encues_alcance.periodo_lectivo;
DEFINE vc_turno_examen  LIKE gde_encues_alcance.turno_examen;
DEFINE c_generar        LIKE gde_encues_alcance.generar;
DEFINE vc_titulo        LIKE gde_encues_alcance.titulo;
DEFINE c_responderan    LIKE gde_encues_alcance.responderan;
DEFINE i_alcance_mat, i_alcance_car, i_alcance_com        INTEGER;
DEFINE iTipoElemento, iTipoConcepto, iConcepto, iElemento, iformulario  INTEGER;
DEFINE vcMateria        LIKE sga_materias.materia; 
DEFINE vcMateriaNombre  LIKE sga_materias.nombre;
DEFINE vcComisionNombre  LIKE sga_comisiones.nombre;
DEFINE vcConceptoDesc  LIKE gde_concepto.descripcion;
DEFINE viComision INTEGER;

BEGIN

  LET iTipoElemento = 3; -- Materia
  LET iTipoConcepto = 5; -- Comision
  LET i_alcance_mat = 0;
  LET i_alcance_car = 0;
  LET i_alcance_com = 0;


  SELECT unidad_academica, encuestado, anio_academico, NVL(periodo_lectivo, '<TODOS>'), NVL(turno_examen, '<TODOS>'), generar, responderan, titulo, encuesta
    INTO vcUA, vc_encuestado, i_anio_academico, vc_periodo_lect, vc_turno_examen, c_generar, c_responderan, vc_titulo, i_encuesta
    FROM gde_encues_alcance
   WHERE alcance = pAlcance;

  IF NOT ((vc_encuestado = 'A' AND c_generar = 'I') OR (vc_encuestado = 'D' AND c_generar = 'P')) THEN
      RETURN;
  END IF;
		
  SELECT COUNT(alcance) INTO i_alcance_mat FROM gde_alcance_mat WHERE alcance = pAlcance;
  SELECT COUNT(alcance) INTO i_alcance_car FROM gde_alcance_car WHERE alcance = pAlcance;
  SELECT COUNT(alcance) INTO i_alcance_com FROM gde_alcance_com WHERE alcance = pAlcance;

  -- Bloque para crear tablas temporales.
  BEGIN
    ON EXCEPTION IN (-206) -- Temp table  already exists in session 
        -- Si existe la tabla continua en la siguiente sentencia...
    END EXCEPTION WITH RESUME;
    DROP TABLE _Tcom;
    CREATE TEMP TABLE _Tcom (comision integer) WITH NO LOG;
  END;

  -- Comisiones del Alcance de la encuesta
  INSERT INTO _Tcom (comision)
    SELECT comision
      FROM sga_comisiones
     WHERE anio_academico = i_anio_academico
       AND (periodo_lectivo = vc_periodo_lect OR vc_periodo_lect = '<TODOS>') 
       AND (i_alcance_mat = 0 OR materia IN (SELECT gde_alcance_mat.materia FROM gde_alcance_mat WHERE alcance = pAlcance))
       AND (i_alcance_com = 0 OR comision IN (SELECT gde_alcance_com.comision FROM gde_alcance_com WHERE alcance = pAlcance));

  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- ENCUESTADOS
  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  DELETE FROM _Tencuestado_aux;
  DELETE FROM _Tencuestado;

     

 IF vc_encuestado = 'D'  AND c_responderan = 'TO' THEN
  -- ++++++++++++++++++++++++++++++++++++++++++++++
  -- DOCENTES
  -- ++++++++++++++++++++++++++++++++++++++++++++++
  -- TO = Todos los docentes de las comisiones seleccionadas

  -- Alumnos Inscriptos a cursar en comisiones de un periodo lectivo.
  INSERT INTO _Tencuestado_aux (unidad_academica, nro_inscripcion, materia, comision)
       SELECT sga_docentes.unidad_academica,
              sga_docentes.nro_inscripcion, 
              sga_comisiones.materia,
              sga_comisiones.comision
        FROM 
            _Tcom as T,
            sga_comisiones,
            sga_docentes_com,
            sga_docentes
        WHERE sga_comisiones.comision = T.comision
          AND sga_docentes_com.comision = sga_comisiones.comision
          AND sga_docentes.legajo = sga_docentes_com.legajo; 
 END IF; -- Docentes
 
 
 IF vc_encuestado = 'A' THEN
  -- ++++++++++++++++++++++++++++++++++++++++++++++
  -- ALUMNOS 
  -- ++++++++++++++++++++++++++++++++++++++++++++++
 
   IF c_responderan = 'IC' THEN
    -- IC = Alumnos Inscriptos a cursar en comisiones de un periodo lectivo.
    INSERT INTO _Tencuestado_aux (unidad_academica, nro_inscripcion, materia, comision)
       SELECT sga_alumnos.unidad_academica,
              sga_alumnos.nro_inscripcion, 
              sga_comisiones.materia,
              sga_comisiones.comision
        FROM 
            _Tcom as T,
            sga_comisiones,
            sga_insc_cursadas,
            sga_alumnos,
	    sga_actas_cursado,
	    sga_det_acta_curs
        WHERE  sga_comisiones.comision = T.comision
            AND sga_insc_cursadas.comision = sga_comisiones.comision
            AND sga_insc_cursadas.unidad_academica = sga_alumnos.unidad_academica
            AND sga_insc_cursadas.carrera = sga_alumnos.carrera
            AND sga_insc_cursadas.legajo = sga_alumnos.legajo
	    AND sga_insc_cursadas.comision = sga_actas_cursado.comision
            AND sga_actas_cursado.acta = sga_det_acta_curs.acta
	    AND sga_insc_cursadas.carrera = sga_det_acta_curs.carrera
	    AND sga_insc_cursadas.legajo = sga_det_acta_curs.legajo

	-- U820: se personaliza para incluir sólo inscriptos que están en acta
		AND (sga_det_acta_curs.resultado in ('A', 'R') OR (sga_det_acta_curs.resultado = 'U' AND sga_det_acta_curs.cond_regularidad = 1))
	-- U820: se personaliza para incluir sólo inscriptos que están en acta

            AND (i_alcance_car = 0 OR sga_alumnos.carrera IN (SELECT gde_alcance_car.carrera FROM gde_alcance_car WHERE alcance = pAlcance));
            

  ELIF c_responderan = 'CD' OR c_responderan = 'CR' THEN
    -- CD = Alumnos con la cursada desaprobada
    -- CR = Alumnos con cursada aprobada (regularizada)
    
    INSERT INTO _Tencuestado_aux (unidad_academica, nro_inscripcion, materia, comision)
       SELECT DISTINCT 
              sga_alumnos.unidad_academica,
              sga_alumnos.nro_inscripcion, 
              sga_comisiones.materia,
              sga_comisiones.comision
         FROM _Tcom as T,
              sga_comisiones,
              sga_actas_cursado,   
              sga_det_acta_curs,
              sga_alumnos
         WHERE sga_comisiones.comision = T.comision
           AND sga_actas_cursado.comision = sga_comisiones.comision
           AND sga_actas_cursado.estado = 'C'
           AND sga_det_acta_curs.unidad_academica = sga_actas_cursado.unidad_academica
           AND sga_det_acta_curs.acta = sga_actas_cursado.acta
           AND ((c_responderan = 'CD' AND (sga_det_acta_curs.resultado = 'R' OR sga_det_acta_curs.cond_regularidad = 1)) OR   -- Desaprobados
                (c_responderan = 'CR' AND sga_det_acta_curs.resultado = 'A')        -- Aprobados
               ) 
           AND sga_det_acta_curs.estado = 'A'
           AND sga_det_acta_curs.unidad_academica = sga_alumnos.unidad_academica
           AND sga_det_acta_curs.carrera = sga_alumnos.carrera
           AND sga_det_acta_curs.legajo = sga_alumnos.legajo
           AND (i_alcance_car = 0 OR sga_alumnos.carrera IN (SELECT gde_alcance_car.carrera FROM gde_alcance_car WHERE alcance = pAlcance));

  ELIF c_responderan = 'CP' THEN
     -- Alumnos con cursada promocionada
    INSERT INTO _Tencuestado_aux (unidad_academica, nro_inscripcion, materia, comision)
       SELECT DISTINCT 
               sga_alumnos.unidad_academica,
              sga_alumnos.nro_inscripcion, 
              sga_comisiones.materia,
              sga_comisiones.comision
         FROM _Tcom as T,
              sga_comisiones,
              sga_actas_promo,   
              sga_det_acta_promo,
              sga_alumnos
         WHERE sga_comisiones.comision = T.comision
           AND sga_actas_promo.comision = sga_comisiones.comision
           AND sga_actas_promo.estado = 'C'
           AND sga_det_acta_promo.unidad_academica = sga_actas_promo.unidad_academica
           AND sga_det_acta_promo.acta = sga_actas_promo.acta
           AND sga_det_acta_promo.resultado   = 'P'  -- Promocion
           AND sga_det_acta_promo.estado      = 'A'
           AND sga_det_acta_promo.rectificado = 'N'
           AND sga_det_acta_promo.unidad_academica = sga_alumnos.unidad_academica
           AND sga_det_acta_promo.carrera = sga_alumnos.carrera
           AND sga_det_acta_promo.legajo = sga_alumnos.legajo
           AND (i_alcance_car = 0 OR sga_alumnos.carrera IN (SELECT gde_alcance_car.carrera FROM gde_alcance_car WHERE alcance = pAlcance));
  
  END IF;     
 END IF; -- Alumnos
  
  -- Paso de la auxiliar a la de encuestados. Dejo un solo registro por persona-comision.
  INSERT INTO _Tencuestado (unidad_academica, nro_inscripcion, comision, materia)
    SELECT DISTINCT unidad_academica, nro_inscripcion, comision, materia FROM _Tencuestado_aux;
  
  
  -- ++++++++++++++++++++++++++ FIN ENCUESTADOS +++++++++++++++++++++++++++++++++++++     
     
  
  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --                             FORMULARIOS 
  -- Registra uno por comision
  -- Concepto = Comision
  -- Elemento = Materia
  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Inserto un concepto por cada comision (si no existe)
  INSERT INTO gde_concepto (descripcion, unidad_academica, materia, comision, tipo_concepto, generado_en_kolla, estado)
      SELECT 
           CASE
                WHEN LENGTH(m.nombre) > 210 THEN m.nombre_reducido || ' (' || m.materia || ') - Comisión: ' || c.nombre
                ELSE m.nombre_reducido || ' (' || m.materia || ') - Comisión: ' || c.nombre
          END,
           c.unidad_academica, c.materia, c.comision, iTipoConcepto, 'N', 'A'
        FROM sga_comisiones as c,
             _Tcom as T,
             sga_materias as m
       WHERE c.comision = T.comision
         AND m.unidad_academica = c.unidad_academica
         AND m.materia = c.materia
         AND c.comision NOT IN (SELECT comision FROM _Tconcepto_o WHERE tipo_concepto = iTipoConcepto);


  -- Inserto un elemento por cada cada materia (si no existe)
  INSERT INTO gde_elemento (descripcion, unidad_academica, materia, tipo_elemento, generado_en_kolla, estado)
      SELECT DISTINCT 
           CASE
                WHEN LENGTH(m.nombre) > 245 THEN m.nombre_reducido || ' (' || m.materia || ')'
                ELSE m.nombre_reducido || ' (' || m.materia || ')'
          END,
             m.unidad_academica, m.materia, iTipoElemento, 'N', 'A'
        FROM sga_comisiones as c,
             _Tcom as T,
             sga_materias as m
       WHERE c.comision = T.comision
         AND m.unidad_academica = c.unidad_academica
         AND m.materia = c.materia
         AND m.materia NOT IN (SELECT materia FROM _Telemento_o WHERE tipo_elemento = iTipoElemento);

   
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Inserto un formulario por cada comision. Formularios nuevos que no existan para las comisiones involucradas
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  FOREACH SELECT c.unidad_academica, c.comision, c.materia, c.nombre
            INTO vcUA, viComision, vcMateria, vcComisionNombre
            FROM _Tcom as T, 
                 sga_comisiones as c
           WHERE c.comision = T.comision
             AND c.comision NOT IN (SELECT gde_concepto.comision
                                      FROM _Tform_o as F, 
                                           gde_concepto
                                      WHERE gde_concepto.concepto = F.concepto
                                        AND gde_concepto.tipo_concepto = iTipoConcepto) -- Formularios de Conceptos de Comisiones

           SELECT concepto, descripcion INTO iConcepto, vcConceptoDesc
             FROM gde_concepto
            WHERE comision = viComision
              AND tipo_concepto    = iTipoConcepto;

           SELECT elemento INTO iElemento
             FROM gde_elemento
            WHERE unidad_academica = vcUA
              AND materia          = vcMateria
              AND tipo_elemento    = iTipoElemento;

     
     -- Inserto el formulario con un solo elemento detalle.                                
     -- Un concepto con la comision y en el detalle un elemento con la materia de la comision.
     INSERT INTO gde_formulario (alcance, nombre, concepto, estado, generado_en_kolla) 
          VALUES (pAlcance, 
                  vcConceptoDesc,
                  iConcepto, 
                  'A', 
                  'N');
     LET iformulario = dbinfo("sqlca.sqlerrd1"); -- formulario insertado
     
     INSERT INTO gde_formulario_det (formulario, encuesta, elemento, tipo_elemento) 
          VALUES (iformulario, i_encuesta, iElemento, iTipoElemento);
                                     
  END FOREACH;
  -- ++++++++++++++++++++ Fin Formularios ++++++++++++++++++++++++++++++++++++++++++
  
  
  -- Borro los formularios de comisiones que ya no van mas
    -- Recupero formularios originales de comisiones que ya no estan seleccionadas
    INSERT INTO _Tform_baja (formulario, estado, generado_en_kolla)
      SELECT F.formulario, F.estado, F.generado_en_kolla 
        FROM _Tform_o as F, 
             gde_concepto
       WHERE gde_concepto.concepto = F.concepto
         AND gde_concepto.tipo_concepto = iTipoConcepto
         AND gde_concepto.comision NOT IN (SELECT comision FROM _Tcom);

    -- Solo activo aquellos formularios que estaban dados de baja de conceptos relacioandos con comisiones seleccionadas por el usuario.
    UPDATE gde_formulario SET estado = 'A' 
     WHERE estado = 'B'
       AND formulario NOT IN (SELECT formulario FROM _Tform_baja)  -- Formularios que no se dan de baja
       AND formulario IN (SELECT formulario FROM _Tform_o);  

  -- Marco como dados de baja los formularios que ya no van mas y estan generados en KOLLA
  UPDATE gde_formulario SET estado = 'B'
      WHERE formulario IN (SELECT formulario FROM _Tform_baja WHERE generado_en_kolla = 'S' AND estado = 'A');


  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
  -- Borro todos los encuestados que aun no respondiron y los vuelvo a generar..
  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
  -- Borro encuestados de formularios que no van mas
  DELETE FROM gde_encues_persona  WHERE formulario IN (SELECT formulario FROM _Tform_baja) AND fecha_respuesta IS NULL;  
  
  DELETE FROM _Tencuestado_baja;
  INSERT INTO _Tencuestado_baja (respuesta)
     SELECT p.respuesta
       FROM gde_formulario as f, gde_concepto as c, gde_encues_persona as p
      WHERE f.alcance = pAlcance
        AND c.concepto = f.concepto
        AND p.formulario = f.formulario
        AND p.fecha_respuesta IS NULL
        AND NOT EXISTS (SELECT 1 FROM _Tencuestado as T
                          WHERE T.unidad_academica = p.unidad_academica
                            AND T.nro_inscripcion = p.nro_inscripcion
                            AND T.comision = c.comision);
 
  DELETE FROM gde_encues_persona WHERE respuesta IN (SELECT respuesta FROM _Tencuestado_baja);

  -- Inserto encuestdos que aun quedan en la tabla
  DELETE FROM _Tencuestado_o;
  INSERT INTO _Tencuestado_o (respuesta, unidad_academica, nro_inscripcion, formulario, fecha_alta, fecha_respuesta)
     SELECT p.respuesta, p.unidad_academica, p.nro_inscripcion, p.formulario, p.fecha_alta, p.fecha_respuesta
       FROM gde_formulario as f, gde_encues_persona as p
      WHERE f.alcance = pAlcance
        AND p.formulario = f.formulario;

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Borro formularios que no fueron aun generados en Kolla
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  DELETE FROM gde_formulario_det
    WHERE formulario IN (SELECT formulario FROM _Tform_baja WHERE generado_en_kolla = 'N');
  DELETE FROM gde_formulario
    WHERE formulario IN (SELECT formulario FROM _Tform_baja WHERE generado_en_kolla = 'N');


  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- BORRO/INSERTO ENCUESTADOS
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     
  -- Inserto encuestados nuevos de formularios activos
  INSERT INTO gde_encues_persona (unidad_academica, nro_inscripcion, formulario)
     SELECT E.unidad_academica, E.nro_inscripcion, F.formulario   
       FROM _Tencuestado as E,
            gde_concepto as C,
            gde_formulario as F
      WHERE C.comision = E.comision
        AND C.tipo_concepto = iTipoConcepto  -- Comision
        AND F.concepto = C.concepto
        AND F.alcance = pAlcance
        AND F.estado = 'A'
        AND NOT EXISTS (SELECT 1 FROM _Tencuestado_o as EO 
                         WHERE EO.unidad_academica = E.unidad_academica
                           AND EO.nro_inscripcion = E.nro_inscripcion
                           AND EO.formulario = F.formulario);


  -- Borro tabla temporal
  DROP TABLE _Tcom;

END;
END PROCEDURE;
-- ************************************** Fin procedure sp_enc_crea_i *********************************************