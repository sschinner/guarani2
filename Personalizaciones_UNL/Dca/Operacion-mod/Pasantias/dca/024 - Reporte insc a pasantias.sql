-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Versión 1.5.0
-- *******************************************************************************

Execute procedure dba.sui_operaciones( '820rep01', 'Listado de Inscripción a Pasantías', 'Listado de Inscripción a Pasantías', null );
INSERT INTO dba.acc_parametros ( operacion, orden, ventana, parametros, cierra_anterior ) VALUES ( '820rep01', 1, 'w_reporte_ag', 'uo_dw_key, dr820_inscpas, dl820_inscripcion_pasantias_ag', 'N' );
INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( '820rep01', 'C' );
INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( '820rep01', 'I' );


-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Versión 1.5.0
-- *******************************************************************************


-- ***********************************************************************************************************
-- AUTOGESTION
-- ***********************************************************************************************************
DELETE FROM acc_parametros_ag where operacion = '820rep01' ; 

INSERT INTO acc_parametros_ag  ( operacion, orden, ventana, parametros, titulo, cierra_anterior ) 
	VALUES ( '820rep01', 1, 'w_reporte_ag', 'uo_dw_key, dr820_inscpas, dl820_inscripcion_pasantias_ag', NULL, 'N' );
