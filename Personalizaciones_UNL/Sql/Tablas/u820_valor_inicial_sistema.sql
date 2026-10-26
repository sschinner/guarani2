CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF NOT EXISTS (SELECT tabname
			FROM systables
			WHERE tabname = 'u820_valor_inicial_sistema') THEN

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.7.0
-- Tabla u820_valor_inicial_sistema
-- *******************************************************************************
-- DROP TABLE u820_valor_inicial_sistema;
CREATE TABLE "dba".u820_valor_inicial_sistema (
       UNIDAD_ACADEMICA     varchar(5) NOT NULL,
       CAMPO      varchar(18) NOT NULL,
       SISTEMA varchar(20) NOT NULL,
       VALOR_INICIAL varchar(60) NOT NULL
);


ALTER TABLE "dba".u820_valor_inicial_sistema
       ADD CONSTRAINT PRIMARY KEY (UNIDAD_ACADEMICA, CAMPO, SISTEMA)
              CONSTRAINT pk820_valor_inicial_sistema;


ALTER TABLE "dba".u820_valor_inicial_sistema 
	ADD CONSTRAINT FOREIGN KEY (UNIDAD_ACADEMICA, CAMPO)
                             REFERENCES sga_valor_inicial (UNIDAD_ACADEMICA, CAMPO)
              CONSTRAINT fk_u820_valor_sistema_valor_inicial;


-- *********** Fin del script de la tabla u820_valor_inicial_sistema **********

	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

revoke all on "dba".u820_valor_inicial_sistema from public;
grant select, update, insert, delete on "dba".u820_valor_inicial_sistema to internet; 
grant select, update, insert, delete on "dba".u820_valor_inicial_sistema to guarani;

-- *****************************************************************************************
-- La siguiente seccion de script esta comentado en bloque, para que no sea contemplado en la migración
-- *****************************************************************************************

{
insert into u820_valor_inicial_sistema 
select unidad_academica, campo, 'Kolla', unidad_academica
from sga_valor_inicial;
}


