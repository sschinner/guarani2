-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_pedidos_certif_diploma_req
-- Procedure spd_u820_ped_cert_dip_req (asociado al trigger de INSERT)
-- *******************************************************************************
-- DROP PROCEDURE spd_u820_ped_cert_dip_req ;
CREATE PROCEDURE spd_u820_ped_cert_dip_req (
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
       'D');
end;
end procedure;
-- ********** Fin del procedure asociado al trigger de INSERT de u820_pedidos_certif_diploma_req **********


-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_pedidos_certif_diploma_req
-- Trigger de Insert td820_pedidos_certif_dip_req
-- *******************************************************************************
-- DROP TRIGGER td820_pedidos_certif_dip_req;
CREATE TRIGGER td820_pedidos_certif_dip_req DELETE on u820_pedidos_certif_diploma_req
referencing OLD as OLD
FOR EACH ROW (
   EXECUTE PROCEDURE spd_u820_ped_cert_dip_req (
       OLD.id_certif_pedido           ,
       OLD.requisito                  ,
       OLD.hash_notificacion  ,
       OLD.url                ,
       OLD.uid_nuxeo                ,
       OLD.fecha_actualizacion
    )
);
-- ********** Fin del trigger de Insert td820_pedidos_certif_dip_req **********
