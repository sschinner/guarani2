CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'spu_u820_ped_cert') THEN
		DROP PROCEDURE spu_u820_ped_cert ;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_pedidos_certif
-- Procedure spu_u820_ped_cert (asociado al trigger de UPDATE)
-- *******************************************************************************
-- DROP PROCEDURE spu_u820_ped_cert;

CREATE PROCEDURE spu_u820_ped_cert (
       o_id_certif_pedido like u820_pedidos_certif.id_certif_pedido,
       o_estado_pago like u820_pedidos_certif.estado_pago,
       o_validado like u820_pedidos_certif.validado,
       o_fecha_vencimiento_pago like u820_pedidos_certif.fecha_vencimiento_pago,
       o_hash_pago like u820_pedidos_certif.hash_pago,
       o_identificador_cobro like u820_pedidos_certif.identificador_cobro,
       o_expediente like u820_pedidos_certif.expediente,
       o_url_descarga like u820_pedidos_certif.url_descarga,
       o_motivorechazo like u820_pedidos_certif.motivorechazo,
       o_identificador_deuda like u820_pedidos_certif.identificador_deuda,
       o_path_nuxeo like u820_pedidos_certif.path_nuxeo,
       n_id_certif_pedido like u820_pedidos_certif.id_certif_pedido,
       n_estado_pago like u820_pedidos_certif.estado_pago,
       n_validado like u820_pedidos_certif.validado,
       n_fecha_vencimiento_pago like u820_pedidos_certif.fecha_vencimiento_pago,
       n_hash_pago like u820_pedidos_certif.hash_pago,
       n_identificador_cobro like u820_pedidos_certif.identificador_cobro,
       n_expediente like u820_pedidos_certif.expediente,
       n_url_descarga like u820_pedidos_certif.url_descarga,
       n_motivorechazo like u820_pedidos_certif.motivorechazo,
       n_identificador_deuda like u820_pedidos_certif.identificador_deuda,
       n_path_nuxeo like u820_pedidos_certif.path_nuxeo)
BEGIN

   -------------------------------------------------------------------------------- 
   -- Impide que se modifique la clave primaria de un registro 
   -------------------------------------------------------------------------------- 
   IF o_id_certif_pedido <> n_id_certif_pedido  THEN
      raise exception -746,0,'No se puede modificar la clave primaria de un registro.';
   END IF;


   -- Carga la tabla de log para auditoria
   INSERT INTO log_u820_pedidos_certif (
     id_certif_pedido,
     estado_pago,
     validado,
     fecha_vencimiento_pago,
     hash_pago,
     identificador_cobro,
     expediente,
     url_descarga,
     motivorechazo,
     identificador_deuda,
     path_nuxeo,
     usuario,
     fecha_act,
     oper)
   VALUES (
     n_id_certif_pedido,
     n_estado_pago,
     n_validado,
     n_fecha_vencimiento_pago,
     n_hash_pago,
     n_identificador_cobro,
     n_expediente,
     n_url_descarga,
     n_motivorechazo,
     n_identificador_deuda,
     n_path_nuxeo,
     User,
     Current year to Second,
     'U');
end;
end procedure;
-- ********** Fin del procedure asociado al trigger de UPDATE de u820_pedidos_certif **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_pedidos_certif
-- Trigger de Update tu820_pedidos_certif
-- *******************************************************************************
-- DROP TRIGGER tu820_pedidos_certif;


CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
  IF EXISTS (SELECT trigid
      FROM systriggers
      WHERE trigname = 'tu820_pedidos_certif') THEN
    DROP TRIGGER tu820_pedidos_certif;
  END IF;   
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

CREATE TRIGGER tu820_pedidos_certif UPDATE on u820_pedidos_certif
referencing old as old new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spu_u820_ped_cert (
     old.id_certif_pedido,
     old.estado_pago,
     old.validado,
     old.fecha_vencimiento_pago,
     old.hash_pago,
     old.identificador_cobro,
     old.expediente,
     old.url_descarga,
     old.motivorechazo,
     old.identificador_deuda,
     old.path_nuxeo,
     new.id_certif_pedido,
     new.estado_pago,
     new.validado,
     new.fecha_vencimiento_pago,
     new.hash_pago,
     new.identificador_cobro,
     new.expediente,
     new.url_descarga,
     new.motivorechazo,
     new.identificador_deuda,
     new.path_nuxeo)
);
-- ********** Fin del trigger de Update tu820_pedidos_certif **********
