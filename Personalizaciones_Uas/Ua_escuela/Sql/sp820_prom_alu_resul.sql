CREATE PROCEDURE verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_prom_alu_res') THEN
		DROP PROCEDURE sp820_prom_alu_res;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE verifica_objeto();
DROP PROCEDURE verifica_objeto();

-- ******************************************************
-- Lista el promedio de un alumno 
-- Ultima modificacion: Version 1.10.0
-- AHORA EL ATRIBUTO PROMEDIABLE SE SACA SIEMPRE DEL PLAN
-- ******************************************************
-- execute procedure sp820_prom_alu_res ('FCJS', '1', '21878581-1', 'N');

--DROP PROCEDURE sp820_prom_alu_res; 
CREATE PROCEDURE "dba".sp820_prom_alu_res(
                                    pUA      LIKE sga_alumnos.unidad_academica,
                                    pCarrera LIKE sga_alumnos.carrera,
                                    pLegajo  LIKE sga_alumnos.legajo,
                                    pTodas   char DEFAULT 'S' -- S- Aprobadas y Reprobadas / N- Solo aprobadas
                                   )
 RETURNING decimal(6,2), char(1); -- promedio, si es por resolucion 609/2010 o normal.

 DEFINE nPromedio      decimal(6,2);
 DEFINE nSumExam       decimal(10,2);
 DEFINE nCantExam      Integer;
 DEFINE cPromedioResolucion char(1);

-- Variables para el manejo de excepciones
 DEFINE sql_err             integer;
 DEFINE isam_err          integer;
 DEFINE error_info          varchar(76);


 DEFINE	vplan_alumno	LIKE sga_atrib_mat_plan.plan;
 DEFINE	vplan_version_act	LIKE sga_atrib_mat_plan.version;


-- blk de excepciones
ON EXCEPTION SET sql_err, isam_err, error_info

   RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;


BEGIN

  -- inicializo las vars.
  LET nPromedio     = NULL;
  LET nSumExam      = 0;
  LET nCantExam     = 0;
  LET cPromedioResolucion = 'N';

select plan into vplan_alumno
from sga_alumnos
where carrera = pCarrera
	and legajo = pLegajo;

select version_actual into vplan_version_act
from sga_planes
where carrera = pCarrera
	and plan = vplan_alumno;

  -- si Todas en N van solo las aprobadas
  IF pTodas = 'N' THEN
      LET pTodas = 'A';
  END IF;


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
     AND  vw_hist_academica.nota NOT IN ('A', 'N')
     AND (vw_hist_academica.resultado  = pTodas OR  pTodas = 'S')

     AND sga_atrib_mat_plan.unidad_academica = vw_hist_academica.unidad_academica
     AND sga_atrib_mat_plan.carrera          = vw_hist_academica.carrera
     AND sga_atrib_mat_plan.plan             = vw_hist_academica.plan
     AND sga_atrib_mat_plan.version          = vw_hist_academica.version
     AND sga_atrib_mat_plan.materia          = vw_hist_academica.materia
     AND sga_atrib_mat_plan.promediable      = 'S'


-- U820 ************************************************************************************************
-- Solo las materias del Plan en el que se encuentra actualmente el alumno
-- U820 ************************************************************************************************
     AND sga_atrib_mat_plan.materia in (select materia from sga_atrib_mat_plan where carrera = pCarrera and plan = vplan_alumno and version = vplan_version_act)

     AND sga_det_escala.escala_notas = vw_hist_academica.escala_notas
     AND sga_det_escala.nota         = vw_hist_academica.nota;



   -- calculo el promedio
   IF nCantExam > 0 THEN
      LET nPromedio = nSumExam / nCantExam ;
   END IF ;


  RETURN nPromedio, cPromedioResolucion;

END;

END PROCEDURE;


