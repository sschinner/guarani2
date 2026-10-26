drop PROCEDURE "dba".sp820_histacademic_sinversion;
CREATE PROCEDURE "dba".sp820_histacademic_sinversion( pUnidadAcademica LIKE sga_alumnos.unidad_academica, pCarrera LIKE sga_alumnos.carrera, pLegajo LIKE sga_alumnos.legajo )
       RETURNING varchar(5),     -- materia
                 varchar(100),   -- nombre de la materia
                 date,           -- fecha
                 varchar(15),    -- resultado
                 varchar(5),     -- nota
                 varchar(255),    -- forma de aprobacion
                 char(1),        -- tipo de acta
                 varchar(10),    -- acta
                 varchar(10),    -- acta promocion
                 varchar(15),    -- nro resolucion
                 varchar(5),     -- plan
                 varchar(5),     -- version
                 varchar(20),    -- Nombre Carrera Reducido
                 varchar(30),    -- Nombre materia Reducido
                 integer,    -- Escala de Notas
                 integer,    -- Equivalencia
	varchar (15), -- Descripcion Nota
	varchar (15); -- Concepto Nota


-- U820 ***************************************************************
-- Variables auxiliares personalizadas
-- U820 ***************************************************************

DEFINE vc_DescNota LIKE sga_det_escala.descripcion;
DEFINE vc_ConceptoNota LIKE sga_det_escala.concepto;

DEFINE	vplan_alumno		LIKE sga_atrib_mat_plan.plan;
DEFINE	vplan_version_alumno	LIKE sga_atrib_mat_plan.version;
DEFINE	vcalidad	LIKE sga_alumnos.calidad;


   DEFINE vcCarNomReducido   varchar(20);
   DEFINE vcMateria          LIKE sga_materias.materia;
   DEFINE vcNombreMateria    LIKE sga_materias.nombre;
   DEFINE vcNombreMatRed    LIKE sga_materias.nombre_reducido;
   DEFINE dFecha             LIKE sga_detalle_acta.fecha_de_examen;
   DEFINE cResultado         varchar(15);
   DEFINE vcNota             LIKE sga_detalle_acta.nota;
   DEFINE iEscalaNota      integer;
   DEFINE cFormaAprob        varchar(255);
   DEFINE cTipoActa          LIKE sga_actas_examen.tipo_acta;
   DEFINE vcActa             LIKE sga_actas_examen.acta;
   DEFINE vcActaProm         LIKE sga_actas_promo.acta;
   DEFINE vcNroResolucion    LIKE sga_equiv_operac.nro_resolucion;
   DEFINE vcPlan             LIKE sga_atrib_mat_plan.plan;
   DEFINE vcVersion          LIKE sga_atrib_mat_plan.version;
   DEFINE iEquivalencia             LIKE sga_equiv_otorgada.equivalencia;


/* Recupera la Historia Academica de un alumno */
BEGIN

   -- inicializo valores default
   LET vcMateria        = NULL;
   LET vcNombreMateria  = NULL;
   LET vcNombreMatRed  = NULL;
   LET dFecha           = NULL;
   LET cResultado       = NULL;
   LET vcNota           = NULL;
   LET cFormaAprob      = NULL;
   LET cTipoActa        = NULL;
   LET vcActa           = NULL;
   LET vcActaProm       = NULL;
   LET vcNroResolucion  = NULL;
   LET vcPlan           = NULL;
   LET vcVersion        = NULL;
   LET iEscalaNota        = NULL;
   LET iEquivalencia        = NULL;
   LET vc_DescNota = NULL;

   LET vc_ConceptoNota = NULL;

SELECT   nombre_reducido  INTO vcCarNomReducido
FROM   sga_carreras
  WHERE unidad_academica 	= pUnidadAcademica
   AND carrera		= pCarrera;

select plan, calidad into vplan_alumno, vcalidad
from sga_alumnos
where carrera = pCarrera
	and legajo = pLegajo;
BEGIN
     on exception in (-206)
       -- Tabla no existe continuo el proceso	
      end exception with resume;
      DROP TABLE aux_acad;
END;


select * 
from vw820_hist_academ where legajo = plegajo
into temp aux_acad with no log;

   FOREACH
    SELECT aux_acad.materia,
           sga_atrib_mat_plan.nombre_materia,
           sga_atrib_mat_plan.nombre_reducido,
           aux_acad.fecha,
           DECODE(aux_acad.resultado,'A', 'Aprobado' , 'R',  'Reprobado', 'P', 'Promocionado'),
           aux_acad.escala_notas,
           aux_acad.nota,
           aux_acad.forma_aprobacion,
           aux_acad.tipo_acta,
           aux_acad.acta_examen_orig,
           aux_acad.acta_promo_orig,
           aux_acad.nro_resolucion,
           aux_acad.equivalencia,
           aux_acad.plan,
           aux_acad.version,
	aux_acad.descripcion,
	aux_acad.concepto
      INTO vcMateria,
           vcNombreMateria,
           vcNombreMatRed,
           dFecha,
           cResultado,
           iEscalaNota,
           vcNota,
           cFormaAprob,
           cTipoActa,
           vcActa,
           vcActaProm,
           vcNroResolucion,
           iEquivalencia,
           vcPlan,
           vcVersion,
	vc_descNota,
	vc_conceptoNota
           
      FROM aux_acad,
           sga_atrib_mat_plan
     WHERE aux_acad.unidad_academica 	= pUnidadAcademica
       AND aux_acad.carrera		= pCarrera
       AND aux_acad.legajo 		= pLegajo
       AND aux_acad.unidad_academica	= sga_atrib_mat_plan.unidad_academica
       AND aux_acad.carrera 		= sga_atrib_mat_plan.carrera
       AND aux_acad.plan		= sga_atrib_mat_plan.plan
       AND aux_acad.version		= sga_atrib_mat_plan.version
       AND aux_acad.materia 		= sga_atrib_mat_plan.materia

-- Solo las materias rendidas en el plan del alumno.
  AND (aux_acad.plan = vplan_alumno)


     ORDER BY aux_acad.fecha, 
              sga_atrib_mat_plan.nombre_reducido ASC

      -- No devuelvo las materias que esten homologadas, ya que estan no deben mostrarse.	
      IF TRIM(cFormaAprob) <> 'Homologada'  THEN

         -- devuelvo los valores
         RETURN vcMateria, vcNombreMateria, dFecha,cResultado, vcNota, cFormaAprob,
             cTipoActa, vcActa, vcActaProm, vcNroResolucion, vcPlan, vcVersion, vcCarNomReducido, vcNombreMatRed, iEscalaNota, iEquivalencia, vc_DescNota, vc_ConceptoNota WITH RESUME;


      END IF;

   END FOREACH ;

END;

 BEGIN
     on exception in (-206)
       -- Tabla no existe continuo el proceso	
      end exception with resume;
      DROP TABLE aux_acad;
 END;

END PROCEDURE
                                                               
