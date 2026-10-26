CREATE PROCEDURE "dba".verifica_objeto();
BEGIN
    IF NOT EXISTS (SELECT * 
                    FROM systables 
                    WHERE tabname = 'u820_requisitos_diploma') 
    THEN

    -- drop table u820_requisitos_diploma;
    CREATE TABLE "dba".u820_requisitos_diploma
    (   tipo_de_carrera             char(1)         NOT NULL,
        modalidad                   character(1)    NOT NULL,
        requisito                   varchar(5)      NOT NULL,
        metadato_tipo_documento     varchar(100),
        metadato_subtipo_documento  varchar(100),
        metadato_cantidad_maxima    integer
    );

    ALTER TABLE "dba".u820_requisitos_diploma
            ADD CONSTRAINT PRIMARY KEY (tipo_de_carrera, modalidad, requisito) 
                    CONSTRAINT pk_u820_requisitos_diploma;

    ALTER TABLE "dba".u820_requisitos_diploma
             ADD CONSTRAINT FOREIGN KEY (requisito)
                                 REFERENCES sga_requisitos
                  CONSTRAINT fk_u820_requisitos_diploma_sga_requisitos;

    ALTER TABLE "dba".u820_requisitos_diploma
             ADD CONSTRAINT FOREIGN KEY (tipo_de_carrera)
                                 REFERENCES sga_tipos_carrera
                  CONSTRAINT fk_u820_requisitos_diploma_sga_tipos_carrera;

    END IF;
END;
END PROCEDURE;

EXECUTE PROCEDURE verifica_objeto();
DROP PROCEDURE verifica_objeto();

revoke all on "dba".u820_requisitos_diploma from public;
grant select, update, insert, delete on "dba".u820_requisitos_diploma to guarani;
grant select, update, insert, delete on "dba".u820_requisitos_diploma to internet;


INSERT INTO sga_requisitos (requisito, nombre, observaciones) 
	VALUES ('1010', 'Libre deuda biblioteca', 'Libre deuda biblioteca');
INSERT INTO sga_requisitos (requisito, nombre, observaciones) 
	VALUES ('1011', 'Constancia de publicacion de Tesis en Biblioteca Virtual', 'Constancia de publicacion de Tesis en Biblioteca Virtual');
INSERT INTO sga_requisitos (requisito, nombre, observaciones) 
	VALUES ('1012', 'Libre de deuda de pagos', 'Libre de deuda de pagos');
INSERT INTO sga_requisitos (requisito, nombre, observaciones) 
	VALUES ('1013', 'DNI (Frente)', 'Documento Nacional de Identidad (Frente)');
INSERT INTO sga_requisitos (requisito, nombre, observaciones) 
	VALUES ('1014', 'DNI (Reverso)', 'Documento Nacional de Identidad (Reverso)');
INSERT INTO sga_requisitos (requisito, nombre, observaciones) 
	VALUES ('1015', 'Partida de nacimiento legalizada y actualizada (Frente)', 'Partida de nacimiento legalizada y actualizada (Frente)');
INSERT INTO sga_requisitos (requisito, nombre, observaciones) 
	VALUES ('1016', 'Partida de nacimiento legalizada y actualizada (Reverso)', 'Partida de nacimiento legalizada y actualizada (Reverso)');

-- ======================================================================
-- Modalidad presencial
-- ======================================================================
-- ?????????????????????????????????????
-- 'C': Grado
-- ?????????????????????????????????????
-- DNI
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('C', 'P', '1013', 'Documento de identidad', 'Frente', 1);
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('C', 'P', '1014', 'Documento de identidad', 'Reverso', 1);
-- Fotografia
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('C', 'P', 'UNL04', 'Fotografia', 'Tipo carnet (frente)', 1);
-- Fotoc. Partida Nacimiento
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('C', 'P', '1015', 'Partida de nacimiento', 'Frente', 1);
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('C', 'P', '1016', 'Partida de nacimiento', 'Reverso', 1);
-- Libre deuda biblioteca
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('C', 'P', '1010', 'Libre deuda biblioteca', 'Completo', 1);

-- ?????????????????????????????????????
-- 'R': Pregrado
-- ?????????????????????????????????????
-- DNI
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('R', 'P', '1013', 'Documento de identidad', 'Frente', 1);
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('R', 'P', '1014', 'Documento de identidad', 'Reverso', 1);
-- Fotografia
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('R', 'P', 'UNL04', 'Fotografia', 'Tipo carnet (frente)', 1);
-- Fotoc. Partida Nacimiento
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('R', 'P', '1015', 'Partida de nacimiento', 'Frente', 1);
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('R', 'P', '1016', 'Partida de nacimiento', 'Reverso', 1);
-- Libre deuda biblioteca
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('R', 'P', '1010', 'Libre deuda biblioteca', 'Completo', 1);

-- ?????????????????????????????????????
-- 'P': Posgrado
-- ?????????????????????????????????????
-- DNI
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('P', 'P', '1013', 'Documento de identidad', 'Frente', 1);
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('P', 'P', '1014', 'Documento de identidad', 'Reverso', 1);
-- Fotografia
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('P', 'P', 'UNL04', 'Fotografia', 'Tipo carnet (frente)', 1);
-- Fotoc. Partida Nacimiento
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('P', 'P', '1015', 'Partida de nacimiento', 'Frente', 1);
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('P', 'P', '1016', 'Partida de nacimiento', 'Reverso', 1);
-- Libre deuda biblioteca
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('P', 'P', '1010', 'Libre deuda biblioteca', 'Completo', 1);
-- Constancia de publicaci? de Tesis en Biblioteca Virtual
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('P', 'P', '1011', 'Constancia de publicacion de Tesis en Biblioteca Virtual', 'Completo', 1);
-- Libre deuda pagos
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('P', 'P', '1012', 'Libre deuda pagos', 'Completo', 1);

-- ======================================================================
-- Modalidad distancia
-- ======================================================================
-- ?????????????????????????????????????
-- 'C': Grado
-- ?????????????????????????????????????
-- DNI
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('C', 'D', '1013', 'Documento de identidad', 'Frente', 1);
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('C', 'D', '1014', 'Documento de identidad', 'Reverso', 1);
-- Fotografia
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('C', 'D', 'UNL04', 'Fotografia', 'Tipo carnet (frente)', 1);
-- Fotoc. Partida Nacimiento
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('C', 'D', '1015', 'Partida de nacimiento', 'Frente', 1);
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('C', 'D', '1016', 'Partida de nacimiento', 'Reverso', 1);
-- Libre deuda biblioteca
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('C', 'D', '1010', 'Libre deuda biblioteca', 'Completo', 1);
-- Libre deuda pagos
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('C', 'D', '1012', 'Libre deuda pagos', 'Completo', 1);

-- ?????????????????????????????????????
-- 'R': Pregrado
-- ?????????????????????????????????????
-- DNI
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('R', 'D', '1013', 'Documento de identidad', 'Frente', 1);
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('R', 'D', '1014', 'Documento de identidad', 'Reverso', 1);
-- Fotografia
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('R', 'D', 'UNL04', 'Fotografia', 'Tipo carnet (frente)', 1);
-- Fotoc. Partida Nacimiento
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('R', 'D', '1015', 'Partida de nacimiento', 'Frente', 1);
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('R', 'D', '1016', 'Partida de nacimiento', 'Reverso', 1);
-- Libre deuda biblioteca
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('R', 'D', '1010', 'Libre deuda biblioteca', 'Completo', 1);
-- Libre deuda pagos
INSERT INTO u820_requisitos_diploma (tipo_de_carrera, modalidad, requisito, metadato_tipo_documento, metadato_subtipo_documento, metadato_cantidad_maxima) 
	VALUES ('R', 'D', '1012', 'Libre deuda pagos', 'Completo', 1);

