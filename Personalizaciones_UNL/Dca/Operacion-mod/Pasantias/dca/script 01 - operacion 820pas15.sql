Execute procedure dba.sui_operaciones('820pas15',
	'U.N.L. (Inscriptos a Pasantías)',
	'U.N.L. (Inscriptos a Pasantías)',
	NULL);

INSERT INTO acc_operacion_mod VALUES (
	'u820Pas',
	'820pas15',
	'Reportes',
	515);

INSERT INTO acc_parametros VALUES (
	'820pas15',
	1,
	'w_reporte',
    'uo_dw_filtros,dp820_inscriptos_a_pasantia,uo_dw,dr820_inscriptos_a_pasantia,dl820_inscriptos_a_pasantia',
	NULL,
	NULL,
	'N');

INSERT INTO acc_acciones_oper VALUES (
	'820pas15',
	'C');