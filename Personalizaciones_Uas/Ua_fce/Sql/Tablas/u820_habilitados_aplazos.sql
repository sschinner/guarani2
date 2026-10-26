-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos - Personalización UNL
-- Versión 1.9.0
-- Tabla u820_habilitados
-- *******************************************************************************
-- DROP TABLE u820_habilitados;

CREATE PROCEDURE sp_crea_tabla_u820_habilitados();

BEGIN

IF NOT EXISTS (SELECT * FROM systables where tabname = 'u820_habilitados') THEN

CREATE TABLE u820_habilitados (
       UNIDAD_ACADEMICA     varchar(5) NOT NULL,
       CARRERA              varchar(5) NOT NULL,
       LEGAJO               varchar(15) NOT NULL,
       PLAN                 varchar(5) NOT NULL,
       VERSION varchar(5) NOT NULL,
       MATERIA              varchar(5) NOT NULL,
       CANT_APLAZOS	integer,
       FECHA_HABILITACION                date,
       OBSERVACIONES        varchar(255)
);

ALTER TABLE u820_habilitados
       ADD CONSTRAINT PRIMARY KEY (UNIDAD_ACADEMICA, CARRERA, LEGAJO, PLAN, VERSION, MATERIA, CANT_APLAZOS)
              CONSTRAINT pk_u820_habilitados;


ALTER TABLE u820_habilitados
       ADD CONSTRAINT FOREIGN KEY (UNIDAD_ACADEMICA, CARRERA, LEGAJO, PLAN)
                             REFERENCES sga_cambios_plan
              CONSTRAINT fk_u820_hab_cambios_p;

ALTER TABLE u820_habilitados
       ADD CONSTRAINT FOREIGN KEY (UNIDAD_ACADEMICA, CARRERA, PLAN, VERSION, MATERIA)
                             REFERENCES sga_atrib_mat_plan
              CONSTRAINT fk_u820_hab_atr_plan;


revoke all on u820_habilitados from public;
grant all on u820_habilitados to guarani;

END IF;
END;
END PROCEDURE;

EXECUTE PROCEDURE sp_crea_tabla_u820_habilitados();
DROP PROCEDURE sp_crea_tabla_u820_habilitados();


-- *********** Fin del script de la tabla u820_habilitados **********


-- *******************************************************************************
-- Tabla de Auditoria log_u820_habilitados
-- *******************************************************************************
-- DROP TABLE log_u820_habilitados;
CREATE PROCEDURE sp_crea_tabla_log_u820_habilitados();

BEGIN

IF NOT EXISTS (SELECT * FROM systables where tabname = 'log_u820_habilitados') THEN


CREATE TABLE log_u820_habilitados (
          logid SERIAL(1),
         UNIDAD_ACADEMICA     varchar(5) NOT NULL,
       CARRERA              varchar(5) NOT NULL,
       LEGAJO               varchar(15) NOT NULL,
       PLAN                 varchar(5) NOT NULL,
       MATERIA              varchar(5) NOT NULL,
       FECHA                date NOT NULL,
       CANT_APLAZOS	integer,
       OBSERVACIONES        varchar(255),
          usuario varchar(8) DEFAULT USER NOT NULL,
          fecha_act  DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND  NOT NULL,
          oper CHAR(1) NOT NULL
);

ALTER TABLE log_u820_habilitados
      ADD CONSTRAINT PRIMARY KEY ( logid );


-- Las tablas de log no pueden ser alteradas
revoke all on log_u820_habilitados from public;
grant select on log_u820_habilitados to public;

END IF;
END;
END PROCEDURE;

EXECUTE PROCEDURE sp_crea_tabla_log_u820_habilitados();
DROP PROCEDURE sp_crea_tabla_log_u820_habilitados();


-- *********** Fin de tabla de auditoria de log_u820_habilitados ***********
