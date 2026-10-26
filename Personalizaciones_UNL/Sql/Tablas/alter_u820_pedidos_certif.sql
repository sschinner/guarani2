-- Nuevo campo para comunicacion con WS de Medios de Cobro
ALTER TABLE "dba".u820_pedidos_certif ADD (identificador_deuda varchar(255));
ALTER TABLE "dba".log_u820_pedidos_certif ADD (identificador_deuda varchar(255));

ALTER TABLE "dba".u820_pedidos_certif MODIFY (identificador_cobro varchar(255)); 
DROP INDEX in_identpedidocertif;