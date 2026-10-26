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

-- drop table u820_ult_nro_acta;
create table u820_ult_nro_acta 

(unidad_academica	varchar(5),
anio_academico	integer,
proximo_nro	integer,
prox_nro_rec	integer);

alter table u820_ult_nro_acta
add constraint foreign key (anio_academico)
references sga_anio_academico
constraint fk_anio_academico;

alter table u820_ult_nro_acta
add constraint primary key (unidad_academica, anio_academico)
constraint pk_ult_nro_acta;

END IF;
END;
END PROCEDURE;
-- *************** Fin del procedimiento "dba".sp_crea_tabla_u820_ult_nro_acta ********************

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

