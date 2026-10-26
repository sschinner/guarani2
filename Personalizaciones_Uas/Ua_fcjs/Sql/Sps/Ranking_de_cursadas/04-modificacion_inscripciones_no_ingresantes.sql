select	*
from	sga_periodos_lect

{
-- Veo cuantas inscripciones a cursadas hay
select *
from sga_insc_cursadas
where comision in (	select comision
		from sga_comisiones
		where anio_academico = 2022
			and periodo_lectivo = '1° cuatrimestre'
			--and materia not in ('1', '2', '3', '4')
)
and fecha_inscripcion >= '2022-03-07 00:00:00'

select * from sga_comisiones where periodo_lectivo = 'C de Verano'

-- Paso las inscripciones a rechazadas 'R'
-- begin;
-- update sga_insc_cursadas
set estado = 'R'
where comision in (	select comision
		from sga_comisiones
		where anio_academico = 2022
			and periodo_lectivo = '1° cuatrimestre'
			--and materia not in ('1', '2', '3', '4')
)
and fecha_inscripcion >= '2022-03-21 00:00:00'
-- commit;






-- Veo las inscripciones rankeadas que entraron
select *
from sga_insc_cursadas
where '*' || trim(both ' ' from legajo) || '*' || comision || '*' in (
		select '*' || trim(both ' ' from legajo) || '*' || comision || '*'
		from u820_rank_curs
		where version_ranking = '136'
			and ingreso = 'S')


-- Paso las inscripciones aceptadas en el ranking a Aceptadas 'A'
-- begin;
-- update sga_insc_cursadas
set estado = 'A'
where '*' || trim(both ' ' from legajo) || '*' || comision || '*' in (
		select '*' || trim(both ' ' from legajo) || '*' || comision || '*'
		from u820_rank_curs
		where version_ranking = '136'
			and ingreso = 'S')
-- commit;


rollback;





-- Veo que los dos números coincidan
select count(*) as cantidades
from u820_rank_curs 
where version_ranking = '136'
	and ingreso = 'S'
union all
select count(*)
from sga_insc_cursadas
where comision in (	select comision
		from sga_comisiones
		where anio_academico = 2022
			and periodo_lectivo = '1° cuatrimestre'
			--and materia not in ('1', '2', '3', '4')
)
and fecha_inscripcion >= '2022-03-21 00:00:00'
	and estado = 'A';


commit;

rollback;

}

-- COMMIT;
-- ROLLBACK;