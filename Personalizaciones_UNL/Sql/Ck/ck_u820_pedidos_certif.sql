ALTER TABLE "dba".u820_pedidos_certif DROP CONSTRAINT ck_estado_pago;
ALTER TABLE "dba".u820_pedidos_certif DROP CONSTRAINT ck_validado;

ALTER TABLE "dba".u820_pedidos_certif
       ADD CONSTRAINT CHECK (estado_pago IN ('P', 'N', 'M', 'V'))
              CONSTRAINT ck_estado_pago;

ALTER TABLE "dba".u820_pedidos_certif
       ADD CONSTRAINT CHECK (validado IN ('N', 'S', 'R'))
              CONSTRAINT ck_validado;
