CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
    IF NOT EXISTS (SELECT tabname
                    FROM systables
                    WHERE tabname = 'u820_pedidos_certif_diploma') 
    THEN

    -- *******************************************************************************
    -- SIU - SGA - Sistema de Gestion de Alumnos
    -- Versión 2.9.2
    -- Tabla u820_pedidos_certif_diploma
    -- *******************************************************************************
    -- DROP TABLE "dba".u820_pedidos_certif_diploma;
    CREATE TABLE "dba".u820_pedidos_certif_diploma (
        id_certif_pedido            integer NOT NULL,
        imprenta                    char(1) DEFAULT 'S' NOT NULL,
        requisitos_validados        char(1) DEFAULT 'N' NOT NULL,
        url_titulo_tramite          varchar(255),
        url_certificado_analitico   varchar(255),
        carrera                     varchar(5) NOT NULL,
        titulo                      varchar(5) NOT NULL,
        autorizado_apellido         varchar (100),
        autorizado_nombre           varchar (100),
        autorizado_documento        varchar (100)
    );

    ALTER TABLE "dba".u820_pedidos_certif_diploma
           ADD CONSTRAINT PRIMARY KEY (id_certif_pedido)
                  CONSTRAINT pk_u820_pedidos_certif_diploma;

    ALTER TABLE "dba".u820_pedidos_certif_diploma
           ADD CONSTRAINT CHECK (imprenta IN ('S', 'N'))
                  CONSTRAINT ck_imprenta;

    ALTER TABLE "dba".u820_pedidos_certif_diploma
           ADD CONSTRAINT CHECK (requisitos_validados IN ('S', 'N'))
                  CONSTRAINT ck_requisitos_validados;

    ALTER TABLE "dba".u820_pedidos_certif_diploma
           ADD CONSTRAINT FOREIGN KEY (id_certif_pedido)
                    REFERENCES "dba".u820_pedidos_certif
            CONSTRAINT fk_u820_ped_dip_u820_ped_cert; 

    END IF;

    -- *********** Fin del script de la tabla u820_pedidos_certif_diploma **********

    -- *******************************************************************************
    -- SIU - SGA - Sistema de Gestion de Alumnos
    -- Versión 2.9.2
    -- Tabla u820_pedidos_certif_diploma
    -- Tabla de Auditoria log_u820_pedidos_certif_diploma
    -- *******************************************************************************
    IF NOT EXISTS (SELECT tabname
                    FROM systables
                    WHERE tabname = 'log_u820_pedidos_certif_diploma') 
    THEN

    -- DROP TABLE "dba".log_u820_pedidos_certif_diploma;
    CREATE TABLE "dba".log_u820_pedidos_certif_diploma (
            logid                   SERIAL(1),
            id_certif_pedido        integer NOT NULL,
            imprenta                char(1) DEFAULT 'S' NOT NULL,
            requisitos_validados    char(1) DEFAULT 'N' NOT NULL,
            url_titulo_tramite      varchar(255),
            url_certificado_analitico varchar(255),
            carrera                 varchar(5),
            titulo                  varchar(5),
            autorizado_apellido         varchar (100),
            autorizado_nombre           varchar (100),
            autorizado_documento        varchar (100),
            usuario                 varchar(8) DEFAULT USER NOT NULL,
            fecha_act               DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND  NOT NULL,
            oper                    CHAR(1) NOT NULL
    );

    ALTER TABLE "dba".log_u820_pedidos_certif_diploma
          ADD CONSTRAINT PRIMARY KEY ( logid );
    
    END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

revoke all on "dba".u820_pedidos_certif_diploma from public;
grant select, update, insert, delete on "dba".u820_pedidos_certif_diploma to internet; 
grant select, update, insert, delete on "dba".u820_pedidos_certif_diploma to guarani;

-- Las tablas de log no pueden ser alteradas
revoke all on "dba".log_u820_pedidos_certif_diploma from public;
grant select on "dba".log_u820_pedidos_certif_diploma to internet; 
grant select on "dba".log_u820_pedidos_certif_diploma to guarani;