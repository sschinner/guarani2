CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_crea_datocensal') THEN
		DROP PROCEDURE sp_crea_datocensal;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.05.0
-- Ultima actualizacion 2.08.0
-- Procedure sp_crea_datocensal
-- 
-- SP que crea un registro en la tabla sga_datos_censales para una persona
-- en un período dado
-- *******************************************************************************
-- DROP PROCEDURE sp_crea_datocensal;
CREATE PROCEDURE "dba".sp_crea_datocensal(aunidad_academica LIKE sga_datos_censales.unidad_academica, anro_inscrip LIKE sga_datos_censales.nro_inscripcion)

BEGIN
  -------------------------------------------------------------------------
  -- Inserta en sga_datos Censales
  -- Verifico si ya existen datos censales,
  -- en tal caso recupero el ultimo y creo una copia del mismo
  -------------------------------------------------------------------------
   ON EXCEPTION IN (-206)
      -- esto lo realizo porque si no existen datos en la tabla temporal
      -- entonces me daria error al querer borrarla.
      -- El -206 es error de tabla no existe en la db.
   END EXCEPTION WITH RESUME;
   
   IF NOT EXISTS (SELECT ' ' FROM sga_datos_censales
                   WHERE unidad_academica = aunidad_academica
                     AND  nro_inscripcion = anro_inscrip) THEN
      
      -- Inserto un registro en Blanco en el DC.
      INSERT INTO sga_datos_censales ( unidad_academica, nro_inscripcion,  fecha_relevamiento )  
           VALUES (aunidad_academica, anro_inscrip, TODAY);
      
      -- Inserto un registro en Blanco en el DC Aux
      INSERT INTO sga_datos_cen_aux ( unidad_academica, nro_inscripcion,  fecha_relevamiento )
           VALUES ( aunidad_academica, anro_inscrip, TODAY );
      
      -- Inserto un registro en Blanco en el DC Aux2
      INSERT INTO sga_datos_cen_aux2 ( unidad_academica, nro_inscripcion,  fecha_relevamiento )
           VALUES ( aunidad_academica, anro_inscrip, TODAY );
      
   ELSE
      
      -- Existe por lo menos un registro en la entidad sga_datos_censales.
      -- Recupero el ultimo ingresado. Me guio por la fecha de Relevamiento.
      SELECT unidad_academica,
             nro_inscripcion,
             fecha_relevamiento,
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
			 empresa_otra,
			 sector,
			 subsector,
			 facilidad_est_emp,
			 facilidad_est_inst,
			 antiguedad
        FROM sga_datos_censales
       WHERE unidad_academica = aunidad_academica
         AND nro_inscripcion = anro_inscrip
         AND fecha_relevamiento = (SELECT MAX(dc.fecha_relevamiento)
                                     FROM sga_datos_censales dc
                                    WHERE dc.unidad_academica = aunidad_academica
                                      AND dc.nro_inscripcion = anro_inscrip)
        INTO TEMP temp_datos_cens;
      
      
      -- Recupero el ultimo ingresado. Me guio por la fecha de Relevamiento.
      SELECT unidad_academica ,
             nro_inscripcion  ,
             fecha_relevamiento,
             sec_egreso       ,
             sec_anio_ingreso ,
             sec_anio_admision,
             o_est_ter_estado ,
             o_est_uni_estado ,
             sit_actual_padre ,
             sit_actual_madre ,
             tit_obt_padre    ,
             tit_obt_madre    ,
             cant_fami_cargo  ,
             cant_empl_cargo  ,
             barrio_per_lec   ,
             barrio_proc      ,
             barrio_alleg     ,
             pais_nacionalidad,
             existe_trab_alum ,
             cant_hijos_alum  ,
             vive_actual_con  ,
             obra_social_alu  ,
             obra_social_trab ,
             obra_social_fami ,
             obra_social_univ ,
             costea_estudios  ,
             tiene_beca       ,
             tiene_beca_univ  ,
             tiene_beca_nacio ,
             tiene_beca_inter ,
             remuneracion     ,
             horario_trabajo  ,
             practica_deportes,
             hace_dep_univ    ,
             hace_dep_gim_priv,
             hace_dep_partic  ,
             hace_dep_otros   ,
             prac_dep_futbol  ,
             prac_dep_basquet ,
             prac_dep_voley   ,
             prac_dep_gimnasia,
             prac_dep_tenis   ,
             prac_dep_natacion,
             prac_dep_handball,
             prac_dep_otros   ,
             padre_vive       ,
             madre_vive       ,
             vive_con_conyuge ,
             vive_con_padre   ,
             vive_con_madre   ,
             vive_con_hijos   ,
             vive_con_hermanos
        FROM sga_datos_cen_aux
       WHERE unidad_academica = aunidad_academica
         AND nro_inscripcion = anro_inscrip
         AND fecha_relevamiento = (SELECT MAX(dc.fecha_relevamiento)
                                     FROM sga_datos_cen_aux dc
                                    WHERE dc.unidad_academica = aunidad_academica
                                      AND dc.nro_inscripcion = anro_inscrip)
        INTO TEMP temp_dat_cen_aux;
      
      
      -- Recupero el ultimo ingresado. Me guio por la fecha de Relevamiento.
      SELECT unidad_academica  ,
             nro_inscripcion   ,
             fecha_relevamiento,
             alu_obra_social   ,
             alu_est_civil_uh  ,
             alu_trab_hace     ,
             alu_trab_desjub   ,
             alu_trab_fami     ,
             alu_trab_ocup     ,
             alu_trab_tarea    ,
             padre_trab_hace   ,
             padre_trab_ocup   ,
             padre_trab_otro   ,
             padre_trab_tarea  ,
             madre_trab_hace   ,
             madre_trab_ocup   ,
             madre_trab_otro   ,
             madre_trab_tarea  ,
             alu_cos_est_ap_fam,
             alu_cos_est_trab  ,
             alu_cos_est_beca  ,
             alu_cos_est_plsoc ,
             alu_cos_est_otra  ,
             alu_cos_est_espec ,
             alu_beca_muni     ,
             alu_beca_otra     ,
             alu_beca_prov     ,
             alu_beca_tipo_eco ,
             alu_beca_tipo_ser ,
             alu_beca_tipo_inv ,
             alu_beca_eco_tran ,
             alu_beca_eco_come ,
             alu_beca_eco_foto ,
             alu_beca_eco_efec ,
             alu_beca_eco_habi ,
             alu_otestsup_uni  ,
             alu_otestsup_tipo ,
             alu_otestsup_area ,
             alu_otestsup_carr ,
             alu_otestsup_esta ,
             alu_otestsup_egre ,
             alu_otestsup_niv  ,
             alu_tec_pc_casa   ,
             alu_tec_pc_trab   ,
             alu_tec_pc_univ   ,
             alu_tec_pc_otro   ,
             alu_tec_int_casa  ,
             alu_tec_int_trab  ,
             alu_tec_int_univ  ,
             alu_tec_int_cyber ,
             alu_tec_int_otro  ,
             alu_tec_usint_cha ,
             alu_tec_usint_cap ,
             alu_tec_usint_est ,
             alu_tec_usint_per ,
             alu_tec_usint_mai ,
             alu_tec_int_regul ,
             alu_idioma_ingl   ,
             alu_idioma_fran   ,
             alu_idioma_port   ,
             alu_idioma_ital   ,
             alu_idioma_alem   ,
             alu_idioma_otro
        FROM sga_datos_cen_aux2
       WHERE unidad_academica = aunidad_academica
         AND nro_inscripcion = anro_inscrip
         AND fecha_relevamiento = (SELECT MAX(dc.fecha_relevamiento)
                                     FROM sga_datos_cen_aux2 dc
                                    WHERE dc.unidad_academica = aunidad_academica
                                      AND dc.nro_inscripcion = anro_inscrip)
        INTO TEMP temp_dat_cen_aux2;
      
      
      ----------------------
      -- Inserto el registro
      INSERT INTO sga_datos_censales ( unidad_academica,
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
									   empresa_otra,
									   sector,
									   subsector,
									   facilidad_est_emp,
									   facilidad_est_inst,
									   antiguedad )
           SELECT unidad_academica,
                  nro_inscripcion,
                  TODAY,
                  TODAY,
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
				  empresa_otra,
				  sector,
				  subsector,
				  facilidad_est_emp,
				  facilidad_est_inst,
				  antiguedad
				  
             FROM temp_datos_cens
            WHERE unidad_academica = aunidad_academica
              AND nro_inscripcion = anro_inscrip;
      
      
      -- Inserto el registro
      INSERT INTO sga_datos_cen_aux ( unidad_academica,
                                      nro_inscripcion,
                                      fecha_relevamiento,
                                      sec_egreso,
                                      sec_anio_ingreso,
                                      sec_anio_admision,
                                      o_est_ter_estado,
                                      o_est_uni_estado,
                                      sit_actual_padre,
                                      sit_actual_madre,
                                      tit_obt_padre,
                                      tit_obt_madre,
                                      cant_fami_cargo,
                                      cant_empl_cargo,
                                      barrio_per_lec,
                                      barrio_proc,
                                      barrio_alleg,
                                      pais_nacionalidad,
                                      existe_trab_alum,
                                      cant_hijos_alum,
                                      vive_actual_con,
                                      obra_social_alu,
                                      obra_social_trab,
                                      obra_social_fami,
                                      obra_social_univ,
                                      costea_estudios,
                                      tiene_beca,
                                      tiene_beca_univ,
                                      tiene_beca_nacio,
                                      tiene_beca_inter,
                                      remuneracion,
                                      horario_trabajo,
                                      practica_deportes,
                                      hace_dep_univ,
                                      hace_dep_gim_priv,
                                      hace_dep_partic,
                                      hace_dep_otros,
                                      prac_dep_futbol,
                                      prac_dep_basquet,
                                      prac_dep_voley,
                                      prac_dep_gimnasia,
                                      prac_dep_tenis,
                                      prac_dep_natacion,
                                      prac_dep_handball,
                                      prac_dep_otros,
                                      padre_vive,
                                      madre_vive,
                                      vive_con_conyuge,
                                      vive_con_padre,
                                      vive_con_madre,
                                      vive_con_hijos,
                                      vive_con_hermanos )
           SELECT unidad_academica,
                  nro_inscripcion,
                  TODAY,
                  sec_egreso,
                  sec_anio_ingreso,
                  sec_anio_admision,
                  o_est_ter_estado,
                  o_est_uni_estado,
                  sit_actual_padre,
                  sit_actual_madre,
                  tit_obt_padre,
                  tit_obt_madre,
                  cant_fami_cargo,
                  cant_empl_cargo,
                  barrio_per_lec,
                  barrio_proc,
                  barrio_alleg,
                  pais_nacionalidad,
                  existe_trab_alum,
                  cant_hijos_alum,
                  vive_actual_con,
                  obra_social_alu,
                  obra_social_trab,
                  obra_social_fami,
                  obra_social_univ,
                  costea_estudios,
                  tiene_beca,
                  tiene_beca_univ,
                  tiene_beca_nacio,
                  tiene_beca_inter,
                  remuneracion,
                  horario_trabajo,
                  practica_deportes,
                  hace_dep_univ,
                  hace_dep_gim_priv,
                  hace_dep_partic,
                  hace_dep_otros,
                  prac_dep_futbol,
                  prac_dep_basquet,
                  prac_dep_voley,
                  prac_dep_gimnasia,
                  prac_dep_tenis,
                  prac_dep_natacion,
                  prac_dep_handball,
                  prac_dep_otros,
                  padre_vive,
                  madre_vive,
                  vive_con_conyuge,
                  vive_con_padre,
                  vive_con_madre,
                  vive_con_hijos,
                  vive_con_hermanos 
             FROM temp_dat_cen_aux
            WHERE unidad_academica = aunidad_academica
              AND nro_inscripcion = anro_inscrip;
      
      -- Inserto el registro
      INSERT INTO sga_datos_cen_aux2 ( unidad_academica,
                                       nro_inscripcion,
                                       fecha_relevamiento,
                                       alu_obra_social   ,
                                       alu_est_civil_uh  ,
                                       alu_trab_hace     ,
                                       alu_trab_desjub   ,
                                       alu_trab_fami     ,
                                       alu_trab_ocup     ,
                                       alu_trab_tarea    ,
                                       padre_trab_hace   ,
                                       padre_trab_ocup   ,
                                       padre_trab_otro   ,
                                       padre_trab_tarea  ,
                                       madre_trab_hace   ,
                                       madre_trab_ocup   ,
                                       madre_trab_otro   ,
                                       madre_trab_tarea  ,
                                       alu_cos_est_ap_fam,
                                       alu_cos_est_trab  ,
                                       alu_cos_est_beca  ,
                                       alu_cos_est_plsoc ,
                                       alu_cos_est_otra  ,
                                       alu_cos_est_espec ,
                                       alu_beca_muni     ,
                                       alu_beca_otra     ,
                                       alu_beca_prov     ,
                                       alu_beca_tipo_eco ,
                                       alu_beca_tipo_ser ,
                                       alu_beca_tipo_inv ,
                                       alu_beca_eco_tran ,
                                       alu_beca_eco_come ,
                                       alu_beca_eco_foto ,
                                       alu_beca_eco_efec ,
                                       alu_beca_eco_habi ,
                                       alu_otestsup_uni  ,
                                       alu_otestsup_tipo ,
                                       alu_otestsup_area ,
                                       alu_otestsup_carr ,
                                       alu_otestsup_esta ,
                                       alu_otestsup_egre ,
                                       alu_otestsup_niv  ,
                                       alu_tec_pc_casa   ,
                                       alu_tec_pc_trab   ,
                                       alu_tec_pc_univ   ,
                                       alu_tec_pc_otro   ,
                                       alu_tec_int_casa  ,
                                       alu_tec_int_trab  ,
                                       alu_tec_int_univ  ,
                                       alu_tec_int_cyber ,
                                       alu_tec_int_otro  ,
                                       alu_tec_usint_cha ,
                                       alu_tec_usint_cap ,
                                       alu_tec_usint_est ,
                                       alu_tec_usint_per ,
                                       alu_tec_usint_mai ,
                                       alu_tec_int_regul ,
                                       alu_idioma_ingl   ,
                                       alu_idioma_fran   ,
                                       alu_idioma_port   ,
                                       alu_idioma_ital   ,
                                       alu_idioma_alem   ,
                                       alu_idioma_otro   )
           SELECT unidad_academica,
                  nro_inscripcion,
                  TODAY,
                  alu_obra_social   ,
                  alu_est_civil_uh  ,
                  alu_trab_hace     ,
                  alu_trab_desjub   ,
                  alu_trab_fami     ,
                  alu_trab_ocup     ,
                  alu_trab_tarea    ,
                  padre_trab_hace   ,
                  padre_trab_ocup   ,
                  padre_trab_otro   ,
                  padre_trab_tarea  ,
                  madre_trab_hace   ,
                  madre_trab_ocup   ,
                  madre_trab_otro   ,
                  madre_trab_tarea  ,
                  alu_cos_est_ap_fam,  
                  alu_cos_est_trab  ,  
                  alu_cos_est_beca  ,  
                  alu_cos_est_plsoc ,  
                  alu_cos_est_otra  ,  
                  alu_cos_est_espec ,       
                  alu_beca_muni     ,  
                  alu_beca_otra     ,  
                  alu_beca_prov     ,  
                  alu_beca_tipo_eco ,  
                  alu_beca_tipo_ser ,  
                  alu_beca_tipo_inv ,
                  alu_beca_eco_tran ,
                  alu_beca_eco_come ,
                  alu_beca_eco_foto ,
                  alu_beca_eco_efec ,
                  alu_beca_eco_habi ,
                  alu_otestsup_uni  ,       
                  alu_otestsup_tipo ,  
                  alu_otestsup_area ,       
                  alu_otestsup_carr ,       
                  alu_otestsup_esta ,
                  alu_otestsup_egre ,
                  alu_otestsup_niv  ,
                  alu_tec_pc_casa   ,
                  alu_tec_pc_trab   ,
                  alu_tec_pc_univ   ,
                  alu_tec_pc_otro   ,
                  alu_tec_int_casa  ,
                  alu_tec_int_trab  ,
                  alu_tec_int_univ  ,
                  alu_tec_int_cyber ,
                  alu_tec_int_otro  ,
                  alu_tec_usint_cha ,
                  alu_tec_usint_cap ,
                  alu_tec_usint_est ,
                  alu_tec_usint_per ,
                  alu_tec_usint_mai ,
                  alu_tec_int_regul ,
                  alu_idioma_ingl   ,
                  alu_idioma_fran   ,
                  alu_idioma_port   ,
                  alu_idioma_ital   ,
                  alu_idioma_alem   ,
                  alu_idioma_otro
             FROM temp_dat_cen_aux2
            WHERE unidad_academica = aunidad_academica
              AND nro_inscripcion = anro_inscrip;
      
      
      
      -- Borro la tabla temporal
      DROP TABLE temp_datos_cens;
      DROP TABLE temp_dat_cen_aux;
      DROP TABLE temp_dat_cen_aux2;
      
   END IF;

END;
END PROCEDURE;
-- *************** FIN DEL PROCEDURE sp_crea_datocensal ***************
-- *****************************************************************************
-- Permisos del procedimiento
-- *****************************************************************************
revoke execute on "dba".sp_crea_datocensal from public;
grant execute on "dba".sp_crea_datocensal to guarani; -- Rol de usuarios de Gestión
grant execute on "dba".sp_crea_datocensal to siguv_consulta; -- Rol de usuarios de SIGUV
grant execute on "dba".sp_crea_datocensal to ue_siguv_guarani; -- Rol de usuarios de SIGUV
