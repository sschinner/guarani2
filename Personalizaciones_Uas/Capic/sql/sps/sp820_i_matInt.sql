-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.0.5
-- Ultima modificacion: 2.0.5
-- Procedure sp820_i_matInt
-- 
-- Inserta la materia en la carrera de integración. El trigger de la tabla sga_opt_generica, hace el insert en la tabla sga_atrib_mat_plan
-- Precondiciones: la carrera de integración esta asociada al grupo de carreras 'i0001' (grupo de carreras de integración)
--	El grupo de carreras de integración solo tiene asociado la carrera de integración
-- *****************************************************************************
-- DROP PROCEDURE sp820_i_matInt;
CREATE PROCEDURE sp820_i_matInt(
	pMateria  LIKE sga_materias.materia)

                          RETURNING smallint,       -- status -1 Error/ 1 OK
                                    varchar(255);   -- mensaje 

-- vars para la respuesta
DEFINE iStatus           smallint;
DEFINE vcMsg             varchar(255);


-- vars para el manejo de excepciones
DEFINE sql_err, isam_err            integer;
DEFINE error_info          varchar(76);

-- vars locales
DEFINE vcUa LIKE sga_carreras.unidad_academica;
DEFINE vcCarrera LIKE sga_carreras.carrera;
DEFINE vcPlan LIKE sga_planes.plan;
DEFINE vcVersion LIKE sga_planes.version_actual;
DEFINE vcNombreMateria LIKE sga_materias.nombre;


-- blk de excepciones
ON EXCEPTION SET sql_err, isam_err, error_info
      LET iStatus 	  = -1; 
      LET vcMsg 	  =  'Problemas al realizar la inserción de Materias de Integración' || '; ' || sql_err  || '; ' || error_info;
      RETURN iStatus, vcMsg;
--   RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;

BEGIN
   
   -- OK
   LET iStatus 	  = 0; 
   LET vcMsg 	  =  'OK';
   LET vcCarrera = NULL;
   LET vcPlan = NULL;
   LET vcVersion = NULL;
   LET vcNombreMateria = NULL;

   
select car.unidad_academica, car.carrera, pl.plan, pl.version_actual INTO vcUA, vcCarrera, vcPlan, vcVersion

from sga_grupos_carrera gc
	join sga_carreras_grupo cg
		join sga_carreras car
			join sga_planes pl
			on pl.carrera = car.carrera
		on cg.carrera = car.carrera
	on gc.grupo_carrera = cg.grupo_carrera
Where gc.grupo_carrera = 'i0001'
	and pl.estado = 'V';

select nombre INTO vcNombreMateria
from sga_materias
where materia = pMateria;

insert into sga_mat_genericas (UNIDAD_ACADEMICA, MATERIA_GENERICA, MATERIA_OPTATIVA, VALOR_MATERIA) 
	values (vcUA, 'GMI01', pMateria, 1);
	
insert into sga_opt_generica (UNIDAD_ACADEMICA, CARRERA, PLAN, VERSION, MATERIA_OPTATIVA, MATERIA_GENERICA, GENERADOR) 
	values (vcUA, vcCarrera, vcPlan, vcVersion, pMateria, 'GMI01', 'S');

update sga_atrib_mat_plan set sale_listado = 'S' where unidad_academica = vcUA and carrera =  vcCarrera and plan = vcPlan and version = vcVersion and materia = pMateria;


  RETURN iStatus, vcMsg;
   
END;
END PROCEDURE;
-- ************************* Procedure sp820_i_matInt ****************************

