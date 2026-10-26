create table "dba".u820_ult_nro_acta 
  (
    unidad_academica varchar(5),
    carrera varchar(5),
    anio_academico integer,
    proximo_nro integer,
    prox_nro_rec integer,
    primary key (unidad_academica,carrera,anio_academico)  constraint "dba".pk_ult_nro_acta
  );

revoke all on "dba".u820_ult_nro_acta from "public" as "dba";

