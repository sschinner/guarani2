CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'spu_u820_ped_cert_dip') THEN
		DROP PROCEDURE spu_u820_ped_cert_dip ;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_pedidos_certif_diploma
-- Procedure spu_u820_ped_cert_dip (asociado al trigger de UPDATE)
-- *******************************************************************************
-- DROP PROCEDURE spu_u820_ped_cert_dip ;
CREATE PROCEDURE spu_u820_ped_cert_dip (
       o_id_certif_pedido           like log_u820_pedidos_certif_diploma.id_certif_pedido,
       o_imprenta                   like log_u820_pedidos_certif_diploma.imprenta,
       o_requisitos_validados       like log_u820_pedidos_certif_diploma.requisitos_validados,
       o_url_titulo_tramite         like log_u820_pedidos_certif_diploma.url_titulo_tramite,
       o_url_certificado_analitico  like log_u820_pedidos_certif_diploma.url_certificado_analitico,
       o_carrera                    like log_u820_pedidos_certif_diploma.carrera,
       o_titulo                     like log_u820_pedidos_certif_diploma.titulo,
       o_autorizado_apellido        like log_u820_pedidos_certif_diploma.autorizado_apellido,
       o_autorizado_nombre          like log_u820_pedidos_certif_diploma.autorizado_nombre,
       o_autorizado_documento       like log_u820_pedidos_certif_diploma.autorizado_documento,
       o_tipo_tramite				like log_u820_pedidos_certif_diploma.tipo_tramite,
       n_id_certif_pedido           like log_u820_pedidos_certif_diploma.id_certif_pedido,
       n_imprenta                   like log_u820_pedidos_certif_diploma.imprenta,
       n_requisitos_validados       like log_u820_pedidos_certif_diploma.requisitos_validados,
       n_url_titulo_tramite         like log_u820_pedidos_certif_diploma.url_titulo_tramite,
       n_url_certificado_analitico  like log_u820_pedidos_certif_diploma.url_certificado_analitico,
       n_carrera                    like log_u820_pedidos_certif_diploma.carrera,
       n_titulo                     like log_u820_pedidos_certif_diploma.titulo,
       n_autorizado_apellido        like log_u820_pedidos_certif_diploma.autorizado_apellido,
       n_autorizado_nombre          like log_u820_pedidos_certif_diploma.autorizado_nombre,
       n_autorizado_documento       like log_u820_pedidos_certif_diploma.autorizado_documento,
       n_tipo_tramite				like log_u820_pedidos_certif_diploma.tipo_tramite
)
BEGIN

   -------------------------------------------------------------------------------- 
   -- Impide que se modifique la clave primaria de un registro 
   -------------------------------------------------------------------------------- 
   IF o_id_certif_pedido <> n_id_certif_pedido  THEN
      raise exception -746,0,'No se puede modificar la clave primaria de un registro.';
   END IF;


   -- Carga la tabla de log para auditoria
   INSERT INTO log_u820_pedidos_certif_diploma (
       id_certif_pedido,
       imprenta,
       requisitos_validados,
       url_titulo_tramite,
       url_certificado_analitico,
       carrera,
       titulo,
       autorizado_apellido,
       autorizado_nombre,
       autorizado_documento,
       tipo_tramite,
       usuario,
       fecha_act,
       oper                 
)
   VALUES (
       n_id_certif_pedido,
       n_imprenta,
       n_requisitos_validados,
       n_url_titulo_tramite,
       n_url_certificado_analitico,
       n_carrera,
       n_titulo,
       n_autorizado_apellido,
       n_autorizado_nombre,
       n_autorizado_documento,
       n_tipo_tramite,
       User,
       Current year to Second,
       'U');
end;
end procedure;
-- ********** Fin del procedure asociado al trigger de UPDATE de u820_pedidos_certif_diploma **********
CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
  IF EXISTS (SELECT trigid
      FROM systriggers
      WHERE trigname = 'tu820_pedidos_certif_dip') THEN
    DROP TRIGGER tu820_pedidos_certif_dip;
  END IF;   
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_pedidos_certif_diploma
-- Trigger de Update tu820_pedidos_certif_dip
-- *******************************************************************************
-- DROP TRIGGER tu820_pedidos_certif_dip;
CREATE TRIGGER tu820_pedidos_certif_dip UPDATE on u820_pedidos_certif_diploma
referencing OLD as OLD NEW as NEW
FOR EACH ROW (
   EXECUTE PROCEDURE spu_u820_ped_cert_dip (
       OLD.id_certif_pedido,
       OLD.imprenta,
       OLD.requisitos_validados,
       OLD.url_titulo_tramite,
       OLD.url_certificado_analitico,
       OLD.carrera,
       OLD.titulo,
       OLD.autorizado_apellido,
       OLD.autorizado_nombre,
       OLD.autorizado_documento,
       OLD.tipo_tramite,
       NEW.id_certif_pedido,
       NEW.imprenta,
       NEW.requisitos_validados,
       NEW.url_titulo_tramite,
       NEW.url_certificado_analitico,
       NEW.carrera,
       NEW.titulo,
       NEW.autorizado_apellido,
       NEW.autorizado_nombre,
       NEW.autorizado_documento,
       NEW.tipo_tramite
    )

);
-- ********** Fin del trigger de Update tu820_pedidos_certif_dip **********
