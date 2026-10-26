
-- Agregar un nuevo Punto de Control: Alumno- Pasantía

Insert Into par_puntos_control values (8201, 'Alumno - Pasantía', 'Un Alumno selecciona una Pasantía', 's,s,s,s,s,n'  );

Insert into par_punto_desc_par values (8201, 1, 's', 'varchar(5)', 'unidad_academica','Q');
Insert into par_punto_desc_par values (8201, 2, 's', 'varchar(10)', 'nro_inscripcion','Q');
Insert into par_punto_desc_par values (8201, 3, 's', 'varchar(15)', 'legajo','Q');
Insert into par_punto_desc_par values (8201, 4, 's', 'varchar(5)', 'carrera','Q');
Insert into par_punto_desc_par values (8201, 5, 's', 'varchar(5)', 'plan','Q');
Insert into par_punto_desc_par values (8201, 6, 'n', 'integer', 'id_pasantia','Q');


-- Agregar evento 8201 Cursar Pasantia 
Insert into par_eventos values (8201, 'Cursar Pasantia', 'Cursar Pasantia');

-- Agrega los Puntos de Control 2 (Persona - Operación), 3 (Alumno - Operación), 24 (Requisitos), 8201 (Alumno - Pasantia) a la Operacion 820pas04 ('Inscripción a Pasantías') y a la Operacion 820rep01 ('Listado de Pasantías')

begin;

-- Configurar los Puntos de Control por Evento:
Insert into par_puntos_x_event values (8201, 2);
Insert into par_puntos_x_event values (8201, 3);
Insert into par_puntos_x_event values (8201, 24);
Insert into par_puntos_x_event values (8201, 8201);

Insert into par_eventos_x_oper values ('820pas04', 8201);
Insert into par_eventos_x_oper values ('820rep01', 8201);


commit;
rollback

-- Configurar los controles por evento
execute PROCEDURE sp_ConfCont_Eve ( 8201 );

-- Configurar el control:
execute procedure  sp_ConfPuntoOper ( '820pas04', 8201, 2);
execute procedure  sp_ConfPuntoOper ( '820pas04', 8201, 3);
execute procedure  sp_ConfPuntoOper ( '820pas04', 8201, 24);
execute procedure  sp_ConfPuntoOper ( '820pas04', 8201, 8201);

execute procedure  sp_ConfPuntoOper ( '820rep01', 8201, 2);
execute procedure  sp_ConfPuntoOper ( '820rep01', 8201, 3);
execute procedure  sp_ConfPuntoOper ( '820rep01', 8201, 24);
execute procedure  sp_ConfPuntoOper ( '820rep01', 8201, 8201);


-- Agrega los Puntos de Control 2 (Persona - Operación), 3 (Alumno - Operación), 24 (Requisitos)
-- Agregar los controles a realizar en cada Operacion/Pagina
begin;

Insert into par_puntos_x_pag values ('820pas04', 'a_alumnos/u820_elegirInscPasantia.php', 2, 1,3);
Insert into par_puntos_x_pag values ('820pas04', 'a_alumnos/u820_elegirInscPasantia.php', 3, 2,3);
Insert into par_puntos_x_pag values ('820pas04', 'a_alumnos/u820_elegirInscPasantia.php', 24, 3,3);
Insert into par_puntos_x_pag values ('820pas04', 'a_alumnos/u820_elegirInscPasantia.php', 8201, 4,3);

commit;


