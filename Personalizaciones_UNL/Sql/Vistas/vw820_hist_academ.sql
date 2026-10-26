-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.2.0
-- Vista vw820_hist_academ
-- Ultima modificacion: Version 1.10.0, 2.0.0, 2.1.0
-- ***************************************************************************
-- U820: se agregaron los campos descripción de nota y concepto.
-- ***************************************************************************
--
-- Muestra la histora academica de los alumnos, combinando todos sus resultados en
-- examenes, promociones, equivalencias, homologaciones, etc.
-- 
-- Formas de Aprobacion:
--       'Examen',
--       'Examen equivalente',
--       'Promoción',
--       'Promoción en otra carrera',
--       'Homologada'
--       'Equivalencia'
--       'Equivalencia equivalente',
--       'Otras',
--
-- *****************************************************************************
CREATE PROCEDURE "dba".verifica_objeto()

BEGIN

IF EXISTS (SELECT * FROM systables where tabname = 'vw820_hist_academ' and tabtype = "V") THEN

	DROP VIEW "dba".vw820_hist_academ;
END IF;

END;
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

CREATE VIEW "dba".vw820_hist_academ
          ( unidad_academica,
            carrera,
            legajo,
            materia,
            fecha,
            resultado,

            concepto, -- U820

            escala_notas,
            nota,

            descripcion, -- U820

            forma_aprobacion,
            tipo_acta,
            acta,
            acta_examen_orig, -- nuevo 2.0.3
            acta_promocion,
            acta_promo_orig, -- nuevo 2.0.3
            equivalencia,
            nro_resolucion,
            plan,
            version,
            nua)  AS -- nuevo 2.0.3

-- Actas de examen (no muestra las materias que se rinden por partes)
SELECT { + ordered} sga_actas_examen.unidad_academica,
       sga_detalle_acta.carrera,
       sga_detalle_acta.legajo,
       sga_actas_examen.materia,
       sga_detalle_acta.fecha_de_examen,
       sga_detalle_acta.resultado,
       sga_det_escala.concepto,
       sga_actas_examen.escala_notas,
       sga_detalle_acta.nota,
       sga_det_escala.descripcion,
       'Examen',
       sga_actas_examen.tipo_acta,
       sga_actas_examen.acta,
       sga_actas_examen.acta,
       0, -- acta de promocion
       0, -- acta de promocion
       0, -- equivalencia
       '', -- nro. de resolucion de equivalencia,
       sga_detalle_acta.plan,
       sga_detalle_acta.version,
       sga_actas_examen.nua
  FROM sga_detalle_acta,
       sga_actas_examen,
		OUTER sga_det_escala
 WHERE sga_actas_examen.tipo_acta = 'N'
   AND sga_detalle_acta.estado = 'A'
   AND sga_detalle_acta.rectificado = 'N'
   AND sga_detalle_acta.resultado <> 'U'
   AND sga_actas_examen.unidad_academica = sga_detalle_acta.unidad_academica
   AND sga_actas_examen.tipo_acta = sga_detalle_acta.tipo_acta
   AND sga_actas_examen.acta = sga_detalle_acta.acta
   AND sga_actas_examen.estado = 'C'

   AND sga_actas_examen.escala_notas = sga_det_escala.escala_notas
   AND sga_detalle_acta.nota = sga_det_escala.nota

   AND NOT EXISTS (SELECT '' FROM sga_cond_aprob
                    WHERE sga_cond_aprob.unidad_academica = sga_actas_examen.unidad_academica
                      AND sga_cond_aprob.materia = sga_actas_examen.materia )
 UNION ALL
SELECT {+ ordered} sga_actas_examen.unidad_academica,
       sga_detalle_acta.carrera,
       sga_detalle_acta.legajo,
       sga_actas_examen.materia,
       sga_detalle_acta.fecha_de_examen,
       sga_detalle_acta.resultado,
       sga_det_escala.concepto,
       sga_actas_examen.escala_notas,
       sga_detalle_acta.nota,
       sga_det_escala.descripcion,
       'Examen',
       sga_actas_examen.tipo_acta, -- tipo de acta original
       sga_actas_examen.acta, -- acta actual
       sga_actas_examen.acta_referencia, -- acta original
       0, -- acta de promocion
       0, -- acta de promocion
       0, -- equivalencia
       '', -- nro. de resolucion de equivalencia,
       sga_detalle_acta.plan,
       sga_detalle_acta.version,
       sga_actas_examen.nua
  FROM sga_detalle_acta,           -- detalle del acta rectificativa
             sga_actas_examen,        -- acta rectificativa
		OUTER sga_det_escala
 WHERE sga_actas_examen.tipo_acta = 'R'
   AND sga_detalle_acta.estado = 'A'
   AND sga_detalle_acta.rectificado = 'N'
   AND sga_detalle_acta.resultado <> 'U'
   AND sga_actas_examen.unidad_academica = sga_detalle_acta.unidad_academica
   AND sga_actas_examen.tipo_acta = sga_detalle_acta.tipo_acta
   AND sga_actas_examen.acta = sga_detalle_acta.acta
   AND sga_actas_examen.estado = 'C'

   AND sga_actas_examen.escala_notas = sga_det_escala.escala_notas
   AND sga_detalle_acta.nota = sga_det_escala.nota

   AND NOT EXISTS (SELECT ''  FROM sga_detalle_acta  det_acta_orig
		WHERE det_acta_orig.unidad_academica = sga_detalle_acta.unidad_academica
		   AND det_acta_orig.tipo_acta = 'N'
		   AND det_acta_orig.acta = sga_actas_examen.acta_referencia
		   AND det_acta_orig.carrera = sga_detalle_acta.carrera
		   AND det_acta_orig.legajo = sga_detalle_acta.legajo
		   AND det_acta_orig.estado  <> 'A')  -- Que no este invalidado el registro original, si existe.


 UNION ALL

-- Notas de exámenes equivalentes, Actas Normales
SELECT {+ ordered} sga_examenes_equiv.unidad_academica,
       sga_examenes_equiv.carrera,
       sga_examenes_equiv.legajo,
       sga_actas_examen.materia,
       -- sga_examenes_equiv.fecha,
	   sga_detalle_acta.fecha_de_examen,
       sga_detalle_acta.resultado,
       sga_det_escala.concepto,
       sga_actas_examen.escala_notas,
       sga_detalle_acta.nota,
       sga_det_escala.descripcion,
       'Examen equivalente',
       sga_actas_examen.tipo_acta,
       sga_actas_examen.acta,
       sga_actas_examen.acta,
       0, -- acta de promocion
       0, -- acta de promocion
       0, -- equivalencia
       '', -- nro. de resolucion de equivalencia,
       sga_examenes_equiv.plan,
       sga_examenes_equiv.version,
       sga_actas_examen.nua
  FROM sga_examenes_equiv,
       sga_detalle_acta,
       sga_actas_examen,
		OUTER sga_det_escala
 WHERE sga_detalle_acta.unidad_academica = sga_examenes_equiv.unidad_academica
   AND sga_detalle_acta.tipo_acta = sga_examenes_equiv.tipo_acta
   AND sga_detalle_acta.acta = sga_examenes_equiv.acta
   AND sga_detalle_acta.carrera = sga_examenes_equiv.carrera_original
   AND sga_detalle_acta.legajo = sga_examenes_equiv.legajo_original

   AND sga_actas_examen.unidad_academica = sga_examenes_equiv.unidad_academica
   AND sga_actas_examen.tipo_acta = sga_examenes_equiv.tipo_acta
   AND sga_actas_examen.acta        = sga_examenes_equiv.acta

   AND sga_actas_examen.escala_notas = sga_det_escala.escala_notas
   AND sga_detalle_acta.nota = sga_det_escala.nota

   AND sga_actas_examen.estado = 'C'
   AND sga_actas_examen.tipo_acta = 'N'
   AND sga_detalle_acta.estado = 'A'
   AND sga_detalle_acta.rectificado = 'N'
   AND sga_detalle_acta.resultado <> 'U'
   AND NOT EXISTS (SELECT '' FROM sga_cond_aprob
                    WHERE sga_cond_aprob.unidad_academica = sga_actas_examen.unidad_academica
                      AND sga_cond_aprob.materia = sga_actas_examen.materia )

 UNION ALL
-- Examenes Equivalentes, Actas Rectificativas.
SELECT {+ ordered} sga_actas_examen.unidad_academica,
       sga_examenes_equiv.carrera,
       sga_examenes_equiv.legajo,
       sga_actas_examen.materia,
       -- sga_examenes_equiv.fecha,
	   sga_detalle_acta.fecha_de_examen,
       sga_detalle_acta.resultado,
       sga_det_escala.concepto,
       sga_actas_examen.escala_notas,
       sga_detalle_acta.nota,
       sga_det_escala.descripcion,
       'Examen equivalente',
       sga_actas_examen.tipo_acta, -- tipo de acta actual
       sga_actas_examen.acta,      -- acta actual
       sga_actas_examen.acta_referencia, -- acta original
       0, -- acta de promocion
       0, -- acta de promocion orig
       0, -- equivalencia
       '', -- nro. de resolucion de equivalencia,
       sga_examenes_equiv.plan,
       sga_examenes_equiv.version,
       sga_actas_examen.nua
  FROM  sga_examenes_equiv,
        sga_detalle_acta,           -- detalle del acta rectificativa
        sga_actas_examen,            -- acta rectificativa
		OUTER sga_det_escala

 WHERE sga_detalle_acta.unidad_academica = sga_examenes_equiv.unidad_academica
   AND sga_detalle_acta.tipo_acta = sga_examenes_equiv.tipo_acta
   AND sga_detalle_acta.acta         = sga_examenes_equiv.acta
   AND sga_detalle_acta.carrera   = sga_examenes_equiv.carrera_original
   AND sga_detalle_acta.legajo      = sga_examenes_equiv.legajo_original

   AND sga_actas_examen.unidad_academica = sga_examenes_equiv.unidad_academica
   AND sga_actas_examen.tipo_acta 	= sga_examenes_equiv.tipo_acta
   AND sga_actas_examen.acta 	= sga_examenes_equiv.acta

   AND sga_actas_examen.escala_notas = sga_det_escala.escala_notas
   AND sga_detalle_acta.nota = sga_det_escala.nota

   AND sga_actas_examen.estado = 'C'
   AND sga_actas_examen.tipo_acta = 'R'
   AND sga_detalle_acta.estado = 'A'
   AND sga_detalle_acta.rectificado = 'N'
   AND sga_detalle_acta.resultado <> 'U'
   AND NOT EXISTS (SELECT ''  FROM sga_detalle_acta  det_acta_orig
		WHERE det_acta_orig.unidad_academica = sga_detalle_acta.unidad_academica
		   AND det_acta_orig.tipo_acta = 'N'
		   AND det_acta_orig.acta = sga_actas_examen.acta_referencia
		   AND det_acta_orig.carrera = sga_detalle_acta.carrera
		   AND det_acta_orig.legajo = sga_detalle_acta.legajo
		   AND det_acta_orig.estado  <> 'A')  -- Que no este invalidado el registro original, si existe.

   AND NOT EXISTS (SELECT '' FROM sga_cond_aprob
                    WHERE sga_cond_aprob.unidad_academica = sga_actas_examen.unidad_academica
                      AND sga_cond_aprob.materia = sga_actas_examen.materia )

 UNION ALL

-- Actas de promociones
 SELECT sga_det_acta_promo.unidad_academica,   
         sga_det_acta_promo.carrera,   
         sga_det_acta_promo.legajo,   
         sga_comisiones.materia,
         sga_det_acta_promo.fecha,   
         'A', -- resultado
       sga_det_escala.concepto,
         sga_actas_promo.escala_notas,
         sga_det_acta_promo.nota,   
       sga_det_escala.descripcion,
         'Promoción',
         sga_actas_promo.tipo, -- P tipo de acta original de Promocion
         '',  -- Acta de examen
         '',  -- Acta de examen
         sga_det_acta_promo.acta,   
         sga_det_acta_promo.acta,   
         0, 
         '',
         sga_det_acta_promo.plan,   
         sga_det_acta_promo.version,
         sga_actas_promo.nua   
    FROM sga_actas_promo,   
         sga_det_acta_promo,
         sga_comisiones,
		OUTER sga_det_escala  
   WHERE sga_actas_promo.unidad_academica = sga_det_acta_promo.unidad_academica 
     AND sga_actas_promo.acta = sga_det_acta_promo.acta  
     AND sga_actas_promo.estado = 'C'   
     AND sga_actas_promo.tipo = 'P'   
     AND sga_det_acta_promo.rectificado = 'N' 
     AND sga_det_acta_promo.resultado   = 'P'
     AND sga_det_acta_promo.estado      = 'A'
     AND sga_comisiones.comision = sga_actas_promo.comision

     AND sga_actas_promo.escala_notas = sga_det_escala.escala_notas
     AND sga_det_acta_promo.nota = sga_det_escala.nota

 UNION 

  -- Registros no rectificados de actas rectificativas cerradas
  -- El folio y renglon que muestra es el del acta original. Para eso se hace el join
-- entre el det_1 y det_2
  SELECT det_2.unidad_academica,   
         det_2.carrera,   
         det_2.legajo,   
         sga_comisiones.materia,
         det_2.fecha,   
         'A', -- resultado
       sga_det_escala.concepto,
         sga_actas_promo.escala_notas,
         det_2.nota, 
       sga_det_escala.descripcion,  
         'Promoción',
         sga_actas_promo.tipo,   -- tipo de acta Rectificativa de Promocion
         '', -- Acta de Examen
         '', -- Acta de Examen
         sga_actas_promo.acta,   		  -- Acta Actual	
         sga_actas_promo.acta_referencia,   -- Acta Original
       0, -- equivalencia
       '',
         det_2.plan,   
         det_2.version,
         sga_actas_promo.nua      

    FROM sga_actas_promo,   		 -- Cabecera del Acta
         sga_det_acta_promo  det_2,	 -- Detalle del Acta Rectificada
         sga_comisiones,
		OUTER sga_det_escala 

   WHERE sga_actas_promo.unidad_academica = det_2.unidad_academica 
     AND sga_actas_promo.acta   = det_2.acta  
     AND sga_actas_promo.tipo   = 'R' 
     AND sga_actas_promo.estado = 'C' 
     AND det_2.rectificado = 'N' 
     AND det_2.resultado  = 'P' 
     AND det_2.estado  = 'A' 
     AND sga_comisiones.comision = sga_actas_promo.comision 
     AND NOT EXISTS (SELECT ''  FROM sga_det_acta_promo  det_acta_orig
		WHERE det_acta_orig.unidad_academica = det_2.unidad_academica
		   AND det_acta_orig.carrera = det_2.carrera
		   AND det_acta_orig.legajo   = det_2.legajo
		   AND det_acta_orig.acta     =  sga_actas_promo.acta_referencia
		   AND det_acta_orig.estado  <> 'A')  -- Que no este invalidado el registro original, si existe.

     AND sga_actas_promo.escala_notas = sga_det_escala.escala_notas
     AND det_2.nota = sga_det_escala.nota


 UNION ALL


-- Notas de promociones equivalentes
SELECT sga_promo_equiv.unidad_academica,
       sga_promo_equiv.carrera,
       sga_promo_equiv.legajo,
       sga_comisiones.materia,
       -- sga_promo_equiv.fecha,
       sga_det_acta_promo.fecha,
       'A', -- sga_det_acta_promo.resultado
       sga_det_escala.concepto,
       sga_actas_promo.escala_notas,
       sga_det_acta_promo.nota,
       sga_det_escala.descripcion,
       'Promoción en otra carrera',
       sga_actas_promo.tipo,   -- Tipo de Acta de Promocion
       '',  -- Acta de Examen
       '',  
       sga_promo_equiv.acta,
       sga_promo_equiv.acta,
       0, -- equivalencia
       '',
       sga_promo_equiv.plan,
       sga_promo_equiv.version,
       sga_actas_promo.nua   
  FROM sga_promo_equiv,
         sga_actas_promo,
         sga_det_acta_promo,
         sga_comisiones,
		OUTER sga_det_escala
 WHERE sga_actas_promo.unidad_academica = sga_promo_equiv.unidad_academica
   AND sga_actas_promo.acta = sga_promo_equiv.acta
   AND sga_actas_promo.tipo = 'P'   -- Actas Normales de Promocion
   AND sga_actas_promo.estado = 'C' 
   AND sga_det_acta_promo.unidad_academica = sga_promo_equiv.unidad_academica
   AND sga_det_acta_promo.carrera = sga_promo_equiv.carrera_original
   AND sga_det_acta_promo.legajo = sga_promo_equiv.legajo_original
   AND sga_det_acta_promo.acta = sga_promo_equiv.acta
   AND sga_det_acta_promo.resultado = 'P'
   AND sga_det_acta_promo.estado = 'A'
   AND sga_det_acta_promo.rectificado = 'N'
   AND  sga_comisiones.comision = sga_actas_promo.comision

   AND sga_actas_promo.escala_notas = sga_det_escala.escala_notas
   AND sga_det_acta_promo.nota = sga_det_escala.nota


 UNION ALL
-- Notas de promociones equivalentes. Promociones de Actas Rectificativas
SELECT sga_promo_equiv.unidad_academica,
       sga_promo_equiv.carrera,
       sga_promo_equiv.legajo,
       sga_comisiones.materia,
       sga_promo_equiv.fecha,
       'A', -- sga_det_acta_promo.resultado
       sga_det_escala.concepto,
       sga_actas_promo.escala_notas,
       sga_det_acta_promo.nota,
       sga_det_escala.descripcion,
       'Promoción en otra carrera',
       sga_actas_promo.tipo,   -- Tipo de Acta de Promocion
       '',  -- Acta de Examen
       '',  
       sga_promo_equiv.acta,  -- Acta Actual
       sga_actas_promo.acta_referencia, -- Acta Original
       0, -- equivalencia
       '',
       sga_promo_equiv.plan,
       sga_promo_equiv.version,
        sga_actas_promo.nua   
  FROM sga_promo_equiv,
         sga_actas_promo,
         sga_det_acta_promo,
         sga_comisiones,
		OUTER sga_det_escala
 WHERE sga_actas_promo.unidad_academica = sga_promo_equiv.unidad_academica
   AND sga_actas_promo.acta = sga_promo_equiv.acta
   AND sga_actas_promo.tipo = 'R'   -- Actas Rectificativas de Promocion
   AND sga_actas_promo.estado = 'C' 
   AND sga_det_acta_promo.unidad_academica = sga_promo_equiv.unidad_academica
   AND sga_det_acta_promo.carrera = sga_promo_equiv.carrera_original
   AND sga_det_acta_promo.legajo = sga_promo_equiv.legajo_original
   AND sga_det_acta_promo.acta = sga_promo_equiv.acta
   AND sga_det_acta_promo.resultado = 'P'
   AND sga_det_acta_promo.estado = 'A'
   AND sga_det_acta_promo.rectificado = 'N'
   AND  sga_comisiones.comision = sga_actas_promo.comision

   AND sga_actas_promo.escala_notas = sga_det_escala.escala_notas
   AND sga_det_acta_promo.nota = sga_det_escala.nota

     AND NOT EXISTS (SELECT ''  FROM sga_det_acta_promo  det_acta_orig
		WHERE det_acta_orig.unidad_academica = sga_actas_promo.unidad_academica
		   AND det_acta_orig.carrera = sga_det_acta_promo.carrera
		   AND det_acta_orig.legajo   = sga_det_acta_promo.legajo
		   AND det_acta_orig.acta     =  sga_actas_promo.acta_referencia
		   AND det_acta_orig.estado  <> 'A')  -- Que no este invalidado el registro original, si existe.

 UNION ALL

-- Equivalencias Totales  de Tramites de Equiv Normales (Originales)
SELECT  {+ ordered } distinct
       sga_equiv_otorgada.unidad_academica,
       sga_equiv_otorgada.carrera,
       sga_equiv_otorgada.legajo,
       sga_equiv_otorgada.materia,
       CASE WHEN sga_equiv_operac.origen = 'S' AND sga_equiv_notasext.fecha is not NULL THEN sga_equiv_notasext.fecha ELSE sga_equiv_otorgada.fecha END, -- Fecha Examen -- U820
       sga_equiv_otorgada.resultado,
       sga_det_escala.concepto,
       sga_equiv_otorgada.escala_notas,
       sga_equiv_otorgada.nota,
       sga_det_escala.descripcion,
       --DECODE(sga_equiv_operac.origen, 'H', 'Homologada', 'S', NVL('Examen (' || sga_instituciones.nombre  || ')', 'Equivalencia'), 'Equivalencia'), -- U820

       (CASE WHEN sga_instituciones.institucion IS NOT NULL and sga_equiv_operac.origen = 'S' THEN 'Examen - (' ELSE '' END) || DECODE(sga_equiv_operac.origen, 'H', 'Homologada', 'S', CASE WHEN sga_instituciones.institucion IS NULL THEN 'Equivalencia' ELSE sga_instituciones.nombre END, 'Equivalencia') || (CASE WHEN sga_instituciones.institucion IS NOT NULL and sga_equiv_operac.origen = 'S' THEN ')' ELSE '' END) as forma_aprobacion, -- U820

       --DECODE(sga_equiv_operac.origen, 'H', 'Homologada', 'S', 'Equivalencia', 'Equivalencia'), -- U820
       'N', -- tipo Equivalencia
       DECODE(sga_equiv_operac.origen, 'S', NVL(sga_equiv_notasext.acta, sga_equiv_operac.nro_resolucion), ''), -- Acta Examen -- U820
       DECODE(sga_equiv_operac.origen, 'S', NVL(sga_equiv_notasext.acta, sga_equiv_operac.nro_resolucion), ''), -- Acta Examen -- U820

       0, -- Acta Promocion
       0,
       sga_equiv_otorgada.equivalencia,
       sga_equiv_operac.nro_resolucion, -- U820
       sga_equiv_otorgada.plan,
       sga_equiv_otorgada.version,
       sga_equiv_operac.nua   
  FROM  sga_equiv_otorgada,
              sga_equiv_operac,
              sga_atrib_mat_plan,
		OUTER sga_det_escala, OUTER sga_equiv_notasext, OUTER sga_instituciones
 WHERE sga_equiv_operac.operacion_equiv = sga_equiv_otorgada.operacion_equiv 

   AND sga_equiv_operac.tipo_equiv = 'N'
   AND sga_equiv_operac.estado  = 'C'

  AND  sga_equiv_otorgada.alcance = 'T'
   AND sga_equiv_otorgada.estado = 'A'
   AND sga_equiv_otorgada.rectificado = 'N'
   AND sga_equiv_otorgada.resultado <> 'U'

   AND sga_atrib_mat_plan.unidad_academica = sga_equiv_otorgada.unidad_academica
   AND sga_atrib_mat_plan.carrera = sga_equiv_otorgada.carrera
   AND sga_atrib_mat_plan.plan = sga_equiv_otorgada.plan
   AND sga_atrib_mat_plan.version = sga_equiv_otorgada.version
   AND sga_atrib_mat_plan.materia = sga_equiv_otorgada.materia

   AND sga_equiv_otorgada.escala_notas = sga_det_escala.escala_notas
   AND sga_equiv_otorgada.nota = sga_det_escala.nota

   AND sga_equiv_otorgada.equivalencia = sga_equiv_notasext.equivalencia
   AND sga_equiv_operac.institucion = sga_instituciones.institucion


 UNION ALL


-- Equivalencias Totales  de Tramites Rectificativos de Equiv  (Originales)
SELECT {+ ordered} distinct
       sga_equiv_otorgada.unidad_academica,
       sga_equiv_otorgada.carrera,
       sga_equiv_otorgada.legajo,
       sga_equiv_otorgada.materia,
       CASE WHEN sga_equiv_operac.origen = 'S' AND sga_equiv_notasext.fecha is not NULL THEN sga_equiv_notasext.fecha ELSE sga_equiv_otorgada.fecha END, -- Fecha Examen -- U820
       sga_equiv_otorgada.resultado,
       sga_det_escala.concepto,
       sga_equiv_otorgada.escala_notas,
       sga_equiv_otorgada.nota,
       sga_det_escala.descripcion,
       -- DECODE(sga_equiv_operac.origen, 'H', 'Homologada', 'S', NVL('Examen (' || sga_instituciones.nombre  || ')', 'Equivalencia'), 'Equivalencia'), -- U820
       (CASE WHEN sga_instituciones.institucion IS NOT NULL and sga_equiv_operac.origen = 'S' THEN 'Examen - (' ELSE '' END) || DECODE(sga_equiv_operac.origen, 'H', 'Homologada', 'S', CASE WHEN sga_instituciones.institucion IS NULL THEN 'Equivalencia' ELSE sga_instituciones.nombre END, 'Equivalencia') || (CASE WHEN sga_instituciones.institucion IS NOT NULL and sga_equiv_operac.origen = 'S' THEN ')' ELSE '' END) as forma_aprobacion, -- U820
       'R',	
       DECODE(sga_equiv_operac.origen, 'S', NVL(sga_equiv_notasext.acta, sga_equiv_operac.nro_resolucion), ''), -- Acta Examen -- U820
       DECODE(sga_equiv_operac.origen, 'S', NVL(sga_equiv_notasext.acta, sga_equiv_operac.nro_resolucion), ''), -- Acta Examen -- U820
       0,	
       0,	
       sga_equiv_otorgada.equivalencia,
       sga_equiv_operac.nro_resolucion, -- U820
       sga_equiv_otorgada.plan,
       sga_equiv_otorgada.version,
       sga_equiv_operac.nua   

  FROM   sga_equiv_otorgada,     -- Detalle Equivalencias Rectificativas
               sga_equiv_operac,	              -- Cabecera Tramite de Equiv Rectificativa	
               sga_atrib_mat_plan,
		OUTER sga_det_escala, OUTER sga_equiv_notasext, OUTER sga_instituciones

 WHERE    sga_equiv_operac.operacion_equiv = sga_equiv_otorgada.operacion_equiv 
   AND sga_equiv_operac.tipo_equiv = 'R'
   AND sga_equiv_operac.estado  = 'C'
   AND sga_equiv_otorgada.alcance = 'T'
   AND sga_equiv_otorgada.estado = 'A'
   AND sga_equiv_otorgada.rectificado = 'N'
   AND sga_equiv_otorgada.resultado <> 'U'

   AND sga_atrib_mat_plan.unidad_academica = sga_equiv_otorgada.unidad_academica
   AND sga_atrib_mat_plan.carrera = sga_equiv_otorgada.carrera
   AND sga_atrib_mat_plan.plan = sga_equiv_otorgada.plan
   AND sga_atrib_mat_plan.version = sga_equiv_otorgada.version
   AND sga_atrib_mat_plan.materia = sga_equiv_otorgada.materia 

   AND sga_equiv_otorgada.escala_notas = sga_det_escala.escala_notas
   AND sga_equiv_otorgada.nota = sga_det_escala.nota

   AND sga_equiv_otorgada.equivalencia = sga_equiv_notasext.equivalencia
   AND sga_equiv_operac.institucion = sga_instituciones.institucion


 UNION ALL

  -- Equivalencias Equivalentes (equiv vale en otras carreras)
  -- Recupera la equivalencia original, verifica que este cerrado, activo y no rectificado.
  SELECT  {+ ordered }
         sga_equiv_equiv.unidad_academica,   
         sga_equiv_equiv.carrera,   
         sga_equiv_equiv.legajo,   
         sga_equiv_otorgada.materia,
         -- sga_equiv_equiv.fecha,   
		 sga_equiv_otorgada.fecha,   
         sga_equiv_otorgada.resultado,   
       sga_det_escala.concepto,
         sga_equiv_otorgada.escala_notas,   
         sga_equiv_otorgada.nota,   
       sga_det_escala.descripcion,
       'Equivalencia equivalente',
         sga_equiv_operac.tipo_equiv,   
         '',   
         '',   
         0,   
         0,   
         sga_equiv_equiv.equivalencia,   
         sga_equiv_operac.nro_resolucion,   
         sga_equiv_equiv.plan,   
         sga_equiv_equiv.version,
       sga_equiv_operac.nua      
    FROM sga_equiv_equiv,
         sga_equiv_otorgada,
         sga_equiv_operac,
		OUTER sga_det_escala
   WHERE sga_equiv_otorgada.equivalencia = sga_equiv_equiv.equivalencia
     AND sga_equiv_operac.operacion_equiv = sga_equiv_otorgada.operacion_equiv
     AND sga_equiv_operac.estado = 'C'		-- Tramite de Equivalencia Cerrado.
     AND sga_equiv_otorgada.alcance = 'T'	-- Equivalencia Total	
     AND sga_equiv_otorgada.estado = 'A'	-- Activo
     AND sga_equiv_otorgada.rectificado = 'N'	-- No Rectificado
    AND sga_equiv_otorgada.resultado <> 'U'

   AND sga_equiv_otorgada.escala_notas = sga_det_escala.escala_notas
   AND sga_equiv_otorgada.nota = sga_det_escala.nota

 UNION ALL

-- Otras materias aprobadas (genericas y materias aprobadas por partes)
SELECT sga_otras_mat_apro.unidad_academica,
       sga_otras_mat_apro.carrera,
       sga_otras_mat_apro.legajo,
       sga_otras_mat_apro.materia,
       sga_otras_mat_apro.fecha,
       'A',
       sga_det_escala.concepto,
       sga_tipos_materia.escala_examen,
       sga_otras_mat_apro.nota,
       sga_det_escala.descripcion,
       'Otras',
       '',
       '',
       '',
       0,
       0,
       0, -- equivalencia
       '',
       sga_otras_mat_apro.plan,
       sga_otras_mat_apro.version,
       ''	
  FROM sga_otras_mat_apro,
       sga_atrib_mat_plan,
       sga_materias,
       sga_tipos_materia,
		OUTER sga_det_escala
 WHERE sga_atrib_mat_plan.unidad_academica = sga_otras_mat_apro.unidad_academica
   AND sga_atrib_mat_plan.carrera = sga_otras_mat_apro.carrera
   AND sga_atrib_mat_plan.plan = sga_otras_mat_apro.plan
   AND sga_atrib_mat_plan.version = sga_otras_mat_apro.version
   AND sga_atrib_mat_plan.materia = sga_otras_mat_apro.materia
   AND sga_materias.unidad_academica = sga_atrib_mat_plan.unidad_academica
   AND sga_materias.materia = sga_atrib_mat_plan.materia
   AND sga_tipos_materia.tipo_de_materia = sga_materias.tipo_de_materia

   AND sga_tipos_materia.escala_examen = sga_det_escala.escala_notas
   AND sga_otras_mat_apro.nota = sga_det_escala.nota

;

-- ******************* Fin de la vista vw820_hist_academ***********************


-- *****************************************************************************
-- Permisos de la VISTA vw820_hist_academ
-- *****************************************************************************
grant select on "dba".vw820_hist_academ to guarani; -- Rol de usuarios de Gestión
grant select on "dba".vw820_hist_academ to internet; -- Rol de usuario de Internet
