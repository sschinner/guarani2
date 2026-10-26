CREATE PROCEDURE "dba".verifica_objeto()
BEGIN

IF NOT EXISTS (SELECT tabname
			FROM systables
			WHERE tabname = 'u820_banco_sangre') THEN

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 1.1.0
-- Tabla u820_boleto_estudiantil
-- *******************************************************************************

CREATE TABLE "dba".u820_banco_sangre (
       UNIDAD_ACADEMICA     varchar(5) NOT NULL,
       NRO_INSCRIPCION      varchar(10) NOT NULL,
       FECHA_RELEVAMIENTO   datetime year to second NOT NULL,
       BANCO_SANGRE   char(1) NOT NULL
);


ALTER TABLE "dba".u820_banco_sangre
       ADD CONSTRAINT PRIMARY KEY (UNIDAD_ACADEMICA, NRO_INSCRIPCION, FECHA_RELEVAMIENTO)
              CONSTRAINT pk_banco_sangre;



-- *********** Fin del script de la tabla u820_banco_sangre **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.1.0
-- Tabla u820_banco_sangre
-- Tabla de Auditoria log_banco_sangre
-- *******************************************************************************
END IF;

IF NOT EXISTS (SELECT tabname
			FROM systables
			WHERE tabname = 'log_banco_sangre') THEN


CREATE TABLE log_banco_sangre (
          logid SERIAL(1),
          unidad_academica varchar(5),
          nro_inscripcion varchar(10),
          fecha_relevamiento datetime year to second,
          banco_sangre char(1),
          usuario      varchar(8) DEFAULT USER NOT NULL,
          fecha_act  DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND  NOT NULL,
          oper CHAR(1) NOT NULL
);

ALTER TABLE log_banco_sangre
      ADD CONSTRAINT PRIMARY KEY ( logid );


-- *********** Fin de tabla de auditoria de u820_banco_sangre ***********

END IF;		
END
END PROCEDURE;


EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

revoke all on "dba".u820_banco_sangre from public;
grant select, update, insert, delete on "dba".u820_banco_sangre to internet; 
grant select, update, insert, delete on "dba".u820_banco_sangre to guarani;

-- Las tablas de log no pueden ser alteradas
revoke all on "dba".log_banco_sangre from public;
grant select on "dba".log_banco_sangre to guarani;
grant select on "dba".log_banco_sangre to internet;