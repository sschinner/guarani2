CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF NOT EXISTS (SELECT tabname
			FROM systables
			WHERE tabname = 'u820_ped_bol_est') THEN

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 1.1.0
-- Tabla u820_ped_bol_est
-- *******************************************************************************

CREATE TABLE "dba".u820_ped_bol_est (
	ID_LOG SERIAL,
	APELLIDO_PARAM     varchar(30),
	NOMBRES_PARAM varchar(30),
	TIPO_DOCUMENTO_PARAM INTEGER,
	NRO_DOCUMENTO_PARAM DECIMAL(15,0),
	SEXO_PARAM CHAR(1),
	FECHA_PARAM VARCHAR(10),
	RETORNO_BD INTEGER,
	APELLIDO_BD varchar(30),
	NOMBRES_BD varchar(30),
	OBSERVACION_BD CHAR(400),
	FECHA_RELEVAMIENTO   datetime year to second NOT NULL

);


END IF;
END
END PROCEDURE;


EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();
-- *********** Fin del script de la tabla u820_ped_bol_est **********

revoke all on "dba".u820_ped_bol_est from public;
grant select, update, insert, delete on "dba".u820_ped_bol_est to internet; 
grant select, update, insert, delete on "dba".u820_ped_bol_est to guarani;
