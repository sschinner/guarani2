-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SIU-GUARANI 2 - Sistema de Gestión Académica
-- Versión 2.9.3
-- Araucano Nominal - Archivo temporal de alumnos egresados o posibles egresados
-- Tabla: int_araunom_egres
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- DROP TABLE int_araunom_egres;
CREATE TABLE int_araunom_egres
(
	anio_academico integer NOT NULL,
	unidad_academica varchar(5) NOT NULL,
	carrera varchar(5) NOT NULL,
	legajo varchar(15) NOT NULL,
	titulo varchar(5) NOT NULL,
	titulo_araucano integer NOT NULL,
	fecha_egreso date,
	solicito_titulo char(1) DEFAULT 'N' NOT NULL
);

-- ALTER TABLE int_araunom_egres DROP CONSTRAINT pk_int_araunom_egres;
ALTER TABLE int_araunom_egres ADD CONSTRAINT PRIMARY KEY (anio_academico,unidad_academica, carrera, legajo, titulo) CONSTRAINT pk_int_araunom_egres;

-- ++++++++++++++++++++++++++ Fin tabla int_araunom_egres +++++++++++++++++++++++++++++