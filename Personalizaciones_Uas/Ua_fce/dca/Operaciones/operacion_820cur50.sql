Execute procedure dba.sui_operaciones('820cur50',
	'Inscriptos a cursar - Orden Nota',
	'Inscriptos a cursar - Orden Nota',
	NULL);

Begin;

set constraints all deferred;
DELETE FROM acc_operacion_mod WHERE operacion = "820cur50";


INSERT INTO acc_operacion_mod VALUES (
	'00000015',
	'820cur50',
	'Reportes',
	602);

INSERT INTO acc_parametros VALUES (
	'820cur50',
	1,
	'w_reporte',
    'uo_dw_una_comision, dp820_comision, uo_dw, dl820_inscriptos_por_com_nota, dl820_inscriptos_por_com_nota', Null, Null, 'N');

INSERT INTO acc_acciones_oper VALUES (
	'820cur50',
	'C');

commit;
