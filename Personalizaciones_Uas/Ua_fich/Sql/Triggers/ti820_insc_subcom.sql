-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 1.7.0
-- Tabla sga_insc_subcom
-- Procedure spi_insc_subcom (asociado al trigger de INSERT)
-- *******************************************************************************
CREATE PROCEDURE verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'spi_insc_subcom') THEN
		DROP PROCEDURE spi_insc_subcom;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE verifica_objeto();
DROP PROCEDURE verifica_objeto();


CREATE PROCEDURE "dba".spi_insc_subcom(
       n_unidad_academica like sga_insc_subcom.unidad_academica,
       n_carrera like sga_insc_subcom.carrera,
       n_legajo like sga_insc_subcom.legajo,
       n_comision like sga_insc_subcom.comision,
       n_subcomision like sga_insc_subcom.subcomision)
BEGIN

   -- No se puede insertar en sga_insc_subcom si no existe en sga_subcomisiones
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_insc_subcom si no existe en sga_insc_cursadas
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT


   -- Carga la tabla de log para auditoria
   INSERT INTO log_insc_subcom (
     unidad_academica,
     carrera,
     legajo,
     comision,
     subcomision,
     usuario,
     fecha_act,
     oper)
   VALUES (
     n_unidad_academica,
     n_carrera,
     n_legajo,
     n_comision,
     n_subcomision,
     User,
     Current year to Second,
     'I');
END;
END PROCEDURE
;
-- ********** Fin del procedure asociado al trigger de INSERT de sga_insc_subcom **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Tabla sga_insc_subcom
-- Procedure personalizado uai_insc_subcom (asociado al trigger de INSERT)
-- *******************************************************************************
 DROP PROCEDURE i820_insc_subcom ;
CREATE PROCEDURE "dba".i820_insc_subcom(
        n_unidad_academica like sga_insc_subcom.unidad_academica,
        n_carrera like sga_insc_subcom.carrera,
        n_legajo like sga_insc_subcom.legajo,
        n_comision like sga_insc_subcom.comision,
        n_subcomision like sga_insc_subcom.subcomision)
 BEGIN
--
--   -------------------------------------------------------------------------------- 
--   -- CODIGO PERSONALIZADO
--   -------------------------------------------------------------------------------- 

execute procedure u820_cupo_subcomi(n_comision);

 END;
 END PROCEDURE;
-- **** Fin del procedure personalizado asociado al trigger de INSERT de sga_insc_subcom ****
-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 1.7.0
-- Tabla sga_insc_subcom
-- Trigger de Insert ti_insc_subcom
-- *******************************************************************************
DROP TRIGGER ti_insc_subcom ;
CREATE TRIGGER ti_insc_subcom INSERT on sga_insc_subcom
referencing new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spi_insc_subcom (
     new.unidad_academica,
     new.carrera,
     new.legajo,
     new.comision,
     new.subcomision)
,

   EXECUTE PROCEDURE i820_insc_subcom (
     new.unidad_academica,
     new.carrera,
     new.legajo,
     new.comision,
     new.subcomision)
);
-- ********** Fin del trigger de Insert ti_insc_subcom **********
 
