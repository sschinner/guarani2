
-- *******************************************************************************
-- SIU - Guaraní. Sistema de Gestión Académica
-- Versiï¿½n 2.0.5
-- *******************************************************************************

Execute procedure dba.sui_operaciones('netmi03',
	'Inscripción a Curs.',
	'Inscripción a Mat. Integración',
	NULL);

INSERT INTO acc_operacion_mod VALUES (
	'Net00400',
	'netmi03',
	'Internet',
	2);

INSERT INTO acc_acciones_oper VALUES (
	'netmi03',
	'C');


