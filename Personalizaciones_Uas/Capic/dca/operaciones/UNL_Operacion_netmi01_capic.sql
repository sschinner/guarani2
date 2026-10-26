
-- *******************************************************************************
-- SIU - Guaraní­. Sistema de Gestión Académica
-- Versión 2.0.5
-- *******************************************************************************


Execute procedure dba.sui_operaciones('netmi01',
	'Baja Insc. Curs.',
	'Baja de Inscripción a Mat. Integración',
	NULL);

INSERT INTO acc_operacion_mod VALUES (
	'Net00400',
	'netmi01',
	'Internet',
	3);

INSERT INTO acc_acciones_oper VALUES (
	'netmi01',
	'C');


