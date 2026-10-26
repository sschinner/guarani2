-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_pedidos_certif_diploma_req
-- Procedure spu_u820_ped_cert_dip_req (asociado al trigger de UPDATE)
-- *******************************************************************************
-- DROP PROCEDURE spu_u820_ped_cert_dip_req ;
CREATE PROCEDURE spu_u820_ped_cert_dip_req (
       o_id_certif_pedido       like log_u820_pedidos_certif_diploma_req.id_certif_pedido,
       o_requisito              like log_u820_pedidos_certif_diploma_req.requisito,
       o_hash_notificacion      like log_u820_pedidos_certif_diploma_req.hash_notificacion,
       o_url                    like log_u820_pedidos_certif_diploma_req.url,
       o_uid_nuxeo              like log_u820_pedidos_certif_diploma_req.uid_nuxeo,
       o_fecha_actualizacion    like log_u820_pedidos_certif_diploma_req.fecha_actualizacion,

       n_id_certif_pedido       like log_u820_pedidos_certif_diploma_req.id_certif_pedido,
       n_requisito              like log_u820_pedidos_certif_diploma_req.requisito,
       n_hash_notificacion      like log_u820_pedidos_certif_diploma_req.hash_notificacion,
       n_url                    like log_u820_pedidos_certif_diploma_req.url,
       n_uid_nuxeo              like log_u820_pedidos_certif_diploma_req.uid_nuxeo,
       n_fecha_actualizacion    like log_u820_pedidos_certif_diploma_req.fecha_actualizacion
)
BEGIN

   -------------------------------------------------------------------------------- 
   -- Impide que se modifique la clave primaria de un registro 
   -------------------------------------------------------------------------------- 
   IF o_id_certif_pedido <> n_id_certif_pedido  THEN
      raise exception -746,0,'No se puede modificar la clave primaria de un registro.';
   END IF;


   -- Carga la tabla de log para auditoria
   INSERT INTO log_u820_pedidos_certif_diploma_req (
       id_certif_pedido       ,
       requisito              ,
       hash_notificacion      ,
       url                    ,
       uid_nuxeo                    ,
       fecha_actualizacion    ,
       usuario,
       fecha_act,
       oper                 
)
   VALUES (
       n_id_certif_pedido       ,
       n_requisito              ,
       n_hash_notificacion      ,
       n_url                    ,
       n_uid_nuxeo                    ,
       n_fecha_actualizacion    ,
       User,
       Current year to Second,
       'U');
end;
end procedure;
-- ********** Fin del procedure asociado al trigger de UPDATE de u820_pedidos_certif_diploma_req **********



-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_pedidos_certif_diploma_req
-- Trigger de Update tu820_pedidos_certif_dip_req
-- *******************************************************************************
-- DROP TRIGGER tu820_pedidos_certif_dip_req;
CREATE TRIGGER tu820_pedidos_certif_dip_req UPDATE on u820_pedidos_certif_diploma_req
referencing OLD as OLD NEW as NEW
FOR EACH ROW (
   EXECUTE PROCEDURE spu_u820_ped_cert_dip_req (
       OLD.id_certif_pedido       ,
       OLD.requisito              ,
       OLD.hash_notificacion      ,
       OLD.url                    ,
       OLD.uid_nuxeo              ,
       OLD.fecha_actualizacion    ,
       NEW.id_certif_pedido       ,
       NEW.requisito              ,
       NEW.hash_notificacion      ,
       NEW.url                    ,
       NEW.uid_nuxeo              ,
       NEW.fecha_actualizacion    
    )

);
-- ********** Fin del trigger de Update tu820_pedidos_certif_dip_req **********
