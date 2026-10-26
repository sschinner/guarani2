CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_detalle_acta_pr') THEN
		DROP PROCEDURE sp820_detalle_acta_pr;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.03.0
-- Ultima version modificacion: 
--   2.05.1: Ahora el sp tambien retorna los alumnos agregados por rectificativas.
--   2.08.0: Se modifico sp_alumnos_com
--
-- Procedure: sp820_detalle_acta_pr
--
-- Lista el detalle de un acta de promocion, se utiliza en Guarani3w.
-- *******************************************************************************
-- DROP PROCEDURE "dba".sp820_detalle_acta_pr;

CREATE PROCEDURE "dba".sp820_detalle_acta_pr(
   pUA LIKE sga_unidades_acad.unidad_academica, 
   pActa LIKE sga_actas_cursado.acta)

RETURNING VARCHAR(5),   --  0 sga_actas_promo.unidad_academica
          INTEGER,      --  1 sga_actas_promo.acta
          CHAR(1),      --  2 sga_actas_promo.tipo
          INTEGER,      --  3 sga_actas_promo.comision
          DATE,         --  4 sga_actas_promo.fecha_generacion
          DATE,         --  5 sga_actas_promo.fecha_cierre
          INTEGER,      --  6 sga_actas_promo.acta_referencia
          INTEGER,      --  7 sga_actas_promo.renglones_folio
          VARCHAR(15),  --  8 sga_actas_promo.libro
          INTEGER,      --  9 sga_actas_promo.escala_notas
          VARCHAR(5),   -- 10 sga_actas_promo.carrera
          VARCHAR(255), -- 11 sga_actas_promo.observaciones
          CHAR(1),      -- 12 sga_actas_promo.estado
          VARCHAR(5),   -- 13 sga_comisiones.materia
          INTEGER,      -- 14 sga_comisiones.anio_academico
          VARCHAR(20),  -- 15 sga_comisiones.periodo_lectivo
          VARCHAR(15),  -- 16 sga_comisiones.nombre
          VARCHAR(255), -- 17 sga_materias.nombre
          VARCHAR(5),   -- 18 sga_det_acta_promo.carrera
          VARCHAR(15),  -- 19 sga_det_acta_promo.legajo
          INTEGER,      -- 20 sga_det_acta_promo.folio
          INTEGER,      -- 21 sga_det_acta_promo.renglon
          INTEGER,      -- 22 sga_det_acta_promo.cond_regularidad
          DATE,         -- 23 sga_det_acta_promo.fecha
          CHAR(1),      -- 24 sga_det_acta_promo.resultado
          VARCHAR(5),   -- 25 sga_det_acta_promo.nota
          VARCHAR(1),   -- 26 sga_det_acta_promo.rectificado
          VARCHAR(5),   -- 27 sga_det_acta_promo.plan
          VARCHAR(5),   -- 28 sga_det_acta_promo.version
          VARCHAR(1),   -- 29 sga_det_acta_promo.estado
          VARCHAR(30),  -- 30 sga_personas.apellido
          VARCHAR(30),  -- 31 sga_personas.nombres
          VARCHAR(15),  -- 32 sga_det_escala.concepto
          VARCHAR(15),  -- 33 sga_det_escala.descripcion
          INTEGER,      -- 34 que acta la rectifica?
          VARCHAR(1), --35 promocional 
	  VARCHAR(20); -- nro documento	

DEFINE vc_unidad_acad LIKE sga_actas_promo.unidad_academica;
DEFINE vc_acta        LIKE sga_actas_promo.acta;
DEFINE vc_tipo        LIKE sga_actas_promo.tipo;
DEFINE vc_comision    LIKE sga_actas_promo.comision;
DEFINE vc_fecha_gen   LIKE sga_actas_promo.fecha_generacion;
DEFINE vc_fecha_cier  LIKE sga_actas_promo.fecha_cierre;
DEFINE vc_acta_ref    LIKE sga_actas_promo.acta_referencia;
DEFINE vc_reng_folio  LIKE sga_actas_promo.renglones_folio;
DEFINE vc_libro       LIKE sga_actas_promo.libro;
DEFINE vc_escala_not  LIKE sga_actas_promo.escala_notas;
DEFINE vc_carrera     LIKE sga_actas_promo.carrera;
DEFINE vc_observacion LIKE sga_actas_promo.observaciones;
DEFINE vc_estado      LIKE sga_actas_promo.estado;
DEFINE vc_materia     LIKE sga_comisiones.materia;
DEFINE vc_anio_acade  LIKE sga_comisiones.anio_academico;
DEFINE vc_per_lectiv  LIKE sga_comisiones.periodo_lectivo;
DEFINE vc_nombre_com  LIKE sga_comisiones.nombre;
DEFINE vc_nombre_mat  LIKE sga_materias.nombre;
DEFINE vc_det_carr    LIKE sga_det_acta_promo.carrera;
DEFINE vc_legajo      LIKE sga_det_acta_promo.legajo;
DEFINE vc_folio       LIKE sga_det_acta_promo.folio;
DEFINE vc_renglon     LIKE sga_det_acta_promo.renglon;
DEFINE vc_cond_regul  LIKE sga_det_acta_promo.cond_regularidad;
DEFINE vc_fecha       LIKE sga_det_acta_promo.fecha;
DEFINE vc_resultado   LIKE sga_det_acta_promo.resultado;
DEFINE vc_nota        LIKE sga_det_acta_promo.nota;
DEFINE vc_rectificado LIKE sga_det_acta_promo.rectificado;
DEFINE vc_plan        LIKE sga_det_acta_promo.plan;
DEFINE vc_version     LIKE sga_det_acta_promo.version;
DEFINE vc_det_estado  LIKE sga_det_acta_promo.estado;
DEFINE vc_apellido    LIKE sga_personas.apellido;
DEFINE vc_nombres     LIKE sga_personas.nombres;
DEFINE vc_concepto    LIKE sga_det_escala.concepto;
DEFINE vc_descripcion LIKE sga_det_escala.descripcion;
DEFINE vc_aux_acta    LIKE sga_actas_promo.acta_referencia;
DEFINE vc_acta_rect  LIKE sga_actas_promo.acta_referencia;
DEFINE vc_promocional  varchar(1);
DEFINE vc_nro_documento     LIKE sga_personas.nro_documento;

DEFINE l_unidad_academica LIKE sga_actas_cursado.unidad_academica;
DEFINE l_comision         LIKE sga_comisiones.comision;
DEFINE l_pct_asistencia   LIKE sga_curs_pendiente.pct_asistencia;   
DEFINE l_acta_promocion   LIKE sga_curs_pendiente.acta_promocion;   
DEFINE l_acta_regular     LIKE sga_curs_pendiente.acta_regular;   
DEFINE l_folio_regular    LIKE sga_curs_pendiente.folio_regular;   
DEFINE l_renglon_regular  LIKE sga_curs_pendiente.renglon_regular;   
DEFINE l_promocional      LIKE sga_curs_pendiente.promocional;  
DEFINE l_controlado       LIKE sga_curs_pendiente.controlado;  
DEFINE l_agregado	  char(1);
DEFINE l_tiene_nota       char(1);  
DEFINE vcArchivoFoto varchar(180);

BEGIN

  LET vc_escala_not = NULL;
  LET vc_det_estado = NULL;
  LET vc_rectificado = NULL;
  LET vc_descripcion = NULL;
  LET vc_concepto  = NULL;
 LET vc_promocional='S';
 
  SELECT sga_actas_promo.unidad_academica,   
         sga_actas_promo.acta,   
         sga_actas_promo.tipo,   
         sga_actas_promo.comision,   
         sga_actas_promo.fecha_generacion,   
         sga_actas_promo.fecha_cierre,   
         sga_actas_promo.acta_referencia,   
         sga_actas_promo.renglones_folio,   
         sga_actas_promo.libro,   
         sga_actas_promo.escala_notas,   
         sga_actas_promo.carrera,   
         sga_actas_promo.observaciones,   
         sga_actas_promo.estado,
         sga_comisiones.materia,   
         sga_comisiones.anio_academico,   
         sga_comisiones.periodo_lectivo,   
         sga_comisiones.nombre, 
         nvl(sga_atrib_mat_plan.nombre_materia, sga_materias.nombre)
 
    INTO vc_unidad_acad, vc_acta, vc_tipo, vc_comision, vc_fecha_gen,
         vc_fecha_cier, vc_acta_ref, vc_reng_folio, vc_libro, vc_escala_not,
         vc_carrera, vc_observacion, vc_estado, vc_materia, vc_anio_acade,
         vc_per_lectiv, vc_nombre_com, vc_nombre_mat

    FROM sga_actas_promo,
         sga_comisiones,   
         sga_materias,
	outer(sga_planes, sga_atrib_mat_plan)
     
   WHERE sga_actas_promo.unidad_academica    = pUA
     AND sga_actas_promo.acta                = pActa

     AND sga_actas_promo.comision            = sga_comisiones.comision

      AND sga_comisiones.unidad_academica     = sga_materias.unidad_academica
      AND sga_comisiones.materia              = sga_materias.materia

	AND dba.sga_planes.unidad_academica = dba.sga_comisiones.unidad_academica
	AND dba.sga_planes.carrera = dba.sga_comisiones.carrera
	AND dba.sga_planes.plan =dba.sga_comisiones.plan
	AND dba.sga_atrib_mat_plan.unidad_academica =dba.sga_planes.unidad_academica
	AND dba.sga_atrib_mat_plan.carrera =dba.sga_planes.carrera
	AND dba.sga_atrib_mat_plan.plan =dba.sga_planes.plan
	AND dba.sga_atrib_mat_plan.version =dba.sga_planes.version_actual
	AND dba.sga_atrib_mat_plan.materia =dba.sga_comisiones.materia;

  -- Si el acta esta cerrada recupero el detalle de sga_det_acta_promo
  IF vc_estado = 'C' THEN
    
    FOREACH
      SELECT sga_det_acta_promo.carrera,   
             sga_det_acta_promo.legajo,   
             sga_det_acta_promo.folio,   
             sga_det_acta_promo.renglon,   
             sga_det_acta_promo.cond_regularidad,   
             sga_det_acta_promo.fecha,   
             sga_det_acta_promo.resultado,   
             sga_det_acta_promo.nota,   
             sga_det_acta_promo.rectificado,   
             sga_det_acta_promo.plan,   
             sga_det_acta_promo.version,   
             sga_det_acta_promo.estado,
             sga_personas.apellido,
             sga_personas.nombres,
             sga_det_escala.concepto,
             sga_det_escala.descripcion,
	     sga_personas.nro_documento	

       INTO vc_det_carr, vc_legajo, 
            vc_folio, vc_renglon, vc_cond_regul, vc_fecha, vc_resultado, 
            vc_nota, vc_rectificado, vc_plan, vc_version, vc_det_estado, vc_apellido,
            vc_nombres, vc_concepto, vc_descripcion,vc_nro_documento

        FROM sga_actas_promo,
             sga_det_acta_promo,
             sga_alumnos,
             sga_personas,
       OUTER sga_det_escala
       WHERE sga_actas_promo.unidad_academica    = pUA
         AND sga_actas_promo.acta                = pActa
         AND sga_det_acta_promo.unidad_academica = sga_actas_promo.unidad_academica  
         AND sga_det_acta_promo.acta             = sga_actas_promo.acta

         AND sga_alumnos.unidad_academica        = sga_det_acta_promo.unidad_academica  
         AND sga_alumnos.carrera                 = sga_det_acta_promo.carrera
         AND sga_alumnos.legajo                  = sga_det_acta_promo.legajo
 
         AND sga_personas.unidad_academica       = sga_alumnos.unidad_academica
         AND sga_personas.nro_inscripcion        = sga_alumnos.nro_inscripcion
  
         AND sga_det_escala.escala_notas         = sga_actas_promo.escala_notas
         AND sga_det_escala.nota                 = sga_det_acta_promo.nota 

      ORDER BY folio, renglon  

      LET vc_acta_rect = NULL;

      -- Si el registro esta rectificado busco la 
      -- ultima acta rectificativa valida.
      IF vc_rectificado = 'S' AND vc_tipo = 'P' THEN
             
        SELECT sga_actas_promo.acta
          INTO vc_acta_rect
          FROM sga_actas_promo,
               sga_det_acta_promo
         WHERE sga_actas_promo.unidad_academica = pUA
           AND sga_actas_promo.estado           = 'C'
           AND sga_actas_promo.tipo             = 'R' 
           AND sga_actas_promo.acta_referencia  = pActa
                  
           AND sga_actas_promo.unidad_academica = sga_det_acta_promo.unidad_academica
           AND sga_actas_promo.acta             = sga_det_acta_promo.acta
           
           AND sga_det_acta_promo.carrera       = vc_det_carr
           AND sga_det_acta_promo.legajo        = vc_legajo
         
           AND sga_det_acta_promo.rectificado   = 'N';
         
      END IF 
      
      RETURN vc_unidad_acad, vc_acta, vc_tipo, vc_comision, vc_fecha_gen,
             vc_fecha_cier, vc_acta_ref, vc_reng_folio, vc_libro, vc_escala_not,
             vc_carrera, vc_observacion, vc_estado, vc_materia, vc_anio_acade,
             vc_per_lectiv, vc_nombre_com, vc_nombre_mat, vc_det_carr, vc_legajo, 
             vc_folio, vc_renglon, vc_cond_regul, vc_fecha, vc_resultado, 
             vc_nota, vc_rectificado, vc_plan, vc_version, vc_det_estado, vc_apellido,
             vc_nombres, vc_concepto, vc_descripcion, vc_acta_rect, vc_promocional, vc_nro_documento
      WITH RESUME;
    END FOREACH     
     
    IF vc_tipo = 'P' THEN
      -- Retorno los renglones agregados en rectifiativas
      FOREACH		
        SELECT sga_actas_promo.acta,
               sga_det_acta_promo.carrera,   
               sga_det_acta_promo.legajo,   
               '',   
               '',   
               sga_det_acta_promo.cond_regularidad,   
               sga_det_acta_promo.fecha,   
               sga_det_acta_promo.resultado,   
               sga_det_acta_promo.nota,   
               'S', -- sga_det_acta_promo.rectificado,   
               sga_det_acta_promo.plan,   
               sga_det_acta_promo.version,   
               sga_det_acta_promo.estado,
               sga_personas.apellido,
               sga_personas.nombres,
               sga_det_escala.concepto,
               sga_det_escala.descripcion,
	       sga_personas.nro_documento
  
         INTO vc_acta_rect, vc_det_carr, vc_legajo, 
              vc_folio, vc_renglon, vc_cond_regul, vc_fecha, vc_resultado, 
              vc_nota, vc_rectificado, vc_plan, vc_version, vc_det_estado, vc_apellido,
              vc_nombres, vc_concepto, vc_descripcion,vc_nro_documento
  
         FROM sga_actas_promo,
              sga_det_acta_promo,
              sga_alumnos,
              sga_personas,
        OUTER sga_det_escala
        WHERE sga_actas_promo.unidad_academica    = pUA
          AND sga_actas_promo.acta_referencia     = pActa
          AND sga_actas_promo.tipo                = 'R'
          AND sga_actas_promo.estado              = 'C'
 
          AND sga_det_acta_promo.unidad_academica = sga_actas_promo.unidad_academica  
          AND sga_det_acta_promo.acta             = sga_actas_promo.acta
          AND sga_det_acta_promo.rectificado      = 'N'
 
          AND sga_alumnos.unidad_academica        = sga_det_acta_promo.unidad_academica  
          AND sga_alumnos.carrera                 = sga_det_acta_promo.carrera
          AND sga_alumnos.legajo                  = sga_det_acta_promo.legajo
  
          AND sga_personas.unidad_academica       = sga_alumnos.unidad_academica
          AND sga_personas.nro_inscripcion        = sga_alumnos.nro_inscripcion
  
          AND sga_det_escala.escala_notas         = sga_actas_promo.escala_notas
          AND sga_det_escala.nota                 = sga_det_acta_promo.nota 
 
          AND NOT EXISTS (
 
              SELECT 1 
                FROM sga_actas_promo ap,
                     sga_det_acta_promo dap 
               WHERE ap.unidad_academica = pUA
                 AND ap.acta             = pActa
                 AND ap.tipo             = 'P'
                 AND ap.estado           = 'C'
                 AND ap.unidad_academica = dap.unidad_academica
                 AND ap.acta             = dap.acta
                 
                 AND dap.unidad_academica = sga_det_acta_promo.unidad_academica  
                 AND dap.carrera          = sga_det_acta_promo.carrera
                 AND dap.legajo           = sga_det_acta_promo.legajo
          )

       RETURN vc_unidad_acad, vc_acta, vc_tipo, vc_comision, vc_fecha_gen,
              vc_fecha_cier, vc_acta_ref, vc_reng_folio, vc_libro, vc_escala_not,
              vc_carrera, vc_observacion, vc_estado, vc_materia, vc_anio_acade,
              vc_per_lectiv, vc_nombre_com, vc_nombre_mat, vc_det_carr, vc_legajo, 
              vc_folio, vc_renglon, vc_cond_regul, vc_fecha, vc_resultado, 
              vc_nota, vc_rectificado, vc_plan, vc_version, vc_det_estado, vc_apellido,
              vc_nombres, vc_concepto, vc_descripcion, vc_acta_rect, vc_promocional, vc_nro_documento
       WITH RESUME;
    
     END FOREACH
   END IF
   --  Si esta abierta recupero del temporal
   ELSE

     LET vc_rectificado = 'N';

     FOREACH 
       EXECUTE PROCEDURE sp820_alumnos_com(vc_comision, 'MT') 
         INTO l_unidad_academica, vc_det_carr, vc_legajo, l_comision, vc_plan, vc_version, 
              vc_fecha, vc_cond_regul, vc_resultado, vc_nota, l_pct_asistencia,
              l_acta_promocion, vc_folio, vc_renglon, l_acta_regular, l_folio_regular,
              l_renglon_regular, vc_promocional, l_controlado, vc_apellido, vc_nombres, l_agregado, l_tiene_nota, vcArchivoFoto, vc_nro_documento 

       LET vc_folio = nvl(vc_folio,l_folio_regular);
       LET vc_renglon = nvl(vc_renglon,l_renglon_regular);

       LET vc_acta_rect = NULL;

     SELECT descripcion
       INTO vc_descripcion
       FROM sga_det_escala
      WHERE sga_det_escala.escala_notas = vc_escala_not
        AND sga_det_escala.nota         = vc_nota;

     
      RETURN vc_unidad_acad, vc_acta, vc_tipo, vc_comision, vc_fecha_gen,
             vc_fecha_cier, vc_acta_ref, vc_reng_folio, vc_libro, vc_escala_not,
             vc_carrera, vc_observacion, vc_estado, vc_materia, vc_anio_acade,
             vc_per_lectiv, vc_nombre_com, vc_nombre_mat, vc_det_carr, vc_legajo, 
             vc_folio, vc_renglon, vc_cond_regul, vc_fecha, vc_resultado, 
             vc_nota, vc_rectificado, vc_plan, vc_version, vc_det_estado, vc_apellido,
             vc_nombres, vc_concepto, vc_descripcion, vc_acta_rect, vc_promocional, vc_nro_documento
             WITH RESUME;

    END FOREACH;
  END IF
END;
END PROCEDURE; 
-- ***************************Stored Procedure sp820_detalle_acta_pr *******************************


--******************************************************************************
-- execute procedure sp820_detalle_acta_pr ('FCJS','2145/15')

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_detalle_acta_pr 
-- *****************************************************************************
revoke execute on "dba".sp820_detalle_acta_pr from public;
grant execute on "dba".sp820_detalle_acta_pr to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_detalle_acta_pr to internet; -- Rol de usuario de Internet
