CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_histacademic') THEN
		DROP PROCEDURE sp820_histacademic;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SP: sp820_histAcademic
-- Version de modificacion: 2.0.0
--
-- Nota: NO devuelve las materias que fueron homoladas.
--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE PROCEDURE "dba".sp820_histacademic( pUnidadAcademica LIKE sga_alumnos.unidad_academica, pCarrera LIKE sga_alumnos.carrera, pLegajo LIKE sga_alumnos.legajo )
       RETURNING varchar(5),     -- materia
                 varchar(255),   -- nombre de la materia
                 date,           -- fecha
                 varchar(15),    -- resultado
                 varchar(5),     -- nota
                 varchar(255),    -- forma de aprobacion
                 char(1),        -- tipo de acta
                 varchar(15),    -- acta
                 varchar(15),    -- acta promocion
                 varchar(15),    -- nro resolucion
                 varchar(5),     -- plan
                 varchar(5),     -- version
                 varchar(20),    -- Nombre Carrera Reducido
                 varchar(30),    -- Nombre materia Reducido
                 integer,    	 -- Escala de Notas
                 integer,    	 -- Equivalencia
	  	 varchar (15),   -- Descripcion Nota
		 varchar (15);   -- Concepto Nota


-- U820 ******************************************************************************
-- Variables auxiliares personalizadas: se devuelve descripción de la nota y concepto
-- U820 ******************************************************************************

DEFINE vc_DescNota LIKE sga_det_escala.descripcion;
DEFINE vc_ConceptoNota LIKE sga_det_escala.concepto;

DEFINE	vplan_alumno		LIKE sga_atrib_mat_plan.plan;
DEFINE	vplan_version_act	LIKE sga_atrib_mat_plan.version;

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
DEFINE vcActa        varchar(15); --      LIKE sga_actas_examen.acta;
DEFINE vcActaProm      varchar(15); --    LIKE sga_actas_promo.acta;
DEFINE vcNroResolucion    LIKE sga_equiv_operac.nro_resolucion;
DEFINE vcPlan             LIKE sga_atrib_mat_plan.plan;
DEFINE vcVersion          LIKE sga_atrib_mat_plan.version;
DEFINE iEquivalencia             LIKE sga_equiv_otorgada.equivalencia;

-- DEFINE DEL SP DE HISTORIA ACADEMICA

DEFINE vw_unidad_academica varchar(5);
DEFINE vw_carrera varchar(5);
DEFINE vw_legajo varchar(15);
DEFINE vw_materia varchar(5);
DEFINE vw_fecha date;
DEFINE vw_resultado varchar(15);
DEFINE vw_concepto_nota varchar(15);
DEFINE vw_escala_notas integer;
DEFINE vw_nota varchar(5);
DEFINE vw_descripcion_nota varchar(15);
DEFINE vw_forma_aprobacion varchar(255);
DEFINE vw_tipo_acta char(1);
DEFINE vw_acta varchar(10);
DEFINE vw_acta_examen_orig varchar(10);
DEFINE vw_acta_promocion varchar(10);
DEFINE vw_acta_promo_orig varchar(10);
DEFINE vw_equivalencia integer;
DEFINE vw_resolucion varchar(15);
DEFINE vw_plan varchar(5);
DEFINE vw_version varchar(5);
DEFINE vw_nua varchar(15);


-- Recupera la Historia Academica de un alumno
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

LET vw_unidad_academica = NULL;
LET vw_carrera = NULL;
LET vw_legajo = NULL;
LET vw_materia = NULL;
LET vw_fecha = NULL;
LET vw_resultado = NULL;
LET vw_concepto_nota = NULL;
LET vw_escala_notas = NULL;
LET vw_nota = NULL;
LET vw_descripcion_nota = NULL;
LET vw_forma_aprobacion = NULL;
LET vw_tipo_acta = NULL;
LET vw_acta = NULL;
LET vw_acta_examen_orig = NULL;
LET vw_acta_promocion = NULL;
LET vw_acta_promo_orig = NULL;
LET vw_equivalencia = NULL;
LET vw_resolucion = NULL;
LET vw_plan = NULL;
LET vw_version = NULL;
LET vw_nua = NULL;
LET vplan_version_act = NULL;

select plan into vplan_alumno
from sga_alumnos
where carrera = pCarrera
	and legajo = pLegajo;

select version_actual into vplan_version_act
from sga_planes
where carrera = pCarrera
	and plan = vplan_alumno;

SELECT   nombre_reducido  INTO vcCarNomReducido
FROM   sga_carreras
  WHERE unidad_academica 	= pUnidadAcademica
   AND carrera		= pCarrera;


BEGIN
     on exception in (-206)
       -- Tabla no existe continuo el proceso	
      end exception with resume;
      DROP TABLE aux_acad;
END;


SELECT * 
FROM vw820_hist_academ 
WHERE legajo = plegajo
AND carrera = pcarrera
INTO temp aux_acad WITH no log;

   FOREACH
    SELECT aux_acad.materia,
           --sga_atrib_mat_plan.nombre_materia,
           --sga_atrib_mat_plan.nombre_reducido,
(select nombre_materia from sga_atrib_mat_plan where carrera = pcarrera and plan = vplan_alumno and version = vplan_version_act and materia = aux_acad.materia) as nombre_materia,
(select nombre_reducido from sga_atrib_mat_plan where carrera = pcarrera and plan = vplan_alumno and version = vplan_version_act and materia = aux_acad.materia) as nombre_reducido,
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

-- Solo las materias del Ultimo Plan al que pertenece el alumno.
	AND aux_acad.materia In (select materia from sga_atrib_mat_plan where carrera = pcarrera and plan = vplan_alumno and version = vplan_version_act)

     ORDER BY aux_acad.fecha, 
              sga_atrib_mat_plan.nombre_reducido ASC

      -- No devuelvo las materias que esten homologadas, ya que estas no deben mostrarse.	
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

END PROCEDURE;
-- *************************** FIN PROCESO sp820_histAcademic *************************** 
revoke execute on "dba".sp820_histacademic from public;

grant execute on "dba".sp820_histacademic to guarani; -- Rol de usuarios de Gestión
grant execute on "dba".sp820_histacademic to internet; -- Usuario de internet


