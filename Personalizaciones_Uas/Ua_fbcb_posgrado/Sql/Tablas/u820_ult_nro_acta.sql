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

CREATE PROCEDURE "dba".sp_crea_tabla_u820_ult_nro_acta();

BEGIN

IF NOT EXISTS (SELECT * FROM systables where tabname = 'u820_ult_nro_acta') THEN


-- DROP TABLE u820_ult_nro_acta;
CREATE TABLE u820_ult_nro_acta (
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


ALTER TABLE  u820_ult_nro_acta 
       ADD CONSTRAINT PRIMARY KEY (anio_academico)
              CONSTRAINT pk_u820_ult_nro_acta ;

ALTER TABLE u820_ult_nro_acta ADD (nro_09 int);
ALTER TABLE u820_ult_nro_acta ADD (nro_10 int);

END IF;
END;
END PROCEDURE;
-- *************** Fin del procedimiento "dba".sp_crea_tabla_u820_ult_nro_acta *******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_crea_tabla_u820_ult_nro_acta 
-- *****************************************************************************
revoke execute on "dba".sp_crea_tabla_u820_ult_nro_acta from public;
grant execute on "dba".sp_crea_tabla_u820_ult_nro_acta to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_crea_tabla_u820_ult_nro_acta to internet; -- Rol de usuario de Internet

-- Se ejecuta y eliminar procedimiento
EXECUTE PROCEDURE "dba".sp_crea_tabla_u820_ult_nro_acta ();
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();