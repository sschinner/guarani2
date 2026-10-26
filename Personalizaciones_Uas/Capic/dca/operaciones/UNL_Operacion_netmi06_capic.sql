
-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Versión 2.0.3
-- *******************************************************************************

Execute procedure dba.sui_operaciones('netmi06',
	'Inscripción a Examen',
	'Inscripción a Examen Mat. Integración',
	NULL);

INSERT INTO acc_operacion_mod VALUES (
	'Net00400',
	'netmi06',
	'Internet',
	2);

INSERT INTO acc_acciones_oper VALUES (
	'netmi06',
	'C');



