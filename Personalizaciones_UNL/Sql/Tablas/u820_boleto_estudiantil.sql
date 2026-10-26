CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF NOT EXISTS (SELECT tabname
			FROM systables
			WHERE tabname = 'u820_boleto_estudiantil') THEN

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 1.1.0
-- Tabla u820_boleto_estudiantil
-- *******************************************************************************

CREATE TABLE "dba".u820_boleto_estudiantil (
       UNIDAD_ACADEMICA     varchar(5) NOT NULL,
       NRO_INSCRIPCION      varchar(10) NOT NULL,
       FECHA_RELEVAMIENTO   datetime year to second NOT NULL,
       BOLETO_ESTUDIANTIL   char(1) NOT NULL
);


ALTER TABLE "dba".u820_boleto_estudiantil
       ADD CONSTRAINT PRIMARY KEY (UNIDAD_ACADEMICA, NRO_INSCRIPCION, FECHA_RELEVAMIENTO)
              CONSTRAINT pk_boleto_estudiantil;



-- *********** Fin del script de la tabla u820_boleto_estudiantil **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.1.0
-- Tabla u820_boleto_estudiantil
-- Tabla de Auditoria log_boleto_estudiantil
-- *******************************************************************************
END IF;

	IF NOT EXISTS (SELECT tabname
			FROM systables
			WHERE tabname = 'log_boleto_estudiantil') THEN


CREATE TABLE "dba".log_boleto_estudiantil (
          logid SERIAL(1),
          unidad_academica varchar(5),
          nro_inscripcion varchar(10),
          fecha_relevamiento datetime year to second,
          boleto_estudiantil char(1),
          usuario      varchar(8) DEFAULT USER NOT NULL,
          fecha_act  DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND  NOT NULL,
          oper CHAR(1) NOT NULL
);

ALTER TABLE "dba".log_boleto_estudiantil
      ADD CONSTRAINT PRIMARY KEY ( logid );


-- *********** Fin de tabla de auditoria de u820_boleto_estudiantil ***********

	END IF;		
END
END PROCEDURE;


EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

revoke all on "dba".u820_boleto_estudiantil from public;
grant select, update, insert, delete on "dba".u820_boleto_estudiantil to internet; 
grant select, update, insert, delete on "dba".u820_boleto_estudiantil to guarani;


-- Las tablas de log no pueden ser alteradas
revoke all on "dba".log_boleto_estudiantil from public;
grant select on "dba".log_boleto_estudiantil to internet; 
grant select on "dba".log_boleto_estudiantil to guarani;