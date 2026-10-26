--DROP PROCEDURE sp820_prom_pond_alu;
CREATE PROCEDURE "dba".sp820_prom_pond_alu (
                                    pUA      LIKE sga_alumnos.unidad_academica,
                                    pCarrera LIKE sga_alumnos.carrera,
                                    pLegajo  LIKE sga_alumnos.legajo)

RETURNING decimal(4,2); -- promedio ponderado

DEFINE nPromedio      decimal(4,2);
DEFINE nSumExam       decimal(10,2);
DEFINE nCantExam      Integer;
DEFINE nCantExamApro      Integer;

-- Variables para el manejo de excepciones
DEFINE sql_err             integer;
DEFINE isam_err          integer;
DEFINE error_info          varchar(76);


DEFINE	vplan_alumno		LIKE sga_atrib_mat_plan.plan;
DEFINE	vplan_version_act	LIKE sga_atrib_mat_plan.version;
DEFINE  vCantMateriasPlan integer;


-- blk de excepciones
ON EXCEPTION SET sql_err, isam_err, error_info

   RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;


BEGIN

  -- inicializo las vars.
  LET nPromedio     = NULL;
  LET nSumExam      = 0;
  LET nCantExam     = 0;

select plan into vplan_alumno
from sga_alumnos
where carrera = pCarrera
	and legajo = pLegajo;

select version_actual, cnt_materias into vplan_version_act, vCantMateriasPlan
from sga_planes
where carrera = pCarrera
	and plan = vplan_alumno;

  -- Retornar las sumas de las notas y la cantidad de EXAMENES Y PROMOCIONES.
  SELECT SUM(sga_det_escala.valor_numerico), Count(sga_det_escala.nota)
    INTO nSumExam, nCantExam
    FROM vw_hist_academica,
         sga_atrib_mat_plan,
         sga_det_escala
   WHERE vw_hist_academica.unidad_academica = pUA
     AND vw_hist_academica.carrera = pCarrera
     AND vw_hist_academica.legajo = pLegajo
     AND vw_hist_academica.nota        IS NOT NULL

     AND sga_atrib_mat_plan.unidad_academica = vw_hist_academica.unidad_academica
     AND sga_atrib_mat_plan.carrera          = vw_hist_academica.carrera
     AND sga_atrib_mat_plan.plan             = vw_hist_academica.plan
     AND sga_atrib_mat_plan.version          = vw_hist_academica.version
     AND sga_atrib_mat_plan.materia          = vw_hist_academica.materia
     AND sga_atrib_mat_plan.promediable      = 'S'
     AND sga_atrib_mat_plan.sale_listado      = 'S'

-- U820 ************************************************************************************************
-- Solo las materias del Plan en el que se encuentra actualmente el alumno
-- U820 ************************************************************************************************
     AND sga_atrib_mat_plan.materia in (select materia from sga_atrib_mat_plan where carrera = pCarrera and plan = vplan_alumno and version = vplan_version_act)

     AND sga_det_escala.escala_notas = vw_hist_academica.escala_notas
     AND sga_det_escala.nota         = vw_hist_academica.nota;



  -- Retornar las sumas de las notas y la cantidad de EXAMENES Y PROMOCIONES Aprobados.
  SELECT count(*)
    INTO nCantExamApro
    FROM vw_hist_academica,
         sga_atrib_mat_plan
   WHERE vw_hist_academica.unidad_academica = pUA
     AND vw_hist_academica.carrera = pCarrera
     AND vw_hist_academica.legajo = pLegajo 
     AND sga_atrib_mat_plan.unidad_academica = vw_hist_academica.unidad_academica
     AND sga_atrib_mat_plan.carrera          = vw_hist_academica.carrera
     AND sga_atrib_mat_plan.plan             = vw_hist_academica.plan
     AND sga_atrib_mat_plan.version          = vw_hist_academica.version
     AND sga_atrib_mat_plan.materia          = vw_hist_academica.materia
     AND sga_atrib_mat_plan.sale_listado      = 'S'
     AND vw_hist_academica.resultado = "A"
-- U820 ************************************************************************************************
-- Solo las materias del Plan en el que se encuentra actualmente el alumno
-- U820 ************************************************************************************************
     AND sga_atrib_mat_plan.materia in (select materia from sga_atrib_mat_plan where carrera = pCarrera and plan = vplan_alumno and version = vplan_version_act);


   -- calculo el promedio

LET nPromedio = case when nSumExam is null or nSumExam = 0 or nCantExam is null or nCantExam = 0 then 0 else 5 * nSumExam / nCantExam end + 10 * nCantExamApro / vCantMateriasPlan;
-- LET nPromedio = 5 * nSumExam / nCantExam + 10 * nCantExamApro / vCantMateriasPlan;



  RETURN nPromedio;

END;

END PROCEDURE;
-- ********************* FIN PROCEDURE sp820_prom_alu_res *********************

-- execute procedure sp820_prom_pond_alu ('FICH', '06', '21878581-1');





