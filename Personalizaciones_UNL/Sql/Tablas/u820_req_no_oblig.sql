-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.5.22
-- Tabla u820_req_no_oblig
-- Tabla de requisitos obligatorios de UNL, para realizar actividad académica.
--	Se controla su cumplimiento pasado el año de ingreso.
-- Se deja la carrera, para poder manejar alumnos externos y por integración
-- *******************************************************************************

CREATE PROCEDURE "dba".sp_crea_tabla_u820_req_no_oblig();

BEGIN

IF NOT EXISTS (SELECT * FROM systables where tabname = 'u820_req_no_oblig') THEN

-- drop table u820_req_no_oblig;
create table "dba".u820_req_no_oblig(
	unidad_academica	varchar (5) not null,
	carrera		varchar (5),
	requisito		varchar (5)not null);

-- Agregar atributos para control por fecha individual de requisitos
alter table "dba".u820_req_no_oblig add dia integer;
alter table "dba".u820_req_no_oblig add mes integer;
alter table "dba".u820_req_no_oblig add delta_anio integer;

alter table "dba".u820_req_no_oblig
add constraint foreign key (requisito)
references sga_requisitos
constraint fk820_requisito;


-- ATENCIÓN: HASTA UNIFICAR EL TEMA REQUISITOS, AGREGAR LA FK QUE CORRESPONDA
-- alter table u820_req_no_oblig drop constraint fk820_requisito_car;
alter table "dba".u820_req_no_oblig
add constraint foreign key (unidad_academica, carrera, requisito)
references sga_requisitos_car
constraint fk820_requisito_car;

-- alter table "dba".u820_req_no_oblig drop constraint fk820_requisito_ua;
alter table "dba".u820_req_no_oblig
add constraint foreign key (unidad_academica, requisito)
references sga_requisitos_ua
constraint fk820_requisito_ua;


-- *********** Fin del script de la tabla u820_req_no_oblig **********

END IF;
END;
END PROCEDURE;

EXECUTE PROCEDURE "dba".sp_crea_tabla_u820_req_no_oblig();
DROP PROCEDURE "dba".sp_crea_tabla_u820_req_no_oblig();

revoke all on "dba".sga_datos_cen_aux from public;
grant select, update, insert, delete on "dba".u820_req_no_oblig to guarani;
grant select, update, insert, delete on "dba".u820_req_no_oblig to internet;

-- *****************************************************************************************
-- La siguiente sección del script esta comentado en bloque, para que no sea contemplado en la migración
-- *****************************************************************************************

{ 
-- ESTA PARTE DEL SCRIPT NO CORRER: VERIFICAR LUEGO SI ES NECESARIO ARREGLAR/INSERTAR DATOS
-- **********************************************************
-- UNIFICACION DE REQUISITOS DE INGRESO
-- **********************************************************
-- select * from sga_requisitos;

begin;

set constraints all deferred;

set triggers for sga_requisitos  disabled;
set triggers for sga_hist_req_cump  disabled;
set triggers for sga_fec_excep_req  disabled;
set triggers for u820_req_no_oblig disabled;
set triggers for sga_requisitos_car  disabled;
set triggers for sga_requisitos_ua  disabled;
set triggers for sga_req_cumplidos  disabled;

update sga_requisitos set requisito = 'UNL01', nombre = 'DNI y Fotocopia', observaciones = 'Documento Nacional de Identidad y fotocopia de la primera hoja'
where requisito = '00001';

update sga_requisitos set requisito = 'UNL02', nombre = 'Fotocopia de Partida de Nacimiento', observaciones = 'Fotocopia legalizada de la partida de nacimiento'
where requisito = '00002';

update sga_requisitos set requisito = 'UNL03', nombre = 'Certificado de Estudios Secundarios legalizado en la UNL', observaciones = 'Certificado de Estudios Secundarios legalizado en la UNL'
where requisito = '00003';

update sga_requisitos set requisito = 'UNL04', nombre = 'Fotografías 4x4', observaciones = 'Fotografías 4x4 de frente'
where requisito = '00004';

update sga_requisitos set requisito = 'UNL05', nombre = 'Certificado de Grupo y Factor Sanguíneo', observaciones = 'Constancia de Grupo Sanguíneo y Factor RH'
where requisito = '00005';

update sga_requisitos set requisito = 'UNL06', nombre = 'Certificado de Profilaxis', observaciones = 'Certificado de Profilaxis'
where requisito = '00006';

update sga_requisitos set requisito = 'UNL07', nombre = 'Constancia de Terminación de Estudios Secundarios', observaciones = 'Constancia de Terminación de Estudios Secundarios'
where requisito = '00007';

-- **********************************************************************************************

update sga_hist_req_cump  set requisito = 'UNL01' where requisito = '00001';
update sga_hist_req_cump  set requisito = 'UNL02' where requisito = '00002';
update sga_hist_req_cump  set requisito = 'UNL03' where requisito = '00003';
update sga_hist_req_cump  set requisito = 'UNL04' where requisito = '00004';
update sga_hist_req_cump  set requisito = 'UNL05' where requisito = '00005';
update sga_hist_req_cump  set requisito = 'UNL06' where requisito = '00006';
update sga_hist_req_cump  set requisito = 'UNL07' where requisito = '00007';

update sga_fec_excep_req  set requisito = 'UNL01' where requisito = '00001';
update sga_fec_excep_req  set requisito = 'UNL02' where requisito = '00002';
update sga_fec_excep_req  set requisito = 'UNL03' where requisito = '00003';
update sga_fec_excep_req  set requisito = 'UNL04' where requisito = '00004';
update sga_fec_excep_req  set requisito = 'UNL05' where requisito = '00005';
update sga_fec_excep_req  set requisito = 'UNL06' where requisito = '00006';
update sga_fec_excep_req  set requisito = 'UNL07' where requisito = '00007';

update u820_req_no_oblig set requisito = 'UNL01' where requisito = '00001';
update u820_req_no_oblig set requisito = 'UNL02' where requisito = '00002';
update u820_req_no_oblig set requisito = 'UNL03' where requisito = '00003';
update u820_req_no_oblig set requisito = 'UNL04' where requisito = '00004';
update u820_req_no_oblig set requisito = 'UNL05' where requisito = '00005';
update u820_req_no_oblig set requisito = 'UNL06' where requisito = '00006';
update u820_req_no_oblig set requisito = 'UNL07' where requisito = '00007';

update sga_requisitos_car  set requisito = 'UNL01' where requisito = '00001';
update sga_requisitos_car  set requisito = 'UNL02' where requisito = '00002';
update sga_requisitos_car  set requisito = 'UNL03' where requisito = '00003';
update sga_requisitos_car  set requisito = 'UNL04' where requisito = '00004';
update sga_requisitos_car  set requisito = 'UNL05' where requisito = '00005';
update sga_requisitos_car  set requisito = 'UNL06' where requisito = '00006';
update sga_requisitos_car  set requisito = 'UNL07' where requisito = '00007';

update sga_requisitos_ua  set requisito = 'UNL01' where requisito = '00001';
update sga_requisitos_ua  set requisito = 'UNL02' where requisito = '00002';
update sga_requisitos_ua  set requisito = 'UNL03' where requisito = '00003';
update sga_requisitos_ua  set requisito = 'UNL04' where requisito = '00004';
update sga_requisitos_ua  set requisito = 'UNL05' where requisito = '00005';
update sga_requisitos_ua  set requisito = 'UNL06' where requisito = '00006';
update sga_requisitos_ua  set requisito = 'UNL07' where requisito = '00007';

update sga_req_cumplidos  set requisito = 'UNL01' where requisito = '00001';
update sga_req_cumplidos  set requisito = 'UNL02' where requisito = '00002';
update sga_req_cumplidos  set requisito = 'UNL03' where requisito = '00003';
update sga_req_cumplidos  set requisito = 'UNL04' where requisito = '00004';
update sga_req_cumplidos  set requisito = 'UNL05' where requisito = '00005';
update sga_req_cumplidos  set requisito = 'UNL06' where requisito = '00006';
update sga_req_cumplidos  set requisito = 'UNL07' where requisito = '00007';

commit;

set triggers for sga_requisitos  enabled;
set triggers for sga_hist_req_cump  enabled;
set triggers for sga_fec_excep_req  enabled;
set triggers for u820_req_no_oblig enabled;
set triggers for sga_requisitos_car  enabled;
set triggers for sga_requisitos_ua  enabled;
set triggers for sga_req_cumplidos  enabled;


-- VERIFICAR EN GUARANI, QUE LAS CARRERAS DE GRADO ESTEN ASIGNADAS A ESTE GRUPO.
-- REEMPLAZAR LA CADENA "ua" POR LA SIGLA DE LA UA

insert into sga_grupos_carrera (UNIDAD_ACADEMICA, GRUPO_CARRERA,NOMBRE, OBSERVACIONES) values ('FBCB', '00001', 'Carreras de Grado', 'Carreras de Grado de la UNL');


-- INSERTAR REQUISITOS EN TABLA PARA CONTROL DE REQUISITOS UNL
Begin;
delete from u820_req_no_oblig where 1=1;
insert into u820_req_no_oblig 
	select ua.unidad_academica, car.carrera, req.requisito
	from sga_requisitos req, sga_carreras car, sga_valor_inicial ua, sga_carreras_grupo gcar
	where gcar.carrera = car.carrera
		and gcar.grupo_carrera = '00001'
		and req.requisito in ('UNL03', 'UNL06');

commit;

-- Verificar/Agregar atributos para control por fecha individual de requisitos
alter table u820_req_no_oblig add dia integer;
alter table u820_req_no_oblig add mes integer;
alter table u820_req_no_oblig add delta_anio integer;


-- Actualizar datos de fechas de cumplimiento de requisitos
-- Título
update u820_req_no_oblig set dia = 1 WHERE REQUISITO = 'UNL03';
update u820_req_no_oblig set mes = 6 WHERE REQUISITO = 'UNL03';
-- Delta implica a controlar en año actual (0) o en año siguiente (1) al de ingreso
update u820_req_no_oblig set delta_anio = 1 WHERE REQUISITO = 'UNL03';

-- Profilaxis
update u820_req_no_oblig set dia = 1 WHERE REQUISITO = 'UNL06';
update u820_req_no_oblig set mes = 6 WHERE REQUISITO = 'UNL06';
update u820_req_no_oblig set delta_anio = 1 WHERE REQUISITO = 'UNL06';

}