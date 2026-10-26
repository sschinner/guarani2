CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'spi_u820_ped_cert_dip') THEN
		DROP PROCEDURE spi_u820_ped_cert_dip ;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_pedidos_certif_diploma
-- Procedure spi_u820_ped_cert_dip (asociado al trigger de INSERT)
-- *******************************************************************************
-- DROP PROCEDURE spi_u820_ped_cert_dip ;
CREATE PROCEDURE spi_u820_ped_cert_dip (
       p_id_certif_pedido           like log_u820_pedidos_certif_diploma.id_certif_pedido,
       p_imprenta                   like log_u820_pedidos_certif_diploma.imprenta,
       p_requisitos_validados       like log_u820_pedidos_certif_diploma.requisitos_validados,
       p_url_titulo_tramite         like log_u820_pedidos_certif_diploma.url_titulo_tramite,
       p_url_certificado_analitico  like log_u820_pedidos_certif_diploma.url_certificado_analitico,
       p_carrera                    like log_u820_pedidos_certif_diploma.carrera,
       p_titulo                     like log_u820_pedidos_certif_diploma.titulo,
       p_autorizado_apellido        like log_u820_pedidos_certif_diploma.autorizado_apellido,
       p_autorizado_nombre          like log_u820_pedidos_certif_diploma.autorizado_nombre,
       p_autorizado_documento       like log_u820_pedidos_certif_diploma.autorizado_documento,
       p_tipo_tramite				like log_u820_pedidos_certif_diploma.tipo_tramite
      )
BEGIN

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
       p_id_certif_pedido,
       p_imprenta,
       p_requisitos_validados,
       p_url_titulo_tramite,
       p_url_certificado_analitico,
       p_carrera,
       p_titulo,
       p_autorizado_apellido,
       p_autorizado_nombre,
       p_autorizado_documento,
       p_tipo_tramite,
       User,
       Current year to Second,
       'I');
end;
end procedure;
-- ********** Fin del procedure asociado al trigger de INSERT de u820_pedidos_certif_diploma **********

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
  IF EXISTS (SELECT trigid
      FROM systriggers
      WHERE trigname = 'ti820_pedidos_certif_dip') THEN
    DROP TRIGGER ti820_pedidos_certif_dip;
  END IF;   
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.2
-- Tabla u820_pedidos_certif_diploma
-- Trigger de Insert ti820_pedidos_certif_dip
-- *******************************************************************************
-- DROP TRIGGER ti820_pedidos_certif_dip;
CREATE TRIGGER ti820_pedidos_certif_dip INSERT on u820_pedidos_certif_diploma
referencing NEW as NEW
FOR EACH ROW (
   EXECUTE PROCEDURE spi_u820_ped_cert_dip (
       NEW.id_certif_pedido           ,
       NEW.imprenta                   ,
       NEW.requisitos_validados       ,
       NEW.url_titulo_tramite         ,
       NEW.url_certificado_analitico  ,
       NEW.carrera                    ,
       NEW.titulo                     ,
       NEW.autorizado_apellido        ,
       NEW.autorizado_nombre          ,
       NEW.autorizado_documento       ,
       NEW.tipo_tramite
    )
);
-- ********** Fin del trigger de Insert ti820_pedidos_certif_dip **********
