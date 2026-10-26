

-------- Agregado para ejecución automática
CREATE PROCEDURE verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'spi_u820_habilitados') THEN
		DROP PROCEDURE spi_u820_habilitados ;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE verifica_objeto();
DROP PROCEDURE verifica_objeto();
---------------------------------------------------------------------------------------------------
-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.00
-- Tabla u820_habilitados
-- Procedure uai_u820_habilitados (asociado al trigger de INSERT)
-- *******************************************************************************

-- DROP PROCEDURE spi_u820_habilitados ;

CREATE PROCEDURE "dba".spi_u820_habilitados(
       n_unidad_academica like u820_habilitados.unidad_academica,
       n_carrera     like u820_habilitados.carrera,
       n_legajo like u820_habilitados.legajo,
       n_plan like u820_habilitados.plan,
       n_materia like u820_habilitados.materia,
       n_fecha_habilitacion like u820_habilitados.fecha_habilitacion,
       n_cant_aplazos like u820_habilitados.cant_aplazos,
       n_OBSERVACIONES like u820_habilitados.observaciones)

BEGIN

INSERT INTO log_u820_habilitados (
	UNIDAD_ACADEMICA,
	CARRERA,
	LEGAJO,
	PLAN, 
	MATERIA,
	FECHA_HABILITACION,
	CANT_APLAZOS,
	OBSERVACIONES,
     usuario,
     fecha_act,
     operacion
)
   VALUES (
     n_unidad_academica,
     n_carrera,
     n_legajo,
     n_plan,
     n_materia,
     n_fecha_habilitacion,
     n_cant_aplazos,
     n_OBSERVACIONES,
     User,
     Current year to Second,
     'I');

end;
end procedure;

-- ********** Fin del procedure asociado al trigger de INSERT de u820_habilitados **********


-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Tabla sga_detalle_acta
-- Trigger de Insert ti_detalle_acta
-- *******************************************************************************
CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigid
			FROM systriggers
			WHERE trigname = 'ti_u820_habilitados') THEN
		DROP TRIGGER ti_u820_habilitados;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

CREATE TRIGGER dba.ti_u820_habilitados INSERT on u820_habilitados
referencing new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spi_u820_habilitados (
     new.unidad_academica,
          new.CARRERA          ,
          new.LEGAJO  ,
          new.PLAN      ,
          new.MATERIA        ,
          new.FECHA_HABILITACION,
          new.CANT_APLAZOS, 
         new.OBSERVACIONES
)

--,

--   EXECUTE PROCEDURE uai_u820_habilitados (
--     new.unidad_academica,
--          new.CARRERA          ,
--          new.LEGAJO  ,
--          new.PLAN      ,
--          new.MATERIA        ,
--          new.FECHA_HABILITACION,
--          new.CANT_APLAZOS, 
--         new.OBSERVACIONES)
);
-- ********** Fin del trigger de Insert **********

set triggers for u820_habilitados enabled;

