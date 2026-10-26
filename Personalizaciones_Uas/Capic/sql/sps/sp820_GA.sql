-- Verificar GA: ¿como saber si la Generica esta aprobada?, ya que la generica no aparece en vw_hist_academica, hay que calcularlo aparte.





-- ******************************************************
-- Lista el promedio de un alumno 
-- Ultima modificacion: Version 1.10.0
-- Procedimiento que devuelve la cantidad de materias que posee el plan y la cantidad de materias aprobadas por un alumno
-- Listado de ERRORES:
--	nCantMat		=	0;	-- El alumno no posee materias aprobadas;
--	nSumPlan	=	-3;	-- EL plan del alumno no existe;
-- ******************************************************
-- DROP PROCEDURE sp820_ga; 
 CREATE PROCEDURE "dba".sp820_ga(
                                    pUA      LIKE sga_alumnos.unidad_academica,
                                    pCarrera LIKE sga_alumnos.carrera,
                                    pLegajo  LIKE sga_alumnos.legajo
                                   )
 RETURNING Integer, Integer;	--decimal(4,2); -- promedio

 DEFINE nGrado      decimal(4,2);
 DEFINE nSumPlan    Integer;  --decimal(10,2);
 DEFINE nCantMat     Integer;

 DEFINE	vplan_alumno		LIKE sga_atrib_mat_plan.plan;
 DEFINE	vplan_version_act		LIKE sga_atrib_mat_plan.version;

BEGIN

  LET nCantMat	=	NULL;
  LET nSumPlan	=	NULL;

 -- Se obtiene el plan del alumno segun su legajo y carrera en la que esta inscripto
  SELECT plan INTO vplan_alumno
	FROM sga_alumnos
		WHERE carrera	=	pCarrera
		AND legajo	=	pLegajo;

 -- Se obtiene la ultima version del plan activo correspondiente a la carrera del alumno
  SELECT version_actual INTO vplan_version_act
	 FROM sga_planes
		WHERE carrera	=	pCarrera
		AND plan		=	vplan_alumno;

-- calculamos la cantidad de materias del plan, que sean obligatorias y de tipo normal o genérica
  SELECT COUNT(*) INTO nSumPlan
	FROM sga_atrib_mat_plan a, sga_materias m
		WHERE a.carrera	=	pCarrera
		AND a.plan	=	vplan_alumno
		AND a.version	=	vplan_version_act
		AND a.materia	=	m.materia
		AND a.obligatoria	=	'S'
		AND a.tipo_materia	in	('N','G');

-- En base a su historia académica se obtiene la cantidad de materias aprobadas que posee el alumno que a la vez sean obligatorias y de tipo normal o genérica


select count(*) INTO nCantMat 
from sga_alumnos a
    join vw_hist_academica h
      on a.legajo = h.legajo
        and h.carrera = a.carrera
        and a.plan = vplan_alumno
        and a.legajo = 	pLegajo	

where a.carrera = pCarrera
    and h.resultado = 'A'
    and h.materia in (
                        select distinct materia from sga_atrib_mat_plan p where p.plan = a.plan and p.carrera = a.carrera and p.obligatoria = 'S' and p.tipo_materia in ('N','G')
                    )
group by a.legajo, a.plan;

-- ****************************************************************************************
-- Aquí en realidad hay que sumarle las genericas obligatorias aprobadas
-- ****************************************************************************************

  IF nCantMat  = 0 THEN
  	LET nCantMat	=	0;	-- El alumno no posee materias aprobadas;
  END IF ;

  IF nSumPlan  IS NULL THEN
  	LET nSumPlan	=	-3;	-- EL plan del alumno no existe;
  END IF ;

  -- Calcula el grado de avance dividiendo la cantidad de materias aprobadas del alumno sobre la cantidad de materias del plan
  --IF nCantMat  > 0 THEN
  --	LET nGrado	=	nCantMat  / nSumPlan ;
  --END IF ;

-- devuelve cantidad de materias aprobadas y cantidad de materias del plan
  RETURN nCantMat, nSumPlan ; 

-- devuelve el grado de avance del alumno
--  RETURN nGrado; 	-- descomentar esta linea para devolver el grado de avance

END;

END PROCEDURE;
