CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_intcon_ifz015') THEN
		DROP PROCEDURE sp_intcon_ifz015;
	END IF;		
END
END PROCEDURE;


EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.03.1, 2.7.0
-- Procedure sp_intcon_ifz015
-- 
-- Recupera cantidad de INSCRIPTOS, APROBADOS, REPROBADOS, PROMOCIONADOS en
-- la materia/carrera/anio academico pasados como parametro
-- *****************************************************************************
-- DROP PROCEDURE "dba".sp_intcon_ifz015;
CREATE PROCEDURE "dba".sp_intcon_ifz015 ( pUnidadAcademica VARCHAR(5),
                                    pCarrera VARCHAR(5),
                                    pMateria VARCHAR(5),
                                    pAnioDesde INTEGER,
                                    pAnioHasta INTEGER )
       RETURNING VARCHAR(5),   -- unidad_academica
                 VARCHAR(5),   -- carrera
                 VARCHAR(100), -- nombre materia
	VARCHAR (100), -- apellido presidente
                 INTEGER,      -- anio
--                 INTEGER,      -- Cantidad de Alumnos inscriptos a rendir examen
                 INTEGER,      -- Cantidad de alumnos que se presentaron a rendir examen
                 INTEGER,      -- Cantidad de alumnos que aprobaron
--                 INTEGER,      -- Cantidad de alumnos que no se presentaron a rendir examen
                 INTEGER,      -- Cantidad de alumnos que reprobaron examenes
                 VARCHAR(5),   -- materia
                 VARCHAR(255); -- nombre de la carrera



-- Variables locales
DEFINE iAnio             INTEGER;
DEFINE cnt_inscriptos    INTEGER;
DEFINE cnt_preexa        INTEGER;
DEFINE cnt_apro8         INTEGER;
DEFINE cnt_repexa        INTEGER;
DEFINE cnt_ausexa        INTEGER;
DEFINE vNombreMateria    LIKE sga_materias.nombre;
DEFINE vApellido	LIKE sga_personas.apellido;
DEFINE pLegajo	LIKE sga_docentes.legajo;
DEFINE aux               DECIMAL(6,2);
DEFINE vc_nombre_carrera VARCHAR(255);

-- Variables para el manejo de excepciones
DEFINE SQLErr             INTEGER;
DEFINE ISAMError          INTEGER;
DEFINE errorInfo          VARCHAR(76);

-- Si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
   RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;

BEGIN
   
   -- Recupero el nombre de la carrera
   SELECT nombre
     INTO vc_nombre_carrera
     FROM sga_carreras
    WHERE unidad_academica = pUnidadAcademica
      AND carrera          = pCarrera;
   
   -- Recorro los ultimos Años academicos
   LET iAnio =  pAnioDesde;
   
   WHILE iAnio <=  pAnioHasta
      
      SELECT nombre
        INTO vNombreMateria
        FROM sga_materias
       WHERE unidad_academica = pUnidadAcademica
         AND materia = pMateria; 

FOREACH
      SELECT distinct p.apellido, d.legajo
      INTO vApellido, pLegajo
      FROM sga_docentes_llama dll, sga_docentes d, sga_personas p
      WHERE dll.anio_academico = iAnio
      AND dll.materia = pMateria
      AND dll.rol = 'P'
      AND dll.legajo = d.legajo
      AND d.nro_inscripcion = p.nro_inscripcion
      
      LET cnt_inscriptos = 0;
      LET cnt_preexa = 0;
      LET cnt_apro8 = 0;
      LET cnt_repexa = 0;
      LET cnt_ausexa = 0;
      
--      EXECUTE PROCEDURE sp_intcon_insexmat ( pUnidadAcademica, pCarrera, pMateria, pLegajo, iAnio) INTO cnt_inscriptos;
      
      EXECUTE PROCEDURE sp_intcon_resexmat ( pUnidadAcademica, pCarrera, pMateria, pLegajo, iAnio, null, null, null ) INTO cnt_preexa;
      EXECUTE PROCEDURE sp_intcon_resexmat ( pUnidadAcademica, pCarrera, pMateria, pLegajo, iAnio, 'A', null, null )  INTO cnt_apro8;
      EXECUTE PROCEDURE sp_intcon_resexmat ( pUnidadAcademica, pCarrera, pMateria, pLegajo, iAnio, 'R', null, null )  INTO cnt_repexa;
--      EXECUTE PROCEDURE sp_intcon_resexmat ( pUnidadAcademica, pCarrera, pMateria, pLegajo, iAnio, 'U', null, null )  INTO cnt_ausexa;
      
      RETURN pUnidadAcademica, pCarrera, vNombreMateria, vApellido, iAnio, cnt_preexa, cnt_apro8, cnt_repexa, pMateria, vc_nombre_carrera WITH RESUME;	

END FOREACH;
      
      LET iAnio = iAnio + 1;
      
   END WHILE;  
   
END;
END PROCEDURE;
-- ************************ Fin del procedure sp_intcon_ifz015 ************************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_intcon_ifz015
-- *****************************************************************************
revoke execute on "dba".sp_intcon_ifz015 from public;
grant execute on "dba".sp_intcon_ifz015 to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_intcon_ifz015 to internet; -- Rol de usuario de Internet