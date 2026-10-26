CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF NOT EXISTS (SELECT tabname
			FROM systables
			WHERE tabname = 'u820_encuesta_egr') THEN

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.7.0
-- Tabla u820_encuesta_egr
-- *******************************************************************************

CREATE TABLE "dba".u820_encuesta_egr (
       UNIDAD_ACADEMICA     varchar(5) NOT NULL,
       NRO_INSCRIPCION      varchar(10) NOT NULL,
       TITULO      varchar(5) NOT NULL,
       FECHA_RELEVAMIENTO   datetime year to second NOT NULL,
       CUMPLIDA   char(1) NOT NULL,
       NRO_TRANSACCION varchar(20) NOT NULL
);


ALTER TABLE "dba".u820_encuesta_egr
       ADD CONSTRAINT PRIMARY KEY (UNIDAD_ACADEMICA, NRO_INSCRIPCION, TITULO)
              CONSTRAINT pk_encuesta_egr;


ALTER TABLE "dba".u820_encuesta_egr
	ADD CONSTRAINT FOREIGN KEY (UNIDAD_ACADEMICA, NRO_INSCRIPCION, TITULO)
                             REFERENCES SGA_TITULOS_OTORG
              CONSTRAINT fk_u820_encuesta_egr_tit_otor;


-- *********** Fin del script de la tabla u820_encuesta_egr **********


-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.7.0
-- Tabla u820_encuesta_egr
-- Tabla de Auditoria log_encuesta_egr
-- *******************************************************************************
END IF;

	IF NOT EXISTS (SELECT tabname
			FROM systables
			WHERE tabname = 'log_encuesta_egr') THEN


CREATE TABLE "dba".log_encuesta_egr (
          logid SERIAL(1),
          unidad_academica varchar(5),
          nro_inscripcion varchar(10),
          titulo varchar(5),
          fecha_relevamiento datetime year to second,
          cumplida char(1),
          nro_transaccion varchar(20),
          usuario      varchar(8) DEFAULT USER NOT NULL,
          fecha_act  DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND  NOT NULL,
          oper CHAR(1) NOT NULL
);

ALTER TABLE "dba".log_encuesta_egr
      ADD CONSTRAINT PRIMARY KEY ( logid );


-- *********** Fin de tabla de auditoria de u820_encuesta_egr ***********

	END IF;		
END
END PROCEDURE;


EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

revoke all on "dba".u820_encuesta_egr from public;
grant select, update, insert, delete on "dba".u820_encuesta_egr to internet; 
grant select, update, insert, delete on "dba".u820_encuesta_egr to guarani;

-- Las tablas de log no pueden ser alteradas
revoke all on "dba".log_encuesta_egr from public;
grant select on "dba".log_encuesta_egr to internet; 
grant select on "dba".log_encuesta_egr to guarani;