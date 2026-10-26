-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version Alfa 1.2.0
-- Tabla u820_adeuda_cuota
-- *******************************************************************************
--Borra el procedimiento si existe
CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_crea_tabla_u820_adeuda_cuota') THEN
		DROP PROCEDURE sp_crea_tabla_u820_adeuda_cuota;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();

-- Comentarios: 
-- Uso la menor cantidad de restricciones posibles, dado que a los fines del control, es suficiente. CEMED deberia asegurar que los datos introducidos son correctos para el alumno en cuestion. Por ej. que la materia corresponda al plan del alumno o que el DNI se corresponda al de la Persona.
-- Solo restringo a que exista la Persona y la Materia. 

CREATE PROCEDURE "dba".sp_crea_tabla_u820_adeuda_cuota();

BEGIN

IF NOT EXISTS (SELECT * FROM systables where tabname = 'u820_adeuda_cuota') THEN


CREATE TABLE u820_adeuda_cuota (
       UNIDAD_ACADEMICA     varchar(5) NOT NULL,
       TIPO_DOCUMENTO       integer NOT NULL,
       NRO_DOCUMENTO        varchar(15) NOT NULL,
       MATERIA              varchar(5) NOT NULL,
       PERIODO_LECTIVO	varchar(20) NOT NULL,
       ANIO_ACADEMICO	varchar(10) NOT NULL,
       FECHA_IMPUTACION     date NOT NULL, -- Formato: mm/dd/yyyy
       TIPO_MODALIDAD	char (1) NOT NULL, -- C: cursado; E: examen
       OBSERVACIONES        varchar(255)
);


ALTER TABLE u820_adeuda_cuota
       ADD CONSTRAINT PRIMARY KEY (UNIDAD_ACADEMICA, TIPO_DOCUMENTO, NRO_DOCUMENTO, MATERIA, PERIODO_LECTIVO, ANIO_ACADEMICO, TIPO_MODALIDAD)
              CONSTRAINT pk_adeuda_cuota;

ALTER TABLE u820_adeuda_cuota
       ADD CONSTRAINT FOREIGN KEY (UNIDAD_ACADEMICA)
       			REFERENCES sga_unidades_acad
              CONSTRAINT fk_ad_cuota_unidad;

-- ALTER TABLE u820_adeuda_cuota
--       ADD CONSTRAINT FOREIGN KEY (UNIDAD_ACADEMICA, TIPO_DOCUMENTO, NRO_DOCUMENTO)
--                             REFERENCES sga_personas
--              CONSTRAINT fk_ad_cuota_persona;

ALTER TABLE u820_adeuda_cuota
       ADD CONSTRAINT FOREIGN KEY (UNIDAD_ACADEMICA, MATERIA)
                             REFERENCES sga_materias
              CONSTRAINT fk_ad_cuota_materia;




grant all on u820_adeuda_cuota to public;
-- *********** Fin del script de la tabla u820_adeuda_cuota**********

END IF;
END;
END PROCEDURE;
-- ************************** Fin del Procedimiento sp_crea_tabla_u820_adeuda_cuota **************************

--Ejecuto y borro los Procedimientos
EXECUTE PROCEDURE sp_crea_tabla_u820_adeuda_cuota();
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version Alfa 6.0
-- Tabla log_adeuda_cuota;
-- Tabla de Auditoria log_adeuda_cuota;
-- *******************************************************************************
--Borra el procedimiento si existe
CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_crea_tabla_log_adeuda_cuota') THEN
		DROP PROCEDURE sp_crea_tabla_log_adeuda_cuota;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();

-- Comienza el Procedimiento sp_crea_tabla_log_adeuda_cuota
CREATE PROCEDURE "dba".sp_crea_tabla_log_adeuda_cuota();

BEGIN

IF NOT EXISTS (SELECT * FROM systables where tabname = 'log_adeuda_cuota') THEN

CREATE TABLE log_adeuda_cuota (
          logid SERIAL(1),
       UNIDAD_ACADEMICA     varchar(5) NOT NULL,
       TIPO_DOCUMENTO       integer NOT NULL,
       NRO_DOCUMENTO        varchar(15) NOT NULL,
       MATERIA              varchar(5) NOT NULL,
       PERIODO_LECTIVO	varchar(20) NOT NULL,
       ANIO_ACADEMICO	varchar(10) NOT NULL,
       FECHA_IMPUTACION     date NOT NULL,
       TIPO_MODALIDAD	char (1), -- C: cursado; E: examen
       OBSERVACIONES        varchar(255),
       usuario      varchar(8) DEFAULT USER NOT NULL,
       fecha_act  DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND  NOT NULL,
       operacion CHAR(1) NOT NULL
);

ALTER TABLE log_adeuda_cuota
      ADD CONSTRAINT PRIMARY KEY ( logid );

-- Las tablas de log no pueden ser alteradas
revoke all on log_adeuda_cuota from public;
grant select on log_adeuda_cuota to public;
-- *********** Fin de tabla de auditoria de u820_adeuda_cuota;***********

END IF;
END;
END PROCEDURE;
-- ************************** Fin del Procedimiento sp_crea_tabla_log_adeuda_cuota **************************

--Ejecuto y borro los Procedimientos
EXECUTE PROCEDURE "dba".sp_crea_tabla_log_adeuda_cuota();
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


