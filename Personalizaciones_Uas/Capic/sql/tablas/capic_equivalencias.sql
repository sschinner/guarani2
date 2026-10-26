-- ***************************************************************************
-- Tabla u820_equi_capic_co 
-- Tabla personalizada para matener la comisión CAPIC a la que se inscribió el alumno, y que dio origen a la equivalencia
-- ***************************************************************************
-- DROP TABLE u820_equi_capic_co;
CREATE TABLE u820_equi_capic_co (
		EQUIVALENCIA         integer NOT NULL,
		CAPIC_COMISION             integer NOT NULL
);

ALTER TABLE u820_equi_capic_co
       ADD CONSTRAINT PRIMARY KEY (EQUIVALENCIA)
              CONSTRAINT pk_u820_equi_capic_co;

