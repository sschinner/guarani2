-- *******************************************************************************
-- VALIDACION DE USUARIO CORRECTO PARA LA EJECUCION DEL SCRIPT
-- 
-- SI SALE UN MENSAJE DE ERROR, NO CONTINUE CON LA EJECUCION DEL SCRIPT
-- TIENE QUE VOLVER A LOGUEARSE AL SQL-EDITOR CON EL USUARIO 'dba'
-- *******************************************************************************
EXECUTE PROCEDURE sp_soy_dba();
-- *******************************************************************************
--PERMISOS GUARANI
grant connect to gerencial_ro;
grant RESOURCE to gerencial_ro;

-- Doy permisos a tablas de dimensiones
GRANT SELECT ON dba.sga_sit_laboral TO gerencial_ro;
GRANT SELECT ON dba.sga_titulos_plan TO gerencial_ro;
GRANT SELECT ON dba.sga_cond_regular TO gerencial_ro;
GRANT SELECT ON dba.sga_reinscripcion TO gerencial_ro;
GRANT SELECT ON dba.vw_hist_academica TO gerencial_ro;

GRANT SELECT ON dba.sga_docentes TO gerencial_ro;
GRANT SELECT ON dba.sga_docentes_com TO gerencial_ro;
GRANT SELECT ON dba.sga_atrib_mat_plan TO gerencial_ro;
GRANT SELECT ON dba.mdp_tipo_documento TO gerencial_ro;
GRANT SELECT ON dba.sga_planes TO gerencial_ro;
GRANT SELECT ON dba.sga_materias TO gerencial_ro;

GRANT SELECT ON dba.sga_unidades_acad TO gerencial_ro;
GRANT SELECT ON dba.sga_carreras TO gerencial_ro;
GRANT SELECT ON dba.acc_usuarios TO gerencial_ro;
GRANT SELECT ON dba.int_arau_titulos TO gerencial_ro;
GRANT SELECT ON dba.sga_titulos TO gerencial_ro;
GRANT SELECT ON dba.mug_provincias TO gerencial_ro;
GRANT SELECT ON dba.mug_localidades TO gerencial_ro;
GRANT SELECT ON dba.mug_dptos_partidos TO gerencial_ro;
GRANT SELECT ON dba.sga_coleg_sec TO gerencial_ro;
GRANT SELECT ON dba.mug_paises TO gerencial_ro;
GRANT SELECT ON dba.sga_departamentos TO gerencial_ro;
GRANT SELECT ON dba.sga_situacion_asp TO gerencial_ro;
GRANT SELECT ON dba.sga_carrera_aspira TO gerencial_ro;
GRANT SELECT ON dba.sga_personas TO gerencial_ro;
GRANT SELECT ON dba.sga_periodo_insc TO gerencial_ro;
GRANT SELECT ON dba.sga_sedes TO gerencial_ro;
GRANT SELECT ON dba.sga_mesas_examen TO gerencial_ro;
GRANT SELECT ON dba.sga_actas_examen TO gerencial_ro;
GRANT SELECT ON dba.sga_detalle_acta TO gerencial_ro;
GRANT SELECT ON dba.sga_examenes_equiv TO gerencial_ro;
GRANT SELECT ON dba.int_dw_alumnos_red TO gerencial_ro;
GRANT SELECT ON dba.int_dw_persona_red TO gerencial_ro;
GRANT SELECT ON dba.sga_equiv_otorgada TO gerencial_ro;
GRANT SELECT ON dba.sga_equiv_operac TO gerencial_ro;
GRANT SELECT ON dba.sga_equiv_equiv TO gerencial_ro;
GRANT SELECT ON dba.sga_actas_cursado TO gerencial_ro;
GRANT SELECT ON dba.sga_det_acta_curs TO gerencial_ro;
GRANT SELECT ON dba.sga_det_acta_promo TO gerencial_ro;
GRANT SELECT ON dba.sga_actas_promo TO gerencial_ro;
GRANT SELECT ON dba.sga_comisiones TO gerencial_ro;
GRANT SELECT ON dba.sga_periodos_lect TO gerencial_ro;
GRANT SELECT ON dba.sga_cursadas_equiv TO gerencial_ro;
GRANT SELECT ON dba.sga_anio_academico TO gerencial_ro;
GRANT SELECT ON dba.sga_promo_equiv TO gerencial_ro;
GRANT SELECT ON dba.sga_valor_inicial TO gerencial_ro;
GRANT SELECT ON dba.sga_tipos_titulo TO gerencial_ro;
GRANT SELECT ON dba.sga_datos_censales TO gerencial_ro;
GRANT SELECT ON dba.sga_cursadas TO gerencial_ro;

GRANT SELECT ON dba.int_arau_log_alu TO gerencial_ro;
GRANT SELECT ON dba.int_arau_nuinscrip TO gerencial_ro;
GRANT SELECT ON dba.sga_alumnos TO gerencial_ro;
GRANT SELECT ON dba.int_arau_reinscrip TO gerencial_ro;
GRANT SELECT ON dba.int_arau_egres TO gerencial_ro;
GRANT SELECT ON dba.sga_titulos_otorg TO gerencial_ro;

GRANT SELECT ON dba.mce_estados TO gerencial_ro;
GRANT SELECT ON dba.gde_encues_persona TO gerencial_ro;
GRANT SELECT ON dba.gde_formulario TO gerencial_ro;
GRANT SELECT ON dba.gde_encues_alcance TO gerencial_ro;
GRANT SELECT ON dba.gde_encuestas TO gerencial_ro;
GRANT SELECT ON dba.sga_cmb_tit_otorg TO gerencial_ro;

-- Doy permiso de ejecución a SPs de soporte
grant execute on sp_int_dw_delete to gerencial_ro;
grant execute on sp_int_dw_i_alu to gerencial_ro;
grant execute on sp_int_dw_i_per to gerencial_ro;

grant execute on sp_int_arau_delete to gerencial_ro;
grant execute on sp_int_arau_actcab to gerencial_ro;
grant execute on sp_int_arau_ingegr to gerencial_ro;
grant execute on sp_int_arau_ingnui to gerencial_ro;
grant execute on sp_int_arau_ingrei to gerencial_ro;

-- Doy permiso de ejecución a SPs de extracción de datos
grant execute on spdw_cubo_alumnos to gerencial_ro;
