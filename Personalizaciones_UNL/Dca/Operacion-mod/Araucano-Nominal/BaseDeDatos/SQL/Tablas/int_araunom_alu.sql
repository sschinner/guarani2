-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SIU-GUARANI 2 - Sistema de Gestión Académica
-- Versión 2.9.3
-- Araucano Nominal - Archivo 0 - Alumnos a informar
-- Tabla: int_araunom_alu
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- DROP TABLE int_araunom_alu;
CREATE TABLE int_araunom_alu
(
	id_alumno SERIAL NOT NULL,
	anio_academico integer NOT NULL,
	tipo_documento smallint NOT NULL,
	nro_documento varchar(15) NOT NULL,
	cuil_cuit varchar(15),
	genero smallint NOT NULL,
	fecha_nacimiento varchar(8),
	horas_trabajo varchar(4),
	nivel_inst_padre integer,
	nivel_inst_madre integer,
	nacimiento_pais integer,
	nacimiento_loc integer
);

-- ALTER TABLE int_araunom_alu DROP CONSTRAINT pk_int_araunom_alu;
ALTER TABLE int_araunom_alu ADD CONSTRAINT PRIMARY KEY (id_alumno) CONSTRAINT pk_int_araunom_alu;

-- ++++++++++++++++++++++++++ Fin tabla int_araunom_alu +++++++++++++++++++++++++++++