-- ***************************************************************
-- SUBMODULO DE PASANTIAS
-- ***************************************************************
INSERT INTO acc_submodulos (
	submodulo,
	nombre,
	bitmap)
	VALUES (
	'u820pas',
	'Pasantías',
	null);

-- ***************************************************************
-- MODULOS DE PASANTIAS
-- ***************************************************************
-- GESTION
INSERT INTO acc_modulos (
	modulo,
	nombre,
	bitmap)
	VALUES (
	'u820pas',
	'Pasantías',
	null);

-- INTERNET
INSERT INTO acc_modulos (
	modulo,
	nombre,
	bitmap)
VALUES ('Net00200',
	'Pasantías',
	null);


-- ***************************************************************
-- OPERACIONES
-- ***************************************************************
-- ABM DE PASANTIAS
Execute procedure dba.sui_operaciones( 
	'820pas01',
	'ABM de Pasantías',
	'Alta, Baja y Modificacion de Pasantías.',
	null );

Execute procedure dba.sui_ventanas('w820_pasantias_planes') ;

INSERT INTO acc_operacion_mod VALUES (
	'u820pas',
	'820pas01',
	'u820pas',
	10);

INSERT INTO dba.acc_parametros ( 
	operacion, 
	orden, 
	ventana, 
	parametros, 
	cierra_anterior ) 
	VALUES ( 
	'820pas01',
	1, 
	'w_abm_lista_seleccion', 
	'uo_dw, dk820_pasantias, 12', 
	'N' );

INSERT INTO dba.acc_parametros ( 
	operacion, 
	orden, 
	ventana, 
	parametros, 
	cierra_anterior )
	VALUES ( 
	'820pas01',
	2, 
	'w820_pasantias_planes', 
	'uo_dw, d820_pasantias, uo_selec_busq, uo_dw, dks820_planes_no_estan_pasantia, uo_dw, d820_planes_de_una_pasantia, 10', 'N' );

INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( '820pas01', 'A' );
INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( '820pas01', 'B' );
INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( '820pas01', 'C' );
INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( '820pas01', 'M' );


-- SOLICITANTES
Execute procedure dba.sui_operaciones( '820pas02', 'ABM Solicitantes de Pasantias', null, null );

INSERT INTO acc_operacion_mod VALUES (
	'u820pas',
	'820pas02',
	'u820pas',
	20);

INSERT INTO dba.acc_parametros ( operacion, orden, ventana, parametros, cierra_anterior )
	VALUES ( '820pas02', 1, 'w_abm_lista_seleccion', 'uo_dw, dk820_solicitantes_pasantias, 10', 'N' );

INSERT INTO dba.acc_parametros ( operacion, orden, ventana, parametros, cierra_anterior )
	VALUES ( '820pas02', 2, 'w_abm_detalle', 'uo_dw, d820_solicitantes_pasantias ,1', 'N' );

INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( '820pas02', 'A' );
INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( '820pas02', 'B' );
INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( '820pas02', 'C' );
INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( '820pas02', 'M' );


-- PLANIFICACION DE CONDICIONES
Execute procedure dba.sui_operaciones( 
	'820pas03',
	'Planificación de Condiciones',
	'Planificación de Condiciones.',
	null );

Execute procedure dba.sui_ventanas('w820_pasantias_condiciones') ;

INSERT INTO acc_operacion_mod VALUES (
	'u820pas',
	'820pas03',
	'u820pas',
	30);

INSERT INTO dba.acc_parametros ( 
	operacion, 
	orden, 
	ventana, 
	parametros, 
	cierra_anterior ) 
	VALUES ( 
	'820pas03',
	1, 
	'w_abm_lista_seleccion', 
	'uo_dw, dk820_pasantias, 12', 
	'N' );

INSERT INTO dba.acc_parametros ( 
	operacion, 
	orden, 
	ventana, 
	parametros, 
	cierra_anterior ) 
	VALUES ( 
	'820pas03',
	2, 
	'w_abm_lista_seleccion', 
	'uo_dw, dk820_pasantias_planes, 12', 
	'N' );

INSERT INTO dba.acc_parametros ( 
	operacion, 
	orden, 
	ventana, 
	parametros, 
	cierra_anterior )
	VALUES ( 
	'820pas03',
	3, 
	'w820_pasantias_condiciones', 
	'uo_dw, d820_pasantias_planes, uo_selec_busq, uo_dw, dks820_materias_no_estan_pasantia_plan, uo_dw, d820_materias_de_una_pasantia_plan, 10', 'N' );

INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( '820pas03', 'A' );
INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( '820pas03', 'B' );
INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( '820pas03', 'C' );
INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( '820pas03', 'M' );



-- RANKING DE INSCRIPTOS
Execute procedure dba.sui_operaciones('820pas15',
	'U.N.L. (Inscriptos a Pasantías)',
	'U.N.L. (Inscriptos a Pasantías)',
	NULL);

INSERT INTO acc_operacion_mod VALUES (
	'u820pas',
	'820pas15',
	'Reportes',
	515);

INSERT INTO acc_parametros VALUES (
	'820pas15',
	1,
	'w_reporte',
    'uo_dw_filtros,dp820_inscriptos_a_pasantia,uo_dw,dr820_inscriptos_a_pasantia,dl820_inscriptos_a_pasantia',
	NULL,
	NULL,
	'N');

INSERT INTO acc_acciones_oper VALUES (
	'820pas15',
	'C');





-- RANKING PARA PUBLICACION (REDUCIDO)
Execute procedure dba.sui_operaciones('820pas25',
	'U.N.L. (Publicación de Inscriptos a Pasantías)',
	'U.N.L. (Publicación de Inscriptos a Pasantías)',
	NULL);

INSERT INTO acc_operacion_mod VALUES (
	'u820pas',
	'820pas25',
	'Reportes',
	525);

INSERT INTO acc_parametros VALUES (
	'820pas25',
	1,
	'w_reporte',
    'uo_dw_filtros,dp820_inscriptos_a_pasantia,uo_dw,dr820_publicar_insc_pasantia,dl820_publicar_insc_pasantia',
	NULL,
	NULL,
	'N');

INSERT INTO acc_acciones_oper VALUES (
	'820pas25',
	'C');













-- ***************************************************************
-- OPERACIONES
-- ***************************************************************
-- BAJA DE INSCRIPCION POR INTERNET
Execute procedure dba.sui_operaciones('netpas01',
	'Anulación',
	'Anular Inscripción a Pasantía',
	NULL);

INSERT INTO acc_operacion_mod VALUES (
	'Net00200',
	'netpas01',
	'Internet',
	1);

INSERT INTO acc_acciones_oper VALUES (
	'netpas01',
	'C');

INSERT INTO dba.acc_oper_nom_x_int ( operacion, interfaz, nombre )  VALUES ( 'netpas01', 3, 'Eliminar Insc. a Pasantías' );
Insert into acc_parametros_net values ('netpas01', 1, 'a_alumnos/u820_eliminarInscPasantia.php', null, 'Eliminar Insc. a Pasantías');
Insert into acc_parametros_net values ('netpas01', 2, 'a_alumnos/u820_desinscribirsePasantia.php', null, 'Resultado Anular Pasantías');






-- CONSULTA DE INSCRIPCION POR INTERNET
Execute procedure dba.sui_operaciones('netpas02',
	'Consulta',
	'Consultar Inscripción a Pasantías',
	NULL);

INSERT INTO acc_operacion_mod VALUES (
	'Net00200',
	'netpas02',
	'Internet',
	2);

INSERT INTO acc_acciones_oper VALUES (
	'netpas02',
	'C');

INSERT INTO dba.acc_oper_nom_x_int ( operacion, interfaz, nombre )  VALUES ( 'netpas02', 3, 'Consultar Insc. a Pasantías' );
Insert into acc_parametros_net values ('netpas02', 1, 'a_alumnos/u820_consultarInscPasantias.php', null, 'Consultar Insc. a Pasantías');









-- INSCRIPCION POR INTERNET
Execute procedure dba.sui_operaciones('netpas03',
	'Inscripción',
	'Inscripción a Pasantía',
	NULL);

INSERT INTO acc_operacion_mod VALUES (
	'Net00200',
	'netpas03',
	'Internet',
	3);

INSERT INTO acc_acciones_oper VALUES (
	'netpas03',
	'C');


INSERT INTO dba.acc_oper_nom_x_int ( operacion, interfaz, nombre )  VALUES ( 'netpas03', 3, 'Inscripciones a Pasantías' );


Insert into acc_parametros_net values ('netpas03', 1, 'a_alumnos/elegirCarrera.php', null, 'Elegir Carrera');
Insert into acc_parametros_net values ('netpas03', 2, 'a_alumnos/u820_elegirInscPasantia.php', null, 'Inscripciones a Pasantías');
Insert into acc_parametros_net values ('netpas03', 3, 'a_alumnos/u820_inscribirsePasantia.php', null, 'Resultado Insc. a Pasantías');












-- *********************************************************************************************************
-- CONTROLES
-- *********************************************************************************************************
-- Agregar un nuevo Punto de Control: Alumno- Pasantía

Insert Into par_puntos_control values (8201, 'Alumno - Pasantía', 'Un Alumno selecciona una Pasantía', 's,s,s,s,s,n'  );

Insert into par_punto_desc_par values (8201, 1, 's', 'varchar(5)', 'unidad_academica', 'Q');
Insert into par_punto_desc_par values (8201, 2, 's', 'varchar(10)', 'nro_inscripcion', 'Q');
Insert into par_punto_desc_par values (8201, 3, 's', 'varchar(15)', 'legajo', 'Q');
Insert into par_punto_desc_par values (8201, 4, 's', 'varchar(5)', 'carrera', 'Q');
Insert into par_punto_desc_par values (8201, 5, 's', 'varchar(5)', 'plan', 'Q');
Insert into par_punto_desc_par values (8201, 6, 'n', 'integer', 'id_pasantia', 'Q');


-- Agregar evento 8201 Cursar Pasantia 
Insert into par_eventos values (8201, 'Cursar Pasantia', 'Cursar Pasantia');

-- Agrega los Puntos de Control 2 (Persona - Operación), 3 (Alumno - Operación), 24 (Requisitos), 8201 (Alumno - Pasantia) a la Operacion netpas03 ('Inscripción a Pasantías')

begin;

-- Configurar los Puntos de Control por Evento:
Insert into par_puntos_x_event values (8201, 2);
Insert into par_puntos_x_event values (8201, 3);
Insert into par_puntos_x_event values (8201, 24);
Insert into par_puntos_x_event values (8201, 8201);

Insert into par_eventos_x_oper values ('netpas03', 8201);

commit;

-- Configurar los controles por evento
execute PROCEDURE sp_ConfCont_Eve ( 8201 );

-- Configurar el control:
execute procedure  sp_ConfPuntoOper ( 'netpas03', 8201, 2);
execute procedure  sp_ConfPuntoOper ( 'netpas03', 8201, 3);
execute procedure  sp_ConfPuntoOper ( 'netpas03', 8201, 24);
execute procedure  sp_ConfPuntoOper ( 'netpas03', 8201, 8201);

insert into par_puntos_x_pag (operacion, pagina, punto_de_control, orden, interfaz) values ("netpas03", "a_alumnos/u820_inscribirsePasantia.php", "2", "1","3");
insert into par_puntos_x_pag (operacion, pagina, punto_de_control, orden, interfaz) values ("netpas03", "a_alumnos/u820_inscribirsePasantia.php", "3", "2","3");
insert into par_puntos_x_pag (operacion, pagina, punto_de_control, orden, interfaz) values ("netpas03", "a_alumnos/u820_inscribirsePasantia.php", "24", "3","3");
insert into par_puntos_x_pag (operacion, pagina, punto_de_control, orden, interfaz) values ("netpas03", "a_alumnos/u820_inscribirsePasantia.php", "8201", "4","3");

-- Control de condiciones de Pasantía

begin;

-- El control es sobre el Alumno que selecciona una Pasantía.

insert into par_implem_control (stored_procedure, parametros) values ("ctr_cond_pas", "s,s,s,s,s,n");

insert into par_controles (control, stored_procedure, desc_abreviada, descripcion, param_adicionales) values (82030, "ctr_cond_pas", "Controla Condiciones Alumno - Pasantia.", "Controla Condiciones Alumno - Pasantia.", null);

insert into par_cont_x_punto (punto_de_control, control) values (8201, 82030);


-- mensajes que devuelve
insert into mme_mensajes values (3, 820030, 'No cumplís con las materias pedidas en la Pasantía.', 'No cumplís con las materias pedidas en la Pasantía.', 2, 1);
insert into mme_mensajes values (3, 820031, 'No cumplís con la cantidad de materias pedida en la Pasantía.', 'No cumplís con la cantidad de materias pedida en la Pasantía.', 2, 1);
insert into mme_mensajes values (3, 820032, 'No cumplís con el porcentaje de materias aprobadas pedida en la Pasantía.', 'No cumplís con el porcentaje de materias aprobadas pedida en la Pasantía.', 2, 1);
insert into mme_mensajes values (3, 820033, 'Superaste la cantidad máxima de materias pedida en la Pasantía.', 'Superaste la cantidad máxima de materias pedida en la Pasantía.', 2, 1);
insert into mme_mensajes values (3, 820034, 'Superaste el porcentaje máximo de materias aprobadas pedido en la Pasantía.', 'Superaste el porcentaje máximo de materias aprobadas pedido en la Pasantía.', 2, 1);


commit;

execute procedure sp_confcont_cont (8201, 82030);
