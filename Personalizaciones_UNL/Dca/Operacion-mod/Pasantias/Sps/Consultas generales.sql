select * from acc_parametros_net
where operacion like '%Pas%'
order by 1, 2;

select * from par_puntos_x_pag
where operacion like '%Pas%'
order by 1, 2;

select * from acc_oper_nom_x_int
where operacion like '%Pas%'
order by 1, 2;

select * from par_implem_control
where stored_procedure = 'ctr_cond_pas';

select * from par_eventos_x_oper
order by 1, 2;

select * from par_puntos_x_oper
where evento = '8201'
order by 1, 3;


select * from  par_puntos_control;

execute procedure ctr_ptos_x_pagina ('netpas03', 'a_alumnos/u820_inscribirsePasantia.php');

SELECT nombre, origen_param_web, orden FROM par_punto_desc_par WHERE punto_de_control = 8201 ORDER BY orden;


-- correcion para eliminar la operacion ficticia
-- rollback;

begin;
set triggers for acc_parametros_net disabled;
set triggers for par_puntos_x_pag disabled;
set triggers for acc_oper_nom_x_int disabled;

update acc_parametros_net
set operacion = '820Pas04'
where operacion like '%820pas04%';

update par_puntos_x_pag
set operacion = '820Pas04'
where operacion like '%820pas04%';

update acc_oper_nom_x_int
set operacion = '820Pas04'
where operacion like '%820pas04%';

set triggers for acc_parametros_net enabled;
set triggers for par_puntos_x_pag enabled;
set triggers for acc_oper_nom_x_int enabled;


commit;

select * from acc_operaciones order by 1;

execute  PROCEDURE sp_operaciones_net ('FICH', '23929955');

-- rollback
begin;
set triggers for par_eventos_x_oper disabled;
set triggers for par_puntos_x_oper disabled;
set triggers for par_cont_x_oper disabled;
set triggers for sga_conf_controles disabled;

set constraints all deferred;

update par_eventos_x_oper
set operacion = '820Pas04'
where operacion like '%820pas04%';

update par_puntos_x_oper
set operacion = '820Pas04'
where operacion like '%820pas04%';

update par_cont_x_oper
set operacion = '820Pas04'
where operacion like '%820pas04%';

update sga_conf_controles
set operacion = '820Pas04'
where operacion like '%820pas04%';

commit;

set triggers for par_eventos_x_oper enabled;
set triggers for par_puntos_x_oper enabled;
set triggers for par_cont_x_oper enabled;
set triggers for sga_conf_controles enabled;
