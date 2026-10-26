-- ****************************************************************************************
-- ATENCION : Si el submódulo "Becas" no existe, hay que descomentar el siguiente insert y 
--
-- crearlo porque la operacion ifz00039 lo usa dentro del módulo Interfaces.

-- ****************************************************************************************

Execute procedure dba.sui_operaciones( 'ifz00039', 'Convocatoria Renovación 2014 - PNBU - PNBB', 'Convocatoria Renovación 2014 - PNBU - PNBB', null );

Begin;
set constraints all deferred;
DELETE FROM dba.acc_operacion_mod WHERE modulo = '00000070' and operacion = 'ifz00039';
DELETE FROM acc_ventanas WHERE ventana = 'w_pnbu_2014';
DELETE FROM acc_submodulos WHERE submodulo = 'Becas';
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Ventana w_pnbu_2014
-- Version 2.8.1
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

INSERT INTO acc_ventanas (ventana) values ('w_pnbu_2014');
INSERT INTO acc_submodulos (submodulo, nombre) VALUES ('Becas','Becas');

-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Operacion: ifz00039
-- Version: 2.8.1
-- *******************************************************************************


INSERT INTO dba.acc_parametros ( operacion, orden, ventana, parametros, cierra_anterior ) VALUES ( 'ifz00039', 1, 'w_pnbu_2014', '', 'N' );
INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( 'ifz00039', 'C' );

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Operacion: ifz00039
-- Módulo: 00000070 - Interfaces
-- Version: 2.8.1
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
INSERT INTO dba.acc_operacion_mod ( modulo, operacion, submodulo, orden ) VALUES ( '00000070', 'ifz00039', 'Becas', 39);

Commit;


