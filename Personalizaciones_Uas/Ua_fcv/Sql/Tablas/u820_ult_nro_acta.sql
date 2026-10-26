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

		CREATE TABLE u820_ult_nro_acta 

		(unidad_academica	varchar(5),
		proximo_nro			integer,
		prox_nro_rec		integer);

		ALTER TABLE u820_ult_nro_acta
		ADD constraint foreign key (unidad_academica)
		references sga_unidades_acad
		constraint fk_unidad_acad;

		ALTER TABLE u820_ult_nro_acta
		ADD constraint primary key (unidad_academica)
		constraint pk_ult_nro_acta;

	END IF;
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".sp_crea_tabla_u820_ult_nro_acta();

-- ******************** FIN PROCESO sp_crea_tabla_u820_ult_nro_acta ********************

revoke execute on "dba".sp_crea_tabla_u820_ult_nro_acta from public;
grant execute on "dba".sp_crea_tabla_u820_ult_nro_acta to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_crea_tabla_u820_ult_nro_acta to internet; -- Rol de usuario de Internet

EXECUTE PROCEDURE "dba".sp_crea_tabla_u820_ult_nro_acta();
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();