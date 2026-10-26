-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SIU-GUARANI 2 - Sistema de Gestión Académica
-- Versión 2.9.3
-- Araucano Nominal - Archivo 1 - Oferta académica
-- Tabla: int_araunom_oferta
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- DROP TABLE int_araunom_oferta;
CREATE TABLE int_araunom_oferta
(
	id_oferta SERIAL NOT NULL,
	anio_academico integer NOT NULL,
	tipo_documento smallint NOT NULL,
	nro_documento varchar(15) NOT NULL,
	cuil_cuit varchar(15),
	instituc_araucano integer NOT NULL,
	titulo_araucano integer NOT NULL,
	anio_ingreso integer NOT NULL,
	forma_ingreso smallint NOT NULL,
	fecha_egreso varchar(8),
	procedencia smallint,
	unidad_academica varchar(5) NOT NULL,
	carrera varchar(5) NOT NULL,
	legajo varchar(15) NOT NULL,
	plan varchar(5) NOT NULL
);

-- ALTER TABLE int_araunom_oferta DROP CONSTRAINT pk_int_araunom_ofe;
ALTER TABLE int_araunom_oferta ADD CONSTRAINT PRIMARY KEY (id_oferta) CONSTRAINT pk_int_araunom_ofe;

-- ++++++++++++++++++++++++++ Fin tabla int_araunom_oferta +++++++++++++++++++++++++++++