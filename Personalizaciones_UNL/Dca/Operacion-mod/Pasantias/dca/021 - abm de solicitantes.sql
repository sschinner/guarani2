-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Versión 2.0
-- *******************************************************************************
Execute procedure dba.sui_operaciones( '820pas02', 'ABM Solicitantes de Pasantias', null, null );

INSERT INTO dba.acc_parametros ( operacion, orden, ventana, parametros, cierra_anterior )
	VALUES ( '820pas02', 1, 'w_abm_lista_seleccion', 'uo_dw, dk820_solicitantes_pasantias, 10', 'N' );

INSERT INTO dba.acc_parametros ( operacion, orden, ventana, parametros, cierra_anterior )
	VALUES ( '820pas02', 2, 'w_abm_detalle', 'uo_dw, d820_solicitantes_pasantias ,1', 'N' );

INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( '820pas02', 'A' );
INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( '820pas02', 'B' );
INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( '820pas02', 'C' );
INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( '820pas02', 'M' );
