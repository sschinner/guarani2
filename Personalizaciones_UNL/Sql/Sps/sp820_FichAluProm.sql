CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_fichaluprom') THEN
		DROP PROCEDURE sp820_fichaluprom;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.7.0
-- Procedure sp_FichAluProm
-- 
-- Consulta los promedios en cada carrera de una persona en la unidad academica.
-- Promedio con aplazos y sin aplazos.
-- ******************************************************************************
-- Creating procedure
CREATE PROCEDURE "dba".sp820_fichaluprom ( pUnidadAcademica LIKE sga_personas.unidad_academica, pNroInscripcion LIKE sga_personas.nro_inscripcion )
       RETURNING varchar(5), varchar(10), varchar(30), varchar(30), varchar(5), varchar(100), varchar(15), varchar(5), decimal(4,2), decimal(4,2);

-- Descripcion del Return:
-- varchar(5),   -- unidad_academica
-- varchar(10),  -- nro_inscripcion
-- varchar(30),  -- apellido
-- varchar(30),  -- nombres
-- varchar(5),   -- carrera
-- varchar(100), -- carrera_nombre
-- varchar(15),  -- legajo
-- varchar(5),   -- plan
-- decimal(4,2), -- promedio_con_aplazos
-- decimal(4,2), -- promedio_sin_aplazos


DEFINE vc_apellido        LIKE sga_personas.apellido;
DEFINE vc_nombres         LIKE sga_personas.nombres;
DEFINE vc_carrera         LIKE sga_carreras.carrera;
DEFINE vc_carrera_nombre  LIKE sga_carreras.nombre;
DEFINE vc_legajo          LIKE sga_alumnos.legajo;
DEFINE vc_plan            LIKE sga_alumnos.plan;
DEFINE vi_prom_con        decimal(4,2);
DEFINE vi_prom_sin        decimal(4,2);
DEFINE vi_retorno         SMALLINT;
DEFINE cPromedioResolucion char(1);

BEGIN
   
   -- inicializaciones.
   LET vc_apellido        = NULL;
   LET vc_nombres         = NULL;
   LET vc_carrera         = NULL;
   LET vc_carrera_nombre  = NULL;
   LET vc_legajo          = NULL;
   LET vc_plan            = NULL;
   LET vi_prom_con        = 0;
   LET vi_prom_sin        = 0;
   LET vi_retorno         = 0;
   LET cPromedioResolucion = NULL;

   -- selecciono los datos personales de la persona.
   SELECT sga_personas.apellido,
          sga_personas.nombres
     INTO vc_apellido, vc_nombres
     FROM sga_personas
    WHERE sga_personas.unidad_academica = pUnidadAcademica
      AND sga_personas.nro_inscripcion = pNroInscripcion;

   -- selecciono los promedios de las distintas carreras de la persona.
   FOREACH SELECT sga_alumnos.carrera,
                  sga_carreras.nombre_reducido,
                  sga_alumnos.legajo,
                  sga_alumnos.plan
             INTO vc_carrera, vc_carrera_nombre, vc_legajo, vc_plan --, vi_prom_con, vi_prom_sin
             FROM sga_alumnos,
                  sga_carreras
            WHERE sga_alumnos.unidad_academica = pUnidadAcademica
              AND sga_alumnos.nro_inscripcion = pNroInscripcion
              AND sga_carreras.unidad_academica = sga_alumnos.unidad_academica
              AND sga_carreras.carrera = sga_alumnos.carrera
         ORDER BY sga_alumnos.carrera
      
	  EXECUTE PROCEDURE sp820_prom_alu_res ( pUnidadAcademica, vc_carrera, vc_legajo, 'S' ) INTO vi_prom_con, cPromedioResolucion;
	  EXECUTE PROCEDURE sp820_prom_alu_res ( pUnidadAcademica, vc_carrera, vc_legajo, 'N' ) INTO vi_prom_sin,  cPromedioResolucion;
      LET vi_retorno = 1;
      RETURN pUnidadAcademica, pNroInscripcion, vc_apellido, vc_nombres, vc_carrera, vc_carrera_nombre, vc_legajo, vc_plan, vi_prom_con, vi_prom_sin WITH RESUME;
      
   END FOREACH;
   
   -- si no tiene carreras con promedio, devuelvo solamente los datos personales.
   IF vi_retorno = 0 THEN
      RETURN pUnidadAcademica, pNroInscripcion, vc_apellido, vc_nombres, vc_carrera, vc_carrera_nombre, vc_legajo, vc_plan, vi_prom_con, vi_prom_sin;
   END IF;
   
END;

END PROCEDURE;
-- **************************  Fin del Procedure sp_FichAluProm **************************

revoke execute on "dba".sp820_fichaluprom from public;
grant execute on "dba".sp820_fichaluprom to guarani;  -- Rol de usuarios de Gestion
grant execute on "dba".sp820_fichaluprom to internet; -- Rol de usuario de Internet
