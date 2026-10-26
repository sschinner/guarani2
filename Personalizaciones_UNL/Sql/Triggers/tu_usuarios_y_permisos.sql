-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.05.0
-- Tabla acc_usuarios
-- Trigger de UPDATE tu_usuarios
-- *******************************************************************************

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigid
			FROM systriggers
			WHERE trigname = 'tu_usuarios') THEN
		DROP TRIGGER tu_usuarios;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP TRIGGER tu_usuarios ;
CREATE TRIGGER tu_usuarios UPDATE on acc_usuarios
referencing old as old new as new
FOR EACH ROW (
   -- Carga la tabla de log para auditoria
   INSERT INTO log_usuarios (usuario_g, nombre, perfil, clave, usuario, fecha_act, oper)
   VALUES (new.usuario, new.nombre, new.perfil, new.clave, User, Current year to Second, 'U')

);
-- ********** Fin del trigger de UPDATE tu_usuarios **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.05.0
-- Tabla acc_perfiles
-- Trigger de UPDATE tu_perfiles
-- *******************************************************************************

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigid
			FROM systriggers
			WHERE trigname = 'tu_perfiles') THEN
		DROP TRIGGER tu_perfiles;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP TRIGGER tu_perfiles;
CREATE TRIGGER tu_perfiles UPDATE on acc_perfiles
referencing old as old new as new
FOR EACH ROW (
   -- Carga la tabla de log para auditoria
   INSERT INTO log_perfiles (perfil, nombre, bitmap, usuario, fecha_act, oper)
   VALUES (new.perfil, new.nombre, new.bitmap, User, Current year to Second, 'U')

);
-- ********** Fin del trigger de UPDATE tu_perfiles **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.05.0
-- Tabla acc_modulos_perfil
-- Trigger de UPDATE tu_modulos_perfil
-- *******************************************************************************


CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigid
			FROM systriggers
			WHERE trigname = 'tu_modulos_perfil') THEN
		DROP TRIGGER tu_modulos_perfil;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- DROP TRIGGER tu_modulos_perfil;
CREATE TRIGGER tu_modulos_perfil UPDATE on acc_modulos_perfil
referencing old as old new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spu_modulos_perfil (
       old.perfil,
       old.modulo,
       new.perfil,
       new.modulo
   ),
   -- Carga la tabla de log para auditoria
   INSERT INTO log_modulos_perfil (perfil, modulo, usuario, fecha_act, oper)
   VALUES (new.perfil, new.modulo, User, Current year to Second, 'U')

);
-- ********** Fin del trigger de UPDATE tu_modulos_perfil **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.05.0
-- Tabla acc_operacion_mod
-- Trigger de UPDATE tu_operacion_mod
-- *******************************************************************************


CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigid
			FROM systriggers
			WHERE trigname = 'tu_operacion_mod') THEN
		DROP TRIGGER tu_operacion_mod;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP TRIGGER tu_operacion_mod;
CREATE TRIGGER tu_operacion_mod UPDATE on acc_operacion_mod
referencing old as old new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spu_operacion_mod (
       old.modulo,
       old.operacion,
       old.submodulo,
       old.orden,
       new.modulo,
       new.operacion,
       new.submodulo,
       new.orden
   ),
   -- Carga la tabla de log para auditoria
   INSERT INTO log_operacion_mod (modulo, operacion, submodulo, orden, usuario, fecha_act, oper)
   VALUES (new.modulo, new.operacion, new.submodulo, new.orden, User, Current year to Second, 'U')

);
-- ********** Fin del trigger de UPDATE tu_operacion_mod **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.05.0
-- Tabla acc_operaciones
-- Trigger de UPDATE tu_operaciones
-- *******************************************************************************

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigid
			FROM systriggers
			WHERE trigname = 'tu_operaciones') THEN
		DROP TRIGGER tu_operaciones;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP TRIGGER tu_operaciones;
CREATE TRIGGER tu_operaciones UPDATE on acc_operaciones
referencing old as old new as new
FOR EACH ROW (
   -- Carga la tabla de log para auditoria
   INSERT INTO log_operaciones (operacion, nombre, descripcion, bitmap, usuario, fecha_act, oper)
   VALUES (new.operacion, new.nombre, new.descripcion, new.bitmap, User, Current year to Second, 'U')

);
-- ********** Fin del trigger de UPDATE tu_operaciones **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.05.0
-- Tabla acc_modulos
-- Trigger de UPDATE tu_modulos
-- *******************************************************************************

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigid
			FROM systriggers
			WHERE trigname = 'tu_modulos') THEN
		DROP TRIGGER tu_modulos;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- DROP TRIGGER tu_modulos;
CREATE TRIGGER tu_modulos UPDATE on acc_modulos
referencing old as old new as new
FOR EACH ROW (
   -- Carga la tabla de log para auditoria
   INSERT INTO log_modulos (modulo, nombre, bitmap, usuario, fecha_act, oper)
   VALUES (new.modulo, new.nombre, new.bitmap, User, Current year to Second, 'U')

);
-- ********** Fin del trigger de UPDATE tu_modulos **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.05.0
-- Tabla acc_submodulos
-- Trigger de UPDATE tu_submodulos
-- *******************************************************************************

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigid
			FROM systriggers
			WHERE trigname = 'tu_submodulos') THEN
		DROP TRIGGER tu_submodulos;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP TRIGGER tu_submodulos;
CREATE TRIGGER tu_submodulos UPDATE on acc_submodulos
referencing old as old new as new
FOR EACH ROW (
   -- Carga la tabla de log para auditoria
   INSERT INTO log_submodulos (submodulo, nombre, bitmap, usuario, fecha_act, oper)
   VALUES (new.submodulo, new.nombre, new.bitmap, User, Current year to Second, 'U')

);
-- ********** Fin del trigger de UPDATE tu_submodulos **********
