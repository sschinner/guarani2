Execute procedure dba.sui_operaciones('820mat22', 'Historia Académica Completa de un alumno', 'Historia Académica Completa de un alumno',NULL);

--INSERT INTO acc_operacion_mod VALUES ( '00000010', '820mat22', 'Reportes', 502);

INSERT INTO acc_parametros VALUES ('820mat22', 1, 'w_reporte_vacio', 'uo_dw_filtros,dp_alumno_carrera_corresponda,uo_dw,dr820_historia_academica_completa,dl820_historia_academica_completa, dr820_sin_historia_academica, dl820_sin_historia_academica', Null, Null, 'N');

INSERT INTO acc_acciones_oper VALUES ('820mat22', 'C');

