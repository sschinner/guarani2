-- ******************************************************
-- Lista el promedio de un alumno 
-- Ultima modificacion: Version 1.10.0
-- Procedimiento que devuelve el anio actual, el anio de ingreso del alumno y el anio en que se cursa la materia pasada por parametro para el alumno.
-- Listado de ERRORES:
--	vAnioCursada	=	-4;	-- si el anio de cursada devuelve -4 es porque no esta seteado para esa materia.
-- ******************************************************

-- DROP PROCEDURE sp820_eac; 
CREATE PROCEDURE "dba".sp820_eac(
                                    pUA      LIKE sga_alumnos.unidad_academica,
                                    pCarrera LIKE sga_alumnos.carrera,
                                    pLegajo  LIKE sga_alumnos.legajo,
                                    pMateria  LIKE sga_materias.materia
                                   )
RETURNING Integer, Integer, integer;	
-- RETURNING decimal(4,2);	-- Descomentar esta linea si queremos devolver el resultado de la formula.

 --DEFINE nGrado      decimal(4,2);	-- Descomentar esta linea si queremos devolver el resultado de la formula.

 DEFINE nAnioActual	integer;
 DEFINE nAnioIngreso	integer;

 DEFINE	vAnioCursada		LIKE	sga_atrib_mat_plan.anio_de_cursada;
 DEFINE	vplan_alumno		LIKE	sga_atrib_mat_plan.plan;
 DEFINE	vplan_version_act		LIKE	sga_atrib_mat_plan.version;

  BEGIN

LET vAnioCursada	= NULL;

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

 -- Se obtiene el anio de ingreso del alumno junto con el anio actual, ambos dos en variables distintas de tipo integer

SELECT p.anio_academico, YEAR(fecha_actual()) INTO nAnioIngreso, nAnioActual 
	FROM sga_carrera_aspira c, sga_periodo_insc p
		WHERE c.nro_inscripcion = (SELECT nro_inscripcion FROM sga_alumnos WHERE legajo = pLegajo AND carrera = pCarrera AND unidad_academica = pUA)
		AND c.periodo_inscripcio	=	p.periodo_inscripcio
		AND c.carrera		=	pCarrera;


 -- Se obtiene el anio en que se cursa la materia para el plan y version del alumno

 SELECT anio_de_cursada INTO vAnioCursada
	FROM sga_atrib_mat_plan
		WHERE plan	 =	vplan_alumno
		AND version	 =	vplan_version_act
		AND materia	 =	pMateria
		AND carrera 	 = 	pCarrera;


	-- Descomentar esta linea si queremos devolver el resultado de la formula.
-- (año actual - año de ingreso - anio de cursado de la materia + 1) / (año actual - año de ingreso + 1)
-- LET nGrado = (nAnioActual - nAnioIngreso - vAnioCursada + 1) / (nAnioActual - nAnioIngreso +1);	

  IF vAnioCursada IS NULL THEN
  	LET vAnioCursada		=	-4;	-- si el anio de cursada devuelve -4 es porque no esta seteado para esa materia.
  END IF;

  RETURN nAnioActual, nAnioIngreso, vAnioCursada;

  --RETURN nGrado;	-- Descomentar esta linea si queremos devolver el resultado de la formula.

  END;

  END PROCEDURE;
