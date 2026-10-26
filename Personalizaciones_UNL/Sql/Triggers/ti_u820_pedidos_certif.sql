CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'spi_u820_ped_cert') THEN
		DROP PROCEDURE spi_u820_ped_cert ;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_pedidos_certif
-- Procedure spi_u820_ped_cert (asociado al trigger de INSERT)
-- *******************************************************************************
-- DROP PROCEDURE spi_u820_ped_cert;

CREATE PROCEDURE spi_u820_ped_cert (
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
     'I');
end;
end procedure;
-- ********** Fin del procedure asociado al trigger de INSERT de u820_pedidos_certif **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_pedidos_certif
-- Trigger de Insert ti820_pedidos_certif
-- *******************************************************************************
-- DROP TRIGGER ti820_pedidos_certif;

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
  IF EXISTS (SELECT trigid
      FROM systriggers
      WHERE trigname = 'ti820_pedidos_certif') THEN
    DROP TRIGGER ti820_pedidos_certif;
  END IF;   
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


CREATE TRIGGER ti820_pedidos_certif INSERT on u820_pedidos_certif
referencing new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spi_u820_ped_cert (
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
-- ********** Fin del trigger de Insert ti820_pedidos_certif **********
