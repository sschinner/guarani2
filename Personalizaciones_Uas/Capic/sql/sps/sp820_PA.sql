-- ******************************************************
-- Lista el promedio de un alumno 
-- Ultima modificacion: Version 1.10.0
-- AHORA EL ATRIBUTO PROMEDIABLE SE SACA SIEMPRE DEL PLAN
-- El procedimiento que calcula el promedio academico es equivalente al existente en el sistema Guaran� sp820_prom_alu_res
-- Listado de ERRORES:
--	nPromedio	=	-5;	-- El alumno no tiene examnes rendidos o bien no tiene notas cargadas
-- ******************************************************
--DROP PROCEDURE sp820_pa; 
CREATE PROCEDURE sp820_pa(
                                    pUA      LIKE sga_alumnos.unidad_academica,
                                    pCarrera LIKE sga_alumnos.carrera,
                                    pLegajo  LIKE sga_alumnos.legajo,
                                    pTodas   char DEFAULT 'S' -- S- Aprobadas y Reprobadas / N- Solo aprobadas
                                   )
 RETURNING decimal(4,2); -- promedio

 DEFINE nPromedio      decimal(4,2);
 DEFINE nSumExam       decimal(10,2);
 DEFINE nCantExam      Integer;

-- Variables para el manejo de excepciones
 DEFINE sql_err             integer;
 DEFINE isam_err          integer;
 DEFINE error_info          varchar(76);


 DEFINE	vplan_alumno		LIKE sga_atrib_mat_plan.plan;
 DEFINE	vplan_version_act	LIKE sga_atrib_mat_plan.version;


-- blk de excepciones
ON EXCEPTION SET sql_err, isam_err, error_info
   -- Borra la tabla temporal
   BEGIN
      -- Si no exist�a, contin�a
      ON EXCEPTION IN  (-206)

 END EXCEPTION WITH RESUME ;
      -- Borra la tabla temporal
      DROP TABLE temp_histacadprom;
   END
   RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;


BEGIN

  -- inicializo las vars.
  LET nPromedio     = NULL;
  LET nSumExam      = 0;
  LET nCantExam     = 0;

  SELECT plan INTO vplan_alumno
	FROM sga_alumnos
		WHERE carrera	=	pCarrera
		AND legajo	=	pLegajo;

  SELECT version_actual INTO vplan_version_act
	FROM sga_planes
		WHERE carrera	=	pCarrera
		AND plan		=	vplan_alumno;

  -- si Todas en N van solo las aprobadas
  IF pTodas = 'N' THEN
      LET pTodas = 'A';
  END IF;


  -- Creo un temporal con la Historia Academica

  SELECT * 
	FROM vw_hist_academica
		WHERE unidad_academica	=	pUA
		AND carrera		=	pCarrera
		AND legajo		=	pLegajo
		INTO TEMP temp_histacadprom;


  -- Retornar las sumas de las notas y la cantidad de EXAMENES Y PROMOCIONES.

  SELECT SUM(sga_det_escala.valor_numerico), Count(sga_det_escala.nota) INTO nSumExam, nCantExam
	FROM temp_histacadprom, sga_atrib_mat_plan, sga_det_escala
		WHERE temp_histacadprom.nota IS NOT NULL
		AND (temp_histacadprom.resultado		=	pTodas OR  pTodas = 'S')
		AND sga_atrib_mat_plan.unidad_academica	=	temp_histacadprom.unidad_academica
		AND sga_atrib_mat_plan.carrera		=	temp_histacadprom.carrera
		AND sga_atrib_mat_plan.plan			=	temp_histacadprom.plan
		AND sga_atrib_mat_plan.version		=	temp_histacadprom.version
		AND sga_atrib_mat_plan.materia		=	temp_histacadprom.materia
		-- AND sga_atrib_mat_plan.promediable		=	'S'

-- U820 ************************************************************************************************
-- Solo las materias del Plan en el que se encuentra actualmente el alumno
-- U820 ************************************************************************************************

		AND sga_atrib_mat_plan.materia in (SELECT materia FROM sga_atrib_mat_plan WHERE carrera = pCarrera AND plan = vplan_alumno AND version = vplan_version_act)
		AND sga_det_escala.escala_notas		=	temp_histacadprom.escala_notas
		AND sga_det_escala.nota			=	temp_histacadprom.nota;


   -- calculo el promedio
   IF nCantExam > 0 THEN
	LET nPromedio	=	nSumExam / nCantExam ;
   ELSE
	LET nPromedio	=	-5;	-- El alumno no tiene examnes rendidos o bien no tiene notas cargadas
   END IF ;


   -- Borro la tabla temporal!
   DROP TABLE  temp_histacadprom;


  RETURN nPromedio;

END;

END PROCEDURE;
