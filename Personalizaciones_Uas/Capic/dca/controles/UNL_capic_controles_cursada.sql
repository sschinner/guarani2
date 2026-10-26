-- **********************************************************************************************
-- Agregar evento 8203 Cursar Materias de Integración
Insert into par_eventos values (8203, 'Cursar Mat. Integración', 'Cursar Mat. Integración');

-- Configurar los Puntos de Control por Evento:
Insert into par_puntos_x_event values (8203, 2);
Insert into par_puntos_x_event values (8203, 3);
Insert into par_puntos_x_event values (8203, 4);
Insert into par_puntos_x_event values (8203, 24);
Insert into par_puntos_x_event values (8203, 36);

Insert into par_eventos_x_oper values ('netmi01', 8203);
Insert into par_eventos_x_oper values ('netmi02', 8203);
Insert into par_eventos_x_oper values ('netmi03', 8203);

-- Configurar los controles por evento
execute PROCEDURE sp_ConfCont_Eve ( 8203);

-- Configurar el control: esto configura para que la operacion pueda verse y setearsele los controles
execute procedure  sp_ConfPuntoOper ( 'netmi01', 8203, 2);
--execute procedure  sp_ConfPuntoOper ( 'netmi01', 8203, 3);
--execute procedure  sp_ConfPuntoOper ( 'netmi01', 8203, 4);
--execute procedure  sp_ConfPuntoOper ( 'netmi01', 8203, 24);
--execute procedure  sp_ConfPuntoOper ( 'netmi01', 8203, 36);

execute procedure  sp_ConfPuntoOper ( 'netmi02', 8203, 2);
--execute procedure  sp_ConfPuntoOper ( 'netmi02', 8203, 3);
--execute procedure  sp_ConfPuntoOper ( 'netmi02', 8203, 4);
--execute procedure  sp_ConfPuntoOper ( 'netmi02', 8203, 24);
--execute procedure  sp_ConfPuntoOper ( 'netmi02', 8203, 36);

execute procedure  sp_ConfPuntoOper ( 'netmi03', 8203, 2);
execute procedure  sp_ConfPuntoOper ( 'netmi03', 8203, 3);
execute procedure  sp_ConfPuntoOper ( 'netmi03', 8203, 4);
execute procedure  sp_ConfPuntoOper ( 'netmi03', 8203, 24);
execute procedure  sp_ConfPuntoOper ( 'netmi03', 8203, 36);

update par_cont_x_oper set es_valido = 'N' where operacion = 'netmi01' and evento = 8203 and punto_de_control = 36 and control = 70;
update par_cont_x_oper set es_valido = 'N' where operacion = 'netmi02' and evento = 8203 and punto_de_control = 36 and control = 70;
update par_cont_x_oper set es_valido = 'N' where operacion = 'netmi03' and evento = 8203 and punto_de_control = 36 and control = 70;

-- Agrega los Puntos de Control 2 (Persona - Operación), 3 (Alumno - Operación), 4 (Alumno - Materia(Cursadas), 24 (Requisitos), 36 (Alumno-Materia-Fecha)
-- Agregar los controles a realizar en cada Operacion/Pagina

