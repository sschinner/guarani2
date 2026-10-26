CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_doc_una_mesa') THEN
		DROP PROCEDURE sp820_doc_una_mesa;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *********************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.8.0
-- Ultima modificacion: Version 1.9.0, 2.0.0, 2.04.0
-- Procedure sp_doc_una_mesa
-- 
-- Recupera los docentes de un llamado de una mesa de examen y los devuelve en un string
-- Recibe: Clave del llamado por mesa
-- Retorna: String con los nombres de los docentes
-- *********************************************************************************
-- DROP PROCEDURE sp820_doc_una_mesa;
CREATE PROCEDURE "dba".sp820_doc_una_mesa ( pUnidadAcademica   LIKE sga_llamados_mesa.unidad_academica,
                                   pMateria           LIKE sga_llamados_mesa.materia,
                                   pAnioAcademico     LIKE sga_llamados_mesa.anio_academico,
                                   pTurnoExamen       LIKE sga_llamados_mesa.turno_examen, 
                                   pMesaExamen        LIKE sga_llamados_mesa.mesa_examen,
                                   pLlamado           LIKE sga_llamados_mesa.llamado )

RETURNING varchar(255);     -- Nombres de los docentes

DEFINE vNombre            varchar(255);
DEFINE vRetorno           varchar(255);
DEFINE longitud, cnt  	  INTEGER;

DEFINE iRol            integer;

-- Variables para el manejo de excepciones
DEFINE SQLErr,ISAMError          integer;
DEFINE errorInfo          varchar(76);

-- Si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo
   RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;

BEGIN
   
   LET vRetorno = '';
   LET cnt = 0;
   LET iRol = 9;
   
   FOREACH
    SELECT TRIM(sga_personas.apellido) || ', ' || TRIM(sga_personas.nombres), 
	CASE sga_docentes_llama.rol WHEN "P" THEN 1 WHEN "V" THEN 2 WHEN "S" THEN 3 END as rol


      INTO vNombre, iRol
      FROM sga_docentes_llama,
           sga_docentes,
           sga_personas
     WHERE sga_docentes.legajo = sga_docentes_llama.legajo
       AND sga_personas.unidad_academica = sga_docentes.unidad_academica
       AND sga_personas.nro_inscripcion = sga_docentes.nro_inscripcion
       AND sga_docentes_llama.unidad_academica = pUnidadAcademica
       AND sga_docentes_llama.materia = pMateria
       AND sga_docentes_llama.anio_academico = pAnioAcademico
       AND sga_docentes_llama.turno_examen = pTurnoExamen
       AND sga_docentes_llama.mesa_examen = pMesaExamen
       AND sga_docentes_llama.llamado = pLlamado
	ORDER BY 2
      LET cnt = cnt + 1;
      IF (LENGTH(vRetorno) + LENGTH(vNombre)) <= 160 THEN
         -- Agrega el nombre del nuevo docente leido.
         -- Si no es el primero, pone un separador.
         IF LENGTH(vRetorno) > 1 THEN
            LET vRetorno = vRetorno || ' - ';
         END IF;
         LET vRetorno = vRetorno || vNombre;
      END IF;
      
   END FOREACH;
   
   LET longitud = LENGTH(vRetorno);
   IF longitud > 0 and longitud < 250 THEN
      IF cnt > 1 THEN
         IF SUBSTR(vRetorno,longitud - 3,3) = ' - ' THEN
           -- Saco la ultima barra
           LET vRetorno = SUBSTR(vRetorno,1, longitud - 2);
         END IF;
      END IF;
   END IF;
   
   RETURN vRetorno;
   
END;
END PROCEDURE;
-- ********************* Fin del procedure sp_doc_una_mesa *********************

-- execute PROCEDURE sp820_cab_acta_examen('FBCB',   'N',   'B0332/14');
-- execute PROCEDURE sp820_doc_una_mesa('FBCB',   '11023', '2014', '2do. Especial', 'A', '1');

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_doc_una_mesa 
-- *****************************************************************************
revoke execute on "dba".sp820_doc_una_mesa from public;
grant execute on "dba".sp820_doc_una_mesa to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_doc_una_mesa to internet; -- Rol de usuario de Internet
