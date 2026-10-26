-- Configurar la operacion ficticia Electiva
Begin;
set constraints all deferred;
DELETE FROM acc_operacion_mod WHERE operacion in ('netele01', 'netele02', 'netele03') AND modulo = 'u820Ele';
DELETE FROM acc_modulos WHERE modulo = 'u820Ele';


-- Agregar evento 8202 Cursar Electiva
DELETE FROM par_eventos WHERE evento = 8202;

-- Configurar los Puntos de Control por Evento:
DELETE FROM par_puntos_x_event WHERE evento = 8202;

DELETE FROM par_eventos_x_oper WHERE evento = 8202 AND operacion in ('netele01', 'netele02', 'netele03') ;

DELETE FROM par_cont_x_evento WHERE evento = 8202;
DELETE FROM par_puntos_x_oper WHERE operacion in ('netele01', 'netele02', 'netele03');
DELETE FROM par_cont_x_oper WHERE operacion in ('netele01', 'netele02', 'netele03');
DELETE FROM sga_conf_controles WHERE operacion in ('netele01', 'netele02', 'netele03');
Commit;


-- Configurar el control: esto configura para que la operacion pueda verse y setearsele los controles

-- Agrega los Puntos de Control 2 (Persona - Operación), 3 (Alumno - Operación), 24 (Requisitos)
-- Agregar los controles a realizar en cada Operacion/Pagina
begin;
Set constraints all deferred;
DELETE FROM par_puntos_x_pag WHERE operacion in ('netele01', 'netele02', 'netele03');
commit;
