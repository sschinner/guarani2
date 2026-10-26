-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Versión 2.6.3
-- *******************************************************************************
-- Cargo la operacion en el modulo del perfil del alumno
Execute procedure dba.sui_operaciones('820agr10', 'Autorización Boleto Estudiantil', 'Permite al alumno dar una autorización para utilizar sus datos en el trámite del boleto estudiantil', NULL);
Begin;
set constraints all deferred;
DELETE FROM acc_operaciones WHERE operacion = "820agr10";
DELETE FROM acc_operacion_mod where operacion = "820agr10";
Commit;

