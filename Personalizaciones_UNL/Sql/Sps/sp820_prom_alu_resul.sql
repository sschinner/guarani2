CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_prom_alu_res') THEN
		DROP PROCEDURE sp820_prom_alu_res;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ******************************************************
-- Lista el promedio de un alumno 
-- Ultima modificacion: Version 1.10.0
-- AHORA EL ATRIBUTO PROMEDIABLE SE SACA SIEMPRE DEL PLAN
-- ******************************************************
-- DROP PROCEDURE sp820_prom_alu_res; 
CREATE PROCEDURE "dba".sp820_prom_alu_res(
                                    pUA      LIKE sga_alumnos.unidad_academica,
                                    pCarrera LIKE sga_alumnos.carrera,
                                    pLegajo  LIKE sga_alumnos.legajo,
                                    pTodas   char DEFAULT 'S' -- S- Aprobadas y Reprobadas / N- Solo aprobadas
                                   )
 RETURNING decimal(6,2), char(1); -- promedio, si es por resolucion 609/2010 o normal.

 DEFINE nSumExamOk       decimal(10,2);
 DEFINE nCantExamOk      Integer;

 DEFINE nPromedioFinala      decimal(6,2);
 DEFINE cPromedioResolucion char(1);

 DEFINE nPromedio      decimal(6,2);
 DEFINE nSumExam       decimal(10,2);
 DEFINE nCantExam      Integer;

DEFINE nPromedioVieja      decimal(6,2);
DEFINE  nSumExamVieja decimal(10,2);
DEFINE  nCantExamVieja Integer;

DEFINE  nSumExamPosterior      decimal(10,2);
DEFINE   nCantExamPosterior     Integer;

-- Variables para el manejo de excepciones
 DEFINE sql_err             integer;
 DEFINE isam_err          integer;
 DEFINE error_info          varchar(76);


 DEFINE	vplan_alumno	LIKE sga_atrib_mat_plan.plan;
 DEFINE	vplan_version_act	LIKE sga_atrib_mat_plan.version;

 DEFINE vc_Fecha	date;
 DEFINE vdFecha Date;
 DEFINE vcCalidad char(1);
 DEFINE vcNroInscripcion LIKE sga_alumnos.nro_inscripcion;
 

-- blk de excepciones
ON EXCEPTION SET sql_err, isam_err, error_info

   RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;


BEGIN

  -- inicializo las vars.
  LET nPromedioFinala     = NULL;
  LET nPromedio     = NULL;
  LET cPromedioResolucion = 'N';
  LET nPromedioVieja     = NULL;
  LET nSumExam      = 0;
  LET nCantExam     = 0;
  LET nSumExamOk      = 0;
  LET nCantExamOk     = 0;
  LET nSumExamVieja      = 0;
  LET nCantExamVieja     = 0;
  LET nSumExamPosterior      = 0;
  LET nCantExamPosterior     = 0;

  LET vc_Fecha = to_date("31/12/2006","%d/%m/%Y");
    

  -- si Todas en N van solo las aprobadas
  IF pTodas = 'N' THEN
      LET pTodas = 'A';
  END IF;
  
 -- =========================================================================================================================================================
  SELECT calidad, nro_inscripcion INTO vcCalidad, vcNroInscripcion
    FROM sga_alumnos
  WHERE unidad_academica = pUA
    AND carrera = pCarrera
    AND legajo = pLegajo;
    
    LET vdFecha = NULL;
    IF vcCalidad = 'E' THEN
       
       -- Alumno Egresado. Recupero fecha de egreso del título de nivel final - Grado
       FOREACH SELECT to.fecha_egreso INTO vdFecha
         FROM sga_titulos_otorg as to,
              sga_titulos as t
		WHERE to.unidad_academica = pUA
 		  AND to.nro_inscripcion = vcNroInscripcion
 		  AND to.carrera = pCarrera
 		  AND to.legajo  = pLegajo
		  AND t.unidad_academica = to.unidad_academica
 		  AND t.titulo =  to.titulo
 		  AND t.nivel = 'GRADO'
 		  -- Al primer registro salgo
 		  EXIT FOREACH;
 	   END FOREACH;	  
        
    END IF;

    IF vdFecha IS NULL THEN
        LET vdFecha = TODAY;
    END IF;	    
    
  -- Recupero Plan y Version del Alumno
  EXECUTE PROCEDURE sp_plan_de_alumno (pUA, pCarrera, pLegajo, vdFecha) INTO vplan_alumno, vplan_version_act;


  -- Retornar las sumas de las notas y la cantidad de EXAMENES Y PROMOCIONES, desde que se puso en vigencia la nueva escala.
  SELECT SUM(sga_det_escala.valor_numerico), 
	Count(sga_det_escala.nota)
    INTO nSumExamPosterior, nCantExamPosterior
    FROM vw_hist_academica,
         sga_atrib_mat_plan,
         sga_det_escala
   WHERE vw_hist_academica.unidad_academica = pUA
     AND vw_hist_academica.carrera = pCarrera
     AND vw_hist_academica.legajo = pLegajo
     AND vw_hist_academica.nota        IS NOT NULL
     AND  vw_hist_academica.nota NOT IN ('A', 'N')
     AND (vw_hist_academica.resultado  = pTodas OR  pTodas = 'S')
     AND vw_hist_academica.fecha > vc_Fecha 

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

  -- Retornar las sumas de las notas y la cantidad de EXAMENES Y PROMOCIONES, hasta que regía la escala vieja, pero con las notas convertidas.
  SELECT SUM(sga_det_escala.valor_numerico), 
	Count(sga_det_escala.nota)
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
     AND vw_hist_academica.fecha <= vc_Fecha 

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

  -- Retornar las sumas de las notas y la cantidad de EXAMENES Y PROMOCIONES, hasta que regía la escala vieja, pero con las notas NO convertidas..
  SELECT SUM(case sga_det_escala.valor_numerico when 2.67 then 2
			when 4.33 then 3
			when 6 then 4
			when 6.67 then 5
			when 7.33 then 6
			when 8 then 7
			when 8.67 then 8
			when 9.33 then 9 else sga_det_escala.valor_numerico end),

	Count(sga_det_escala.nota)
    INTO nSumExamVieja, nCantExamVieja
    FROM vw_hist_academica,
         sga_atrib_mat_plan,
         sga_det_escala
   WHERE vw_hist_academica.unidad_academica = pUA
     AND vw_hist_academica.carrera = pCarrera
     AND vw_hist_academica.legajo = pLegajo
     AND vw_hist_academica.nota        IS NOT NULL
     AND  vw_hist_academica.nota NOT IN ('A', 'N')
     AND (vw_hist_academica.resultado  = pTodas OR  pTodas = 'S')
     AND vw_hist_academica.fecha <= vc_Fecha 

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
      LET nPromedioVieja = nSumExamVieja / nCantExamVieja ;
   END IF ;

  IF nPromedioVieja >= 4 and nPromedio < 6 then 
        -- Calculo del promedio: a determinar que forma se usará (a) ó (b)?
        -- (a)
        -- LET nPromedioFinala = (nSumExamPosterior+6)/(nCantExamPosterior+1);
        -- (b)
        IF nCantExamPosterior = 0 then
                LET nPromedioFinala = 6;
        ELSE
                LET nPromedioFinala =((nSumExamPosterior/nCantExamPosterior) + 6)/2; -- Resolucion 609/2010
                LET cPromedioResolucion = 'S';
        END IF;
   ELSE

          -- Retornar las sumas de las notas y la cantidad de EXAMENES Y PROMOCIONES, hasta que regía la escala vieja, pero con las notas convertidas.
          SELECT SUM(sga_det_escala.valor_numerico), 
                Count(sga_det_escala.nota)
            INTO nSumExamOk, nCantExamOk
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
        
                LET nPromedioFinala = nSumExamOk / nCantExamOk ;

   END IF ;

  RETURN nPromedioFinala, cPromedioResolucion;

END;

END PROCEDURE;
-- **********************************************************************************
revoke execute on "dba".sp820_prom_alu_res from public;
grant execute on "dba".sp820_prom_alu_res to guarani;  -- Rol de usuarios de Gestion
grant execute on "dba".sp820_prom_alu_res to internet; -- Rol de usuario de Internet
