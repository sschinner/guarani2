RENAME COLUMN "dba".u820_pedidos_certif_diploma.tramite_abreviado TO tipo_tramite;

ALTER TABLE "dba".u820_requisitos_diploma ADD (tipo_tramite varchar(1));

--Auditoria
ALTER TABLE "dba".log_u820_pedidos_certif_diploma ADD (tipo_tramite varchar(1));