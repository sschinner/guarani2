-- ***********
-- ATENCIÓN:
-- ***********
-- No realizar el insert de datos correspondiente a la UA en donde se esta haciendo el insert.
-- Inserts de datos en sga_unidades_acad
insert into sga_unidades_acad (unidad_academica, nombre, calle, numero, localidad, codigo_postal, te, universidad, nombre_universidad) values ('FADU', 'Facultad de Arquitectura, Diseño y Urbanismo', 'Ciudad Universitaria - Paraje el Pozo', null, null, '3000', null, 'UNL', 'Universidad Nacional del Litoral');
insert into sga_unidades_acad (unidad_academica, nombre, calle, numero, localidad, codigo_postal, te, universidad, nombre_universidad) values ('FCA', 'Facultad de Ciencias Agrarias', 'Kreder', '2805', 2839, '3080', '420639', 'UNL', 'Universidad Nacional del Litoral');
insert into sga_unidades_acad (unidad_academica, nombre, calle, numero, localidad, codigo_postal, te, universidad, nombre_universidad) values ('FCV', 'Facultad de Ciencias Veterinarias', 'Kreder', '2805', 2839, '3080', '420639', 'UNL', 'Universidad Nacional del Litoral');
insert into sga_unidades_acad (unidad_academica, nombre, calle, numero, localidad, codigo_postal, te, universidad, nombre_universidad) values ('ESS', 'Escuela Superior de Sanidad', 'Ciudad Universitaria  C.C. 217', null, 2518, '3000', '0342-4575206', 'UNL', 'Universidad Nacional del Litoral');
--insert into sga_unidades_acad (unidad_academica, nombre, calle, numero, localidad, codigo_postal, te, universidad, nombre_universidad) values ('FBCB', 'Facultad de Bioquímica y Ciencias Biológicas', 'Paraje el Pozo', null, 2518, '3000', '0342 - 4575206', 'UNL', 'Universidad Nacional del Litoral');
insert into sga_unidades_acad (unidad_academica, nombre, calle, numero, localidad, codigo_postal, te, universidad, nombre_universidad) values ('FCE', 'Facultad de Ciencias Económicas', 'Moreno', '2557', 2518, '3000', '0342-4571180/81', 'UNL', 'Universidad Nacional del Litoral');
insert into sga_unidades_acad (unidad_academica, nombre, calle, numero, localidad, codigo_postal, te, universidad, nombre_universidad) values ('EUAA', 'Escuela Universitaria de Análisis de Alimentos', 'AMEGHINO', '50 ', 1485, '2252', '03404-481203', 'UNL', 'Universidad Nacional del Litoral');
insert into sga_unidades_acad (unidad_academica, nombre, calle, numero, localidad, codigo_postal, te, universidad, nombre_universidad) values ('FCM', 'Escuela de Ciencias Médicas', 'Paraje El Pozo', null, 2518, '3000', '4575117', 'UNL', 'Universidad Nacional del Litoral');
insert into sga_unidades_acad (unidad_academica, nombre, calle, numero, localidad, codigo_postal, te, universidad, nombre_universidad) values ('FCJS', 'Facultad de Ciencias Jurídicas y Sociales', 'Candido Pujato', null, 2518, '3000', null, 'UNL', 'Universidad Nacional del Litoral');
insert into sga_unidades_acad (unidad_academica, nombre, calle, numero, localidad, codigo_postal, te, universidad, nombre_universidad) values ('ISM', 'Instituto Superior de Música', 'Ciudad Universitaria - Paraje el Pozo', null, 2518, '3000', null, 'UNL', 'Universidad Nacional del Litoral');
insert into sga_unidades_acad (unidad_academica, nombre, calle, numero, localidad, codigo_postal, te, universidad, nombre_universidad) values ('FHUC', 'Facultad de Humanidades y Ciencias', 'Ciudad Universitaria - Paraje el Pozo', null, 2518, '3000', null, 'UNL', 'Universidad Nacional del Litoral');
insert into sga_unidades_acad (unidad_academica, nombre, calle, numero, localidad, codigo_postal, te, universidad, nombre_universidad) values ('FICH', 'Facultad de Ingeniería y Ciencias Hídricas', 'Ruta 168', null, 2518, '3000', null, 'UNL', 'Universidad Nacional del Litoral');

-- ***************************************************************************
-- Tabla u820_capic_com - Relación comisiones CAPIC-GUARANI
-- ***************************************************************************
-- DROP TABLE u820_capic_com;
CREATE TABLE u820_capic_com (
       COMISION             integer NOT NULL,
       UNIDAD_ACADEMICA     varchar(5) NOT NULL,
       CAPIC_COMISION             integer NOT NULL
);

ALTER TABLE u820_capic_com
       ADD CONSTRAINT PRIMARY KEY (COMISION)
              CONSTRAINT pk_u820_capic_com;

ALTER TABLE u820_capic_com
       ADD CONSTRAINT FOREIGN KEY (COMISION) REFERENCES sga_comisiones CONSTRAINT fk_u820_capic_com_1;

ALTER TABLE u820_capic_com
       ADD CONSTRAINT FOREIGN KEY (UNIDAD_ACADEMICA) REFERENCES sga_unidades_acad (unidad_academica) CONSTRAINT fk_capic_comisiones_2;

-- *******************************************************************************************
-- Indice unico sobre la tabla de u820_capic_com por CAPIC_COMISION
-- *******************************************************************************************
create unique index in_u820_capic_com  on u820_capic_com (unidad_academica, capic_comision);


