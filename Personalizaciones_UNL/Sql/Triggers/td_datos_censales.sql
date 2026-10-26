CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
  IF EXISTS (SELECT procid
      FROM sysprocedures
      WHERE procname = 'spd_datos_censales') THEN
    DROP PROCEDURE spd_datos_censales;
  END IF;   
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.08.0
-- Tabla sga_datos_censales
-- Procedure spd_datos_censales (asociado al trigger de DELETE)
-- *******************************************************************************
-- DROP PROCEDURE spd_datos_censales ;
CREATE PROCEDURE "dba".spd_datos_censales (
       o_unidad_academica like sga_datos_censales.unidad_academica,
       o_nro_inscripcion like sga_datos_censales.nro_inscripcion,
       o_fecha_relevamien like sga_datos_censales.fecha_relevamiento,
       o_fecha_actualiz like sga_datos_censales.fecha_actualiz,
       o_estado_civil like sga_datos_censales.estado_civil,
       o_turno_preferido like sga_datos_censales.turno_preferido,
       o_e_mail like sga_datos_censales.e_mail,
       o_tipo_visa like sga_datos_censales.tipo_visa,
       o_otorgamiento_vis like sga_datos_censales.otorgamiento_visa,
       o_vencimiento_visa like sga_datos_censales.vencimiento_visa,
       o_tipo_residencia like sga_datos_censales.tipo_residencia,
       o_tipo_res_per_lec like sga_datos_censales.tipo_res_per_lect,
       o_calle_per_lect like sga_datos_censales.calle_per_lect,
       o_numero_per_lect like sga_datos_censales.numero_per_lect,
       o_piso_per_lect like sga_datos_censales.piso_per_lect,
       o_dpto_per_lect like sga_datos_censales.dpto_per_lect,
       o_unidad_per_lect like sga_datos_censales.unidad_per_lect,
       o_loc_per_lect like sga_datos_censales.loc_per_lect,
       o_cp_per_lect like sga_datos_censales.cp_per_lect,
       o_te_per_lect like sga_datos_censales.te_per_lect,
       o_calle_proc like sga_datos_censales.calle_proc,
       o_numero_proc like sga_datos_censales.numero_proc,
       o_piso_proc like sga_datos_censales.piso_proc,
       o_dpto_proc like sga_datos_censales.dpto_proc,
       o_unidad_proc like sga_datos_censales.unidad_proc,
       o_loc_proc like sga_datos_censales.loc_proc,
       o_cp_proc like sga_datos_censales.cp_proc,
       o_te_proc like sga_datos_censales.te_proc,
       o_otros_estud_supe like sga_datos_censales.otros_estud_super,
       o_viven_padres like sga_datos_censales.viven_padres,
       o_fliares_cargo_al like sga_datos_censales.fliares_cargo_alum,
       o_sit_laboral_alu like sga_datos_censales.sit_laboral_alu,
       o_categ_ocup_alum like sga_datos_censales.categ_ocup_alum,
       o_act_econom_alum like sga_datos_censales.act_econom_alum,
       o_det_rama_act_alu like sga_datos_censales.det_rama_act_alum,
       o_hora_sem_trab_al like sga_datos_censales.hora_sem_trab_alum,
       o_rel_trab_carrera like sga_datos_censales.rel_trab_carrera,
       o_sit_laboral_padr like sga_datos_censales.sit_laboral_padre,
       o_ult_est_cur_padr like sga_datos_censales.ult_est_cur_padre,
       o_act_econom_padre like sga_datos_censales.act_econom_padre,
       o_det_rama_act_pad like sga_datos_censales.det_rama_act_padre,
       o_categ_ocup_padre like sga_datos_censales.categ_ocup_padre,
       o_sit_laboral_madr like sga_datos_censales.sit_laboral_madre,
       o_ult_est_cur_madr like sga_datos_censales.ult_est_cur_madre,
       o_act_econom_madre like sga_datos_censales.act_econom_madre,
       o_det_rama_act_mad like sga_datos_censales.det_rama_act_madre,
       o_categ_ocup_madre like sga_datos_censales.categ_ocup_madre,
       o_nombre_pers_alle like sga_datos_censales.nombre_pers_alleg,
       o_calle_pers_alleg like sga_datos_censales.calle_pers_alleg,
       o_nro_pers_alleg like sga_datos_censales.nro_pers_alleg,
       o_piso_pers_alleg like sga_datos_censales.piso_pers_alleg,
       o_dpto_pers_alleg like sga_datos_censales.dpto_pers_alleg,
       o_unidad_pers_alle like sga_datos_censales.unidad_pers_alleg,
       o_loc_pers_alleg like sga_datos_censales.loc_pers_alleg,
       o_cp_pers_alleg like sga_datos_censales.cp_pers_alleg,
       o_te_pers_alleg like sga_datos_censales.te_pers_alleg,
       o_empresa  like sga_datos_censales.empresa,
       o_sector  like sga_datos_censales.sector,
       o_subsector  like sga_datos_censales.subsector,     
       o_empresa_otra  like sga_datos_censales.empresa_otra,
       o_facilidad_est_emp  like sga_datos_censales.facilidad_est_emp,
       o_facilidad_est_inst  like sga_datos_censales.facilidad_est_inst,
       o_antiguedad  like sga_datos_censales.antiguedad,
       o_apellido_pers_alleg like sga_datos_censales.apellido_pers_alleg,
       o_tipo_allegado like sga_datos_censales.tipo_allegado) 


BEGIN

   -------------------------------------------------------------------------------- 
   -- Borra en cascada los registros de la tabla sga_datos_cen_aux (PARENT DELETE CASCADE)
   -------------------------------------------------------------------------------- 
   DELETE FROM sga_datos_cen_aux
    WHERE sga_datos_cen_aux.unidad_academica = o_unidad_academica
      AND sga_datos_cen_aux.nro_inscripcion = o_nro_inscripcion;

   DELETE FROM sga_datos_cen_aux2
    WHERE sga_datos_cen_aux2.unidad_academica = o_unidad_academica
      AND sga_datos_cen_aux2.nro_inscripcion = o_nro_inscripcion;

   -------------------------------------------------------------------------------- 
   -- U820 Borra en cascada los registros de la tabla sga_datos_cen_aux (PARENT DELETE CASCADE)
   -------------------------------------------------------------------------------- 
   DELETE FROM u820_datos_cen_aux
    WHERE u820_datos_cen_aux.unidad_academica = o_unidad_academica
      AND u820_datos_cen_aux.nro_inscripcion = o_nro_inscripcion;

   -- Carga la tabla de log para auditoria
   INSERT INTO log_datos_censales (
     unidad_academica,
     nro_inscripcion,
     fecha_relevamiento,
     fecha_actualiz,
     estado_civil,
     turno_preferido,
     e_mail,
     tipo_visa,
     otorgamiento_visa,
     vencimiento_visa,
     tipo_residencia,
     tipo_res_per_lect,
     calle_per_lect,
     numero_per_lect,
     piso_per_lect,
     dpto_per_lect,
     unidad_per_lect,
     loc_per_lect,
     cp_per_lect,
     te_per_lect,
     calle_proc,
     numero_proc,
     piso_proc,
     dpto_proc,
     unidad_proc,
     loc_proc,
     cp_proc,
     te_proc,
     otros_estud_super,
     viven_padres,
     fliares_cargo_alum,
     sit_laboral_alu,
     categ_ocup_alum,
     act_econom_alum,
     det_rama_act_alum,
     hora_sem_trab_alum,
     rel_trab_carrera,
     sit_laboral_padre,
     ult_est_cur_padre,
     act_econom_padre,
     det_rama_act_padre,
     categ_ocup_padre,
     sit_laboral_madre,
     ult_est_cur_madre,
     act_econom_madre,
     det_rama_act_madre,
     categ_ocup_madre,
     nombre_pers_alleg,
     calle_pers_alleg,
     nro_pers_alleg,
     piso_pers_alleg,
     dpto_pers_alleg,
     unidad_pers_alleg,
     loc_pers_alleg,
     cp_pers_alleg,
     te_pers_alleg,
     empresa,
     sector,
     subsector,     
     empresa_otra,
     facilidad_est_emp,
     facilidad_est_inst,
     antiguedad,
     apellido_pers_alleg,
     tipo_allegado,
     usuario,
     fecha_act,
     oper)
   VALUES (
     o_unidad_academica,
     o_nro_inscripcion,
     o_fecha_relevamien,
     o_fecha_actualiz,
     o_estado_civil,
     o_turno_preferido,
     o_e_mail,
     o_tipo_visa,
     o_otorgamiento_vis,
     o_vencimiento_visa,
     o_tipo_residencia,
     o_tipo_res_per_lec,
     o_calle_per_lect,
     o_numero_per_lect,
     o_piso_per_lect,
     o_dpto_per_lect,
     o_unidad_per_lect,
     o_loc_per_lect,
     o_cp_per_lect,
     o_te_per_lect,
     o_calle_proc,
     o_numero_proc,
     o_piso_proc,
     o_dpto_proc,
     o_unidad_proc,
     o_loc_proc,
     o_cp_proc,
     o_te_proc,
     o_otros_estud_supe,
     o_viven_padres,
     o_fliares_cargo_al,
     o_sit_laboral_alu,
     o_categ_ocup_alum,
     o_act_econom_alum,
     o_det_rama_act_alu,
     o_hora_sem_trab_al,
     o_rel_trab_carrera,
     o_sit_laboral_padr,
     o_ult_est_cur_padr,
     o_act_econom_padre,
     o_det_rama_act_pad,
     o_categ_ocup_padre,
     o_sit_laboral_madr,
     o_ult_est_cur_madr,
     o_act_econom_madre,
     o_det_rama_act_mad,
     o_categ_ocup_madre,
     o_nombre_pers_alle,
     o_calle_pers_alleg,
     o_nro_pers_alleg,
     o_piso_pers_alleg,
     o_dpto_pers_alleg,
     o_unidad_pers_alle,
     o_loc_pers_alleg,
     o_cp_pers_alleg,
     o_te_pers_alleg,
     o_empresa,
     o_sector,
     o_subsector,     
     o_empresa_otra,
     o_facilidad_est_emp,
     o_facilidad_est_inst,
     o_antiguedad,
     o_apellido_pers_alleg,
     o_tipo_allegado,
     User,
     Current year to Second,
     'D');
END;
END PROCEDURE;
-- ********** Fin del procedure asociado al trigger de DELETE de sga_datos_censales **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Tabla sga_datos_censales
-- Procedure personalizado uad_datos_censales (asociado al trigger de DELETE)
-- *******************************************************************************
-- DROP PROCEDURE uad_datos_censales ;
-- CREATE PROCEDURE uad_datos_censales (
--        o_unidad_academica like sga_datos_censales.unidad_academica,
--        o_nro_inscripcion like sga_datos_censales.nro_inscripcion,
--        o_fecha_relevamien like sga_datos_censales.fecha_relevamiento,
--        o_fecha_actualiz like sga_datos_censales.fecha_actualiz,
--        o_estado_civil like sga_datos_censales.estado_civil,
--        o_turno_preferido like sga_datos_censales.turno_preferido,
--        o_e_mail like sga_datos_censales.e_mail,
--        o_tipo_visa like sga_datos_censales.tipo_visa,
--        o_otorgamiento_vis like sga_datos_censales.otorgamiento_visa,
--        o_vencimiento_visa like sga_datos_censales.vencimiento_visa,
--        o_tipo_residencia like sga_datos_censales.tipo_residencia,
--        o_tipo_res_per_lec like sga_datos_censales.tipo_res_per_lect,
--        o_calle_per_lect like sga_datos_censales.calle_per_lect,
--        o_numero_per_lect like sga_datos_censales.numero_per_lect,
--        o_piso_per_lect like sga_datos_censales.piso_per_lect,
--        o_dpto_per_lect like sga_datos_censales.dpto_per_lect,
--        o_unidad_per_lect like sga_datos_censales.unidad_per_lect,
--        o_loc_per_lect like sga_datos_censales.loc_per_lect,
--        o_cp_per_lect like sga_datos_censales.cp_per_lect,
--        o_te_per_lect like sga_datos_censales.te_per_lect,
--        o_calle_proc like sga_datos_censales.calle_proc,
--        o_numero_proc like sga_datos_censales.numero_proc,
--        o_piso_proc like sga_datos_censales.piso_proc,
--        o_dpto_proc like sga_datos_censales.dpto_proc,
--        o_unidad_proc like sga_datos_censales.unidad_proc,
--        o_loc_proc like sga_datos_censales.loc_proc,
--        o_cp_proc like sga_datos_censales.cp_proc,
--        o_te_proc like sga_datos_censales.te_proc,
--        o_otros_estud_supe like sga_datos_censales.otros_estud_super,
--        o_viven_padres like sga_datos_censales.viven_padres,
--        o_fliares_cargo_al like sga_datos_censales.fliares_cargo_alum,
--        o_sit_laboral_alu like sga_datos_censales.sit_laboral_alu,
--        o_categ_ocup_alum like sga_datos_censales.categ_ocup_alum,
--        o_act_econom_alum like sga_datos_censales.act_econom_alum,
--        o_det_rama_act_alu like sga_datos_censales.det_rama_act_alum,
--        o_hora_sem_trab_al like sga_datos_censales.hora_sem_trab_alum,
--        o_rel_trab_carrera like sga_datos_censales.rel_trab_carrera,
--        o_sit_laboral_padr like sga_datos_censales.sit_laboral_padre,
--        o_ult_est_cur_padr like sga_datos_censales.ult_est_cur_padre,
--        o_act_econom_padre like sga_datos_censales.act_econom_padre,
--        o_det_rama_act_pad like sga_datos_censales.det_rama_act_padre,
--        o_categ_ocup_padre like sga_datos_censales.categ_ocup_padre,
--        o_sit_laboral_madr like sga_datos_censales.sit_laboral_madre,
--        o_ult_est_cur_madr like sga_datos_censales.ult_est_cur_madre,
--        o_act_econom_madre like sga_datos_censales.act_econom_madre,
--        o_det_rama_act_mad like sga_datos_censales.det_rama_act_madre,
--        o_categ_ocup_madre like sga_datos_censales.categ_ocup_madre,
--        o_nombre_pers_alle like sga_datos_censales.nombre_pers_alleg,
--        o_calle_pers_alleg like sga_datos_censales.calle_pers_alleg,
--        o_nro_pers_alleg like sga_datos_censales.nro_pers_alleg,
--        o_piso_pers_alleg like sga_datos_censales.piso_pers_alleg,
--        o_dpto_pers_alleg like sga_datos_censales.dpto_pers_alleg,
--        o_unidad_pers_alle like sga_datos_censales.unidad_pers_alleg,
--        o_loc_pers_alleg like sga_datos_censales.loc_pers_alleg,
--        o_cp_pers_alleg like sga_datos_censales.cp_pers_alleg,
--        o_te_pers_alleg like sga_datos_censales.te_pers_alleg,
--        o_apellido_pers_alleg like sga_datos_censales.apellido_pers_alleg,
--        o_tipo_allegado like sga_datos_censales.tipo_allegado)
-- BEGIN
--
--   -------------------------------------------------------------------------------- 
--   -- CODIGO PERSONALIZADO
--   -------------------------------------------------------------------------------- 
--
-- END;
-- END PROCEDURE;
-- **** Fin del procedure personalizado asociado al trigger de DELETE de sga_datos_censales ****
-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.04.0
-- Tabla sga_datos_censales
-- Trigger de Delete td_datos_censales
-- *******************************************************************************
-- DROP TRIGGER td_datos_censales ;
CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
  IF EXISTS (SELECT trigid
      FROM systriggers
      WHERE trigname = 'td_datos_censales') THEN
    DROP TRIGGER td_datos_censales;
  END IF;   
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

CREATE TRIGGER td_datos_censales DELETE on sga_datos_censales
referencing old as old
FOR EACH ROW (
   EXECUTE PROCEDURE spd_datos_censales (
     old.unidad_academica,
     old.nro_inscripcion,
     old.fecha_relevamiento,
     old.fecha_actualiz,
     old.estado_civil,
     old.turno_preferido,
     old.e_mail,
     old.tipo_visa,
     old.otorgamiento_visa,
     old.vencimiento_visa,
     old.tipo_residencia,
     old.tipo_res_per_lect,
     old.calle_per_lect,
     old.numero_per_lect,
     old.piso_per_lect,
     old.dpto_per_lect,
     old.unidad_per_lect,
     old.loc_per_lect,
     old.cp_per_lect,
     old.te_per_lect,
     old.calle_proc,
     old.numero_proc,
     old.piso_proc,
     old.dpto_proc,
     old.unidad_proc,
     old.loc_proc,
     old.cp_proc,
     old.te_proc,
     old.otros_estud_super,
     old.viven_padres,
     old.fliares_cargo_alum,
     old.sit_laboral_alu,
     old.categ_ocup_alum,
     old.act_econom_alum,
     old.det_rama_act_alum,
     old.hora_sem_trab_alum,
     old.rel_trab_carrera,
     old.sit_laboral_padre,
     old.ult_est_cur_padre,
     old.act_econom_padre,
     old.det_rama_act_padre,
     old.categ_ocup_padre,
     old.sit_laboral_madre,
     old.ult_est_cur_madre,
     old.act_econom_madre,
     old.det_rama_act_madre,
     old.categ_ocup_madre,
     old.nombre_pers_alleg,
     old.calle_pers_alleg,
     old.nro_pers_alleg,
     old.piso_pers_alleg,
     old.dpto_pers_alleg,
     old.unidad_pers_alleg,
     old.loc_pers_alleg,
     old.cp_pers_alleg,
     old.te_pers_alleg,
     old.empresa,
     old.sector,
     old.subsector,
     old.empresa_otra,
     old.facilidad_est_emp,
     old.facilidad_est_inst,
     old.antiguedad, 
     old.apellido_pers_alleg, 
     old.tipo_allegado 
)
--,

--   EXECUTE PROCEDURE uad_datos_censales (
--     old.unidad_academica,
--     old.nro_inscripcion,
--     old.fecha_relevamiento,
--     old.fecha_actualiz,
--     old.estado_civil,
--     old.turno_preferido,
--     old.e_mail,
--     old.tipo_visa,
--     old.otorgamiento_visa,
--     old.vencimiento_visa,
--     old.tipo_residencia,
--     old.tipo_res_per_lect,
--     old.calle_per_lect,
--     old.numero_per_lect,
--     old.piso_per_lect,
--     old.dpto_per_lect,
--     old.unidad_per_lect,
--     old.loc_per_lect,
--     old.cp_per_lect,
--     old.te_per_lect,
--     old.calle_proc,
--     old.numero_proc,
--     old.piso_proc,
--     old.dpto_proc,
--     old.unidad_proc,
--     old.loc_proc,
--     old.cp_proc,
--     old.te_proc,
--     old.otros_estud_super,
--     old.viven_padres,
--     old.fliares_cargo_alum,
--     old.sit_laboral_alu,
--     old.categ_ocup_alum,
--     old.act_econom_alum,
--     old.det_rama_act_alum,
--     old.hora_sem_trab_alum,
--     old.rel_trab_carrera,
--     old.sit_laboral_padre,
--     old.ult_est_cur_padre,
--     old.act_econom_padre,
--     old.det_rama_act_padre,
--     old.categ_ocup_padre,
--     old.sit_laboral_madre,
--     old.ult_est_cur_madre,
--     old.act_econom_madre,
--     old.det_rama_act_madre,
--     old.categ_ocup_madre,
--     old.nombre_pers_alleg,
--     old.calle_pers_alleg,
--     old.nro_pers_alleg,
--     old.piso_pers_alleg,
--     old.dpto_pers_alleg,
--     old.unidad_pers_alleg,
--     old.loc_pers_alleg,
--     old.cp_pers_alleg,
--     old.te_pers_alleg, 
--     old.apellido_pers_alleg, 
--     old.tipo_allegado 
);


grant all on u820_datos_cen_aux to guarani;