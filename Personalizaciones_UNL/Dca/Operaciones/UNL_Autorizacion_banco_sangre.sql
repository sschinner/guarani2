-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Versión 2.6.3
-- *******************************************************************************
-- Cargo la operacion en el modulo del perfil del alumno
Execute procedure dba.sui_operaciones('820agr20', 'Autorización Banco de sangre', 'Permite al alumno dar su voluntad de participar en el banco de sangre', NULL);
Begin;
set constraints all deferred;
DELETE FROM acc_operacion_mod WHERE operacion = "820agr20";
DELETE FROM acc_operaciones WHERE operacion = "820agr20";
Commit;
