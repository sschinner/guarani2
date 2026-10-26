-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.6
-- Tabla u820_req_comunicacion
-- *******************************************************************************
CREATE PROCEDURE "dba".verifica_objeto()

BEGIN

IF NOT EXISTS (SELECT * FROM systables where tabname = 'u820_req_comunicacion') THEN

CREATE TABLE "dba".u820_req_comunicacion(
	REQ_COMUNICACION integer NOT NULL,
	DESCRIPCION varchar(255)
);

alter table "dba".u820_req_comunicacion
	add constraint primary key (REQ_COMUNICACION ) 
		constraint pk_u820_req_comunicacion;

Insert into u820_req_comunicacion values (1, "No");
Insert into u820_req_comunicacion values (2, "No Sabe");
Insert into u820_req_comunicacion values (3, "Braile");
Insert into u820_req_comunicacion values (4, "Otros requerimientos para lectura");
Insert into u820_req_comunicacion values (5, "Lengua de Señas Argentina (LSA)");
Insert into u820_req_comunicacion values (6, "Otros");

END IF;


END;

END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

revoke all on "dba".u820_req_comunicacion from public;
grant select, update, insert, delete on "dba".u820_req_comunicacion to guarani;
grant select, update, insert, delete on "dba".u820_req_comunicacion to internet;

