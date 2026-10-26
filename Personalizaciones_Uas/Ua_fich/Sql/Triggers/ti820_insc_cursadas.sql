-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 1.1.0
-- Tabla sga_insc_cursadas
-- Procedure spi_insc_cursadas (asociado al trigger de INSERT)
-- *******************************************************************************
CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'spi_insc_cursadas') THEN
		DROP PROCEDURE spi_insc_cursadas;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

CREATE PROCEDURE "dba".spi_insc_cursadas(
       n_unidad_academica like sga_insc_cursadas.unidad_academica,
       n_carrera like sga_insc_cursadas.carrera,
       n_legajo like sga_insc_cursadas.legajo,
       n_comision like sga_insc_cursadas.comision,
       n_fecha_inscripcio like sga_insc_cursadas.fecha_inscripcion,
       n_calidad_insc like sga_insc_cursadas.calidad_insc,
       n_materia_generica like sga_insc_cursadas.materia_generica,
       n_plan like sga_insc_cursadas.plan,
       n_version like sga_insc_cursadas.version,
       n_nro_transaccion like sga_insc_cursadas.nro_transaccion,
       n_interfaz like sga_insc_cursadas.interfaz,
       n_estado like sga_insc_cursadas.estado)
BEGIN
 
   -- No se puede insertar en sga_insc_cursadas si no existe en sga_materias
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_insc_cursadas si no existe en par_interfaces
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT


  -- No se puede insertar en sga_insc_cursadas si no existe en sga_comisiones
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_insc_cursadas si no existe en sga_versiones_plan
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_insc_cursadas si no existe en sga_alumnos
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT


   -- Carga la tabla de log para auditoria
   INSERT INTO log_insc_cursadas (
     unidad_academica,
     carrera,
     legajo,
     comision,
     fecha_inscripcion,
     calidad_insc,
     materia_generica,
     plan,
     version,
     nro_transaccion,
     interfaz,
     estado,
     usuario,
     fecha_act,
     oper)
   VALUES (
     n_unidad_academica,
     n_carrera,
     n_legajo,
     n_comision,
     n_fecha_inscripcio,
     n_calidad_insc,
     n_materia_generica,
     n_plan,
     n_version,
     n_nro_transaccion,
     n_interfaz,
     n_estado,
     User,
     Current year to Second,
     'I');
end;
end procedure
;
-- ********** Fin del procedure asociado al trigger de INSERT de "dba".spi_insc_cursadas **********

-- *****************************************************************************
-- Permisos del procedimiento "dba".spi_insc_cursadas 
-- *****************************************************************************
revoke execute on "dba".spi_insc_cursadas from public;
grant execute on "dba".spi_insc_cursadas to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".spi_insc_cursadas to internet; -- Rol de usuario de Internet


-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Tabla sga_insc_cursadas
-- Procedure personalizado uai_insc_cursadas (asociado al trigger de INSERT)
-- *******************************************************************************
--DROP PROCEDURE "dba".uai_insc_cursadas ;
--CREATE PROCEDURE "dba".uai_insc_cursadas (
--       n_unidad_academica like sga_insc_cursadas.unidad_academica,
--       n_carrera like sga_insc_cursadas.carrera,
--       n_legajo like sga_insc_cursadas.legajo,
--       n_comision like sga_insc_cursadas.comision,
--       n_fecha_inscripcio like sga_insc_cursadas.fecha_inscripcion,
--       n_calidad_insc like sga_insc_cursadas.calidad_insc,
--       n_materia_generica like sga_insc_cursadas.materia_generica,
--       n_plan like sga_insc_cursadas.plan,
--       n_version like sga_insc_cursadas.version,
--       n_nro_transaccion like sga_insc_cursadas.nro_transaccion,
--       n_interfaz like sga_insc_cursadas.interfaz,
--       n_estado like sga_insc_cursadas.estado)
--BEGIN
--
--   -------------------------------------------------------------------------------- 
--   -- CODIGO PERSONALIZADO
--   -------------------------------------------------------------------------------- 
--
--end;
--end procedure;
-- **** Fin del procedure personalizado asociado al trigger de INSERT de sga_insc_cursadas ****

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 1.1.0
-- Tabla sga_insc_cursadas
-- Trigger de Insert ti_insc_cursadas
-- *******************************************************************************

CREATE PROCEDURE verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigname
			FROM systriggers
			WHERE trigname = 'ti_insc_cursadas') THEN
		DROP TRIGGER ti_insc_cursadas;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE verifica_objeto();
DROP PROCEDURE verifica_objeto();

-- DROP TRIGGER ti_insc_cursadas ;
CREATE TRIGGER "dba".ti_insc_cursadas INSERT on sga_insc_cursadas
referencing new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spi_insc_cursadas (
     new.unidad_academica,
     new.carrera,
     new.legajo,
     new.comision,
     new.fecha_inscripcion,
     new.calidad_insc,
     new.materia_generica,
     new.plan,
     new.version,
     new.nro_transaccion,
     new.interfaz,
     new.estado)
,
   EXECUTE PROCEDURE u820_cupo_comi (
     new.unidad_academica,
     new.carrera,
     new.plan,
     new.comision)

--,

--   EXECUTE PROCEDURE uai_insc_cursadas (
--     new.unidad_academica,
--     new.carrera,
--     new.legajo,
--     new.comision,
--     new.fecha_inscripcion,
--     new.calidad_insc,
--     new.materia_generica,
--     new.plan,
--     new.version,
--     new.nro_transaccion,
--     new.interfaz,
--     new.estado)
);
-- ********** Fin del trigger de Insert "dba".ti_insc_cursadas **********