{
select * from sga_periodos_lect

-- Veo cuantas inscripciones a cursadas hay
select *
from sga_insc_cursadas
where comision in (	select comision
		from sga_comisiones
		where anio_academico = 2022
			and periodo_lectivo = '2do Cuat. 1er AÑO'
			and materia in ('1', '2', '3','4','TS001','TS002','TS003','TS004','TS005','TS006','TS007','11','220')) 

select *
from sga_insc_cursadas
where comision in (	select comision
		from sga_comisiones
		where anio_academico = 2022
			and periodo_lectivo = '2do Cuat. 1er AÑO'
			and materia in ('233')) 


-- Paso las inscripciones a rechazadas 'R'
-- begin;
-- update sga_insc_cursadas
set estado = 'R'
where comision in (	select comision
		from sga_comisiones
		where anio_academico = 2022
			and periodo_lectivo = '2do Cuat. 1er AÑO'
			and materia in ('1', '2', '3','4','TS001','TS002','TS003','TS004','TS005','TS006','TS007','11','220')) 


update sga_insc_cursadas
set estado = 'R'
where comision in (	select comision
		from sga_comisiones
		where anio_academico = 2022
			and periodo_lectivo = '2do Cuat. 1er AÑO'
			and materia in ('233')) 
-- commit;





Select version_ranking,count(*) from u820_rank_curs 
		group by version_ranking 
		order by 1



-- Veo las inscripciones rankeadas que entraron
select *
from sga_insc_cursadas
where '*' || trim(both ' ' from legajo) || '*' || comision || '*' in (
		select '*' || trim(both ' ' from legajo) || '*' || comision || '*'
		from u820_rank_curs
		where version_ranking = '138'
			and ingreso = 'S')


-- Paso las inscripciones aceptadas en el ranking a Aceptadas 'A'
-- begin;
-- update sga_insc_cursadas
set estado = 'A'
where '*' || trim(both ' ' from legajo) || '*' || comision || '*' in (
		select '*' || trim(both ' ' from legajo) || '*' || comision || '*'
		from u820_rank_curs
		where version_ranking = '138'
			and ingreso = 'S')
-- commit;


rollback





-- Veo que los dos números coincidan
select count(*) as cantidades
from u820_rank_curs 
where version_ranking = '138'
	and ingreso = 'S'
union all
select count(*)
from sga_insc_cursadas
where comision in (	select comision
		from sga_comisiones
		where anio_academico = 2022
			and periodo_lectivo = '2do Cuat. 1er AÑO'
			and materia in ('1', '2', '3','4','TS001','TS002','TS003','TS004','TS005','TS006','TS007','11','220'))
	and estado = 'A';



select count(*) as cantidades
from u820_rank_curs 
where version_ranking = '96'
	and ingreso = 'S'
union all
select count(*)
from sga_insc_cursadas
where comision in (	select comision
		from sga_comisiones
		where anio_academico = 2018
			and periodo_lectivo = '2do Cuat. 1er AÑO'
			and materia in ('233')) 
	and estado = 'A';

















select	amp.materia, amp.nombre_materia
from	vw_hist_academica ha
join	sga_atrib_mat_plan amp on ha.carrera = amp.carrera and ha.plan = amp.plan and ha.materia = amp.materia
where	ha.legajo = '37446336-8'
and	amp.version = 49
and	promediable = 'N'




select	*
from	vw_hist_academica ha
join	sga_atrib_mat_plan amp on ha.carrera = amp.carrera and ha.plan = amp.plan and ha.materia = amp.materia
where	ha.legajo = '37446336-8'
and	amp.version = 49
and	resultado = 'A'
and	promediable = 'S'
}




select	distinct materia
from	u820_rank_curs r
join	sga_comisiones c on r.comision = c.comision
where	version_ranking = 128


update	sga_req_cumplidos
set	fecha_presentacion = '08/11/2019'
where	nro_inscripcion = 'FCJS-26580'
and	fecha_presentacion is not null


update	sga_titulos_otorg
set	estado = 'A'
where	legajo in ('40047181-3', '41055573-1')
and	titulo = '1'