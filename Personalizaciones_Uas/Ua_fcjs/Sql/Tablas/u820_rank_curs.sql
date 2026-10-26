CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_crea_tabla_u820_rank_curs') THEN
		DROP PROCEDURE sp_crea_tabla_u820_rank_curs;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();

CREATE PROCEDURE "dba".sp_crea_tabla_u820_rank_curs ();

BEGIN

IF NOT EXISTS (SELECT * FROM systables where tabname = 'u820_rank_curs') THEN


-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.0.3
-- Tabla u820_rank_curs
-- *******************************************************************************
-- DROP TABLE u820_rank_curs;
CREATE TABLE u820_rank_curs(
       UNIDAD_ACADEMICA     varchar(5) NOT NULL,
       CARRERA              varchar(5) NOT NULL,
       LEGAJO               varchar(15) NOT NULL,
       COMISION             integer NOT NULL,
       ESTADO               char(1) NOT NULL, -- estado o condicion de rechazo segun criterios: A (Aceptado); H (Superposicion Horaria); C (Excede cantidad de materias);
       FECHA_INSCRIPCION    datetime year to second NOT NULL,
       CANT_APROB		integer,
       INGRESO	char(1) NOT NULL, -- marca de los que realmente ingresaron
       CERT_TRABAJO char(1) NOT NULL -- si el alumno presento certificado de trabajo

);

ALTER TABLE "dba".u820_rank_curs
	ADD
	(
	cant_aprob_real integer,
	plan character(5),
	version_ranking integer
	);

ALTER TABLE u820_rank_curs
       ADD CONSTRAINT PRIMARY KEY (UNIDAD_ACADEMICA, CARRERA, LEGAJO, 
              COMISION)
              CONSTRAINT pk_u820_rank_curs;

grant all on u820_rank_curs to public;

END IF;
END;
END PROCEDURE;
-- *************** Fin del procedimiento "dba".sp_crea_tabla_u820_rank_curs *******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_crea_tabla_u820_rank_curs 
-- *****************************************************************************
revoke execute on "dba".sp_crea_tabla_u820_rank_curs from public;
grant execute on "dba".sp_crea_tabla_u820_rank_curs to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_crea_tabla_u820_rank_curs to internet; -- Rol de usuario de Internet

-- Se ejecuta y eliminar procedimiento
EXECUTE PROCEDURE "dba".sp_crea_tabla_u820_rank_curs ();
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *********** Fin del script de la tabla u820_rank_curs **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.0.3
-- Tabla u820_rank_curs
-- Tabla de Auditoria log_u820_rank_curs
-- *******************************************************************************
CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_crea_tabla_log_u820_rank_curs') THEN
		DROP PROCEDURE sp_crea_tabla_log_u820_rank_curs;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();


CREATE PROCEDURE "dba".sp_crea_tabla_log_u820_rank_curs ();

BEGIN

IF NOT EXISTS (SELECT * FROM systables where tabname = 'log_u820_rank_curs') THEN



-- DROP TABLE log_u820_rank_curs;
CREATE TABLE log_u820_rank_curs(
          logid SERIAL(1),
          unidad_academica varchar(5),
          carrera varchar(5),
          legajo varchar(15),
          comision integer,
          estado char(1),
       FECHA_INSCRIPCION    datetime year to second NOT NULL,
          cant_aprob integer,
          ingreso char(1),
       cert_trabajo char(1),
          usuario      varchar(8) DEFAULT USER NOT NULL,
          fecha_act  DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND  NOT NULL,
          oper CHAR(1) NOT NULL
);


ALTER TABLE "dba".log_u820_rank_curs
	ADD
	(
	cant_aprob_real integer,
	plan character(5),
	version_ranking integer
	);

ALTER TABLE log_u820_rank_curs
      ADD CONSTRAINT PRIMARY KEY ( logid );

-- Las tablas de log no pueden ser alteradas
revoke all on log_u820_rank_curs from public;
grant select on log_u820_rank_curs to public;
END IF;
END;
END PROCEDURE;
-- *************** Fin del procedimiento "dba".sp_crea_tabla_log_u820_rank_curs *******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_crea_tabla_log_u820_rank_curs 
-- *****************************************************************************
revoke execute on "dba".sp_crea_tabla_log_u820_rank_curs from public;
grant execute on "dba".sp_crea_tabla_log_u820_rank_curs to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_crea_tabla_log_u820_rank_curs to internet; -- Rol de usuario de Internet

-- Se ejecuta y eliminar procedimiento
EXECUTE PROCEDURE "dba".sp_crea_tabla_log_u820_rank_curs ();
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();