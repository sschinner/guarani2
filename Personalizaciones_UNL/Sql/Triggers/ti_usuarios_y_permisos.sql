-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.05.0
-- Tabla acc_usuarios
-- Trigger de Insert ti_usuarios
-- *******************************************************************************


CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigid
			FROM systriggers
			WHERE trigname = 'ti_usuarios') THEN
		DROP TRIGGER ti_usuarios;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP TRIGGER ti_usuarios ;
CREATE TRIGGER ti_usuarios INSERT on acc_usuarios
referencing new as new
FOR EACH ROW (
   execute procedure "dba".spi_usuarios(new.usuario ),
   -- Carga la tabla de log para auditoria
   INSERT INTO log_usuarios (usuario_g, nombre, perfil, clave, usuario, fecha_act, oper)
   VALUES (new.usuario, new.nombre, new.perfil, new.clave, User, Current year to Second, 'I')

);
-- ********** Fin del trigger de Insert ti_usuarios **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.05.0
-- Tabla acc_perfiles
-- Trigger de Insert ti_perfiles
-- *******************************************************************************
CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigid
			FROM systriggers
			WHERE trigname = 'ti_perfiles') THEN
		DROP TRIGGER ti_perfiles;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP TRIGGER ti_perfiles;
CREATE TRIGGER ti_perfiles INSERT on acc_perfiles
referencing new as new
FOR EACH ROW (
   -- Carga la tabla de log para auditoria
   INSERT INTO log_perfiles (perfil, nombre, bitmap, usuario, fecha_act, oper)
   VALUES (new.perfil, new.nombre, new.bitmap, User, Current year to Second, 'I')

);
-- ********** Fin del trigger de Insert ti_perfiles **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.05.0
-- Tabla acc_modulos_perfil
-- Trigger de Insert ti_modulos_perfil
-- *******************************************************************************

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigid
			FROM systriggers
			WHERE trigname = 'ti_modulos_perfil') THEN
		DROP TRIGGER ti_modulos_perfil;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP TRIGGER ti_modulos_perfil;
CREATE TRIGGER ti_modulos_perfil INSERT on acc_modulos_perfil
referencing new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spi_modulos_perfil (
       new.perfil,
       new.modulo
   ),
   -- Carga la tabla de log para auditoria
   INSERT INTO log_modulos_perfil (perfil, modulo, usuario, fecha_act, oper)
   VALUES (new.perfil, new.modulo, User, Current year to Second, 'I')

);
-- ********** Fin del trigger de Insert ti_modulos_perfil **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.05.0
-- Tabla acc_operacion_mod
-- Trigger de Insert ti_operacion_mod
-- *******************************************************************************


CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigid
			FROM systriggers
			WHERE trigname = 'ti_operacion_mod') THEN
		DROP TRIGGER ti_operacion_mod;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP TRIGGER ti_operacion_mod;
CREATE TRIGGER ti_operacion_mod INSERT on acc_operacion_mod
referencing new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spi_operacion_mod (
       new.modulo,
       new.operacion,
       new.submodulo,
       new.orden
   ),
   -- Carga la tabla de log para auditoria
   INSERT INTO log_operacion_mod (modulo, operacion, submodulo, orden, usuario, fecha_act, oper)
   VALUES (new.modulo, new.operacion, new.submodulo, new.orden, User, Current year to Second, 'I')

);
-- ********** Fin del trigger de Insert ti_operacion_mod **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.05.0
-- Tabla acc_operaciones
-- Trigger de Insert ti_operaciones
-- *******************************************************************************

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigid
			FROM systriggers
			WHERE trigname = 'ti_operaciones') THEN
		DROP TRIGGER ti_operaciones;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP TRIGGER ti_operaciones;
CREATE TRIGGER ti_operaciones INSERT on acc_operaciones
referencing new as new
FOR EACH ROW (
   -- Carga la tabla de log para auditoria
   INSERT INTO log_operaciones (operacion, nombre, descripcion, bitmap, usuario, fecha_act, oper)
   VALUES (new.operacion, new.nombre, new.descripcion, new.bitmap, User, Current year to Second, 'I')

);
-- ********** Fin del trigger de Insert ti_operaciones **********


-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.05.0
-- Tabla acc_modulos
-- Trigger de Insert tu_modulos
-- *******************************************************************************
CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigid
			FROM systriggers
			WHERE trigname = 'ti_modulos') THEN
		DROP TRIGGER ti_modulos;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP TRIGGER ti_modulos;
CREATE TRIGGER ti_modulos INSERT on acc_modulos
referencing new as new
FOR EACH ROW (
   -- Carga la tabla de log para auditoria
   INSERT INTO log_modulos (modulo, nombre, bitmap, usuario, fecha_act, oper)
   VALUES (new.modulo, new.nombre, new.bitmap, User, Current year to Second, 'I')

);
-- ********** Fin del trigger de INSERT tu_modulos **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.05.0
-- Tabla acc_submodulos
-- Trigger de Insert ti_submodulos
-- *******************************************************************************

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigid
			FROM systriggers
			WHERE trigname = 'ti_submodulos') THEN
		DROP TRIGGER ti_submodulos;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP TRIGGER ti_submodulos;
CREATE TRIGGER ti_submodulos INSERT on acc_submodulos
referencing new as new
FOR EACH ROW (
   -- Carga la tabla de log para auditoria
   INSERT INTO log_submodulos (submodulo, nombre, bitmap, usuario, fecha_act, oper)
   VALUES (new.submodulo, new.nombre, new.bitmap, User, Current year to Second, 'I')

);
-- ********** Fin del trigger de Insert ti_submodulos **********
