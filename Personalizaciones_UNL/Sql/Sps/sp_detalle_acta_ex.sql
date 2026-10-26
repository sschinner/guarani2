-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.03.0
-- Ultima version modificacion: 
--
-- Procedure: sp_detalle_acta_ex
--
-- Lista el detalle de un acta de examen, Se utiliza en Guarani3w
-- *******************************************************************************
DROP PROCEDURE sp_detalle_acta_ex;
CREATE PROCEDURE sp_detalle_acta_ex(pUA       LIKE sga_unidades_acad.unidad_academica,
                                    pTipoActa LIKE sga_actas_examen.tipo_acta,
                                    pActa     LIKE sga_actas_examen.acta)

RETURNING VARCHAR(5),    -- 0  vc_unidad_acad
          CHAR(1),       -- 1  vc_tipo_acta
          VARCHAR(10),   -- 2  vc_acta
          VARCHAR(15),   -- 3  vc_legajo
          VARCHAR(5),    -- 4  vc_carrera
          INTEGER,       -- 5  vc_folio
          INTEGER,       -- 6  vc_renglon
          -- CHAR(1),       -- 7  vc_tipo_insc
	  VARCHAR(2),       -- 7  vc_tipo_insc. Cond. Regular
          DATE,          -- 8  vc_fecha_exa
          VARCHAR(2),    -- 9  vc_resultado
          VARCHAR(5),    -- 10 vc_nota
          CHAR(1),       -- 11 vc_resultado2
          VARCHAR(5),    -- 12 vc_nota2
          CHAR(1),       -- 13 vc_estado_exa
          VARCHAR(15),   -- 14 vc_nota_desc
          VARCHAR(15),   -- 15 vc_concepto
          VARCHAR(30),   -- 16 vc_apellido
          VARCHAR(30),   -- 17 vc_nombres
          VARCHAR(3),    -- 18 vc_tipo_doc
          VARCHAR(15),   -- 19 vc_nro_doc
          VARCHAR(5),    -- 20 vc_materia
          INTEGER,       -- 21 vc_anio_acad
          VARCHAR(20),   -- 22 vc_turno_exa
          VARCHAR(15),   -- 23 vc_mesa_exa
          INTEGER,       -- 24 vc_llamado
          DATE,          -- 25 vc_fecha
          VARCHAR(15),   -- 26 vc_catedra
          VARCHAR(255),  -- 27 vc_nom_mat
          CHAR(1),       -- 28 vc_rectificado
          CHAR(1),       -- 29 vc_tipo_acta_rect
          VARCHAR(10);   -- 30 vc_acta_rect


DEFINE vc_unidad_acad    LIKE sga_detalle_acta.unidad_academica;
DEFINE vc_tipo_acta      LIKE sga_detalle_acta.tipo_acta;
DEFINE vc_acta           LIKE sga_detalle_acta.acta;
DEFINE vc_legajo         LIKE sga_detalle_acta.legajo;
DEFINE vc_carrera        LIKE sga_detalle_acta.carrera;
DEFINE vc_folio          LIKE sga_detalle_acta.folio;
DEFINE vc_renglon        LIKE sga_detalle_acta.renglon;
--DEFINE vc_tipo_insc      LIKE sga_detalle_acta.tipo_inscripcion;
DEFINE vc_tipo_insc      VARCHAR(2);
DEFINE vc_fecha_exa      LIKE sga_detalle_acta.fecha_de_examen;
DEFINE vc_resultado      LIKE sga_detalle_acta.resultado;
DEFINE vc_nota           LIKE sga_detalle_acta.nota;
DEFINE vc_resultado2     LIKE sga_detalle_acta.resultado_2;
DEFINE vc_nota2          LIKE sga_detalle_acta.nota_2;
DEFINE vc_estado_exa     LIKE sga_detalle_acta.estado;
DEFINE vc_nota_desc      LIKE sga_det_escala.descripcion;
DEFINE vc_concepto       LIKE sga_det_escala.concepto;
DEFINE vc_apellido       LIKE sga_personas.apellido;
DEFINE vc_nombres        LIKE sga_personas.nombres;
DEFINE vc_tipo_doc       LIKE mdp_tipo_documento.desc_abreviada;
DEFINE vc_nro_doc        LIKE sga_personas.nro_documento;
DEFINE vc_materia        LIKE sga_actas_examen.materia;
DEFINE vc_anio_acad      LIKE sga_actas_examen.anio_academico;
DEFINE vc_turno_exa      LIKE sga_actas_examen.turno_examen;
DEFINE vc_mesa_exa       LIKE sga_actas_examen.mesa_examen;
DEFINE vc_llamado        LIKE sga_actas_examen.llamado;
DEFINE vc_fecha          LIKE sga_prestamos.fecha;
DEFINE vc_catedra        LIKE sga_mesas_examen.catedra;
DEFINE vc_nom_mat        LIKE sga_materias.nombre;
DEFINE vc_rectificado    LIKE sga_detalle_acta.rectificado;
DEFINE vc_tipo_acta_rect LIKE sga_detalle_acta.tipo_acta;
DEFINE vc_acta_rect      LIKE sga_detalle_acta.acta;
DEFINE vc_acta_ref       LIKE sga_detalle_acta.acta;
DEFINE vc_aux_acta       LIKE sga_detalle_acta.acta;

BEGIN

  FOREACH SELECT 
    sga_actas_examen.unidad_academica,
    sga_actas_examen.tipo_acta,
    sga_actas_examen.acta,
    sga_detalle_acta.legajo,
    sga_detalle_acta.carrera,
    sga_detalle_acta.folio,
    sga_detalle_acta.renglon,
--    sga_detalle_acta.tipo_inscripcion,
		case when sga_equiv_otorgada.alcance = 'P' then 'EP' -- Tiene una equivalencia parcial (de regularidad)
		when u820_sga_det_acta.condicion_reg = 1 then 'L'
		when u820_sga_det_acta.condicion_reg = 2 then 'L'
		when u820_sga_det_acta.condicion_reg = 3 then 'L'
		when u820_sga_det_acta.condicion_reg = 8 then 'L'
		when u820_sga_det_acta.condicion_reg = 4 then 'R'
		when u820_sga_det_acta.condicion_reg = 6 then 'R'
		when u820_sga_det_acta.condicion_reg = 9 then 'R'
		when u820_sga_det_acta.condicion_reg = 5 then 'PP' -- Tiene una promoción pendiente
		when u820_sga_det_acta.condicion_reg = 7 then 'PP'
		when u820_sga_det_acta.condicion_reg = 10  then 'TP' else '' end as condicion_reg,

    sga_detalle_acta.fecha_de_examen,
    sga_detalle_acta.resultado,
    sga_detalle_acta.nota,
    sga_detalle_acta.resultado_2,
    sga_detalle_acta.nota_2,
    sga_detalle_acta.estado estado_examen,
    sga_det_escala.descripcion,
    sga_det_escala.concepto,
    sga_personas.apellido,
    sga_personas.nombres,   
    mdp_tipo_documento.desc_abreviada,
    sga_personas.nro_documento,
    sga_actas_examen.materia,   
    sga_actas_examen.anio_academico,
    sga_actas_examen.turno_examen,   
    sga_actas_examen.mesa_examen,   
    sga_actas_examen.llamado,   
    sga_prestamos.fecha,
    sga_mesas_examen.catedra,
    nvl(sga_atrib_mat_plan.nombre_materia, sga_materias.nombre),
    sga_detalle_acta.rectificado,
    sga_actas_examen.acta_referencia

  INTO vc_unidad_acad, vc_tipo_acta, vc_acta, vc_legajo, vc_carrera, vc_folio, vc_renglon, 
       vc_tipo_insc, vc_fecha_exa, vc_resultado, vc_nota, vc_resultado2, vc_nota2, 
       vc_estado_exa, vc_nota_desc, vc_concepto, vc_apellido, vc_nombres, vc_tipo_doc, vc_nro_doc, 
       vc_materia, vc_anio_acad, vc_turno_exa, vc_mesa_exa, vc_llamado, vc_fecha, vc_catedra, 
       vc_nom_mat, vc_rectificado, vc_acta_ref

  FROM sga_detalle_acta,
       sga_actas_examen,
       sga_mesas_examen,
       sga_llamados_mesa,
       sga_prestamos,
       sga_alumnos,
       sga_personas,
       mdp_tipo_documento,
       sga_materias,
OUTER  sga_det_escala,
	outer(sga_planes, sga_atrib_mat_plan),
	outer u820_sga_det_acta,
	outer sga_equiv_otorgada
  WHERE sga_detalle_acta.unidad_academica   = pUA  
    AND sga_detalle_acta.tipo_acta          = pTipoActa  
    AND sga_detalle_acta.acta               = pActa

    AND sga_detalle_acta.unidad_academica   = sga_actas_examen.unidad_academica
    AND sga_detalle_acta.tipo_acta          = sga_actas_examen.tipo_acta
    AND sga_detalle_acta.acta               = sga_actas_examen.acta
 
    AND sga_alumnos.unidad_academica        = sga_detalle_acta.unidad_academica
    AND sga_alumnos.carrera                 = sga_detalle_acta.carrera
    AND sga_alumnos.legajo                  = sga_detalle_acta.legajo

    AND sga_personas.unidad_academica       = sga_alumnos.unidad_academica
    AND sga_personas.nro_inscripcion        = sga_alumnos.nro_inscripcion

    AND mdp_tipo_documento.tipo_documento   = sga_personas.tipo_documento

    AND sga_mesas_examen.unidad_academica   = sga_actas_examen.unidad_academica
    AND sga_mesas_examen.materia            = sga_actas_examen.materia
    AND sga_mesas_examen.anio_academico     = sga_actas_examen.anio_academico
    AND sga_mesas_examen.turno_examen       = sga_actas_examen.turno_examen
    AND sga_mesas_examen.mesa_examen        = sga_actas_examen.mesa_examen

    AND sga_llamados_mesa.unidad_academica  = sga_actas_examen.unidad_academica
    AND sga_llamados_mesa.materia           = sga_actas_examen.materia
    AND sga_llamados_mesa.anio_academico    = sga_actas_examen.anio_academico
    AND sga_llamados_mesa.turno_examen      = sga_actas_examen.turno_examen
    AND sga_llamados_mesa.mesa_examen       = sga_actas_examen.mesa_examen
    AND sga_llamados_mesa.llamado           = sga_actas_examen.llamado

    AND sga_prestamos.prestamo              = sga_llamados_mesa.prestamo

    AND sga_det_escala.escala_notas         = sga_actas_examen.escala_notas
    AND sga_det_escala.nota                 = sga_detalle_acta.nota  

    AND sga_materias.unidad_academica       = sga_actas_examen.unidad_academica
    AND sga_materias.materia                = sga_actas_examen.materia

	   AND dba.sga_planes.unidad_academica = dba.sga_mesas_examen.unidad_academica
	   AND dba.sga_planes.carrera = dba.sga_mesas_examen.carrera
	   AND dba.sga_planes.plan =dba.sga_mesas_examen.plan
	   AND dba.sga_atrib_mat_plan.unidad_academica =dba.sga_planes.unidad_academica
	   AND dba.sga_atrib_mat_plan.carrera =dba.sga_planes.carrera
	   AND dba.sga_atrib_mat_plan.plan =dba.sga_planes.plan
	   AND dba.sga_atrib_mat_plan.version =dba.sga_planes.version_actual
	   AND dba.sga_atrib_mat_plan.materia =dba.sga_mesas_examen.materia

       AND u820_sga_det_acta.unidad_academica = sga_detalle_acta.unidad_academica   
       AND u820_sga_det_acta.tipo_acta		= sga_detalle_acta.tipo_acta
       AND u820_sga_det_acta.acta		= sga_detalle_acta.acta
       AND u820_sga_det_acta.carrera		= sga_detalle_acta.carrera 
       AND u820_sga_det_acta.legajo		= sga_detalle_acta.legajo

	AND sga_equiv_otorgada.unidad_academica = sga_detalle_acta.unidad_academica  
        AND sga_equiv_otorgada.carrera = sga_detalle_acta.carrera  
        AND sga_equiv_otorgada.legajo = sga_detalle_acta.legajo  
        AND sga_equiv_otorgada.plan    = sga_detalle_acta.plan  
        AND sga_equiv_otorgada.version = sga_detalle_acta.version
        AND sga_equiv_otorgada.materia = sga_actas_examen.materia
	AND sga_equiv_otorgada.alcance = 'P'
	AND sga_equiv_otorgada.resultado = 'A'
	AND (sga_equiv_otorgada.vencimiento > today OR sga_equiv_otorgada.vencimiento is Null)
	AND sga_equiv_otorgada.estado = 'A'
	AND sga_equiv_otorgada.rectificado = 'N'

	ORDER BY sga_detalle_acta.folio ASC, sga_detalle_acta.renglon ASC	

    LET vc_tipo_acta_rect = NULL;
    LET vc_acta_rect      = NULL;

    IF vc_rectificado = 'S' THEN

       IF pTipoActa = 'N' THEN
          LET vc_aux_acta = pActa;
       ELSE
          LET vc_aux_acta = vc_acta_ref;
       END IF

       SELECT sga_actas_examen.tipo_acta, 
              sga_actas_examen.acta
         INTO vc_tipo_acta_rect, vc_acta_rect
         FROM sga_actas_examen,
              sga_detalle_acta 
        WHERE sga_actas_examen.unidad_academica = pUA
          AND sga_actas_examen.estado           = 'C'
          AND sga_actas_examen.tipo_acta        = 'R' 
          AND sga_actas_examen.acta_referencia  = vc_aux_acta

          AND sga_actas_examen.unidad_academica = sga_detalle_acta.unidad_academica
          AND sga_actas_examen.tipo_acta        = sga_detalle_acta.tipo_acta
          AND sga_actas_examen.acta             = sga_detalle_acta.acta

          AND sga_detalle_acta.carrera          = vc_carrera
          AND sga_detalle_acta.legajo           = vc_legajo

          AND sga_detalle_acta.rectificado      = 'N';

    END IF
 
    RETURN vc_unidad_acad, vc_tipo_acta, vc_acta, vc_legajo, vc_carrera, vc_folio, vc_renglon, 
           vc_tipo_insc, vc_fecha_exa, vc_resultado, vc_nota, vc_resultado2, vc_nota2, 
           vc_estado_exa, vc_nota_desc, vc_concepto, vc_apellido, vc_nombres, vc_tipo_doc, vc_nro_doc, 
           vc_materia, vc_anio_acad, vc_turno_exa, vc_mesa_exa, vc_llamado, vc_fecha, vc_catedra, vc_nom_mat,
           vc_rectificado, vc_tipo_acta_rect, vc_acta_rect
    WITH RESUME;

  END FOREACH;
END
END PROCEDURE;
-- *******************************************************************************

