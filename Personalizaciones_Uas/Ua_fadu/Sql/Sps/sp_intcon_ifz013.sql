CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_intcon_ifz013') THEN
		DROP PROCEDURE sp_intcon_ifz013;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.03.1
-- Procedure sp_coneau_cuadro10
-- 
-- Datos de los alumnos por actividad Curricular (materias), para las carreras de 
-- acreditacion.
-- Alumnos inscriptos a materias, que aprobaron la cursada, desaprobaron, promovidos sin
-- examen final.
-- *****************************************************************************
-- DROP PROCEDURE sp_intcon_ifz013;
CREATE PROCEDURE "dba".sp_intcon_ifz013 ( pUnidadAcademica VARCHAR(5), 
                                    pCarrera         VARCHAR(5),
                                    pMateria         VARCHAR(5),
                                    pAnioDesde       INTEGER,
                                    pAnioHasta       INTEGER)
       RETURNING VARCHAR(5),   -- unidad_academica
                 VARCHAR(5),   -- materia
                 VARCHAR(60),  -- nombre materia
                 VARCHAR(255),  -- nombre catedra
                 INTEGER,      -- anio
                 INTEGER,      -- Cantidad de Alumnos inscriptos a cursar materias
                 INTEGER,      -- Cantidad de alumnos que aprobaron la cursada
                 INTEGER,      -- Cantidad de alumnos que reprobaron la cursada
                 INTEGER,      -- Cantidad de alumnos que promocionaron la cursada (sin examen final) ????
                 INTEGER,      -- Cantidad de alumnos ausentes
                 VARCHAR(5),   -- carrera
                 VARCHAR(255); -- nombre de la carrera

-- Variables locales
DEFINE iAnio             INTEGER;
DEFINE cnt_inscriptos    INTEGER;
DEFINE cnt_aprobados     INTEGER;
DEFINE cnt_reprobados    INTEGER;
DEFINE cnt_promovidos    INTEGER;
DEFINE cnt_ausentes      INTEGER;
DEFINE vNombreMateria    LIKE sga_materias.nombre;
define vc_nombre_carrera VARCHAR(255);

define vc_docentes_com VARCHAR(255);

-- Variables para el manejo de excepciones
DEFINE SQLErr            INTEGER;
DEFINE ISAMError         INTEGER;
DEFINE errorInfo         VARCHAR(76);

-- Si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
   RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;

BEGIN
   
   LET iAnio = pAnioDesde;
   
   SELECT nombre
     INTO vNombreMateria
     FROM sga_materias
    WHERE unidad_academica = pUnidadAcademica
      AND materia = pMateria; 
   
   SELECT nombre 
     INTO vc_nombre_carrera
     FROM sga_carreras
    WHERE unidad_academica=pUnidadAcademica
      AND carrera = pCarrera;
   
   WHILE iAnio <= pAnioHasta
      

   FOREACH

	SELECT distinct sp_docentes_com(comision) as docentes Into vc_docentes_com

	FROM sga_comisiones
	WHERE unidad_academica = pUnidadAcademica
		AND anio_academico   = iAnio
		AND materia          = pMateria



      LET cnt_inscriptos = 0;
      LET cnt_aprobados  = 0;
      LET cnt_reprobados = 0;
      LET cnt_promovidos = 0;
      
      -- Cantidad de INSCRIPTOS A CURSADAS DE LAS MATERIAS de la carrera
      EXECUTE PROCEDURE sp_intcon_incu_mat (pUnidadAcademica, pCarrera, pMateria, iAnio, vc_docentes_com) INTO cnt_inscriptos;
      
      -- Cantidad de APROBADOS EN CURSADAS
      EXECUTE PROCEDURE sp_intcon_rescumat (pUnidadACademica, pCarrera, pMateria, iAnio, 'A', vc_docentes_com) INTO cnt_aprobados;
      
      -- Cantidad de REPROBADOS EN CURSADAS
      EXECUTE PROCEDURE sp_intcon_rescumat (pUnidadACademica, pCarrera, pMateria, iAnio, 'R', vc_docentes_com) INTO cnt_reprobados;
      
      -- Cantidad de PROMOVIDOS EN CURSADAS SIN EXAMEN FINAL
      EXECUTE PROCEDURE sp_intcon_rescumat (pUnidadACademica, pCarrera, pMateria, iAnio, 'P', vc_docentes_com) INTO cnt_promovidos;
      
      -- Cantidad de AUSENTES
      EXECUTE PROCEDURE sp_intcon_rescumat (pUnidadACademica, pCarrera, pMateria, iAnio, 'U', vc_docentes_com) INTO cnt_ausentes;
      
      RETURN pUnidadAcademica, pMateria, vNombreMateria, vc_docentes_com, iAnio, cnt_inscriptos, cnt_aprobados, cnt_reprobados, cnt_promovidos, cnt_ausentes, pCarrera, vc_nombre_carrera WITH RESUME;	
      

      END FOREACH;

      LET iAnio = iAnio + 1;
      
   END WHILE;  
   
END;
END PROCEDURE;
-- ************************ Fin del procedure sp_intcon_ifz013 ************************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_intcon_ifz013
-- *****************************************************************************
revoke execute on "dba".sp_intcon_ifz013 from public;
grant execute on "dba".sp_intcon_ifz013 to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_intcon_ifz013 to internet; -- Rol de usuario de Internet