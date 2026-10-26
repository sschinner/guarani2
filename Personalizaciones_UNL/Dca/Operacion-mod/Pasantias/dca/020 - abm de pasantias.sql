-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Versión 1.7.0
-- *******************************************************************************
Execute procedure dba.sui_operaciones( 
	'820pas01',
	'ABM de Pasantías',
	'Alta, Baja y Modificacion de Pasantías.',
	null );

Execute procedure dba.sui_ventanas('w820_pasantias_planes') ;

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
