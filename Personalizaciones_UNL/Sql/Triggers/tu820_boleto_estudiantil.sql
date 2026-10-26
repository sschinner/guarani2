CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'spu820_boleto_estudiantil') THEN
		DROP PROCEDURE spu820_boleto_estudiantil;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.5.2
-- Tabla u820_boleto_estudiantil
-- Procedure spu_boleto_estudiantil (asociado al trigger de UPDATE)
-- *******************************************************************************

CREATE PROCEDURE "dba".spu820_boleto_estudiantil (
       o_unidad_academica like u820_boleto_estudiantil.unidad_academica,
       o_nro_inscripcion like u820_boleto_estudiantil.nro_inscripcion,
       o_fecha_relevamiento like u820_boleto_estudiantil.fecha_relevamiento,
       o_boleto_estudiantil like u820_boleto_estudiantil.boleto_estudiantil)
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
     o_unidad_academica,
     o_nro_inscripcion,
     o_fecha_relevamiento,
     o_boleto_estudiantil,
     User,
     Current year to Second,
     'U');
end;
end procedure;
-- ********** Fin del procedure asociado al trigger de UPDATE de u820_boleto_estudiantil **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Tabla u820_boleto_estudiantil
-- Procedure personalizado uau_u820_boleto_estudiantil (asociado al trigger de UPDATE)
-- *******************************************************************************
--DROP PROCEDURE uau_u820_boleto_estudiantil ;
--CREATE PROCEDURE uau_u820_boleto_estudiantil (
-- o_unidad_academica like u820_boleto_estudiantil.unidad_academica,
-- o_nro_inscripcion like u820_boleto_estudiantil.nro_inscripcion,
-- o_fecha_relevamiento like u820_boleto_estudiantil.fecha_relevamiento,
-- o_boleto_estudiantil like u820_boleto_estudiantil.boleto_estudiantil)

--BEGIN
--
--   -------------------------------------------------------------------------------- 
--   -- CODIGO PERSONALIZADO
--   -------------------------------------------------------------------------------- 
--
--end;
--end procedure;
-- **** Fin del procedure personalizado asociado al trigger de UPDATE de u820_boleto_estudiantil ****


CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT trigname
			FROM systriggers
			WHERE trigname = 'tu820_boleto_estudiantil') THEN
		DROP TRIGGER tu820_boleto_estudiantil;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.5.2
-- Tabla u820_boleto_estudiantil
-- Trigger de Insert tu820_boleto_estudiantil
-- *******************************************************************************

CREATE TRIGGER tu820_boleto_estudiantil UPDATE on u820_boleto_estudiantil
referencing old as old
FOR EACH ROW (
   EXECUTE PROCEDURE spu820_boleto_estudiantil (
     old.unidad_academica,
     old.nro_inscripcion,
     old.fecha_relevamiento,
     old.boleto_estudiantil)
--,

--   EXECUTE PROCEDURE uau_u820_boleto_estudiantil (
--     old.tipo_de_turno,
--     old.descripcion,
--     old.fecha_relevamiento,
--     old.boleto_estudiantil)
);
-- ********** Fin del trigger de Insert tu820_boleto_estudiantil **********
