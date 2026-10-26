-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.00.0
-- Tabla u820_pasantias
-- *******************************************************************************
-- DROP TABLE u820_pasantias;
CREATE TABLE u820_pasantias (
	UNIDAD_ACADEMICA		varchar(5) NOT NULL,
	ID_PASANTIA			integer  NOT NULL,
	DETALLE			varchar(60) NOT NULL,
	SOLICITANTE			integer NOT NULL,
	FECHA_INICIO			date NOT NULL,
	FECHA_FIN			date NOT NULL,
	FECHA_TOPE_BAJAS		date NOT NULL,
	CNT_MATERIAS			integer,
	POR_CARRERA			integer);


ALTER TABLE u820_pasantias
       ADD CONSTRAINT PRIMARY KEY (UNIDAD_ACADEMICA, ID_PASANTIA)
              CONSTRAINT pk_u820_pasantias;

alter table u820_pasantias add  CNT_MAX_MATERIAS integer;
alter table u820_pasantias add  POR_MAX_CARRERA integer;

revoke all on u820_pasantias from public;
-- *********** Fin del script de la tabla u820_pasantias **********

-- *****************************************************************************
-- Permisos de la tabla u820_pasantias
-- *****************************************************************************
grant SELECT, INSERT, UPDATE, DELETE on u820_pasantias to public;
grant SELECT on u820_pasantias to public;
-- *****************************************************************************








-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.00.0
-- Tabla u820_planes_pas
-- *******************************************************************************
-- DROP TABLE u820_planes_pas;
CREATE TABLE u820_planes_pas (
	UNIDAD_ACADEMICA		varchar(5) NOT NULL,
	ID_PASANTIA			integer NOT NULL,
	CARRERA			varchar(5) NOT NULL,
	PLAN				varchar(5) NOT NULL);


ALTER TABLE u820_planes_pas
       ADD CONSTRAINT PRIMARY KEY (UNIDAD_ACADEMICA, ID_PASANTIA, CARRERA, PLAN)
              CONSTRAINT pk_u820_planes_pas;

revoke all on u820_planes_pas from public;
-- *********** Fin del script de la tabla u820_planes_pas **********

-- *****************************************************************************
-- Permisos de la tabla u820_planes_pas
-- *****************************************************************************
grant SELECT, INSERT, UPDATE, DELETE on u820_planes_pas to public;
grant SELECT on u820_planes_pas to public;
-- *****************************************************************************








-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.00.0
-- Tabla u820_cond_pas
-- *******************************************************************************
-- DROP TABLE u820_cond_pas;
CREATE TABLE u820_cond_pas (
	UNIDAD_ACADEMICA		varchar(5) NOT NULL,
	ID_PASANTIA			integer NOT NULL,
	CARRERA			varchar(5) NOT NULL,
	PLAN				varchar(5) NOT NULL,
	MATERIA			varchar(5) NOT NULL,
	CONDICION			char(1)  NOT NULL);


ALTER TABLE u820_cond_pas
       ADD CONSTRAINT PRIMARY KEY (UNIDAD_ACADEMICA, ID_PASANTIA, CARRERA, PLAN, MATERIA)
              CONSTRAINT pk_u820_cond_pas;

revoke all on u820_cond_pas from public;
-- *********** Fin del script de la tabla u820_cond_pas **********

-- *****************************************************************************
-- Permisos de la tabla u820_pasantias
-- *****************************************************************************
grant SELECT, INSERT, UPDATE, DELETE on u820_cond_pas to public;
grant SELECT on u820_cond_pas to public;
-- *****************************************************************************








-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.00.0
-- Tabla u820_cond_esp_pas
-- *******************************************************************************
-- DROP TABLE u820_cond_esp_pas;
CREATE TABLE u820_cond_esp_pas (
       UNIDAD_ACADEMICA		varchar(5) NOT NULL,
       ID_PASANTIA			integer  NOT NULL,
       FUNCION_VALIDACION		varchar(40) NOT NULL,
       DESCRIPCION			char(45)  NOT NULL);


ALTER TABLE u820_cond_esp_pas
       ADD CONSTRAINT PRIMARY KEY (UNIDAD_ACADEMICA, ID_PASANTIA, FUNCION_VALIDACION)
              CONSTRAINT pk_u820_cond_esp_pas;

revoke all on u820_cond_esp_pas from public;
-- *********** Fin del script de la tabla u820_cond_esp_pas **********

-- *****************************************************************************
-- Permisos de la tabla u820_pasantias
-- *****************************************************************************
grant SELECT, INSERT, UPDATE, DELETE on u820_cond_esp_pas to public;
grant SELECT on u820_cond_esp_pas to public;
-- *****************************************************************************








-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.00.0
-- Tabla u820_solicit_pas
-- *******************************************************************************
-- DROP TABLE u820_solicit_pas;
CREATE TABLE u820_solicit_pas (
       UNIDAD_ACADEMICA		varchar(5) NOT NULL,
       SOLICITANTE			integer NOT NULL,
       RAZON_SOCIAL		varchar(60) NOT NULL);


ALTER TABLE u820_solicit_pas
       ADD CONSTRAINT PRIMARY KEY (UNIDAD_ACADEMICA, SOLICITANTE)
              CONSTRAINT pk_u820_solicit_pas;

revoke all on u820_solicit_pas from public;
-- *********** Fin del script de la tabla u820_solicit_pas **********

-- *****************************************************************************
-- Permisos de la tabla u820_solicit_pas
-- *****************************************************************************
grant SELECT, INSERT, UPDATE, DELETE on u820_solicit_pas to public;
grant SELECT on u820_solicit_pas to public;
-- *****************************************************************************







-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.00.0
-- Tabla u820_insc_pas
-- *******************************************************************************
-- DROP TABLE u820_insc_pas;
CREATE TABLE u820_insc_pas (
	UNIDAD_ACADEMICA	varchar(5) NOT NULL,
	NRO_INSCRIPCION	varchar(10) NOT NULL,
	LEGAJO			varchar(15) NOT NULL,
	CARRERA		varchar(5) NOT NULL,
	PLAN			varchar(5) NOT NULL,
	ID_PASANTIA		integer NOT NULL,
	FECHA_INSCRIPCION	datetime year to second NOT NULL,
	NRO_TRANSACCION	varchar(20) NOT NULL,
	INTERFAZ		integer NOT NULL,
	ESTADO			char(1) NOT NULL);


ALTER TABLE u820_insc_pas
       ADD CONSTRAINT PRIMARY KEY (UNIDAD_ACADEMICA, NRO_INSCRIPCION, ID_PASANTIA)
              CONSTRAINT pk_u820_insc_pas;

revoke all on u820_insc_pas from public;
-- *********** Fin del script de la tabla u820_insc_pas **********

-- *****************************************************************************
-- Permisos de la tabla u820_insc_pas
-- *****************************************************************************
grant SELECT, INSERT, UPDATE, DELETE on u820_insc_pas to public;
grant SELECT on u820_insc_pas to public;
-- *****************************************************************************


-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 1.1.0
-- Tabla u820_insc_baja_pas
-- *******************************************************************************
DROP TABLE u820_insc_baja_pas;
CREATE TABLE u820_insc_baja_pas (
  	UNIDAD_ACADEMICA	varchar(5) NOT NULL,
	NRO_INSCRIPCION	varchar(10) NOT NULL,
	LEGAJO			varchar(15) NOT NULL,
	CARRERA		varchar(5) NOT NULL,
	PLAN			varchar(5) NOT NULL,
	ID_PASANTIA		integer NOT NULL,
	FECHA_INSCRIPCION	datetime year to second NOT NULL,
	NRO_TRANSACCION	varchar(20) NOT NULL,
	INTERFAZ		integer NOT NULL,
	ESTADO			char(1) NOT NULL,
	FECHA_BAJA           datetime year to second NOT NULL,
	NRO_TRANSAC_BAJA     varchar(20) NOT NULL,
	INTERFAZ_BAJA        integer NOT NULL
);


ALTER TABLE u820_insc_baja_pas 
       ADD CONSTRAINT PRIMARY KEY (UNIDAD_ACADEMICA, NRO_INSCRIPCION, ID_PASANTIA, FECHA_BAJA)
              CONSTRAINT pk_u820_insc_baja_bajas;

grant all on u820_insc_baja_pas to public;
-- *********** Fin del script de la tabla u820_insc_baja_pas **********




-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.00.0
-- Tabla u820_mat_exc_pas
-- *******************************************************************************
-- DROP TABLE u820_mat_exc_pas;
CREATE TABLE u820_mat_exc_pas (
	UNIDAD_ACADEMICA		varchar(5) NOT NULL,
	CARRERA			varchar(5) NOT NULL,
	PLAN				varchar(5) NOT NULL,
	MATERIA			varchar(5) NOT NULL);


ALTER TABLE u820_mat_exc_pas
       ADD CONSTRAINT PRIMARY KEY (UNIDAD_ACADEMICA, CARRERA, PLAN, MATERIA)
              CONSTRAINT pk_u820_mat_exc_pas;

revoke all on u820_mat_exc_pas from public;
-- *********** Fin del script de la tabla u820_cond_pas **********



-- *****************************************************************************
-- Permisos de la tabla u820_pasantias
-- *****************************************************************************
grant SELECT, INSERT, UPDATE, DELETE on u820_cond_pas to public;
grant SELECT on u820_cond_pas to public;
-- *****************************************************************************


-- *****************************************************************************
-- Foreing key
-- *****************************************************************************
ALTER TABLE u820_planes_pas DROP CONSTRAINT fk_planes_pasant;
ALTER TABLE u820_cond_pas DROP CONSTRAINT fk_cond_pasant;
ALTER TABLE u820_cond_esp_pas DROP CONSTRAINT fk_cond_esp_pas;
ALTER TABLE u820_pasantias DROP CONSTRAINT fk_sol_pas;
ALTER TABLE u820_insc_pas DROP CONSTRAINT fk_insc_pasant;
ALTER TABLE u820_insc_pas DROP CONSTRAINT fk_insc_pas_per;
ALTER TABLE u820_insc_baja_pas DROP CONSTRAINT fk_insc_b_pasant;
ALTER TABLE u820_insc_baja_pas DROP CONSTRAINT fk_insc_b_pas_per;


ALTER TABLE u820_planes_pas
       ADD CONSTRAINT FOREIGN KEY (UNIDAD_ACADEMICA, ID_PASANTIA)
                             REFERENCES u820_pasantias
              CONSTRAINT fk_planes_pasant;

ALTER TABLE u820_cond_pas
       ADD CONSTRAINT FOREIGN KEY (UNIDAD_ACADEMICA, ID_PASANTIA, CARRERA, PLAN)
                             REFERENCES u820_planes_pas
              CONSTRAINT fk_cond_pasant;

ALTER TABLE u820_cond_esp_pas
       ADD CONSTRAINT FOREIGN KEY (UNIDAD_ACADEMICA, ID_PASANTIA)
                             REFERENCES u820_pasantias
              CONSTRAINT fk_cond_esp_pas;

ALTER TABLE u820_pasantias
       ADD CONSTRAINT FOREIGN KEY (UNIDAD_ACADEMICA, SOLICITANTE)
                             REFERENCES u820_solicit_pas
              CONSTRAINT fk_sol_pas;

ALTER TABLE u820_insc_pas
       ADD CONSTRAINT FOREIGN KEY (UNIDAD_ACADEMICA, ID_PASANTIA)
                             REFERENCES u820_pasantias
              CONSTRAINT fk_insc_pasant;

ALTER TABLE u820_insc_pas
       ADD CONSTRAINT FOREIGN KEY (UNIDAD_ACADEMICA, CARRERA, LEGAJO)
                             REFERENCES sga_alumnos
              CONSTRAINT fk_insc_pas_per;

ALTER TABLE u820_insc_baja_pas 
       ADD CONSTRAINT FOREIGN KEY (UNIDAD_ACADEMICA, ID_PASANTIA)
                             REFERENCES u820_pasantias
              CONSTRAINT fk_insc_b_pasant;

ALTER TABLE u820_insc_baja_pas 
       ADD CONSTRAINT FOREIGN KEY (UNIDAD_ACADEMICA, CARRERA, LEGAJO)
                             REFERENCES sga_alumnos
              CONSTRAINT fk_insc_b_pas_per;
-- *****************************************************************************
-- *****************************************************************************




