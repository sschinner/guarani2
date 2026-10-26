-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.7.0
-- Tabla u820_codigos_univ
-- Tabla de conversion de Codigos de carreras para la UNL.
-- Se agregan los codigos que corresponden a cada UA.
-- *******************************************************************************

CREATE PROCEDURE "dba".verifica_objeto();

BEGIN

IF NOT EXISTS (SELECT * FROM systables where tabname = 'u820_codigos_univ') THEN

create table "dba".u820_codigos_univ
(unidad_academica	varchar(5),
carrera varchar (5),
unl_ua varchar (5),
unl_carrera varchar (5));	

alter table "dba".u820_codigos_univ add constraint primary key (unidad_academica, carrera) constraint pk820_codigos_univ;
alter table "dba".u820_codigos_univ add constraint foreign key (unidad_academica, carrera) references sga_carreras constraint fk820_unidad_carrera;



-- *********** Fin del script de la tabla u820_codigos_univ **********

END IF;


END;

END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

revoke all on "dba".u820_codigos_univ from public;
grant select, update, insert, delete on "dba".u820_codigos_univ to guarani;
grant select, update, insert, delete on "dba".u820_codigos_univ to internet;

-- *****************************************************************************************
-- La siguiente sección de script esta comentado en bloque, para que no sea contemplado en la migración
-- *****************************************************************************************

{
-- EN ESTE SCRIPT NO SE REALIZA LA CARGA DE DATOS. PRIMERO DEBO CARGAR LA TABLA DE CODIGOS

create table ax_codigos_univ
(unidad_academica	varchar(5),
carrera varchar (5),
unl_ua varchar (5),
unl_carrera varchar (5));	

load from "E:\branches\RB-GUARANI_2.0.7_0-UNL_2\Personalizaciones_UNL\Sql\Tablas\codigos_carr_univ.txt" delimiter "|"
insert into ax_codigos_univ;

-- ATENCION, CARGAR LOS CODIGOS DE UNL DE FACULTADES Y CARRERAS --
-- select unidad_academica, carrera from u820_codigos_univ into temp ax_codigos_exist;

Insert into u820_codigos_univ 
	select * from ax_codigos_univ 
	where unidad_academica =  (select unidad_academica from sga_valor_inicial)
		and carrera in (select carrera from sga_carreras)
		and unidad_academica||carrera not in (select unidad_academica||carrera from ax_codigos_exist);
DROP TABLE ax_codigos_univ;
}
