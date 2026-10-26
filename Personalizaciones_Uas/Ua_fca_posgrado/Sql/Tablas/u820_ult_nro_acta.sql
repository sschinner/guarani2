CREATE PROCEDURE sp_crea_tabla_u820_ult_nro_acta();

BEGIN

IF NOT EXISTS (SELECT * FROM systables where tabname = 'u820_ult_nro_acta') THEN

CREATE TABLE "dba".u820_ult_nro_acta (
	       	anio_academico		int NOT NULL,
		nro_rec			int,
		nro			int,
		nro_01			int,
		nro_02			int,
		nro_03			int,
		nro_04			int,
		nro_05			int,
		nro_06			int,
		nro_07			int,
		nro_08			int);


ALTER TABLE  "dba".u820_ult_nro_acta 
       ADD CONSTRAINT PRIMARY KEY (anio_academico)
              CONSTRAINT pk_u820_ult_nro_acta ;


END IF;
END;
END PROCEDURE;

EXECUTE PROCEDURE sp_crea_tabla_u820_ult_nro_acta();
DROP PROCEDURE sp_crea_tabla_u820_ult_nro_acta();
