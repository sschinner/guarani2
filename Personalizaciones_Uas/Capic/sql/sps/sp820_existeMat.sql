-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.0.5
-- Ultima modificacion: 2.0.5
-- Procedure sp820_existeMat
-- 
-- Controla si  la materia existe en la carrera de integración.
-- Precondiciones: la carrera de integración esta asociada al grupo de carreras 'i0001' (grupo de carreras de integración)
--	El grupo de carreras de integración solo tiene asociado la carrera de integración
-- *****************************************************************************
-- DROP PROCEDURE sp820_existeMat;
CREATE PROCEDURE sp820_existeMat(
	pMateria  LIKE sga_materias.materia)

	RETURNING char(1);   -- S - Existe la materia/ N - No existe la materia


-- vars para la respuesta
DEFINE vcRtn             char(1);


-- vars para el manejo de excepciones
DEFINE sql_err, isam_err            integer;
DEFINE error_info          varchar(76);

-- vars locales
DEFINE v_anio              like sga_anio_academico.anio_academico;
DEFINE cnt         integer;
DEFINE vcLegajo	LIKE sga_alumnos.legajo;
DEFINE vcCarrera LIKE sga_carreras.carrera;
DEFINE vcPlan LIKE sga_planes.plan;
DEFINE vcVersion LIKE sga_planes.version_actual;

-- blk de excepciones
ON EXCEPTION SET sql_err, isam_err, error_info
   RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;

BEGIN
   
   -- OK
   LET vcRtn = 'S'; -- existe la materia de integración
   LET vcLegajo = NULL;
   LET vcCarrera = NULL;
   LET vcPlan = NULL;
   LET vcVersion = NULL;
   
select car.carrera, pl.plan, pl.version_actual INTO vcCarrera, vcPlan, vcVersion

from sga_grupos_carrera gc
	join sga_carreras_grupo cg
		join sga_carreras car
			join sga_planes pl
			on pl.carrera = car.carrera
		on cg.carrera = car.carrera
	on gc.grupo_carrera = cg.grupo_carrera
Where gc.grupo_carrera = 'i0001'
	and pl.estado = 'V';
   
   -- Verifico si la materia existe en la Carrera/Plan/Version de intergación
   IF NOT EXISTS (SELECT "*"
     FROM sga_atrib_mat_plan
	WHERE carrera = vcCarrera
	and plan = vcPlan
	and version =  vcVersion
	and materia = pMateria) THEN
      -- La materia no pertenece a la carrera de integracion.
      LET vcRtn = 'N';
   END IF;

  RETURN vcRtn;
   
END;
END PROCEDURE;
-- ************************* Procedure sp820_existeMat ****************************









