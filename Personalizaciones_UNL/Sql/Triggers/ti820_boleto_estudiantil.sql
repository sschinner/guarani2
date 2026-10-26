CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'spi820_boleto_estudiantil') THEN
		DROP PROCEDURE spi820_boleto_estudiantil;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.5.2
-- Tabla u820_boleto_estudiantil
-- Procedure spi_boleto_estudiantil (asociado al trigger de INSERT)
-- *******************************************************************************

CREATE PROCEDURE "dba".spi820_boleto_estudiantil (
       n_unidad_academica like u820_boleto_estudiantil.unidad_academica,
       n_nro_inscripcion like u820_boleto_estudiantil.nro_inscripcion,
       n_fecha_relevamiento like u820_boleto_estudiantil.fecha_relevamiento,
       n_boleto_estudiantil like u820_boleto_estudiantil.boleto_estudiantil)
BEGIN

   -- Carga la tabla de log para auditoria
   INSERT INTO log_boleto_estudiantil (
     unidad_academica,
     nro_inscripcion,
     fecha_relevamiento,
     boleto_estudiantil,
     usuario,
     fecha_act,
     oper)
   VALUES (
     n_unidad_academica,
     n_nro_inscripcion,
     n_fecha_relevamiento,
     n_boleto_estudiantil,
     User,
     Current year to Second,
     'I');
end;
end procedure;
-- ********** Fin del procedure asociado al trigger de INSERT de u820_boleto_estudiantil **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Tabla u820_boleto_estudiantil
-- Procedure personalizado uai_u820_boleto_estudiantil (asociado al trigger de INSERT)
-- *******************************************************************************
--DROP PROCEDURE uai_u820_boleto_estudiantil ;
--CREATE PROCEDURE uai_u820_boleto_estudiantil (
-- n_unidad_academica like u820_boleto_estudiantil.unidad_academica,
-- n_nro_inscripcion like u820_boleto_estudiantil.nro_inscripcion,
-- n_fecha_relevamiento like u820_boleto_estudiantil.fecha_relevamiento,
-- n_boleto_estudiantil like u820_boleto_estudiantil.boleto_estudiantil)

--BEGIN
--
--   -------------------------------------------------------------------------------- 
--   -- CODIGO PERSONALIZADO
--   -------------------------------------------------------------------------------- 
--
--end;
--end procedure;
-- **** Fin del procedure personalizado asociado al trigger de INSERT de u820_boleto_estudiantil ****


CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigname
			FROM systriggers
			WHERE trigname = 'ti820_boleto_estudiantil') THEN
		DROP TRIGGER ti820_boleto_estudiantil;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.5.2
-- Tabla u820_boleto_estudiantil
-- Trigger de Insert ti820_boleto_estudiantil
-- *******************************************************************************

CREATE TRIGGER ti820_boleto_estudiantil INSERT on u820_boleto_estudiantil
referencing new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spi820_boleto_estudiantil (
     new.unidad_academica,
     new.nro_inscripcion,
     new.fecha_relevamiento,
     new.boleto_estudiantil)
--,

--   EXECUTE PROCEDURE uai_u820_boleto_estudiantil (
--     new.tipo_de_turno,
--     new.descripcion)
);
-- ********** Fin del trigger de Insert ti820_boleto_estudiantil **********
