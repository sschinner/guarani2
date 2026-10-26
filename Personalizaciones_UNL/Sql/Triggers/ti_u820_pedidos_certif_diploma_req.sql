-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_pedidos_certif_diploma_req
-- Procedure spi_u820_ped_cert_dip_req (asociado al trigger de INSERT)
-- *******************************************************************************
-- DROP PROCEDURE spi_u820_ped_cert_dip_req ;
CREATE PROCEDURE spi_u820_ped_cert_dip_req (
       p_id_certif_pedido       like log_u820_pedidos_certif_diploma_req.id_certif_pedido,
       p_requisito              like log_u820_pedidos_certif_diploma_req.requisito ,
       p_hash_notificacion      like log_u820_pedidos_certif_diploma_req.hash_notificacion,
       p_url                    like log_u820_pedidos_certif_diploma_req.url,
       p_uid_nuxeo              like log_u820_pedidos_certif_diploma_req.uid_nuxeo,
       p_fecha_actualizacion    like log_u820_pedidos_certif_diploma_req.fecha_actualizacion
      )
BEGIN

   -- Carga la tabla de log para auditoria
   INSERT INTO log_u820_pedidos_certif_diploma_req (
       id_certif_pedido         ,
       requisito              ,
       hash_notificacion      ,
       url                    ,
       uid_nuxeo                    ,
       fecha_actualizacion    ,
       usuario                  ,
       fecha_act                ,
       oper                 
)
   VALUES (
       p_id_certif_pedido   ,
       p_requisito          ,
       p_hash_notificacion  ,
       p_url                ,
       p_uid_nuxeo                ,
       p_fecha_actualizacion,
       User                 ,
       Current year to Second,
       'I');
end;
end procedure;
-- ********** Fin del procedure asociado al trigger de INSERT de u820_pedidos_certif_diploma_req **********


-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_pedidos_certif_diploma_req
-- Trigger de Insert ti820_pedidos_certif_dip_req
-- *******************************************************************************
-- DROP TRIGGER ti820_pedidos_certif_dip_req;
CREATE TRIGGER ti820_pedidos_certif_dip_req INSERT on u820_pedidos_certif_diploma_req
referencing NEW as NEW
FOR EACH ROW (
   EXECUTE PROCEDURE spi_u820_ped_cert_dip_req (
       NEW.id_certif_pedido           ,
       NEW.requisito                  ,
       NEW.hash_notificacion  ,
       NEW.url                ,
       NEW.uid_nuxeo                ,
       NEW.fecha_actualizacion
    )
);
-- ********** Fin del trigger de Insert ti820_pedidos_certif_dip_req **********
