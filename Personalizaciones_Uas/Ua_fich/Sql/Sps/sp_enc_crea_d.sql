-- ***********************************************************************************
-- SIU-GUARANI
-- Version 2.08.0, 2.09.0
-- Procedure sp_enc_crea_d
--
-- Encuesta para ALUMNOS sobre la actuacion docente en las cursadas.
--
-- Crea:
--  - Un concepto por cada comision (sin subcomisiones) o un concepto por cada comision y combinacion de subcomisiones (cuando tiene subcomisiones)
--  - Un elemento por cada docente
--  - Un formulario por cada comision o comision/combinacion de subcomisiones con el concepto de la comision.
--     * El formulario contiene tantos elementos como docentes tenga la comision (para comisiones sin subcomisiones)
--     * 
-- 
-- * A cada alumno le asigna el formulario correspondiente de la comision en la que esta inscripto,etc.
-- * Solo alumnos de las carreras selecciondas.
-- * Solo comisiones de las materias y comisiones seleccionadas
-- * El alumno deberá responder por los docentes de su comision. Todos o solo los del rol seleccionado en el alcance. 
--
-- Responderan:
--  IC = Alumnos Inscriptos a cursar en comisiones de un periodo lectivo.
--  CD = Alumnos con la cursada desaprobada
--  CR = Alumnos con cursada aprobada (regularizada)
--  CP = Alumnos que promocionaron
-- ***********************************************************************************

-- DROP PROCEDURE sp_enc_crea_d (integer);
CREATE PROCEDURE sp_enc_crea_d(pAlcance LIKE gde_encues_alcance.alcance)

DEFINE i_anio_academico, i_encuesta integer;
DEFINE vcUA  varchar(5);
DEFINE vc_encuestado    LIKE gde_encues_alcance.encuestado;
DEFINE vc_periodo_lect  LIKE gde_encues_alcance.periodo_lectivo;
DEFINE vc_turno_examen  LIKE gde_encues_alcance.turno_examen;
DEFINE c_generar        LIKE gde_encues_alcance.generar;
DEFINE vc_titulo        LIKE gde_encues_alcance.titulo;
DEFINE c_responderan    LIKE gde_encues_alcance.responderan;
DEFINE i_alcance_car, i_alcance_mat, i_alcance_com, i_alcance_doc, i_alcance_rol INTEGER;
DEFINE iTipoElemento, iTipoConcepto,  iConcepto, iElemento, iformulario  INTEGER;
DEFINE vcMateria        LIKE sga_materias.materia; 
DEFINE vcMateriaNombre  LIKE sga_materias.nombre;
DEFINE vcComisionNombre  LIKE sga_comisiones.nombre;
DEFINE vcConceptoDesc  LIKE gde_concepto.descripcion;
DEFINE vcElementoDesc  LIKE gde_elemento.descripcion;
DEFINE viComision, viOrden, viSubcomision INTEGER;
DEFINE vcSubcomisiones varchar(60);
DEFINE viTieneSubc SMALLINT;
DEFINE vcSeparador char(1);

BEGIN


 LET vcSeparador = ',' ; -- Separador de las subcomisiones 
 LET iTipoElemento = 4; -- Docente
 LET iTipoConcepto = 5; -- Comision

  SELECT unidad_academica, encuestado, anio_academico, NVL(periodo_lectivo, '<TODOS>'), NVL(turno_examen, '<TODOS>'), generar, responderan, titulo, encuesta
    INTO vcUA, vc_encuestado, i_anio_academico, vc_periodo_lect, vc_turno_examen, c_generar, c_responderan, vc_titulo, i_encuesta
    FROM gde_encues_alcance
   WHERE alcance = pAlcance;

  IF c_generar <> 'D' THEN
      RETURN;
  END IF;

    
 LET i_alcance_mat = 0;
 LET i_alcance_car = 0;
 LET i_alcance_com = 0;
 LET i_alcance_rol = 0;
 SELECT COUNT(*) INTO i_alcance_car FROM gde_alcance_car WHERE alcance = pAlcance;
 SELECT COUNT(*) INTO i_alcance_mat FROM gde_alcance_mat WHERE alcance = pAlcance;
 SELECT COUNT(*) INTO i_alcance_com FROM gde_alcance_com WHERE alcance = pAlcance;
 -- SELECT COUNT(*) INTO i_alcance_doc FROM gde_alcance_doc WHERE alcance = pAlcance;
 SELECT COUNT(*) INTO i_alcance_rol FROM gde_alcance_rol WHERE alcance = pAlcance;

  -- Bloque para crear tablas temporales.
  BEGIN
    ON EXCEPTION IN (-206) 
        -- Si no existe la tabla continua en la siguiente sentencia...por el drop
    END EXCEPTION WITH RESUME;

    DROP TABLE _Tcom;
    DROP TABLE _Tcomsubco;
    DROP TABLE _Tdocsubco;

    CREATE TEMP TABLE _Tcom (comision integer, tiene_subc smallint, tiene_doc smallint, subcomisiones varchar(60)) WITH NO LOG;
    CREATE TEMP TABLE _Tcomsubco (comision integer, subcomisiones varchar(50), tiene_doc smallint) WITH NO LOG;
    CREATE TEMP TABLE _Tdocsubco (legajo varchar(10)) WITH NO LOG;
  END;

 -- Creo tabla temporal con las comisiones que intervienen
 -- Comisiones del Alcance de la encuesta. Comisiones que no tienen subcomisiones..
 INSERT INTO _Tcom (comision, tiene_subc, tiene_doc)
    SELECT comision,  
                  (SELECT count(*) FROM sga_subcomisiones WHERE comision = sga_comisiones.comision),
                  (SELECT count(*) FROM sga_docentes_com WHERE comision = sga_comisiones.comision) 
     FROM sga_comisiones
     WHERE anio_academico = i_anio_academico
       AND (periodo_lectivo = vc_periodo_lect OR '<TODOS>' = vc_periodo_lect) 
       AND (i_alcance_com = 0 OR comision IN (SELECT gde_alcance_com.comision FROM gde_alcance_com WHERE alcance = pAlcance))
       AND (i_alcance_mat = 0 OR materia IN (SELECT gde_alcance_mat.materia FROM gde_alcance_mat WHERE alcance = pAlcance));

UPDATE _Tcom  SET tiene_doc = 1 WHERE tiene_doc > 0;
UPDATE _Tcom  SET tiene_subc = 1 WHERE tiene_subc > 0;

  -- Borro las comisiones que no tienen docentes
  DELETE FROM _Tcom WHERE tiene_doc = 0;

  IF i_alcance_rol > 0 THEN
     -- Borro las comisiones que no tienen docentes de los roles docentes seleccionados
     DELETE FROM _Tcom 
           WHERE (SELECT count(*) FROM sga_docentes_com 
                           WHERE comision = _Tcom.comision 
                                 AND responsabilidad IN (SELECT rol FROM gde_alcance_rol WHERE alcance = pAlcance) 
                         ) = 0;
  END IF;

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- COMISIONES CON SUBCOMISIONES
  -- Recupero las comisiones que tienen subcomisiones con la combinacion de subcomisiones
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 FOREACH SELECT comision INTO viComision 
                      FROM _Tcom WHERE tiene_subc = 1
     -- Recupero la combinacion de subcomisiones por tipo de clase d ela comision.
     -- Se hace con el excecute procedure porque el procedure crea una tabla temporal y la actualiza...

     FOREACH EXECUTE PROCEDURE sp_enc_comb_subco(viComision)  INTO vcSubcomisiones

              INSERT INTO _Tcomsubco (comision, subcomisiones) VALUES ( viComision, vcSubcomisiones);

      END FOREACH;    

 END FOREACH;


  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- ENCUESTADOS
  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  DELETE FROM _Tencuestado_aux;
  DELETE FROM _Tencuestado;
 
  -- ++++++++++++++++++++++++++++++++++++++++++++++
  -- ALUMNOS 
  -- ++++++++++++++++++++++++++++++++++++++++++++++
  IF c_responderan = 'IC' THEN
    -- IC = Alumnos Inscriptos a cursar en comisiones de un periodo lectivo.
    INSERT INTO _Tencuestado_aux (unidad_academica, nro_inscripcion, materia, comision, subcomisiones)
       SELECT sga_alumnos.unidad_academica,
              sga_alumnos.nro_inscripcion, 
              sga_comisiones.materia,
              sga_comisiones.comision,
              CASE
                   WHEN T.tiene_subc = 1 THEN sp_enc_subco_alu (sga_alumnos.unidad_academica, sga_alumnos.carrera, sga_alumnos.legajo, sga_comisiones.comision)
                   ELSE cast(NULL as varchar(60))
              END
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
    
    INSERT INTO _Tencuestado_aux (unidad_academica, nro_inscripcion, materia, comision, subcomisiones)
       SELECT DISTINCT 
              sga_alumnos.unidad_academica,
              sga_alumnos.nro_inscripcion, 
              sga_comisiones.materia,
              sga_comisiones.comision,
              CASE
                   WHEN T.tiene_subc = 1 THEN sp_enc_subco_alu (sga_alumnos.unidad_academica, sga_alumnos.carrera, sga_alumnos.legajo, sga_comisiones.comision)
                   ELSE cast(NULL as varchar(60))
              END CASE
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
    INSERT INTO _Tencuestado_aux (unidad_academica, nro_inscripcion, materia, comision, subcomisiones)
       SELECT DISTINCT 
               sga_alumnos.unidad_academica,
              sga_alumnos.nro_inscripcion, 
              sga_comisiones.materia,
              sga_comisiones.comision,
              CASE
                   WHEN T.tiene_subc = 1 THEN sp_enc_subco_alu (sga_alumnos.unidad_academica, sga_alumnos.carrera, sga_alumnos.legajo, sga_comisiones.comision)
                   ELSE cast(NULL as varchar(60))
              END CASE
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
 END IF; -- Alumnos
  
  -- Paso de la auxiliar a la de encuestados. Dejo un solo registro por persona-comision.
  INSERT INTO _Tencuestado (unidad_academica, nro_inscripcion, comision, materia, subcomisiones)
    SELECT DISTINCT unidad_academica, nro_inscripcion, comision, materia, subcomisiones
       FROM _Tencuestado_aux;
 

 -- ++++++++++++++++++++++++++ FIN ENCUESTADOS +++++++++++++++++++++++++++++++++++++     
     
  
  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --                             FORMULARIOS 
  -- Registra un formulario por comision
  -- A cada formulario le asigna los docentes de la comision (comisiones sin subcomision..)
  -- Concepto = Comision
  -- Elemento = Docente
  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
  -- Inserto un concepto por cada comision (si no existe)
  INSERT INTO gde_concepto (descripcion, unidad_academica, materia, comision, tipo_concepto, generado_en_kolla, estado)
      SELECT 
           CASE
                WHEN LENGTH(m.nombre) > 210 THEN m.nombre_reducido || ' (' || m.materia || ') - Comisión: ' || c.nombre
                ELSE m.nombre || ' (' || m.materia || ') - Comisión: ' || c.nombre
          END,
           c.unidad_academica, c.materia, c.comision, iTipoConcepto, 'N', 'A'
        FROM  _Tcom as T,
            sga_comisiones as c,
             sga_materias as m
       WHERE c.comision = T.comision
         AND m.unidad_academica = c.unidad_academica
         AND m.materia = c.materia
         AND c.comision NOT IN (SELECT comision FROM _Tconcepto_o WHERE tipo_concepto = iTipoConcepto);


  -- Inserto un elemento por cada cada docente de las comisiones seleccionadas (si no existe)
  INSERT INTO gde_elemento (descripcion, legajo_docente, tipo_elemento, generado_en_kolla, estado)
      SELECT DISTINCT 
             p.apellido || ' ' || p.nombres, dc.legajo, iTipoElemento, 'N', 'A'
        FROM _Tcom as T,
             sga_docentes_com as dc,
             sga_docentes as d,
             sga_personas as p
       WHERE dc.comision = T.comision
         AND d.legajo = dc.legajo
         AND p.unidad_academica = d.unidad_academica
         AND p.nro_inscripcion  = d.nro_inscripcion
         AND dc.legajo NOT IN (SELECT legajo_docente FROM _Telemento_o WHERE tipo_elemento = iTipoElemento);

   
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Inserto un formulario por cada comision. Formularios nuevos que no existan para las comisiones involucradas
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  FOREACH 
        -- Comisiones (sin subcomisiones) que no tienen formularios
        SELECT c.unidad_academica, c.comision, c.materia, c.nombre, T.tiene_subc, T.subcomisiones
            INTO vcUA, viComision, vcMateria, vcComisionNombre, viTieneSubc, vcSubcomisiones
            FROM _Tcom as T, 
                 sga_comisiones as c
           WHERE c.comision = T.comision
             AND T.tiene_subc = 0 
             AND c.comision NOT IN (SELECT gde_concepto.comision
                                      FROM _Tform_o as F, 
                                           gde_concepto
                                      WHERE gde_concepto.concepto = F.concepto
                                        AND gde_concepto.tipo_concepto = iTipoConcepto 
                                        AND F.subcomisiones IS NULL ) -- Formularios de Conceptos de Comisiones (sin subcomisiones)

           UNION ALL
        -- Comisiones con subcomisiones que no tienen formularios
        SELECT c.unidad_academica, c.comision, c.materia, c.nombre, 1, T.subcomisiones
            FROM _TcomSubco as T, 
                 sga_comisiones as c
           WHERE c.comision = T.comision
             AND NOT EXISTS (SELECT gde_concepto.comision
                                      FROM _Tform_o as F, 
                                           gde_concepto
                                      WHERE gde_concepto.concepto = F.concepto
                                        AND gde_concepto.tipo_concepto = iTipoConcepto
                                        AND gde_concepto.comision          = T.comision
                                        AND F.subcomisiones = T.subcomisiones ) -- Formularios de Conceptos de Comisiones (con subcomisiones)


           -- Recupero el concepto relacionado con la comision (sin subcomisiones o con la que concuerda con el conjunto de subcomisiones 
           SELECT concepto, descripcion INTO iConcepto, vcConceptoDesc
             FROM gde_concepto
            WHERE comision = viComision
              AND tipo_concepto    = iTipoConcepto;

     -- Inserto el formulario con un solo elemento detalle.                                
     -- Un concepto con la comision y en el detalle un elemento con la materia de la comision.
     INSERT INTO gde_formulario (alcance, nombre, concepto, estado, generado_en_kolla, subcomisiones) 
          VALUES (pAlcance,  vcConceptoDesc, iConcepto,  'A',  'N', vcSubcomisiones );

     LET iformulario = dbinfo("sqlca.sqlerrd1"); -- formulario insertado


      -- Si tiene subcomisiones, solo recupero los docentes de la combinacion de subcomisiones
      DELETE FROM _Tdocsubco;
      IF viTieneSubc = 1 THEN
          FOREACH EXECUTE PROCEDURE f_descomponer(vcSubcomisiones, vcSeparador) INTO viSubcomision
                   INSERT INTO _Tdocsubco (legajo)
                          SELECT dsc.legajo
                             FROM sga_docentes_subco as dsc
                          WHERE comision = viComision
                                AND subcomision = viSubcomision;
          END FOREACH;
      END IF;

     
     -- Recupero los docentes de la comision o combinacion de subcomisiones (si el docente esta en mas de una subcomision, lo inserta una vez) y se los asigno al formulario.
     LET viOrden = 0;
     FOREACH SELECT E.elemento, E.descripcion 
               INTO iElemento, vcElementoDesc
               FROM sga_docentes_com as dc,
                    gde_elemento as E
              WHERE dc.comision = viComision
                AND E.legajo_docente = dc.legajo
                AND E.tipo_elemento  = iTipoElemento
                AND (i_alcance_rol = 0 OR   dc.responsabilidad IN (SELECT gde_alcance_rol.rol FROM gde_alcance_rol WHERE alcance = pAlcance) )
                AND (viTieneSubc = 0 OR
                          (viTieneSubc = 1 AND E.legajo_docente IN ( SELECT legajo FROM _Tdocsubco) )
                         )
              ORDER BY E.descripcion       

          
	      LET viOrden = viOrden + 1;
	      INSERT INTO gde_formulario_det (formulario, encuesta, elemento, tipo_elemento, orden) 
	        VALUES (iformulario, i_encuesta, iElemento, iTipoElemento, viOrden);
     END FOREACH; -- Docentes de la comision
     
     IF viOrden = 0 THEN
            -- No recuperó docentes, entonces borro el formulario
           DELETE FROM gde_formulario WHERE formulario = iformulario;
     END IF;                            
         
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
        AND C.tipo_concepto = iTipoConcepto
        AND F.concepto = C.concepto
        AND  ( 
                   (E.subcomisiones IS NULL AND F.subcomisiones IS NULL)  OR -- Formularios de Comisiones sin subcomisiones
                   (E.subcomisiones IS NOT NULL AND F.subcomisiones IS NOT NULL AND E.subcomisiones = F.subcomisiones)   -- Formulario de Comision con subcomisiones
                 )
        AND F.alcance = pAlcance
        AND F.estado = 'A'
        AND NOT EXISTS (SELECT 1 FROM _Tencuestado_o as EO 
                         WHERE EO.unidad_academica = E.unidad_academica
                           AND EO.nro_inscripcion = E.nro_inscripcion
                           AND EO.formulario = F.formulario);


  -- Borro tabla temporal
    DROP TABLE _Tcom;
    DROP TABLE _Tcomsubco;
    DROP TABLE _Tdocsubco;

END;
END PROCEDURE;
-- ************************************** Fin procedure sp_enc_crea_d *********************************************