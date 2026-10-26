-- *******************************************************************************
-- Tabla de Auditoria log_usuarios
-- *******************************************************************************
CREATE PROCEDURE "dba".sp_crea_tabla_usuarios();

BEGIN

IF NOT EXISTS (SELECT * FROM systables where tabname = 'log_usuarios') THEN

CREATE TABLE "dba".log_usuarios (
          logid SERIAL(1),
	usuario_g VARCHAR(8) NOT NULL,
	nombre VARCHAR(40) NOT NULL, 
	perfil VARCHAR(8) NOT NULL, 
	clave VARCHAR(40),
          usuario varchar(8) DEFAULT USER NOT NULL,
          fecha_act  DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND  NOT NULL,
          oper CHAR(1) NOT NULL
);

ALTER TABLE "dba".log_usuarios
      ADD CONSTRAINT PRIMARY KEY ( logid );


-- *********** Fin de tabla de auditoria de  acc_usuarios ***********

END IF;

-- *******************************************************************************
-- Tabla de Auditoria log_perfiles
-- *******************************************************************************

IF NOT EXISTS (SELECT * FROM systables where tabname = 'log_perfiles') THEN

CREATE TABLE "dba".log_perfiles (
          logid SERIAL(1),
	perfil VARCHAR(8) NOT NULL, 
	nombre VARCHAR(40) NOT NULL, 
	bitmap VARCHAR(40),
          usuario varchar(8) DEFAULT USER NOT NULL,
          fecha_act  DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND  NOT NULL,
          oper CHAR(1) NOT NULL
);

ALTER TABLE "dba".log_perfiles
      ADD CONSTRAINT PRIMARY KEY ( logid );


-- *********** Fin de tabla de auditoria de  acc_perfiles ***********
END IF;

-- *******************************************************************************
-- Tabla de Auditoria log_modulos_perfil
-- *******************************************************************************

IF NOT EXISTS (SELECT * FROM systables where tabname = 'log_modulos_perfil') THEN

CREATE TABLE "dba".log_modulos_perfil (
          logid SERIAL(1),
	perfil VARCHAR(8) NOT NULL, 
	modulo VARCHAR(8) NOT NULL,
          usuario varchar(8) DEFAULT USER NOT NULL,
          fecha_act  DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND  NOT NULL,
          oper CHAR(1) NOT NULL
);

ALTER TABLE "dba".log_modulos_perfil
      ADD CONSTRAINT PRIMARY KEY ( logid );


-- *********** Fin de tabla de auditoria de  acc_modulos_perfil ***********
END IF;

-- *******************************************************************************
-- Tabla de Auditoria log_operacion_mod
-- *******************************************************************************

IF NOT EXISTS (SELECT * FROM systables where tabname = 'log_operacion_mod') THEN

CREATE TABLE "dba".log_operacion_mod (
          logid SERIAL(1),
	modulo VARCHAR(8) NOT NULL, 
	operacion VARCHAR(8) NOT NULL, 
	submodulo VARCHAR(8) NOT NULL, 
	orden INTEGER NOT NULL,
          usuario varchar(8) DEFAULT USER NOT NULL,
          fecha_act  DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND  NOT NULL,
          oper CHAR(1) NOT NULL
);

ALTER TABLE "dba".log_operacion_mod
      ADD CONSTRAINT PRIMARY KEY ( logid );


-- *********** Fin de tabla de auditoria de  acc_operacion_mod ***********
END IF;

-- *******************************************************************************
-- Tabla de Auditoria log_operaciones
-- *******************************************************************************

IF NOT EXISTS (SELECT * FROM systables where tabname = 'log_operaciones') THEN

CREATE TABLE "dba".log_operaciones (
          logid SERIAL(1),
	operacion VARCHAR(8) NOT NULL, 
	nombre VARCHAR(60) NOT NULL, 
	descripcion VARCHAR(255), 
	bitmap VARCHAR(40),
          usuario varchar(8) DEFAULT USER NOT NULL,
          fecha_act  DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND  NOT NULL,
          oper CHAR(1) NOT NULL
);

ALTER TABLE log_operaciones
      ADD CONSTRAINT PRIMARY KEY ( logid );


-- *********** Fin de tabla de auditoria de  acc_operaciones ***********

END IF;

-- *******************************************************************************
-- Tabla de Auditoria log_modulos
-- *******************************************************************************

IF NOT EXISTS (SELECT * FROM systables where tabname = 'log_modulos') THEN

CREATE TABLE "dba".log_modulos (
          logid SERIAL(1),
	modulo VARCHAR(8) NOT NULL, 
	nombre VARCHAR(40) NOT NULL, 
	bitmap VARCHAR(40),
          usuario varchar(8) DEFAULT USER NOT NULL,
          fecha_act  DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND  NOT NULL,
          oper CHAR(1) NOT NULL
);

ALTER TABLE "dba".log_modulos 
      ADD CONSTRAINT PRIMARY KEY ( logid );


-- *********** Fin de tabla de auditoria de  acc_modulos ***********

END IF;

-- *******************************************************************************
-- Tabla de Auditoria log_submodulos
-- *******************************************************************************

IF NOT EXISTS (SELECT * FROM systables where tabname = 'log_submodulos') THEN

CREATE TABLE "dba".log_submodulos (
          logid SERIAL(1),
	submodulo VARCHAR(8) NOT NULL, 
	nombre VARCHAR(40) NOT NULL, 
	bitmap VARCHAR(40),
          usuario varchar(8) DEFAULT USER NOT NULL,
          fecha_act  DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND  NOT NULL,
          oper CHAR(1) NOT NULL
);

ALTER TABLE "dba".log_submodulos 
      ADD CONSTRAINT PRIMARY KEY ( logid );


-- *********** Fin de tabla de auditoria de  acc_submodulos ***********

END IF;
END;
END PROCEDURE;

EXECUTE PROCEDURE "dba".sp_crea_tabla_usuarios();
DROP PROCEDURE "dba".sp_crea_tabla_usuarios();

-- Las tablas de log no pueden ser alteradas
revoke all on "dba".log_usuarios from public;
grant select on "dba".log_usuarios to internet; 
grant select on "dba".log_usuarios to guarani;

revoke all on "dba".log_perfiles from public;
grant select on "dba".log_perfiles to internet; 
grant select on "dba".log_perfiles to guarani;

revoke all on "dba".log_modulos_perfil from public;
grant select on "dba".log_modulos_perfil to internet; 
grant select on "dba".log_modulos_perfil to guarani; 

revoke all on "dba".log_operacion_mod from public;
grant select on "dba".log_operacion_mod to internet; 
grant select on "dba".log_operacion_mod to guarani; 

revoke all on "dba".log_operaciones from public;
grant select on "dba".log_operaciones to internet; 
grant select on "dba".log_operaciones to guarani;

revoke all on "dba".log_modulos from public;
grant select on "dba".log_modulos to internet; 
grant select on "dba".log_modulos to guarani;

revoke all on "dba".log_submodulos from public;
grant select on "dba".log_submodulos to internet; 
grant select on "dba".log_submodulos to guarani;