-- *****************************************************************************************
-- El siguiente script esta comentado en bloque, para que no sea contemplado en la migración
-- *****************************************************************************************
{

-- rollback;
Begin;
-- Estadística
-- Módulo Administración
insert into acc_perfiles values('Estad','Estadística - UNL', null, 0);
insert into acc_modulos values ('EST00002', 'Administración del sistema', null);
insert into acc_operacion_mod select 'EST00002', operacion, submodulo, orden from acc_operacion_mod where modulo = '00000002' and submodulo = 'CtrDatos';
insert into acc_modulos_perfil values('Estad','EST00002');

-- Módulo Matrícula
insert into acc_modulos values ('EST00010', 'Matrícula', null);
insert into acc_operacion_mod select 'EST00010', operacion, submodulo, orden from acc_operacion_mod where modulo = '00000010' and operacion in ('mat00117', 'mat00104', 'mat00105', 'mat00100', 'mat00107', 'mat00120', '820mat15');
insert into acc_modulos_perfil values('Estad','EST00010');

-- Módulo Egresados
insert into acc_modulos values ('EST00060', 'Egresados', null);
insert into acc_operacion_mod select 'EST00060', operacion, submodulo, orden from acc_operacion_mod where modulo = '00000060' and operacion in ('egr00102', 'egr05230');
insert into acc_modulos_perfil values('Estad','EST00060');

-- Módulo Interfaces
insert into acc_modulos values ('EST00070', 'Interfaces', null);
insert into acc_operacion_mod select 'EST00070', operacion, submodulo, orden from acc_operacion_mod where modulo = '00000070' and submodulo in ('Gua-DWH', 'Guar_Ara') and operacion <> 'ifz00029';
insert into acc_operacion_mod select 'EST00070', operacion, submodulo, orden from acc_operacion_mod where modulo = '00000070' and submodulo in ('ArauGua') ;
insert into acc_modulos_perfil values('Estad','EST00070');

-- Módulo Carreras y Planes
insert into acc_modulos values ('EST00005', 'Carreras y Planes', null);
insert into acc_operacion_mod select 'EST00005', operacion, submodulo, orden from acc_operacion_mod where modulo = '00000005' and operacion in ('car00103');
insert into acc_operacion_mod select 'EST00005', operacion, submodulo, orden from acc_operacion_mod where modulo = '00000005' and operacion in ('car00001', 'car00003');
insert into acc_operacion_mod select 'EST00005', operacion, submodulo, orden from acc_operacion_mod where modulo = '00000005' and operacion in ('car00115');
insert into acc_modulos_perfil values('Estad','EST00005');

-- Módulo Unidad Académica
insert into acc_modulos values ('EST00050', 'Unidad Academica', null);
insert into acc_operacion_mod select 'EST00050', operacion, submodulo, orden from acc_operacion_mod where modulo = '00000050' and operacion in ('ua000001', 'ua000031');
insert into acc_modulos_perfil values('Estad','EST00050');

-- Módulo Cursadas
insert into acc_modulos values ('EST00015', 'Cursada', null);
insert into acc_operacion_mod select 'EST00015', operacion, submodulo, orden from acc_operacion_mod where modulo = '00000015' and operacion in ('cur00126');
insert into acc_modulos_perfil values('Estad','EST00015');


grant connect to pstorani;
grant guarani to pstorani;

grant connect to lhernan;
grant guarani to lhernan;

grant connect to gkorell;
grant guarani to gkorell;

grant connect to pmartine;
grant guarani to pmartine;

grant connect to rmeyer;
grant guarani to rmeyer;

grant connect to mbalbi;
grant guarani to mbalbi;

grant connect to ebulgare;
grant guarani to ebulgare;

-- Auditoría
-- Módulo Administración
insert into acc_perfiles values('Audit','Auditoría - UNL', null, 0);
insert into acc_modulos values ('AUD00002', 'Administración del sistema', null);
insert into acc_operacion_mod select 'AUD00002', operacion, submodulo, orden from acc_operacion_mod where modulo = '00000002' and submodulo = 'CtrDatos';
insert into acc_operacion_mod select 'AUD00002', operacion, submodulo, orden from acc_operacion_mod where modulo = '00000002' and submodulo = 'Reportes';
insert into acc_modulos_perfil values('Audit','AUD00002');

-- Módulo Matrícula
insert into acc_modulos values ('AUD00010', 'Matrícula', null);
insert into acc_operacion_mod select 'AUD00010', operacion, submodulo, orden from acc_operacion_mod where modulo = '00000010' and submodulo = 'Reportes';
insert into acc_modulos_perfil values('Audit','AUD00010');

-- Módulo Examenes
insert into acc_modulos values ('AUD00020', 'Exámenes', null);
insert into acc_operacion_mod select 'AUD00020', operacion, submodulo, orden from acc_operacion_mod where modulo = '00000020' and submodulo = 'Reportes';
insert into acc_modulos_perfil values('Audit','AUD00020');

-- Módulo Unidad Académica
insert into acc_modulos values ('AUD00050', 'Unidad Académica', null);
insert into acc_operacion_mod select 'AUD00050', operacion, submodulo, orden from acc_operacion_mod where modulo = '00000050' and submodulo = 'Reportes';
insert into acc_modulos_perfil values('Audit','AUD00050');

-- Módulo Egresados
insert into acc_modulos values ('AUD00060', 'Egresados', null);
insert into acc_operacion_mod select 'AUD00060', operacion, submodulo, orden from acc_operacion_mod where modulo = '00000060' and submodulo = 'Reportes';
insert into acc_modulos_perfil values('Audit','AUD00060');

-- Módulo Interfaces
insert into acc_modulos values ('AUD00070', 'Interfaces', null);
insert into acc_operacion_mod select 'AUD00070', operacion, submodulo, orden from acc_operacion_mod where modulo = '00000070' and submodulo = 'Reportes';
insert into acc_modulos_perfil values('Audit','AUD00070');

-- Módulo Carreras y Planes
insert into acc_modulos values ('AUD00005', 'Carreras y Planes', null);
insert into acc_operacion_mod select 'AUD00005', operacion, submodulo, orden from acc_operacion_mod where modulo = '00000005' and submodulo = 'Reportes';
insert into acc_modulos_perfil values('Audit','AUD00005');

grant connect to dmejias;
grant guarani to dmejias;

grant connect to aagustin;
grant guarani to aagustin;

grant connect to jcrsitob;
grant guarani to jcristob;

grant connect to cmestre;
grant guarani to cmestre;

revoke guarani from mchiesa;
revoke connect from mchiesa;

-- Bienestar
delete from acc_modulos_perfil where perfil = 'Bienest';
delete from acc_perfiles where perfil = 'Bienest';
insert into acc_perfiles values('Bienest','Bienestar - UNL', null, 0);


-- Módulo Interfaces
insert into acc_modulos values ('BIE00070', 'Interfaces', null);
insert into acc_operacion_mod select 'BIE00070', operacion, submodulo, orden from acc_operacion_mod where modulo = '00000070' and submodulo = 'SPU-Cali';
insert into acc_operacion_mod select 'BIE00070', operacion, submodulo, orden from acc_operacion_mod where modulo = '00000070' and submodulo = 'Becas';

begin;
insert into acc_operacion_mod select 'BIE00010', operacion, submodulo, orden from acc_operacion_mod where modulo = '00000080' and operacion in ('mat00125');
commit;

insert into acc_modulos_perfil values('Bienest','BIE00070');

-- Módulo Carreras y Planes
insert into acc_modulos_perfil values('Bienest','AUD00005');


grant connect to lfierro;
grant guarani to lfierro;

grant connect to kzuska;
grant guarani to kzuska;

-- Diploma
delete from acc_modulos_perfil where perfil = 'Dip-Rect';
delete from acc_perfiles where perfil = 'Dip-Rect';
insert into acc_perfiles values('Dip-Rect','Diplomas - UNL', null, 0);

-- Módulo Egresados
insert into acc_modulos values ('rect0061', 'Egresados', null);
insert into acc_operacion_mod select 'rect0061', operacion, submodulo, orden from acc_operacion_mod where modulo = '00000060' and operacion in ('egr05230', 'egr05070', '820egr50', 'egr00102', 'ua000026');
insert into acc_modulos_perfil values('Dip-Rect','rect0061');


grant connect to achianal;
grant guarani to achianal;

grant connect to cfrilloc;
grant guarani to cfrilloc;

grant connect to mgonzale;
grant guarani to mgonzale;

Commit;

-- rollback;
begin;
set constraints all deferred;

delete from sga_sedes_usuario where usuario = 'slopez';
delete from sga_sedes_usuario where usuario = 'pstorani';
delete from sga_sedes_usuario where usuario = 'lhernan';
delete from sga_sedes_usuario where usuario = 'pmartine';
delete from sga_sedes_usuario where usuario = 'gkorell';

delete from sga_sedes_usuario where usuario = 'aagustin';
delete from sga_sedes_usuario where usuario = 'mchiesa';
delete from sga_sedes_usuario where usuario = 'dmejias';
delete from sga_sedes_usuario where usuario = 'cmestre';
delete from sga_sedes_usuario where usuario = 'jcristob';

delete from sga_sedes_usuario where usuario = 'lfierro';
delete from sga_sedes_usuario where usuario = 'kzuska';

delete from sga_sedes_usuario where usuario in ('achianal', 'mgonzale', 'cfrilloc');
delete from sga_sedes_usuario where usuario in ('rmeyer', 'ebulgare', 'mbalbi');

delete from sga_datos_usuarios where usuario = 'slopez';
delete from sga_datos_usuarios where usuario = 'pstorani';
delete from sga_datos_usuarios where usuario = 'lhernan';
delete from sga_datos_usuarios where usuario = 'pmartine';
delete from sga_datos_usuarios where usuario = 'gkorell';

delete from sga_datos_usuarios where usuario = 'aagustin';
delete from sga_datos_usuarios where usuario = 'mchiesa';
delete from sga_datos_usuarios where usuario = 'dmejias';
delete from sga_datos_usuarios where usuario = 'cmestre';
delete from sga_datos_usuarios where usuario = 'jcristob';

delete from sga_datos_usuarios where usuario = 'lfierro';
delete from sga_datos_usuarios where usuario = 'kzuska';

delete from sga_datos_usuarios where usuario in ('achianal', 'mgonzale', 'cfrilloc');
delete from sga_datos_usuarios where usuario in ('rmeyer', 'ebulgare', 'mbalbi');

delete from acc_usuarios where perfil in ('Estad', 'Audit', 'Bienest', 'Dip-Rect');

insert into acc_usuarios values('lhernan', 'Leonardo Hernandez', 'Estad', null);
insert into acc_usuarios values('pstorani', 'Patricia Storani', 'Estad', null);
insert into acc_usuarios values('pmartine', 'Pamela Martinez', 'Estad', null);
insert into acc_usuarios values('gkorell', 'Guillermo Korell', 'Estad', null);

insert into acc_usuarios values('rmeyer', 'Roberto Meyer', 'Estad', null);
insert into acc_usuarios values('ebulgare', 'Esteban Bulgarella', 'Estad', null);
insert into acc_usuarios values('mbalbi', 'María Victoria Balbi', 'Estad', null);

insert into acc_usuarios values('aagustin', 'Alejandra Agustini', 'Audit', null);
insert into acc_usuarios values('dmejias', 'Dario Mejias', 'Audit', null);
insert into acc_usuarios values('cmestre', 'Carolina Mestre', 'Audit', null);
insert into acc_usuarios values('jcristob', 'Julia Cristobal', 'Audit', null);

insert into acc_usuarios values('kzuska', 'Katya Zuska', 'Bienest', null);
insert into acc_usuarios values('lfierro', 'Lucila Fierro', 'Bienest', null);

insert into acc_usuarios values('achianal', 'Alberto Chianalino', 'Dip-Rect', null);
insert into acc_usuarios values('mgonzale', 'Mariana Gonzales', 'Dip-Rect', null);
insert into acc_usuarios values('cfrilloc', 'Cesar Frillocci', 'Dip-Rect', null);

commit;

}
