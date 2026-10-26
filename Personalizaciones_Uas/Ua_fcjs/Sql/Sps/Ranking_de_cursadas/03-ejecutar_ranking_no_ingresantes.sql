{
--select * from sga_comisiones where anio_academico = 2022

 

-- 52 ultima version anterior 

--   EXECUTE PROCEDURE "dba".sp820_ranking_cursada	(2022,  "2do. Cuatrimestre", 0)

/*  
-- Chequeo que los numeros coincidan

select version_ranking, count(*) from u820_rank_curs group by version_ranking order by 1

select	count(*)
from sga_insc_cursadas
where comision in (select comision from sga_comisiones where anio_academico = 2022 and periodo_lectivo = "2do. Cuatrimestre")
	and estado = "A"
and	fecha_inscripcion >= '2021-08-08 00:00:00'


/*
begin work;

delete from u820_rank_curs where version_ranking = 136;
rollback

commit;
*/

select * from sga_insc_cursadas
where estado = 'A'
	and '*' || trim(both from legajo) || '*' || comision in (
		select '*' || trim(both from legajo) || '*' || comision
		from u820_rank_curs
		where version_ranking = 81
			and (estado <> 'A'
			or ingreso <> 'S'))
order by 3

select * from sga_insc_cursadas
where estado = 'P'
	and comision not in (select comision 
			from sga_comisiones 
			where materia in ('1', '2', '3', '4','TS005','TS002','TS003','TS004','234') 
				and anio_academico = 2016
				and periodo_lectivo = '1er. Cuatrimestre');





-- Pasar a rechazadas las que quedaron fuera del ranking
begin;

-- paso a rechazados los no rankeados
update sga_insc_cursadas
set estado = 'R'
where estado = 'A'
	and '*' || trim(both from legajo) || '*' || comision in (
		select '*' || trim(both from legajo) || '*' || comision
		from u820_rank_curs
		where version_ranking = 70
			and (estado <> 'A'
			or ingreso <> 'S'));

-- paso a rechazados los pendientes (no fueron aceptados al procesarlos en guarani)
update sga_insc_cursadas
set estado = 'R'
where estado = 'P'
	and comision not in (select comision 
			from sga_comisiones 
			where materia in ('1', '2', '3', '4','TS005','TS002','TS003','TS004','234') 
				and anio_academico = 2015 
				and periodo_lectivo = 'C de Verano');

commit


select count(*)
from u820_rank_curs
where version_ranking = 23
	and estado = 'A'
	and ingreso = 'S'
union all
select count(*)
from sga_insc_cursadas
where estado = 'A'
	--and fecha_inscripcion > '2009-12-01 11:02:51'
	and comision in (select comision 
			from sga_comisiones 
			where materia not in ('1', '2', '3', '4')
				and anio_academico = 2015 
				and periodo_lectivo = 'C de Verano');


commit;

-- EXECUTE PROCEDURE ctr820_superph ("FCJS", "1", "10315793-1", "17");
-- select * from sga_insc_cursadas where estado = 'P'  -- no debería quedar ninguna que no sea de materias 1, 2, 3 o 4



rollback;

select *
from u820_rank_curs
where version_ranking = 131 and comision = 10269 and cant_aprob <= 13
and estado = 'A'
and ingreso = 'S'

begin;
update
u820_rank_curs
set ingreso = 'N'
where version_ranking = 133
and estado = 'A'
and ingreso = 'S'
and carrera = 3
commit;

update	u820_rank_curs
set	estado = 'A', ingreso = 'S'
where version_ranking = 133
and estado = 'C'
and ingreso = 'N'
and carrera = 3


select	*
from	sga_comisiones
where	materia = '21'
and	anio_academico = 2021
and	periodo_lectivo = '2do. Cuatrimestre'


80 1er año idioma ingles - B1 con 11 materias cupo 54
20 Finanzas - A1A2 2018 con 14 materias cupo 85
20 Finanzas - A1A2 con 19 materias cupo 94
21 Derecho Administrativo - B2 2018 con 14 materias cupo 48


select	*
from	log_operacion_mod
where	operacion = 'cur00106'

delete from acc_operacion_mod where modulo = 'Net00010' and operacion = 'cur00106';

insert into acc_operacion_mod values ('Net00010', 'cur00106', 'Internet', '40');

}


--REPORTE DE BAJAS

select	m.nombre, c.comision, c.nombre, count(ic.legajo)
from	log_insc_cursadas ic
join	u820_rank_curs rc on ic.comision = rc.comision and ic.carrera = rc.carrera and ic.legajo = rc.legajo
join	sga_comisiones c on ic.comision = c.comision
join	sga_materias m on c.materia = m.materia
where	rc.version_ranking = 94
and	ic.fecha_act >= '2018-08-06 00:00:00'
and	oper = 'D'
and	rc.ingreso = 'S'
group by 1,2,3
order by 1,3

select	*
from	sga_insc_cursadas
where	comision = 7171
and	estado = 'A';

select	*
from	u820_rank_curs
where	comision = 7171
and	ingreso = 'S';

begin;
update	u820_rank_curs
set	estado = 'A', ingreso = 'S'
where	carrera||legajo||comision in (
select	distinct carrera||legajo||comision
from	u820_rank_curs
where	version_ranking = '131'
and	carrera = '1'
and	estado = 'C'
and	ingreso = 'N')
commit;

begin
update	u820_rank_curs
set	ingreso = 'N'
where	version_ranking = '130'
and	cant_aprob_real = 0
and	carrera = 3
and	estado = 'A'
and	ingreso = 'S'


rollback