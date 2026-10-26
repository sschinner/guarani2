-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SIU-GUARANI 2 - Sistema de Gestión Académica
-- Versión 2.9.3
-- Araucano Nominal - Archivo 2 - Rendimiento Académico
-- Tabla: int_araunom_rend
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- DROP TABLE int_araunom_rend;
CREATE TABLE int_araunom_rend
(
	id_rendimiento SERIAL NOT NULL,
	anio_academico integer NOT NULL,
	tipo_documento integer NOT NULL,
	nro_documento varchar(15) NOT NULL,
	cuil_cuit varchar(15),
	instituc_araucano integer,
	titulo_araucano integer NOT NULL,
	fecha varchar(8) NOT NULL,
	resultado smallint NOT NULL,
	materia varchar(5) NOT NULL,
	materia_nombre varchar(255) NOT NULL,
	carga_horaria integer,
	obligatoriedad char(1) NOT NULL,
	forma_aprobacion smallint NOT NULL,
	nro_libro varchar(30),
	nro_acta varchar(30),
	folio_fisico integer,
	expediente varchar(30),
	unidad_academica varchar(5) NOT NULL,
	carrera varchar(5) NOT NULL,
	legajo varchar(15) NOT NULL,
	plan varchar(5) NOT NULL
);

-- ALTER TABLE int_araunom_rend DROP CONSTRAINT pk_int_araunom_ren;
ALTER TABLE int_araunom_rend ADD CONSTRAINT PRIMARY KEY (id_rendimiento) CONSTRAINT  pk_int_araunom_ren;

-- ++++++++++++++++++++++++++ Fin tabla int_araunom_rend +++++++++++++++++++++++++++++

