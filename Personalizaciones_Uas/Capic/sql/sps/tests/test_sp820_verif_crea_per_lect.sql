execute procedure sp820_verif_crea_per_lect ('FBCB','Anual','2008','08/18/2008','11/28/2008','2008-07-24 00:00:00','2008-08-15 00:00:00',3)

select * from sga_fec_insc_cur
select * from sga_periodos_lect


set triggers for sga_periodos_lect disabled;
set triggers for sga_fec_insc_cur disabled;

begin
SET CONSTRAINTS ALL DEFERRED;

delete from sga_periodos_lect
where anio_academico = 2008
and periodo_lectivo = 'Anual'

delete from sga_fec_insc_cur
where anio_academico = 2008
and periodo_lectivo = 'Anual'

commit
rollback

set triggers for sga_periodos_lect enabled;
set triggers for sga_fec_insc_cur enabled;

execute procedure sp820_verif_crea_per_lect ('FBCB','Anual','2008','08/18/2008','11/28/2008','2008-07-19 00:00:00','2008-08-15 00:00:00',4)

select * from sga_fec_insc_cur
select * from sga_periodos_lect


set triggers for sga_periodos_lect disabled;
set triggers for sga_fec_insc_cur disabled;

begin
SET CONSTRAINTS ALL DEFERRED;

delete from sga_periodos_lect
where anio_academico = 2008
and periodo_lectivo = 'Anual'

delete from sga_fec_insc_cur
where anio_academico = 2008
and periodo_lectivo = 'Anual'

commit
rollback

set triggers for sga_periodos_lect enabled;
set triggers for sga_fec_insc_cur enabled;