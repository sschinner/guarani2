CREATE PROCEDURE sp_crea_tabla_u820_ult_nro_acta();

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

EXECUTE PROCEDURE sp_crea_tabla_u820_ult_nro_acta();
DROP PROCEDURE sp_crea_tabla_u820_ult_nro_acta();
