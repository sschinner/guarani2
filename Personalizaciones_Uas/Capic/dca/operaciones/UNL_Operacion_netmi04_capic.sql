
-- *******************************************************************************
-- SIU - Guaraní. Sistema de Gestión Académica
-- Versión 2.0.5
-- *******************************************************************************

Execute procedure dba.sui_operaciones('netmi04',
	'Baja Insc. Examen',
	'Baja de Inscripción a Exámen Mat. Integración',
	NULL);

INSERT INTO acc_operacion_mod VALUES (
	'Net00400',
	'netmi04',
	'Internet',
	3);

INSERT INTO acc_acciones_oper VALUES (
	'netmi04',
	'C');


