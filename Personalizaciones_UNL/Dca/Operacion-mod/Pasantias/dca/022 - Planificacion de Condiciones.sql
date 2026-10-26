-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Versión 1.7.0
-- *******************************************************************************
Execute procedure dba.sui_operaciones( 
	'820pas03',
	'Planificación de Condiciones',
	'Planificación de Condiciones.',
	null );

Execute procedure dba.sui_ventanas('w820_pasantias_condiciones') ;

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
