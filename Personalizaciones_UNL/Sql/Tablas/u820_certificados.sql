CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF NOT EXISTS (SELECT tabname
			FROM systables
			WHERE tabname = 'u820_certificados') THEN

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_certificados
-- *******************************************************************************
-- DROP TABLE "dba".u820_certificados;
CREATE TABLE "dba".u820_certificados (
       	certificado     integer NOT NULL,
       	arancelado  char(1) DEFAULT 'S' NOT NULL,
       	dias_vencimiento_pago integer NOT NULL
);


ALTER TABLE "dba".u820_certificados
       ADD CONSTRAINT PRIMARY KEY (certificado)
              CONSTRAINT pk_u820_certificados;

ALTER TABLE "dba".u820_certificados
       ADD CONSTRAINT CHECK (arancelado IN ('S', 'N'))
              CONSTRAINT ck_arancelado;


-- *********** Fin del script de la tabla u820_certificados **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_certificados
-- Tabla de Auditoria log_u820_certificados
-- *******************************************************************************
END IF;

	IF NOT EXISTS (SELECT tabname
			FROM systables
			WHERE tabname = 'log_u820_certificados') THEN

-- DROP TABLE "dba".log_u820_certificados;
CREATE TABLE "dba".log_u820_certificados (
        logid SERIAL(1),
       	certificado     integer NOT NULL,
       	arancelado  char(1) DEFAULT 'S' NOT NULL,
       	dias_vencimiento_pago integer NOT NULL,
        usuario      varchar(8) DEFAULT USER NOT NULL,
        fecha_act  DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND  NOT NULL,
        oper CHAR(1) NOT NULL
);

ALTER TABLE "dba".log_u820_certificados
      ADD CONSTRAINT PRIMARY KEY ( logid );


-- *********** Fin de tabla de auditoria de u820_certificados ***********

	END IF;		
END
END PROCEDURE;


EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

revoke all on "dba".u820_certificados from public;
grant select, update, insert, delete on "dba".u820_certificados to internet; 
grant select, update, insert, delete on "dba".u820_certificados to guarani;


-- Las tablas de log no pueden ser alteradas
revoke all on "dba".log_u820_certificados from public;
grant select on "dba".log_u820_certificados to internet; 
grant select on "dba".log_u820_certificados to guarani;
