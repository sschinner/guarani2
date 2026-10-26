CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_crea_tabla_u820_ult_nro_acta') THEN
		DROP PROCEDURE sp_crea_tabla_u820_ult_nro_acta;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

CREATE PROCEDURE sp_crea_tabla_u820_ult_nro_acta();

BEGIN

IF NOT EXISTS (SELECT * FROM systables where tabname = 'u820_ult_nro_acta') THEN

-- Creating table
CREATE TABLE "dba".u820_ult_nro_acta
	(
	unidad_academica varchar(5,0),
	anio_academico integer,
	proximo_nro_cle integer,
	proximo_nro_001 integer,
	proximo_nro_0391 integer,
	proximo_nro_rec integer,
	proximo_nro_05 integer
	)
	EXTENT SIZE 32 NEXT SIZE 32
	LOCK MODE PAGE;

-- Creating primary key constraint
ALTER TABLE "dba".u820_ult_nro_acta
	ADD CONSTRAINT PRIMARY KEY
		(
		unidad_academica,
		anio_academico
		)
		CONSTRAINT "dba".pk_ult_nro_acta;

-- Creating foreign key constraint
ALTER TABLE "dba".u820_ult_nro_acta
	ADD CONSTRAINT FOREIGN KEY
		(
		anio_academico
		)
		REFERENCES "dba".sga_anio_academico
		(
		anio_academico
		)
		CONSTRAINT "dba".fk_anio_academico;

END IF;
END;
END PROCEDURE;
-- *************** Fin del procedimiento "dba".sp_crea_tabla_u820_ult_nro_acta *******************

-- Se ejecuta y eliminar procedimiento
EXECUTE PROCEDURE "dba".sp_crea_tabla_u820_ult_nro_acta ();
DROP PROCEDURE "dba".sp_crea_tabla_u820_ult_nro_acta ();

