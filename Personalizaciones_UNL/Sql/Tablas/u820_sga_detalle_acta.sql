-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.7.0
-- Tabla u820_sga_det_acta
-- *******************************************************************************
CREATE PROCEDURE "dba".verifica_objeto();

BEGIN

IF NOT EXISTS (SELECT * FROM systables where tabname = 'u820_sga_det_acta') THEN

CREATE TABLE "dba".u820_sga_det_acta (
       UNIDAD_ACADEMICA     varchar(5) NOT NULL,
       TIPO_ACTA            char(1) NOT NULL,
       ACTA                 varchar(10) NOT NULL,
       CARRERA              varchar(5) NOT NULL,
       LEGAJO               varchar(15) NOT NULL,
       CONDICION_REG        integer NOT NULL
 
);


ALTER TABLE "dba".u820_sga_det_acta
       ADD CONSTRAINT PRIMARY KEY (UNIDAD_ACADEMICA, TIPO_ACTA, ACTA, 
              CARRERA, LEGAJO)
              CONSTRAINT pk820_detalle_acta;


-- *********** Fin del script de la tabla u820_sga_det_acta **********
END IF;
END;
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

revoke all on "dba".u820_sga_det_acta from public;
grant select, update, insert, delete on "dba".u820_sga_det_acta to guarani;
grant select, update, insert, delete on "dba".u820_sga_det_acta to internet;
