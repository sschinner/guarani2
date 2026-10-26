{
--	generar orden de recorrido aleatorio para inscripciones
--	priorizar las inscripciones por alumno de acuerdo a fecha-hora de inscripcion
--	obtener la máxima prioridad Xmax
--	para cada prioridad X desde 1 a Xmax
--		recorrer inscripciones disponibles para la prioridad X segun orden generado
--			si la comision de la inscripcion actual tiene cupo y no hay superposicion horaria con alguna inscripcion aceptada
--				marcar como aceptada la inscripcion
--				si la cantidad de inscripciones aceptadas llego al limite para el alumno
--					marcar el resto de las inscripciones como rechazadas
--				sino
--					marcar como rechazadas el resto de las inscripciones a la materia recien aceptada
--				fin
--			sino
--				marcar la inscripcion como reclazada
--			fin
--		fin
--	fin
select * from sga_periodos_lect


select version_ranking, count(*) from u820_rank_curs group by version_ranking order by 1

ultima anterior 51

select version_ranking, count(*) from u820_rank_curs
--where estado =  'A' 
--and ingreso = 'S'
group by version_ranking order by 1


select * from sga_periodos_lect

select count(*) from sga_insc_cursadas where comision in (
	select comision 
	from sga_comisiones 
	where anio_academico = 2018
		and periodo_lectivo = '2do Cuat. 1er AÑO'
		and materia in ('1', '2', '3','4','TS005','TS002','TS003','TS004','TS006','TS007') )
	and estado = 'A';

--

select count(*) from sga_insc_cursadas where comision in (
	select comision 
	from sga_comisiones 
	where anio_academico = 2018
		and periodo_lectivo = '1° cuat. 1ER AÑO'
		and materia in ('233'))
	and estado = 'A';



--   EXECUTE PROCEDURE "dba".sp820_ranking_ing (2022,  "2do Cuat. 1er AÑO")


-- estado:	-- P: pendiente
	-- A: ingreso
	-- H: superposicion horaria
	-- C: cantidad materias
	-- O: ingreso a otra comision
	-- U: cupo de la comision




-- drop table aux_insc_cursadas 
-- select * from aux_insc_cursadas order by legajo, fecha_inscripcion;
-- select * from aux_insc_cursadas where legajo = "7876231-4" order by legajo, fecha_inscripcion;
-- select * from u820_rank_curs where version_ranking = 82;
-- delete from u820_rank_curs where version_ranking = 77;

select * from u820_rank_curs where version_ranking = 78 and cant_aprob < 30 and ingreso = 'N';

select * from u820_rank_curs where version_ranking = 82 and cant_aprob < 30 and ingreso = 'S';

select * from u820_rank_curs where version_ranking = 83 and cant_aprob >= 30 and ingreso = 'N';

select * from u820_rank_curs where version_ranking = 83 and cant_aprob >= 30 and ingreso = 'S';

select * from u820_rank_curs where version_ranking = 86 and cant_aprob <> cant_aprob_real;
}

select * from log_versiones_plan

update u820_rank_curs
set ingreso = 'N'
where version_ranking = 85
and legajo in ('36199272-7', '39632261-2', '40029978-1', '32937690-2', '17517865-8', '37798874-5', '40967899-2', '41412926-7', '40922019-7', '37714340-3', '41603121-7', '38817185-7', '41940622-6', '41256873-6', '40166581-2', '39839155-8', '41342099-4', '39685599-2', '40045026-5', '41119417-7', '40644920-2', '37223300-6', '40646458-3', '41633726-1', '40318042-7', '39717340-8', '41189226-3', '41154473-4', '41490762-9', '37475246-2', '37829469-7', '37570314-1', '41492597-4')
and comision = '6572'

select	*
from sga_comisiones
where materia = '5'
and anio_academico = 2017
and periodo_lectivo = '2do. Cuatrimestre'





