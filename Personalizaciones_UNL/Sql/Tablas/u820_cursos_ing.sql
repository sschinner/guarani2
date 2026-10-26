CREATE PROCEDURE "dba".verifica_objeto();
BEGIN

	IF NOT EXISTS (SELECT * 
			FROM systables 
			where tabname = 'u820_cursos_ing') THEN

-- drop table u820_cursos_ing;
create table "dba".u820_cursos_ing
(	unidad_academica		varchar(5) not null,
	carrera			varchar(5) not null,
	materia			varchar(5) not null,
	obligatoria		varchar(1));

alter table "dba".u820_cursos_ing
	add constraint primary key (unidad_academica, carrera, materia) 
		constraint pk_u820_cursos_ing;

alter table "dba".u820_cursos_ing
	 ADD CONSTRAINT FOREIGN KEY (UNIDAD_ACADEMICA)
                             REFERENCES sga_unidades_acad
              CONSTRAINT fk_u820_cursos_ing_unidades_acad;

alter table "dba".u820_cursos_ing
	 ADD CONSTRAINT FOREIGN KEY (UNIDAD_ACADEMICA, CARRERA)
                             REFERENCES sga_carreras
              CONSTRAINT fk_u820_cursos_ing_carrera;

alter table "dba".u820_cursos_ing
	 ADD plan varchar(5) before materia;

alter table "dba".u820_cursos_ing drop constraint pk_u820_cursos_ing;

alter table "dba".u820_cursos_ing
	add constraint primary key (unidad_academica, carrera, plan, materia) 
		constraint pk_u820_cursos_ing;



-- *********** Fin del script de la tabla u820_cursos_ing **********
END IF;
END;
END PROCEDURE;

EXECUTE PROCEDURE verifica_objeto();
DROP PROCEDURE verifica_objeto();

revoke all on "dba".u820_cursos_ing from public;
grant select, update, insert, delete on "dba".u820_cursos_ing to guarani;
grant select, update, insert, delete on "dba".u820_cursos_ing to internet;

-- *****************************************************************************************
-- La siguiente sección de script esta comentado en bloque, para que no sea contemplado en la migración
-- *****************************************************************************************
{
-- ESTA PARTE DEL SCRIPT NO CORRER: VERIFICAR LUEGO SI ES NECESARIO ARREGLAR/INSERTAR DATOS
-- DETERMINAR EN EL WHERE QUE MATERIAS INCORPORAR
-- select * from u820_cursos_ing;

-- rollback;
begin;

insert into u820_cursos_ing 
select distinct atm.unidad_academica, atm.carrera, atm.plan, atm.materia, atm.obligatoria --, atm.nombre_materia 
from sga_atrib_mat_plan atm
	join sga_planes pl
	on atm.carrera = pl.carrera and atm.plan = pl.plan and atm.version = pl.version_actual
where materia like 'CCP%'; -- in ('00439', '00440', '00425', '00426', '00418'); --like 'I%'; -- or 

update u820_cursos_ing set obligatoria = 'S' where materia in ('CCP-M');

Commit;
}
