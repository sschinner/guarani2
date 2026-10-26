CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
    IF NOT EXISTS (SELECT tabname
                    FROM systables
                    WHERE tabname = 'u820_pedidos_certif_diploma_req') 
    THEN

    -- *******************************************************************************
    -- SIU - SGA - Sistema de Gestion de Alumnos
    -- Versión 2.9.2
    -- Tabla u820_pedidos_certif_diploma_req
    -- *******************************************************************************
    -- DROP TABLE "dba".u820_pedidos_certif_diploma_req;
    CREATE TABLE "dba".u820_pedidos_certif_diploma_req (
        id_certif_pedido    integer NOT NULL,
        requisito           VARCHAR(5) NOT NULL,
        hash_notificacion   varchar(255),
        url                 varchar(255),
        fecha_actualizacion date NOT NULL
    );

    ALTER TABLE "dba".u820_pedidos_certif_diploma_req
           ADD CONSTRAINT PRIMARY KEY (id_certif_pedido, requisito)
                  CONSTRAINT pk_u820_pedidos_certif_diploma_req;

    ALTER TABLE "dba".u820_pedidos_certif_diploma_req
           ADD CONSTRAINT FOREIGN KEY (id_certif_pedido)
                    REFERENCES "dba".u820_pedidos_certif
            CONSTRAINT fk_u820_ped_dip_req_u820_ped_cert; 

    END IF;

    -- *********** Fin del script de la tabla u820_pedidos_certif_diploma_req **********

    -- *******************************************************************************
    -- SIU - SGA - Sistema de Gestion de Alumnos
    -- Versión 2.9.2
    -- Tabla u820_pedidos_certif_diploma_req
    -- Tabla de Auditoria log_u820_pedidos_certif_diploma_req
    -- *******************************************************************************
    IF NOT EXISTS (SELECT tabname
                    FROM systables
                    WHERE tabname = 'log_u820_pedidos_certif_diploma_req') 
    THEN

    -- DROP TABLE "dba".log_u820_pedidos_certif_diploma_req;
    CREATE TABLE "dba".log_u820_pedidos_certif_diploma_req (
            logid               SERIAL(1),
            id_certif_pedido    integer NOT NULL,
            requisito           VARCHAR(5),
            hash_notificacion   varchar(255),
            url                 varchar(255),
            fecha_actualizacion date,
            usuario             varchar(8) DEFAULT USER NOT NULL,
            fecha_act           DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND  NOT NULL,
            oper                CHAR(1) NOT NULL
    );

    ALTER TABLE "dba".log_u820_pedidos_certif_diploma_req
          ADD CONSTRAINT PRIMARY KEY ( logid );
    
    END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

revoke all on "dba".u820_pedidos_certif_diploma_req from public;
grant select, update, insert, delete on "dba".u820_pedidos_certif_diploma_req to internet; 
grant select, update, insert, delete on "dba".u820_pedidos_certif_diploma_req to guarani;

-- Las tablas de log no pueden ser alteradas
revoke all on "dba".log_u820_pedidos_certif_diploma_req from public;
grant select on "dba".log_u820_pedidos_certif_diploma_req to internet; 
grant select on "dba".log_u820_pedidos_certif_diploma_req to guarani;
