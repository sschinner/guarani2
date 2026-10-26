CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_actprovcurs') THEN
		DROP PROCEDURE sp_actprovcurs;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.11.0
-- Procedure sp_actProvCurs
-- Ultima version de modificacion: 2.03.0
--
-- Muestra el resultado de las actas de cursado que todavia no estan cerradas (Aprobadas o reprobadas).
-- SI muestra las regularidades parciales que ya fueron aprobadas (por promocion,
-- examen, equivalencia, etc..)
-- *****************************************************************************

CREATE PROCEDURE "dba".sp_actProvCurs ( pUnidadAcademica  LIKE sga_personas.unidad_academica,
                                 pNroInscripcion   LIKE sga_personas.nro_inscripcion )

       RETURNING VARCHAR(5),    -- unidad academica            0
                 VARCHAR(5),    -- carrera                     1
                 VARCHAR(15),   -- legajo                      2
                 INTEGER,       -- acta	de Regulares           3
                 DATE,          -- fecha de regularidad        4
                 CHAR(1),       -- resultado                   5
                 VARCHAR(20),   -- resultado Descripcion       6
                 VARCHAR(5),    -- nota                        7
                 VARCHAR(5),    -- materia                     8
                 VARCHAR(30),   -- materia nombre reducido     9
                 VARCHAR(30),   -- carrera nombre reducido    10
                 VARCHAR(15);   -- nombre comision            11

/* Muestra todas las notas (no los ausentes) que una persona tenga en actas de cursado que no fueron cerradas. Es decir, de aquellas que tienen Cierres Parciales  */

-- vars para el manejo de excepciones
DEFINE sql_err               INTEGER;
DEFINE isam_err              INTEGER;
DEFINE error_info            VARCHAR(76);
DEFINE v_user_error          VARCHAR(10);
       
DEFINE vcUnidadAcademica     LIKE sga_insc_cursadas.unidad_academica;
DEFINE vcCarrera             LIKE sga_insc_cursadas.carrera;
DEFINE vcLegajo              LIKE sga_insc_cursadas.legajo;
DEFINE vcActa                LIKE sga_det_acta_curs.acta;
DEFINE dFechaRegular         DATE;
DEFINE vcResultadoDesc       VARCHAR(20);
DEFINE vcResultado           LIKE sga_detalle_acta.resultado;
DEFINE vcNota                LIKE sga_detalle_acta.nota;
DEFINE vcMateria             LIKE sga_materias.materia;
DEFINE vcMateriaNombre       LIKE sga_materias.nombre;
DEFINE vcCarreraNombre       LIKE sga_carreras.nombre;
DEFINE vcComision            LIKE sga_comisiones.nombre;

-- blk de excepciones
ON EXCEPTION SET sql_err, isam_err, error_info
   RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;

BEGIN
   
   LET vcUnidadAcademica = NULL ;
   LET vcCarrera         = NULL ;
   LET vcLegajo          = NULL ;
   LET vcActa            = NULL ;
   LET dFechaRegular     = NULL ;
   LET vcResultado       = NULL ;
   LET vcResultadoDesc   = NULL ;
   LET vcNota            = NULL ;
   LET vcMateria         = NULL ;
   LET vcMateriaNombre   = NULL ;
   LET vcCarreraNombre   = NULL ;
   
   FOREACH
    SELECT {+ ordered} 
           vw_reg_parciales.unidad_academica,
           vw_reg_parciales.carrera,
           vw_reg_parciales.legajo,
           vw_reg_parciales.acta_regular,
           vw_reg_parciales.fecha_regularidad,
           vw_reg_parciales.resultado,
-- U820 para traer los sin resultados
-- *******************************************************************************
--  DECODE(vw_reg_parciales.resultado, 'A', 'Aprobado', 'R', 'Reprobado','P','Promocionó' )
           CASE 
	WHEN (sga_comisiones.materia = '233') THEN 'Cons. en Ext. FCJS'
	WHEN (sga_comisiones.materia = '234') THEN 'Cons. en Ext. FCJS'
	WHEN (vw_reg_parciales.resultado is null) THEN 'Cursando'
	ELSE
		DECODE(vw_reg_parciales.resultado, 'A', 'Aprobado', 'R', 'Reprobado','P','Promocionó','U','Libre' )
	END,
-- *******************************************************************************
           vw_reg_parciales.nota,
           vw_reg_parciales.materia,
           sga_materias.nombre_reducido,
           sga_carreras.nombre_reducido,
           sga_comisiones.nombre
      INTO vcUnidadAcademica,
           vcCarrera,
           vcLegajo,
           vcActa,
           dFechaRegular,
           vcResultado,
           vcResultadoDesc,
           vcNota,
           vcMateria,
           vcMateriaNombre,
           vcCarreraNombre,
           vcComision
      FROM sga_alumnos,
           sga_carreras,
           vw_reg_parciales,
           sga_materias,
           sga_comisiones
     WHERE sga_alumnos.unidad_academica = pUnidadAcademica 
       AND sga_alumnos.nro_inscripcion  = pNroInscripcion
       AND sga_alumnos.calidad          = 'A'
       
       AND sga_carreras.unidad_academica = sga_alumnos.unidad_academica
       AND sga_carreras.carrera          = sga_alumnos.carrera
       
       AND vw_reg_parciales.unidad_academica  = sga_alumnos.unidad_academica 
       AND vw_reg_parciales.carrera           = sga_alumnos.carrera
       AND vw_reg_parciales.legajo            = sga_alumnos.legajo
       
       AND sga_materias.unidad_academica = vw_reg_parciales.unidad_academica
       AND sga_materias.materia          = vw_reg_parciales.materia
       
       AND sga_comisiones.comision = vw_reg_parciales.comision
      -- AND vw_reg_parciales.resultado IS NOT NULL

     ORDER BY vw_reg_parciales.fecha_regularidad
      
      -- si no encontro nada, devuelve vacios
      RETURN vcUnidadAcademica,
             vcCarrera,
             vcLegajo,
             vcActa,
             dFechaRegular,
             vcResultado,
             vcResultadoDesc,
             vcNota,
             vcMateria,
             vcMateriaNombre,
             vcCarreraNombre,
             vcComision  WITH RESUME;
      
   END FOREACH;
   
END;

END PROCEDURE;
-- *************** Fin del procedimiento "dba".sp_actProvCurs ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_actProvCurs 
-- *****************************************************************************
revoke execute on "dba".sp_actProvCurs from public;
grant execute on "dba".sp_actProvCurs to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_actProvCurs to internet; -- Rol de usuario de Internet