-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.0.5
-- Ultima modificacion: 2.0.5
-- Procedure sp820_es_alumno
-- 
-- Controla si  la persona es alumno en la carrera de integración.
-- *****************************************************************************
-- DROP PROCEDURE sp820_es_alumno;
CREATE PROCEDURE sp820_es_alumno(
	pNroDocumento  LIKE sga_personas.nro_documento,
	pTipoDocumento LIKE sga_personas.tipo_documento)

	RETURNING char(1),   -- S - Es Alumno/ N - No es Alumno
		varchar(15); -- Legajo

-- vars para la respuesta
DEFINE vcRtn             char(1);

-- vars para el manejo de excepciones
DEFINE sql_err, isam_err            integer;
DEFINE error_info          varchar(76);

-- vars locales
DEFINE v_anio              like sga_anio_academico.anio_academico;
DEFINE cnt         integer;
DEFINE vcLegajo	LIKE sga_alumnos.legajo;

-- blk de excepciones
ON EXCEPTION SET sql_err, isam_err, error_info
   RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;

BEGIN
   
   -- OK
   LET vcRtn = 'S'; -- es alumno
   
   
   -- Verifico si la persona es o no Alumno en la Carrera de intergación
   SELECT legajo
     INTO vcLegajo
     FROM sga_alumnos alu
	join sga_personas per
	on alu.nro_inscripcion = per.nro_inscripcion
    WHERE per.nro_documento = pNroDocumento
	and per.tipo_documento = pTipoDocumento
	and carrera in (select carrera from sga_carreras_grupo where grupo_carrera = 'i0001');
   

   IF vcLegajo IS NULL THEN
      -- La persona no es alumno en la carrera.
      LET vcRtn = 'N';
   END IF;

  RETURN vcRtn, vcLegajo;
   
END;
END PROCEDURE;
-- ************************* Procedure sp820_es_alumno ****************************


