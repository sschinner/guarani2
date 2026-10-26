-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_certificados
-- Procedure spu_u820_certif (asociado al trigger de UPDATE)
-- *******************************************************************************
-- DROP PROCEDURE spu_u820_certif ;
CREATE PROCEDURE spu_u820_certif (
       o_certificado like u820_certificados.certificado,
       o_arancelado like u820_certificados.arancelado,
       o_dias_vencimiento_pago like u820_certificados.dias_vencimiento_pago,
       n_certificado like u820_certificados.certificado,
       n_arancelado like u820_certificados.arancelado,
       n_dias_vencimiento_pago like u820_certificados.dias_vencimiento_pago)
BEGIN

   -------------------------------------------------------------------------------- 
   -- Impide que se modifique la clave primaria de un registro 
   -------------------------------------------------------------------------------- 
   IF o_certificado <> n_certificado  THEN
      raise exception -746,0,'No se puede modificar la clave primaria de un registro.';
   END IF;


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
     'U');
end;
end procedure;
-- ********** Fin del procedure asociado al trigger de UPDATE de u820_certificados **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Tabla sga_certif_pedidos
-- Procedure personalizado uau_certif_pedidos (asociado al trigger de UPDATE)
-- *******************************************************************************
--DROP PROCEDURE uau_certif_pedidos ;
--CREATE PROCEDURE uau_certif_pedidos (
--       n_certif_pedido like sga_certif_pedidos.certif_pedido,
--       n_unidad_academica like sga_certif_pedidos.unidad_academica,
--       n_nro_inscripcion like sga_certif_pedidos.nro_inscripcion,
--       n_certificado like sga_certif_pedidos.certificado,
--       n_fecha_de_pedido like sga_certif_pedidos.fecha_de_pedido,
--       n_copias_pedidas like sga_certif_pedidos.copias_pedidas,
--       n_nro_transaccion like sga_certif_pedidos.nro_transaccion,
--       n_interfaz like sga_certif_pedidos.interfaz,
--       n_fecha_de_emision like sga_certif_pedidos.fecha_de_emision,
--       n_usuario_emisor like sga_certif_pedidos.usuario_emisor,
--       n_copias_impresas like sga_certif_pedidos.copias_impresas)
--BEGIN

   -------------------------------------------------------------------------------- 
   -- CODIGO PERSONALIZADO
   -------------------------------------------------------------------------------- 

--end;
--end procedure;
-- **** Fin del procedure personalizado asociado al trigger de UPDATE de sga_certif_pedidos ****

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_certificados
-- Trigger de Update tuu820_certificados
-- *******************************************************************************
-- DROP TRIGGER tuu820_certificados;
CREATE TRIGGER tuu820_certificados UPDATE on u820_certificados
referencing old as old new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spu_u820_certif (
       old.certificado,
       old.arancelado,
       old.dias_vencimiento_pago,
       new.certificado,
       new.arancelado,
       new.dias_vencimiento_pago)
--,
--   EXECUTE PROCEDURE uau_certif_pedidos (
--     new.certif_pedido,
--     new.unidad_academica,
--     new.nro_inscripcion,
--     new.certificado,
--     new.fecha_de_pedido,
--     new.copias_pedidas,
--     new.nro_transaccion,
--     new.interfaz,
--     new.fecha_de_emision,
--     new.usuario_emisor,
--     new.copias_impresas)
);
-- ********** Fin del trigger de Update tuu820_certificados **********
