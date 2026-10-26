
-- *******************************************************************************
-- SIU  - Guaraní. Sistema de Gestión Académica
-- Versión 2.0.5
-- *******************************************************************************

Execute procedure dba.sui_operaciones('netmi02',
	'Consulta Insc. Curs.',
	'Consultar Inscripción a Mat. Integración',
	NULL);

INSERT INTO acc_operacion_mod VALUES (
	'Net00400',
	'netmi02',
	'Internet',
	1);


INSERT INTO acc_acciones_oper VALUES (
	'netmi02',
	'C');



