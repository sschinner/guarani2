CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_detalle_acta_cu') THEN
		DROP PROCEDURE sp_detalle_acta_cu;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.03.0
-- Ultima version modificacion: 
--
-- Procedure: sp_detalle_acta_cu
--
-- Lista el detalle de un acta de cursada, se utiliza en Guarani3w
-- *******************************************************************************
-- DROP PROCEDURE sp_detalle_acta_cu;

CREATE PROCEDURE "dba".sp_detalle_acta_cu(
  pUA LIKE sga_unidades_acad.unidad_academica, 
  pActa LIKE sga_actas_cursado.acta)
RETURNING VARCHAR(5),   --  0 sga_actas_cursado.unidad_academica
          INTEGER,      --  1 sga_actas_cursado.acta
          VARCHAR(5),   --  2 sga_actas_cursado.carrera
          INTEGER,      --  3 sga_actas_cursado.comision
          VARCHAR(15),  --  4 sga_comisiones.nombre
          VARCHAR(255), --  5 sga_comisiones.materia
          VARCHAR(255), --  6 sga_materias.nombre
          DATE,         --  7 sga_actas_cursado.fecha_generacion
          DATE,         --  8 sga_actas_cursado.fecha_cierre
          INTEGER,      --  9 sga_actas_cursado.version
          INTEGER,      -- 10 sga_actas_cursado.version_impresa
          INTEGER,      -- 11 sga_actas_cursado.nro_ultima_copia
          INTEGER,      -- 12 sga_actas_cursado.renglones_folio
          VARCHAR(15),  -- 13 sga_actas_cursado.libro
          VARCHAR(60),  -- 14 sga_libros_actacur.nombre
          INTEGER,      -- 15 sga_actas_cursado.escala_notas
          VARCHAR(255), -- 16 sga_actas_cursado.observaciones
          CHAR(1),      -- 17 sga_actas_cursado.estado
          INTEGER,      -- 18 sga_comisiones.anio_academico
          VARCHAR(20),  -- 19 sga_comisiones.periodo_lectivo
          CHAR(1),      -- 20 sga_actas_cursado.estado
          VARCHAR(5),   -- 21 sga_det_acta_curs.carrera
          VARCHAR(15),  -- 22 sga_det_acta_curs.legajo
          INTEGER,      -- 23 sga_det_acta_curs.folio
          INTEGER,      -- 24 sga_det_acta_curs.renglon
          VARCHAR(40),  -- 25 sga_cond_regular.descripcion
          DATE,         -- 26 sga_det_acta_curs.fecha_regularidad
          CHAR(1),      -- 27 sga_det_acta_curs.resultado
          VARCHAR(5),   -- 28 sga_det_acta_curs.nota
          CHAR(1),      -- 29 sga_det_acta_curs.rectificado
          VARCHAR(5),   -- 30 sga_det_acta_curs.plan
          VARCHAR(5),   -- 31 sga_det_acta_curs.version
          CHAR(1),      -- 32 sga_det_acta_curs.estado
          VARCHAR(30),  -- 33 sga_personas.apellido
          VARCHAR(30),  -- 34 sga_personas.nombres
          VARCHAR(15),  -- 35 sga_det_escala.concepto
          VARCHAR(15);  -- 36 sga_det_escala.descripcion

DEFINE vc_unidad_acad LIKE sga_actas_cursado.unidad_academica;
DEFINE vc_acta        LIKE sga_actas_cursado.acta;
DEFINE vc_carrera_ac  LIKE sga_actas_cursado.carrera;
DEFINE vc_comision    LIKE sga_actas_cursado.comision;
DEFINE vc_nom_comisio LIKE sga_comisiones.nombre;
DEFINE vc_materia     LIKE sga_comisiones.materia;
DEFINE vc_nom_materia LIKE sga_materias.nombre;
DEFINE vc_fec_generac LIKE sga_actas_cursado.fecha_generacion;
DEFINE vc_fec_cierre  LIKE sga_actas_cursado.fecha_cierre;
DEFINE vc_version     LIKE sga_actas_cursado.version;
DEFINE vc_version_imp LIKE sga_actas_cursado.version_impresa;
DEFINE vc_ultima_copi LIKE sga_actas_cursado.nro_ultima_copia;
DEFINE vc_renglones   LIKE sga_actas_cursado.renglones_folio;
DEFINE vc_libro       LIKE sga_actas_cursado.libro;
DEFINE vc_nombre_libr LIKE sga_libros_actacur.nombre;
DEFINE vc_escala_nota LIKE sga_actas_cursado.escala_notas;
DEFINE vc_observacion LIKE sga_actas_cursado.observaciones;
DEFINE vc_estado_ac   LIKE sga_actas_cursado.estado;
DEFINE vc_anio_academ LIKE sga_comisiones.anio_academico;
DEFINE vc_per_lectivo LIKE sga_comisiones.periodo_lectivo;
DEFINE vc_estado_det  LIKE sga_actas_cursado.estado;
DEFINE vc_carrera_det LIKE sga_det_acta_curs.carrera;
DEFINE vc_legajo      LIKE sga_det_acta_curs.legajo;
DEFINE vc_folio       LIKE sga_det_acta_curs.folio;
DEFINE vc_renglon     LIKE sga_det_acta_curs.renglon;
DEFINE vc_cond_regul  LIKE sga_cond_regular.descripcion;
DEFINE vc_regularidad LIKE sga_det_acta_curs.fecha_regularidad;
DEFINE vc_resultado   LIKE sga_det_acta_curs.resultado;
DEFINE vc_nota        LIKE sga_det_acta_curs.nota;
DEFINE vc_rectificado LIKE sga_det_acta_curs.rectificado;
DEFINE vc_plan        LIKE sga_det_acta_curs.plan;
DEFINE vc_version_det LIKE sga_det_acta_curs.version;
DEFINE vc_estado_cur  LIKE sga_det_acta_curs.estado;
DEFINE vc_apellido    LIKE sga_personas.apellido;
DEFINE vc_nombre      LIKE sga_personas.nombres;
DEFINE vc_concep_nota LIKE sga_det_escala.concepto;
DEFINE vc_descri_nota LIKE sga_det_escala.descripcion;

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
  
  LET vc_escala_nota = NULL;
  LET vc_rectificado = NULL;
  LET vc_estado_cur  = NULL;
  LET vc_concep_nota = NULL;
  LET vc_descri_nota = NULL;
  LET vc_estado_det  = NULL;

  SELECT sga_actas_cursado.unidad_academica,   
         sga_actas_cursado.acta,   
         sga_actas_cursado.carrera,
         sga_actas_cursado.comision,   
         sga_comisiones.nombre, 
         sga_comisiones.materia,   
         nvl(sga_atrib_mat_plan.nombre_materia, sga_materias.nombre),   
         sga_actas_cursado.fecha_generacion,   
         sga_actas_cursado.fecha_cierre,   
         sga_actas_cursado.version,   
         sga_actas_cursado.version_impresa,   
         sga_actas_cursado.nro_ultima_copia,   
         sga_actas_cursado.renglones_folio,   
         sga_actas_cursado.libro,   
         sga_libros_actacur.nombre,   
         sga_actas_cursado.escala_notas,   
         sga_actas_cursado.observaciones,   
         sga_actas_cursado.estado,
         sga_comisiones.anio_academico,
         sga_comisiones.periodo_lectivo

    INTO vc_unidad_acad, vc_acta, vc_carrera_ac, vc_comision, vc_nom_comisio,  
         vc_materia, vc_nom_materia, vc_fec_generac, vc_fec_cierre, vc_version,     
         vc_version_imp, vc_ultima_copi, vc_renglones, vc_libro, vc_nombre_libr, vc_escala_nota,  
         vc_observacion, vc_estado_ac , vc_anio_academ, vc_per_lectivo 
    FROM sga_actas_cursado,
   OUTER sga_libros_actacur,
         sga_comisiones,
         sga_materias,
	outer(sga_planes, sga_atrib_mat_plan)

   WHERE sga_actas_cursado.unidad_academica  = pUA
     AND sga_actas_cursado.acta              = pActa

     AND sga_actas_cursado.comision          = sga_comisiones.comision

     AND sga_materias.unidad_academica       = sga_comisiones.unidad_academica
     AND sga_materias.materia                = sga_comisiones.materia

     AND sga_libros_actacur.unidad_academica = sga_actas_cursado.unidad_academica
     AND sga_libros_actacur.libro            = sga_actas_cursado.libro

	AND dba.sga_planes.unidad_academica = dba.sga_comisiones.unidad_academica
	AND dba.sga_planes.carrera = dba.sga_comisiones.carrera
	AND dba.sga_planes.plan =dba.sga_comisiones.plan
	AND dba.sga_atrib_mat_plan.unidad_academica =dba.sga_planes.unidad_academica
	AND dba.sga_atrib_mat_plan.carrera =dba.sga_planes.carrera
	AND dba.sga_atrib_mat_plan.plan =dba.sga_planes.plan
	AND dba.sga_atrib_mat_plan.version =dba.sga_planes.version_actual
	AND dba.sga_atrib_mat_plan.materia =dba.sga_comisiones.materia;

  IF vc_estado_ac = 'C' THEN 

    FOREACH 
      SELECT sga_det_acta_curs.carrera,   
             sga_det_acta_curs.legajo,   
             sga_det_acta_curs.folio,   
             sga_det_acta_curs.renglon,   
             sga_cond_regular.descripcion, 
             sga_det_acta_curs.fecha_regularidad,   
             sga_det_acta_curs.resultado,   
             sga_det_acta_curs.nota,   
             sga_det_acta_curs.rectificado,   
             sga_det_acta_curs.plan,   
             sga_det_acta_curs.version,   
             sga_det_acta_curs.estado,
             sga_personas.apellido,
             sga_personas.nombres,
             sga_det_escala.concepto,
             sga_det_escala.descripcion
            
        INTO vc_carrera_det, vc_legajo, vc_folio, vc_renglon, vc_cond_regul, vc_regularidad,  
             vc_resultado, vc_nota, vc_rectificado, vc_plan, vc_version_det, vc_estado_cur, 
             vc_apellido, vc_nombre, vc_concep_nota, vc_descri_nota 
            
        FROM sga_det_acta_curs,
             sga_alumnos,
             sga_personas,
             OUTER sga_det_escala, OUTER sga_cond_regular
             
       WHERE sga_det_acta_curs.unidad_academica = pUA
         AND sga_det_acta_curs.acta             = pActa
                                           
         AND sga_alumnos.unidad_academica       = sga_det_acta_curs.unidad_academica
         AND sga_alumnos.carrera                = sga_det_acta_curs.carrera
         AND sga_alumnos.legajo                 = sga_det_acta_curs.legajo
                                            
         AND sga_personas.unidad_academica      = sga_alumnos.unidad_academica
         AND sga_personas.nro_inscripcion       = sga_alumnos.nro_inscripcion
                                            
         AND sga_det_escala.escala_notas        = vc_escala_nota
         AND sga_det_escala.nota                = sga_det_acta_curs.nota

         AND sga_cond_regular.cond_regularidad  = sga_det_acta_curs.cond_regularidad

      RETURN vc_unidad_acad, vc_acta, vc_carrera_ac, vc_comision, vc_nom_comisio,  
             vc_materia, vc_nom_materia, vc_fec_generac, vc_fec_cierre, vc_version,     
             vc_version_imp, vc_ultima_copi, vc_renglones, vc_libro, vc_nombre_libr, vc_escala_nota,  
             vc_observacion, vc_estado_ac, vc_anio_academ, vc_per_lectivo, vc_estado_det, 
             vc_carrera_det, vc_legajo, vc_folio, vc_renglon, vc_cond_regul, vc_regularidad,  
             vc_resultado, vc_nota, vc_rectificado, vc_plan, vc_version_det, vc_estado_cur, 
             vc_apellido, vc_nombre, vc_concep_nota, vc_descri_nota 
             WITH RESUME;
    END FOREACH;
  ELSE

    FOREACH 
      EXECUTE PROCEDURE sp_alumnos_com(vc_comision, 'MT') 
                   INTO l_unidad_academica, vc_carrera_det, vc_legajo, l_comision, vc_plan, vc_version_det, 
                        vc_regularidad, vc_cond_regul, vc_resultado, vc_nota, l_pct_asistencia,
                        l_acta_promocion, vc_folio, vc_renglon, l_acta_regular, l_folio_regular,
                        l_renglon_regular, l_promocional, l_controlado, vc_apellido, vc_nombre, l_agregado, l_tiene_nota, vcArchivoFoto 

      SELECT descripcion 
        INTO vc_cond_regul
        FROM sga_cond_regular
       WHERE sga_cond_regular.cond_regularidad = vc_cond_regul;

     SELECT descripcion
       INTO vc_descri_nota
       FROM sga_det_escala
      WHERE sga_det_escala.escala_notas = vc_escala_nota
        AND sga_det_escala.nota         = vc_nota;

      RETURN vc_unidad_acad, vc_acta, vc_carrera_ac, vc_comision, vc_nom_comisio,  
             vc_materia, vc_nom_materia, vc_fec_generac, vc_fec_cierre, vc_version,     
             vc_version_imp, vc_ultima_copi, vc_renglones, vc_libro, vc_nombre_libr, vc_escala_nota,  
             vc_observacion, vc_estado_ac, vc_anio_academ, vc_per_lectivo, vc_estado_det, 
             vc_carrera_det, vc_legajo, l_folio_regular,l_renglon_regular, vc_cond_regul, vc_regularidad,  
             vc_resultado, vc_nota, vc_rectificado, vc_plan, vc_version_det, vc_estado_cur, 
             vc_apellido, vc_nombre, vc_concep_nota, vc_descri_nota 
             WITH RESUME;
    END FOREACH;

  END IF

END;
END PROCEDURE; 
-- **************************** Stored Procedure sp_detalle_acta_cu ***************************************************


-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_detalle_acta_cu 
-- *****************************************************************************
revoke execute on "dba".sp_detalle_acta_cu from public;
grant execute on "dba".sp_detalle_acta_cu to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_detalle_acta_cu to internet; -- Rol de usuario de Internet