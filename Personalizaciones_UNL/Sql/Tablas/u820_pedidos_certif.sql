CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF NOT EXISTS (SELECT tabname
			FROM systables
			WHERE tabname = 'u820_pedidos_certif') THEN

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_pedidos_certif
-- *******************************************************************************
-- DROP TABLE "dba".u820_pedidos_certif;
CREATE TABLE "dba".u820_pedidos_certif (
       	id_certif_pedido     integer NOT NULL,
	estado_pago char(1) DEFAULT 'N' NOT NULL,
       	validado     char(1) DEFAULT 'N' NOT NULL,
       	fecha_vencimiento_pago date NOT NULL,
       	hash_pago   varchar(255) NOT NULL,
	identificador_cobro varchar(255) NOT NULL,
	expediente varchar(255),
	url_descarga varchar(255)
);


ALTER TABLE "dba".u820_pedidos_certif
       ADD CONSTRAINT PRIMARY KEY (id_certif_pedido)
              CONSTRAINT pk_u820_pedidos_certif;

ALTER TABLE "dba".u820_pedidos_certif
       ADD CONSTRAINT CHECK (estado_pago IN ('P', 'N', 'M'))
              CONSTRAINT ck_estado_pago;

ALTER TABLE "dba".u820_pedidos_certif
       ADD CONSTRAINT CHECK (validado IN ('S', 'N'))
              CONSTRAINT ck_validado;

ALTER TABLE "dba".u820_pedidos_certif
       ADD CONSTRAINT FOREIGN KEY (id_certif_pedido)
		REFERENCES "dba".sga_certif_pedidos
	CONSTRAINT fk_u820_ped_cert_sga_cert_ped;

create unique index in_hashpedidocertif on "dba".u820_pedidos_certif (hash_pago);
create unique index in_identpedidocertif on "dba".u820_pedidos_certif (identificador_cobro);

-- *********** Fin del script de la tabla u820_pedidos_certif **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_pedidos_certif
-- Tabla de Auditoria log_u820_pedidos_certif
-- *******************************************************************************
END IF;

	IF NOT EXISTS (SELECT tabname
			FROM systables
			WHERE tabname = 'log_u820_pedidos_certif') THEN

-- DROP TABLE "dba".log_u820_pedidos_certif;
CREATE TABLE "dba".log_u820_pedidos_certif (
        logid SERIAL(1),
       	id_certif_pedido     integer NOT NULL,
	estado_pago char(1) DEFAULT 'N' NOT NULL,
       	validado     char(1) DEFAULT 'N' NOT NULL,
       	fecha_vencimiento_pago date NOT NULL,
       	hash_pago   varchar(255) NOT NULL,
	identificador_cobro varchar(255),
	expediente varchar(255),
	url_descarga varchar(255),
        usuario      varchar(8) DEFAULT USER NOT NULL,
        fecha_act  DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND  NOT NULL,
        oper CHAR(1) NOT NULL
);

ALTER TABLE "dba".log_u820_pedidos_certif
      ADD CONSTRAINT PRIMARY KEY ( logid );


-- *********** Fin de tabla de auditoria de u820_pedidos_certif ***********

	END IF;		
END
END PROCEDURE;


EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

revoke all on "dba".u820_pedidos_certif from public;
grant select, update, insert, delete on "dba".u820_pedidos_certif to internet; 
grant select, update, insert, delete on "dba".u820_pedidos_certif to guarani;


-- Las tablas de log no pueden ser alteradas
revoke all on "dba".log_u820_pedidos_certif from public;
grant select on "dba".log_u820_pedidos_certif to internet; 
grant select on "dba".log_u820_pedidos_certif to guarani;


ALTER TABLE "dba".u820_pedidos_certif
       ADD (motivorechazo varchar(255));
ALTER TABLE "dba".log_u820_pedidos_certif
       ADD (motivorechazo varchar(255));