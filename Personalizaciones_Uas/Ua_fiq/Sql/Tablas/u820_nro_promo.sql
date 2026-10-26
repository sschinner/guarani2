-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 1.7.0
-- Tabla sga_nua
-- *******************************************************************************
CREATE PROCEDURE sp_crea_tabla_u820_nro_promo();

BEGIN

IF NOT EXISTS (SELECT * FROM systables where tabname = 'u820_nro_promo') THEN



CREATE TABLE u820_nro_promo (
	       	anio_academico		int NOT NULL,
		nro_rec			int,
		nro			int,
		nro_01			int,
		nro_02			int,
		nro_03			int,
		nro_04			int,
		nro_05			int,
		nro_06			int,
		nro_07			int);


ALTER TABLE u820_nro_promo
       ADD CONSTRAINT PRIMARY KEY (anio_academico)
              CONSTRAINT pk_u820_nro_promo;
END IF;
END;
END PROCEDURE;

EXECUTE PROCEDURE sp_crea_tabla_u820_nro_promo();
DROP PROCEDURE sp_crea_tabla_u820_nro_promo();
-- *********** Fin del script de la tabla sga_nua **********
