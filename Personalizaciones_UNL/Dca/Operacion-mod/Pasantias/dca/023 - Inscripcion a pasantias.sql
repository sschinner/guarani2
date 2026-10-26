-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Versión 1.1.0
-- Ultima Modificacion Versión: 1.3
-- *******************************************************************************
Execute procedure dba.sui_operaciones( 
	'820pas04',
	'Inscripción a Pasantías',
	'Inscripción a Pasantías.',
	null );

Execute procedure dba.sui_ventanas('w_selecciona_pasantia_insc_ag') ;

INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( '820pas04', 'C' );
INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( '820pas04', 'M' );


-- ***********************************************************************************************************
-- AUTOGESTION
-- ***********************************************************************************************************
DELETE FROM acc_parametros_ag where operacion = '820pas04' ; 

INSERT INTO acc_parametros_ag  ( operacion, orden, ventana, parametros, titulo, cierra_anterior ) 
	VALUES ( '820pas04', 1, 'w_selecciona_pasantia_insc_ag', 'uo_dw, dk_pasantias_insc,10, uo_dw, dl820_certif_inscpasantias_ag', NULL, 'N' );