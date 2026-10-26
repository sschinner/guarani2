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


-- *****************************************************************************
-- sp820_histAcademic: que trae la info de un alumno. Incluye materias comunes
-- *****************************************************************************

-- Creating procedure
 
CREATE PROCEDURE "dba".sp820_histAcademic(pUnidadAcademica LIKE sga_alumnos.unidad_academica, pCarrera LIKE sga_alumnos.carrera, pLegajo LIKE sga_alumnos.legajo)

   RETURNING	varchar(5),		-- materia
		varchar(100),  	-- nombre de la materia
		date,		-- fecha
		varchar(15),		-- resultado
		varchar(5),		-- nota
		varchar(20),		-- forma de aprobacion
		char(1),	 	-- tipo de acta
		varchar(10), 		-- acta
		varchar(10), 		-- acta promocion
		varchar(15), 		-- nro resolucion
		varchar(5),		-- plan
		varchar(5),		-- version
		varchar(20),	-- Nombre Carrera Reducido
	                 varchar(30),    -- Nombre materia Reducido
                	 integer,    -- Escala de Notas
	                 integer,    -- Equivalencia
		varchar(15),	-- Descripcion de la nota
		varchar(15);	-- Concepto de la nota

DEFINE	vcCarNomReducido		varchar(20);
DEFINE 	vcMateria 	LIKE sga_materias.materia                           ;
DEFINE 	vcNombreMateria 	LIKE sga_materias.nombre                           ;
DEFINE 	dFecha	 	LIKE sga_detalle_acta.fecha_de_examen   ;
DEFINE 	cResultado 	varchar(15)                                                   ;
DEFINE 	vcNota	 	LIKE sga_detalle_acta.nota                         ;
DEFINE 	cFormaAprob 	varchar(20)                                                   ;
DEFINE	 cTipoActa	LIKE sga_actas_examen.tipo_acta              ;	
DEFINE	 vcActa		LIKE sga_actas_examen.acta                     ;	
DEFINE	 vcActaProm	LIKE sga_actas_promo.acta                        ;	
DEFINE	 vcNroResolucion	LIKE sga_equiv_operac.nro_resolucion   ;
DEFINE 	vcPlan	 	LIKE sga_atrib_mat_plan.plan                     ;
DEFINE 	vcVersion	 	LIKE sga_atrib_mat_plan.version                ;
DEFINE	vcDescripcion	LIKE sga_det_escala.descripcion;
DEFINE	vcConcepto	LIKE sga_det_escala.concepto;
DEFINE	viAnio		Integer;
DEFINE	vcPeriodo	LIKE sga_atrib_mat_plan.periodo_dictado;

DEFINE	vplan_alumno		LIKE sga_atrib_mat_plan.plan;
DEFINE	vplan_version_act	LIKE sga_atrib_mat_plan.version;

DEFINE iEscalaNota      integer;
DEFINE iEquivalencia             LIKE sga_equiv_otorgada.equivalencia;
DEFINE vcNombreMatRed    LIKE sga_materias.nombre_reducido;

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


/* Recupera la Historia Academica de un alumno */
BEGIN
   -- inicializo valores default
LET vcMateria		= NULL	;
LET vcNombreMateria	= NULL	;
LET dFecha		= NULL	;
LET cResultado		= NULL	;
LET vcNota		= NULL	;
LET cFormaAprob		= NULL	;
LET cTipoActa		= NULL	;
LET vcActa		= NULL	;
LET vcActaProm		= NULL	;
LET vcNroResolucion	= NULL	;
LET vcPlan		= NULL	;
LET vcVersion		= NULL	;
LET vcDescripcion	= NULL	;
LET vcConcepto		= NULL	;
LET iEscalaNota        = NULL;
LET iEquivalencia        = NULL;

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
	SELECT ha.materia,
	m.nombre_materia,
	m.nombre_reducido,
	ha.fecha,
	DECODE(ha.resultado,'A', 'Aprobado' , 'R',  'Reprobado', 'P', 'Promocionado'), 
	ha.escala_notas,
	ha.nota,
	ha.forma_aprobacion, 
	ha.tipo_acta,
	ha.acta_examen_orig,
	ha.acta_promo_orig,
	ha.nro_resolucion,
	ha.plan,
	ha.version,
	ha.equivalencia,
	ca.nombre_reducido,
	ha.descripcion,
	ha.concepto,
	case when m.anio_de_cursada is Null then 99 else m.anio_de_cursada end anio_de_cursada,
	m.periodo_dictado

	INTO    vcMateria,
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
	vcPlan,
	vcVersion,
	iEquivalencia,

	vcCarNomReducido,
	vcdescripcion,
	vcconcepto,
	viAnio,
	vcPeriodo

	FROM sga_alumnos al
		join aux_acad ha
			join sga_atrib_mat_plan m
			  on ha.carrera	= m.carrera
				and ha.plan	= m.plan
				and ha.version	= m.version
				and ha.materia	= m.materia
		  on al.carrera = ha.carrera
			and al.legajo = ha.legajo
		join sga_carreras ca
		  on al.carrera = ca.carrera
	WHERE ha.unidad_academica 	= pUnidadAcademica
	AND ha.carrera		= pCarrera
	AND ha.legajo 		= pLegajo

-- Solo las materias del Ultimo Plan al que pertenece el alumno.
	AND ha.materia In (select materia from sga_atrib_mat_plan where carrera = pcarrera and plan = vplan_alumno and version = vplan_version_act)

-- Solo las materias rendidas en el plan del alumno.
--      AND (ha.plan = vplan_alumno)

	ORDER BY anio_de_cursada, m.periodo_dictado, ha.materia, m.nombre_reducido, ha.fecha ASC 

      -- No devuelvo las materias que esten homologadas, ya que estan no deben mostrarse.	
      	IF TRIM(cFormaAprob) <> 'Homologada'  THEN


	      -- devuelvo los valores
		RETURN vcMateria,
			vcNombreMateria,
			dFecha,
			cResultado,
			vcNota,
			cFormaAprob,
			cTipoActa,
			vcActa,
			vcActaProm,
			vcNroResolucion,
			vcPlan,
			vcVersion,
			vcCarNomReducido, 

			vcNombreMatRed, 
			iEscalaNota, 
			iEquivalencia,

			vcdescripcion,
			vcconcepto WITH RESUME;

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
-- *************** Fin del procedimiento "dba".sp820_histAcademic ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_histAcademic 
-- *****************************************************************************
revoke execute on "dba".sp820_histAcademic from public;
grant execute on "dba".sp820_histAcademic to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_histAcademic to internet; -- Rol de usuario de Internet

-- *************************** Prueba de ejecucion *******************************
-- execute procedure "dba".sp820_histAcademic('ESS', '07092', '26194676-2');