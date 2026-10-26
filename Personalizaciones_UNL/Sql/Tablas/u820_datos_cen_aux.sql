-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.00.0
-- Tabla u820_datos_cen_aux
-- Select * from u820_datos_cen_aux;
-- *******************************************************************************
CREATE PROCEDURE "dba".verifica_objeto();

BEGIN

IF NOT EXISTS (SELECT * FROM systables where tabname = 'u820_datos_cen_aux') THEN

CREATE TABLE "dba".u820_datos_cen_aux (
       UNIDAD_ACADEMICA		varchar(5) NOT NULL,
       NRO_INSCRIPCION		varchar(10) NOT NULL,
       FECHA_RELEVAMIENTO	date NOT NULL,
       SIT_LABORAL_PAREJA		integer,
       SECTOR_ACT_ECON		integer
);


ALTER TABLE "dba".u820_datos_cen_aux
       ADD CONSTRAINT PRIMARY KEY (UNIDAD_ACADEMICA, NRO_INSCRIPCION, 
              FECHA_RELEVAMIENTO)
              CONSTRAINT pku820_d_cen_aux;

ALTER TABLE "dba".u820_datos_cen_aux ADD (coopera char);
ALTER TABLE "dba".u820_datos_cen_aux ADD (ult_est_cur_pareja integer);
ALTER TABLE "dba".u820_datos_cen_aux ADD (red_social1 varchar(255));
ALTER TABLE "dba".u820_datos_cen_aux ADD (red_social2 varchar(255));
ALTER TABLE "dba".u820_datos_cen_aux ADD (red_social3 varchar(255));
ALTER TABLE "dba".u820_datos_cen_aux ADD (pais_uni_est_sup integer); --(Pais en caso de ser extrajero. Si es extranjero )
ALTER TABLE "dba".u820_datos_cen_aux ADD (inst_uni_est_sup integer); -- (institucion argentina)
ALTER TABLE "dba".u820_datos_cen_aux ADD (alu_otestsup_cant_mat integer); -- (cantidad de materias aprobadas)
ALTER TABLE "dba".u820_datos_cen_aux ADD (cant_hora_sem_trab_alum integer); --(cantidad numerica de horas)
ALTER TABLE "dba".u820_datos_cen_aux ADD (alu_req_acces_fisica char(1));
ALTER TABLE "dba".u820_datos_cen_aux ADD (alu_req_acces_com integer); --codificación de tabla nueva: u820_req_comunicacion



-- *********** Fin del script de la tabla u820_datos_cen_aux **********
END IF;
END;
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

revoke all on u820_datos_cen_aux from public;
grant select, update, insert, delete on u820_datos_cen_aux to guarani;
grant select, update, insert, delete on u820_datos_cen_aux to internet;