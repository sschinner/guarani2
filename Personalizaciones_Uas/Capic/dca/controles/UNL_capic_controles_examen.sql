-- **********************************************************************************************
-- Agregar evento 8204 Rendir Materias de Integración
Insert into par_eventos values (8204, 'Rendir Mat. Integración', 'Rendir Mat. Integración');

-- Configurar los Puntos de Control por Evento:
Insert into par_puntos_x_event values (8204, 2);
Insert into par_puntos_x_event values (8204, 3);
Insert into par_puntos_x_event values (8204, 8);
Insert into par_puntos_x_event values (8204, 24);
Insert into par_puntos_x_event values (8204, 36);

Insert into par_eventos_x_oper values ('netmi04', 8204);
Insert into par_eventos_x_oper values ('netmi05', 8204);
Insert into par_eventos_x_oper values ('netmi06', 8204);

-- Configurar los controles por evento
execute PROCEDURE sp_ConfCont_Eve ( 8204);

-- Configurar el control: esto configura para que la operacion pueda verse y setearsele los controles
execute procedure  sp_ConfPuntoOper ( 'netmi04', 8204, 2);
--execute procedure  sp_ConfPuntoOper ( 'netmi04', 8204, 3);
--execute procedure  sp_ConfPuntoOper ( 'netmi04', 8204, 8);
--execute procedure  sp_ConfPuntoOper ( 'netmi04', 8204, 24);
--execute procedure  sp_ConfPuntoOper ( 'netmi04', 8204, 36);

execute procedure  sp_ConfPuntoOper ( 'netmi05', 8204, 2);
--execute procedure  sp_ConfPuntoOper ( 'netmi05', 8204, 3);
--execute procedure  sp_ConfPuntoOper ( 'netmi05', 8204, 8);
--execute procedure  sp_ConfPuntoOper ( 'netmi05', 8204, 24);
--execute procedure  sp_ConfPuntoOper ( 'netmi05', 8204, 36);

execute procedure  sp_ConfPuntoOper ( 'netmi06', 8204, 2);
execute procedure  sp_ConfPuntoOper ( 'netmi06', 8204, 3);
execute procedure  sp_ConfPuntoOper ( 'netmi06', 8204, 8);
execute procedure  sp_ConfPuntoOper ( 'netmi06', 8204, 24);
execute procedure  sp_ConfPuntoOper ( 'netmi06', 8204, 36);

update par_cont_x_oper set es_valido = 'N' where operacion = 'netmi04' and evento = 8204 and punto_de_control = 36 and control = 71;
update par_cont_x_oper set es_valido = 'N' where operacion = 'netmi05' and evento = 8204 and punto_de_control = 36 and control = 71;
update par_cont_x_oper set es_valido = 'N' where operacion = 'netmi06' and evento = 8204 and punto_de_control = 36 and control = 71;

-- Agrega los Puntos de Control 2 (Persona - Operación), 3 (Alumno - Operación), 8 (Alumno - Materia (Exámenes)), 24 (Requisitos),  36 (Alumno-Materia-Fecha)
-- Agregar los controles a realizar en cada Operacion/Pagina


