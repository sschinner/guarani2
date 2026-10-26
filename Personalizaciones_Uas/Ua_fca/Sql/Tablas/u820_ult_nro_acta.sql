CREATE PROCEDURE "dba".sp_crea_tabla_u820_ult_nro_acta();

BEGIN

IF NOT EXISTS (SELECT * FROM systables where tabname = 'u820_ult_nro_acta') THEN


-- drop table u820_ult_nro_acta;
create table u820_ult_nro_acta 

(unidad_academica	varchar(5),
proximo_nro	integer,
proximo_nro_tec	integer,
prox_nro_rec	integer);

alter table u820_ult_nro_acta
add constraint foreign key (unidad_academica)
references sga_unidades_acad
constraint fk_unidad_acad;

alter table u820_ult_nro_acta
add constraint primary key (unidad_academica)
constraint pk_ult_nro_acta;


END IF;
END;
END PROCEDURE;

EXECUTE PROCEDURE "dba".sp_crea_tabla_u820_ult_nro_acta();
DROP PROCEDURE "dba".sp_crea_tabla_u820_ult_nro_acta();
