CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'spd_u820_ped_cert') THEN
		DROP PROCEDURE spd_u820_ped_cert;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_pedidos_certif
-- Procedure spd_u820_ped_cert (asociado al trigger de DELETE)
-- *******************************************************************************
-- DROP PROCEDURE spd_u820_ped_cert;

CREATE PROCEDURE spd_u820_ped_cert (
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
       o_path_nuxeo like u820_pedidos_certif.path_nuxeo)
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
     o_id_certif_pedido,
     o_estado_pago,
     o_validado,
     o_fecha_vencimiento_pago,
     o_hash_pago,
     o_identificador_cobro,
     o_expediente,
     o_url_descarga,
     o_motivorechazo,
     o_identificador_deuda,
     o_path_nuxeo,
     User,
     Current year to Second,
     'D');
end;
end procedure;
-- ********** Fin del procedure asociado al trigger de DELETE de u820_pedidos_certif **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_pedidos_certif
-- Trigger de Delete td820_pedidos_certif
-- *******************************************************************************
-- DROP TRIGGER td820_pedidos_certif;

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
  IF EXISTS (SELECT trigid
      FROM systriggers
      WHERE trigname = 'td820_pedidos_certif') THEN
    DROP TRIGGER td820_pedidos_certif;
  END IF;   
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

CREATE TRIGGER td820_pedidos_certif DELETE on u820_pedidos_certif
referencing old as old
FOR EACH ROW (
   EXECUTE PROCEDURE spd_u820_ped_cert (
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
     old.path_nuxeo)
);
-- ********** Fin del trigger de Delete td820_pedidos_certif **********
