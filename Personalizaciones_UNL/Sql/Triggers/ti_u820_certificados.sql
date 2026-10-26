-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_certificados
-- Procedure spi_u820_certif (asociado al trigger de INSERT)
-- *******************************************************************************
-- DROP PROCEDURE spi_u820_certif ;
CREATE PROCEDURE spi_u820_certif (
       n_certificado like u820_certificados.certificado,
       n_arancelado like u820_certificados.arancelado,
       n_dias_vencimiento_pago like u820_certificados.dias_vencimiento_pago)
BEGIN

   -- Carga la tabla de log para auditoria
   INSERT INTO log_u820_certificados (
     certificado,
     arancelado,
     dias_vencimiento_pago,
     usuario,
     fecha_act,
     oper)
   VALUES (
     n_certificado,
     n_arancelado,
     n_dias_vencimiento_pago,
     User,
     Current year to Second,
     'D');
end;
end procedure;
-- ********** Fin del procedure asociado al trigger de INSERT de u820_certificados **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Tabla u820_certificados
-- Procedure personalizado uad_certif_pedidos (asociado al trigger de DELETE)
-- *******************************************************************************
--DROP PROCEDURE uad_certif_pedidos ;
--CREATE PROCEDURE uad_certif_pedidos (
--       o_certif_pedido like sga_certif_pedidos.certif_pedido,
--       o_unidad_academica like sga_certif_pedidos.unidad_academica,
--       o_nro_inscripcion like sga_certif_pedidos.nro_inscripcion,
--       o_certificado like sga_certif_pedidos.certificado,
--       o_fecha_de_pedido like sga_certif_pedidos.fecha_de_pedido,
--       o_copias_pedidas like sga_certif_pedidos.copias_pedidas,
--       o_nro_transaccion like sga_certif_pedidos.nro_transaccion,
--       o_interfaz like sga_certif_pedidos.interfaz,
--       o_fecha_de_emision like sga_certif_pedidos.fecha_de_emision,
--       o_usuario_emisor like sga_certif_pedidos.usuario_emisor,
--       o_copias_impresas like sga_certif_pedidos.copias_impresas)
--BEGIN

   -------------------------------------------------------------------------------- 
   -- CODIGO PERSONALIZADO
   -------------------------------------------------------------------------------- 

--end;
--end procedure;
-- **** Fin del procedure personalizado asociado al trigger de DELETE de sga_certif_pedidos ****

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_certificados
-- Trigger de Insert tiu820_certificados
-- *******************************************************************************
-- DROP TRIGGER tiu820_certificados;
CREATE TRIGGER tiu820_certificados INSERT on u820_certificados
referencing new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spi_u820_certif (
     new.certificado,
     new.arancelado,
     new.dias_vencimiento_pago)
--,

--   EXECUTE PROCEDURE uad_certif_pedidos (
--     old.certif_pedido,
--     old.unidad_academica,
--     old.nro_inscripcion,
--     old.certificado,
--     old.fecha_de_pedido,
--     old.copias_pedidas,
--     old.nro_transaccion,
--     old.interfaz,
--     old.fecha_de_emision,
--     old.usuario_emisor,
--     old.copias_impresas)
);
-- ********** Fin del trigger de Delete tiu820_certificados **********
