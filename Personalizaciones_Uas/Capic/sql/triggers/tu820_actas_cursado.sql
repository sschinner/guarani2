-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version Alfa 1.2.0
-- Tabla sga_actas_cursado
-- Procedure spu_actas_cursado (asociado al trigger de UPDATE)
-- *******************************************************************************
DROP PROCEDURE spu_actas_cursado ;
CREATE PROCEDURE spu_actas_cursado (
       o_unidad_academica like sga_actas_cursado.unidad_academica,
       o_acta like sga_actas_cursado.acta,
       o_comision like sga_actas_cursado.comision,
       o_carrera like sga_actas_cursado.carrera,
       o_libro like sga_actas_cursado.libro,
       o_escala_notas like sga_actas_cursado.escala_notas,
       o_fecha_generacion like sga_actas_cursado.fecha_generacion,
       o_fecha_cierre like sga_actas_cursado.fecha_cierre,
       o_nro_ultima_copia like sga_actas_cursado.nro_ultima_copia,
       o_version like sga_actas_cursado.version,
       o_version_impresa like sga_actas_cursado.version_impresa,
       o_renglones_folio like sga_actas_cursado.renglones_folio,
       o_estado like sga_actas_cursado.estado,
       o_observaciones like sga_actas_cursado.observaciones,
       n_unidad_academica like sga_actas_cursado.unidad_academica,
       n_acta like sga_actas_cursado.acta,
       n_comision like sga_actas_cursado.comision,
       n_carrera like sga_actas_cursado.carrera,
       n_libro like sga_actas_cursado.libro,
       n_escala_notas like sga_actas_cursado.escala_notas,
       n_fecha_generacion like sga_actas_cursado.fecha_generacion,
       n_fecha_cierre like sga_actas_cursado.fecha_cierre,
       n_nro_ultima_copia like sga_actas_cursado.nro_ultima_copia,
       n_version like sga_actas_cursado.version,
       n_version_impresa like sga_actas_cursado.version_impresa,
       n_renglones_folio like sga_actas_cursado.renglones_folio,
       n_estado like sga_actas_cursado.estado,
       n_observaciones like sga_actas_cursado.observaciones)
BEGIN
   -------------------------------------------------------------------------------- 
   -- Impide que se modifique la clave primaria de un registro 
   -------------------------------------------------------------------------------- 
   IF o_unidad_academica <> n_unidad_academica OR
      o_acta <> n_acta  THEN
      raise exception -746,0,'No se puede modificar la clave primaria de un registro.';
   END IF;

   -- No se puede insertar en sga_actas_cursado si no existe en sga_escala_notas
   -- (CHILD UPDATE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_actas_cursado si no existe en sga_carreras
   -- (CHILD UPDATE RESTRICT) Este control lo lleva el CONSTRAINT

	-------------------------------------------------------------------------------- 
	-- Impide que se modifique la comision de un acta
	-------------------------------------------------------------------------------- 
	IF o_comision <> n_comision THEN
		raise exception -746, 0, 'No se puede modificar la Comision.';
	END IF;


   -- Carga la tabla de log para auditoria
   INSERT INTO log_actas_cursado (
     unidad_academica,
     acta,
     comision,
     carrera,
     libro,
     escala_notas,
     fecha_generacion,
     fecha_cierre,
     nro_ultima_copia,
     version,
     version_impresa,
     renglones_folio,
     estado,
     observaciones,
     usuario,
     fecha_act,
     operacion)
   VALUES (
     n_unidad_academica,
     n_acta,
     n_comision,
     n_carrera,
     n_libro,
     n_escala_notas,
     n_fecha_generacion,
     n_fecha_cierre,
     n_nro_ultima_copia,
     n_version,
     n_version_impresa,
     n_renglones_folio,
     n_estado,
     n_observaciones,
     User,
     Current year to Second,
     'U');
end;
end procedure;
-- ********** Fin del procedure asociado al trigger de UPDATE de sga_actas_cursado **********

-- U820 ***********************************************************************************************************************
-- Procedimiento para restringir la actualizacion de actas CAPIC
-- No se deberia permitir rectificar una acta si esta es de capic
-- U820 ***********************************************************************************************************************

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Tabla sga_actas_cursado
-- Procedure personalizado spu820_actas_curs (asociado al trigger de UPDATE)
-- *******************************************************************************
DROP PROCEDURE spu820_actas_curs ;
CREATE PROCEDURE spu820_actas_curs (
       o_unidad_academica like sga_actas_cursado.unidad_academica,
       o_acta like sga_actas_cursado.acta,
       o_comision like sga_actas_cursado.comision,
       o_carrera like sga_actas_cursado.carrera,
       o_libro like sga_actas_cursado.libro,
       o_escala_notas like sga_actas_cursado.escala_notas,
       o_fecha_generacion like sga_actas_cursado.fecha_generacion,
       o_fecha_cierre like sga_actas_cursado.fecha_cierre,
       o_nro_ultima_copia like sga_actas_cursado.nro_ultima_copia,
       o_version like sga_actas_cursado.version,
       o_version_impresa like sga_actas_cursado.version_impresa,
       o_renglones_folio like sga_actas_cursado.renglones_folio,
       o_estado like sga_actas_cursado.estado,
       o_observaciones like sga_actas_cursado.observaciones,
       n_unidad_academica like sga_actas_cursado.unidad_academica,
       n_acta like sga_actas_cursado.acta,
       n_comision like sga_actas_cursado.comision,
       n_carrera like sga_actas_cursado.carrera,
       n_libro like sga_actas_cursado.libro,
       n_escala_notas like sga_actas_cursado.escala_notas,
       n_fecha_generacion like sga_actas_cursado.fecha_generacion,
       n_fecha_cierre like sga_actas_cursado.fecha_cierre,
       n_nro_ultima_copia like sga_actas_cursado.nro_ultima_copia,
       n_version like sga_actas_cursado.version,
       n_version_impresa like sga_actas_cursado.version_impresa,
       n_renglones_folio like sga_actas_cursado.renglones_folio,
       n_estado like sga_actas_cursado.estado,
       n_observaciones like sga_actas_cursado.observaciones)
BEGIN

--   -------------------------------------------------------------------------------- 
-- CODIGO PERSONALIZADO
   IF o_estado = 'C' and exists (select 'comision_capic' from capic_comisiones where comision = o_comision) THEN
	raise exception -746,0,'No puede rectificar el Acta. El Acta ha sido cerrada y es de una Comision de Integración';
   END IF;

--   -------------------------------------------------------------------------------- 

end;
end procedure;
-- **** Fin del procedure personalizado asociado al trigger de UPDATE de sga_actas_cursado ****

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version Alfa 6.0
-- Tabla sga_actas_cursado
-- Trigger de Update tu_actas_cursado
-- *******************************************************************************
DROP TRIGGER tu_actas_cursado ;
CREATE TRIGGER tu_actas_cursado UPDATE on sga_actas_cursado
referencing old as old new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spu_actas_cursado (
     old.unidad_academica,
     old.acta,
     old.comision,
     old.carrera,
     old.libro,
     old.escala_notas,
     old.fecha_generacion,
     old.fecha_cierre,
     old.nro_ultima_copia,
     old.version,
     old.version_impresa,
     old.renglones_folio,
     old.estado,
     old.observaciones,
     new.unidad_academica,
     new.acta,
     new.comision,
     new.carrera,
     new.libro,
     new.escala_notas,
     new.fecha_generacion,
     new.fecha_cierre,
     new.nro_ultima_copia,
     new.version,
     new.version_impresa,
     new.renglones_folio,
     new.estado,
     new.observaciones)
/*
,

   EXECUTE PROCEDURE spu820_actas_curs (
     old.unidad_academica,
     old.acta,
     old.comision,
     old.carrera,
     old.libro,
     old.escala_notas,
     old.fecha_generacion,
     old.fecha_cierre,
     old.nro_ultima_copia,
     old.version,
     old.version_impresa,
     old.renglones_folio,
     old.estado,
     old.observaciones,
     new.unidad_academica,
     new.acta,
     new.comision,
     new.carrera,
     new.libro,
     new.escala_notas,
     new.fecha_generacion,
     new.fecha_cierre,
     new.nro_ultima_copia,
     new.version,
     new.version_impresa,
     new.renglones_folio,
     new.estado,
     new.observaciones) */

);
-- ********** Fin del trigger de Update tu_actas_cursado **********
