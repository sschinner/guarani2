-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.05.0
-- Tabla acc_usuarios
-- Trigger de DELETE td_usuarios
-- *******************************************************************************
CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigid
			FROM systriggers
			WHERE trigname = 'td_usuarios') THEN
		DROP TRIGGER td_usuarios;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP TRIGGER td_usuarios ;
CREATE TRIGGER td_usuarios DELETE on acc_usuarios
referencing old as old
FOR EACH ROW (
   
  delete from "dba".sga_datos_usuarios  where (usuario = old.usuario ),
   -- Carga la tabla de log para auditoria
   INSERT INTO log_usuarios (usuario_g, nombre, perfil, clave, usuario, fecha_act, oper)
   VALUES (old.usuario, old.nombre, old.perfil, old.clave, User, Current year to Second, 'D')

);
-- ********** Fin del trigger de DELETE td_usuarios **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.05.0
-- Tabla acc_perfiles
-- Trigger de DELETE td_perfiles
-- *******************************************************************************
CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigid
			FROM systriggers
			WHERE trigname = 'td_perfiles') THEN
		DROP TRIGGER td_perfiles;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP TRIGGER td_perfiles;
CREATE TRIGGER td_perfiles DELETE on acc_perfiles
referencing old as old
FOR EACH ROW (
   -- Carga la tabla de log para auditoria
   INSERT INTO log_perfiles (perfil, nombre, bitmap, usuario, fecha_act, oper)
   VALUES (old.perfil, old.nombre, old.bitmap, User, Current year to Second, 'D')

);
-- ********** Fin del trigger de DELETE td_perfiles **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.05.0
-- Tabla acc_modulos_perfil
-- Trigger de DELETE td_modulos_perfil
-- *******************************************************************************
CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigid
			FROM systriggers
			WHERE trigname = 'td_modulos_perfil') THEN
		DROP TRIGGER td_modulos_perfil;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP TRIGGER td_modulos_perfil;
CREATE TRIGGER td_modulos_perfil DELETE on acc_modulos_perfil
referencing old as old
FOR EACH ROW (
   EXECUTE PROCEDURE spd_modulos_perfil (
       old.perfil,
       old.modulo
   ),
   -- Carga la tabla de log para auditoria
   INSERT INTO log_modulos_perfil (perfil, modulo, usuario, fecha_act, oper)
   VALUES (old.perfil, old.modulo, User, Current year to Second, 'D')

);
-- ********** Fin del trigger de DELETE td_modulos_perfil **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.05.0
-- Tabla acc_modulos
-- Trigger de DELETE td_modulos
-- *******************************************************************************
CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigid
			FROM systriggers
			WHERE trigname = 'td_modulos') THEN
		DROP TRIGGER td_modulos;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP TRIGGER td_modulos;
CREATE TRIGGER td_modulos DELETE on acc_modulos
referencing old as old
FOR EACH ROW (
   EXECUTE PROCEDURE spd_modulos (
       old.modulo,
       old.nombre,
       old.bitmap
   ),
   -- Carga la tabla de log para auditoria
   INSERT INTO log_modulos (modulo, nombre, bitmap, usuario, fecha_act, oper)
   VALUES (old.modulo, old.nombre, old.bitmap, User, Current year to Second, 'D')

);
-- ********** Fin del trigger de DELETE td_modulos **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.05.0
-- Tabla acc_operaciones
-- Trigger de DELETE td_operaciones
-- *******************************************************************************
CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigid
			FROM systriggers
			WHERE trigname = 'td_operaciones') THEN
		DROP TRIGGER td_operaciones;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP TRIGGER td_operaciones;
CREATE TRIGGER td_operaciones DELETE on acc_operaciones
referencing old as old
FOR EACH ROW (
   -- Carga la tabla de log para auditoria
   INSERT INTO log_operaciones (operacion, nombre, descripcion, bitmap, usuario, fecha_act, oper)
   VALUES (old.operacion, old.nombre, old.descripcion, old.bitmap, User, Current year to Second, 'D')

);
-- ********** Fin del trigger de DELETE td_operaciones **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.05.0
-- Tabla acc_submodulos
-- Trigger de DELETE td_submodulos
-- *******************************************************************************
CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigid
			FROM systriggers
			WHERE trigname = 'td_submodulos') THEN
		DROP TRIGGER td_submodulos;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP TRIGGER td_submodulos;
CREATE TRIGGER td_submodulos DELETE on acc_submodulos
referencing old as old
FOR EACH ROW (
   -- Carga la tabla de log para auditoria
   INSERT INTO log_submodulos (submodulo, nombre, bitmap, usuario, fecha_act, oper)
   VALUES (old.submodulo, old.nombre, old.bitmap, User, Current year to Second, 'D')

);
-- ********** Fin del trigger de DELETE td_submodulos **********
