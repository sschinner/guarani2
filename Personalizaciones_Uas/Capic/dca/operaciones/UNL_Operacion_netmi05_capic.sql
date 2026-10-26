
-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Versión 2.0.3
-- *******************************************************************************

Execute procedure dba.sui_operaciones('netmi05',
	'Consulta Insc. Exámen',
	'Consultar Inscripción a Examen Mat. Integración',
	NULL);

INSERT INTO acc_operacion_mod VALUES (
	'Net00400',
	'netmi05',
	'Internet',
	1);


INSERT INTO acc_acciones_oper VALUES (
	'netmi05',
	'C');


