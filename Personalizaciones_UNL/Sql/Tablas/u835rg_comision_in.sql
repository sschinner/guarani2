-- *******************************************************************************
-- SIU - SGA - Sistema de Gestión de Alumnos
-- Versión 1.5.0
-- Tabla u835rg_comision_in
-- *******************************************************************************
CREATE PROCEDURE "dba".sp_crea_tabla_u835rg_comision_in();

BEGIN

IF NOT EXISTS (SELECT * FROM systables where tabname = 'u835rg_comision_in') THEN


CREATE TABLE "dba".u835rg_comision_in (
        unidad_academica     varchar(5) NOT NULL,
        anio_academico       integer NOT NULL,
        periodo_lectivo      varchar(20) NOT NULL,
        carrera              varchar(5) NOT NULL ,
        comision             integer NOT NULL,
        calidad_insc         char(1)  NOT NULL-- P= Promoción R= Regularizar A= Automatico según escala de la comision
);


ALTER TABLE "dba".u835rg_comision_in
       ADD CONSTRAINT PRIMARY KEY (unidad_academica, anio_academico, periodo_lectivo, carrera, comision)
              CONSTRAINT pk_u835rg_com_in;


-- *********** Fin del script de la tabla u835rg_comision_in **********


ALTER TABLE "dba".u835rg_comision_in
       ADD CONSTRAINT FOREIGN KEY (COMISION)
                             REFERENCES sga_comisiones
              CONSTRAINT fk_u835rg_coin_co;

ALTER TABLE "dba".u835rg_comision_in
       ADD CONSTRAINT FOREIGN KEY (ANIO_ACADEMICO, PERIODO_LECTIVO)
                             REFERENCES sga_periodos_lect
              CONSTRAINT fk_u835rg_co_pelec;


END IF;
END;
END PROCEDURE;

EXECUTE PROCEDURE "dba".sp_crea_tabla_u835rg_comision_in();
DROP PROCEDURE "dba".sp_crea_tabla_u835rg_comision_in ();

revoke all on "dba".u835rg_comision_in from public;
grant select, update, insert, delete on "dba".u835rg_comision_in to guarani;
grant select, update, insert, delete on "dba".u835rg_comision_in to internet;