
-- *******************************************************************************
-- SIU - Guaraní­. Sistema de Gestión Académica
-- Versión 2.0.5
-- *******************************************************************************

Execute procedure dba.sui_operaciones('germi01',
	'Cursantes en otras UA',
	'Cursantes en otras UA',
	NULL);

INSERT INTO acc_operacion_mod VALUES (
	'netger10',
	'germi01',
	'Internet',
	3);

INSERT INTO acc_acciones_oper VALUES (
	'germi01',
	'C');



