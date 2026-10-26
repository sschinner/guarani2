Execute procedure dba.sui_operaciones( 'pes00003', 'Datos Académicos de alumnos en el programa PROGR.ES.AR', 'Información de datos académicos para alumnos del plan PROGR.ES.AR', null );

Begin;
set constraints all deferred;
DELETE FROM dba.acc_operacion_mod WHERE modulo = '00000070' and operacion = 'pes00003';
DELETE FROM acc_ventanas WHERE ventana = 'w_informacion_academica_progresar';
DELETE FROM acc_submodulos WHERE submodulo = 'Becas';

-- Submódulo: Becas
-- ANTENCION: Este submódulo ya puede existir, si ya existe continuar con el insert que sigue.
INSERT INTO acc_submodulos (submodulo, nombre) VALUES ('Becas','Becas');

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Ventana w_informacion_academica_progresar 
-- Version 2.9.0
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
INSERT INTO acc_ventanas (ventana) values ('w_informacion_academica_progresar');

-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Operacion: pes00003
-- Version: 2.9.0
-- *******************************************************************************


INSERT INTO dba.acc_parametros ( operacion, orden, ventana, parametros, cierra_anterior ) 
  VALUES ( 'pes00003', 1, 'w_informacion_academica_progresar', '', 'N' );

INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( 'pes00003', 'C' );

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Operacion: pes00003
-- Módulo: 00000070 - Interfaces
-- Version: 2.9.0
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
INSERT INTO dba.acc_operacion_mod ( modulo, operacion, submodulo, orden ) VALUES ( '00000070', 'pes00003', 'Becas', 20);

Commit;


