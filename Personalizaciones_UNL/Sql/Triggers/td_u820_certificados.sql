-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_certificados
-- Procedure spd_u820_certif (asociado al trigger de DELETE)
-- *******************************************************************************
-- DROP PROCEDURE spd_u820_certif ;
CREATE PROCEDURE spd_u820_certif (
       o_certificado like u820_certificados.certificado,
       o_arancelado like u820_certificados.arancelado,
       o_dias_vencimiento_pago like u820_certificados.dias_vencimiento_pago)
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
     o_certificado,
     o_arancelado,
     o_dias_vencimiento_pago,
     User,
     Current year to Second,
     'D');
end;
end procedure;
-- ********** Fin del procedure asociado al trigger de DELETE de u820_certificados **********

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
-- Trigger de Delete tdu820_certificados
-- *******************************************************************************
-- DROP TRIGGER tdu820_certificados;
CREATE TRIGGER tdu820_certificados DELETE on u820_certificados
referencing old as old
FOR EACH ROW (
   EXECUTE PROCEDURE spd_u820_certif (
     old.certificado,
     old.arancelado,
     old.dias_vencimiento_pago)
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
-- ********** Fin del trigger de Delete tdu820_certificados **********
