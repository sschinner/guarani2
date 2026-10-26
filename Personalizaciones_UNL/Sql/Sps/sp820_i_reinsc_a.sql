CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_i_reinsc_a') THEN
		DROP PROCEDURE sp820_i_reinsc_a;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------
-- ATENCION!!
-- PRIMERO VERIFICAR QUE EXISTAN LOS CORRESPONDIENTES REGISTROS EN LAS SIGUIENTES TABLAS:

-- begin;

-- select unidad_academica, nro_inscripcion, max(fecha_relevamiento) as fecha
-- from sga_datos_censales 
-- group by 1, 2
-- into temp aux_censales;

-- select count(*) from aux_censales

-- -----------------------------------
-- sga_datos_cen_aux
-- -----------------------------------
-- insert into sga_datos_cen_aux  (unidad_academica, nro_inscripcion, fecha_relevamiento)
-- select unidad_academica, nro_inscripcion, fecha
-- from aux_censales
-- where unidad_academica||nro_inscripcion||fecha not in 
-- (select unidad_academica||nro_inscripcion||fecha_relevamiento from sga_datos_cen_aux );

-- -----------------------------------
-- sga_datos_cen_aux2
-- -----------------------------------
-- insert into sga_datos_cen_aux2  (unidad_academica, nro_inscripcion, fecha_relevamiento)
-- select unidad_academica, nro_inscripcion, fecha
-- from aux_censales
-- where unidad_academica||nro_inscripcion||fecha not in 
-- (select unidad_academica||nro_inscripcion||fecha_relevamiento from sga_datos_cen_aux2 );

-- -----------------------------------
-- u820_datos_cen_aux
-- -----------------------------------
-- insert into u820_datos_cen_aux (unidad_academica, nro_inscripcion, fecha_relevamiento)
-- select unidad_academica, nro_inscripcion, fecha
-- from aux_censales
-- where unidad_academica||nro_inscripcion||fecha not in 
-- (select unidad_academica||nro_inscripcion||fecha_relevamiento from u820_datos_cen_aux);

-- commit;
-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------


-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.00.0
-- PROCEDURE: sp_i_reinsc_a
CREATE PROCEDURE "dba".sp820_i_reinsc_a (
pUnidad_academica like sga_datos_censales.unidad_academica,		-- UA
pNro_inscripcion like sga_datos_censales.nro_inscripcion,		-- Nro inscripcion
pPperiodo like sga_periodo_insc.periodo_inscripcio,				-- Periodo inscripcion
pFecha_relevamien like sga_datos_censales.fecha_relevamiento,	-- Fecha relevamiento
pTe_per_lect like sga_datos_censales.te_per_lect,				-- Telefono periodo lectivo
pEstado_civil like sga_datos_censales.estado_civil,				-- Estado civil
pCalle_per_lect like sga_datos_censales.calle_per_lect,			-- Calle periodo lectivo
pNumero_per_lect like sga_datos_censales.numero_per_lect,		-- Numero periodo lectivo
pPiso_per_lect like sga_datos_censales.piso_per_lect,			-- Piso periodo lectivo
pDpto_per_lect like sga_datos_censales.dpto_per_lect,			-- Departamento periodo lectivo
pUnidad_per_lect like sga_datos_censales.unidad_per_lect,		-- Unidad periodo lectivo
pLoc_per_lect like sga_datos_censales.loc_per_lect,				-- Localidad periodo lectivo
pCp_per_lect LIKE sga_datos_censales.cp_per_lect,				-- CP periodo lectivo
pCalle_proc like sga_datos_censales.calle_proc,					-- Calle procedencia
pNumero_proc like sga_datos_censales.numero_proc,				-- Numero procedencia
pPiso_proc like sga_datos_censales.piso_proc,					-- Piso procedencia
pDpto_proc like sga_datos_censales.dpto_proc,					-- Departamento procedencia
pUnidad_proc like sga_datos_censales.unidad_proc,				-- Unidad procedencia
pLoc_proc like sga_datos_censales.loc_proc,						-- Localidad procedencia
pCp_proc LIKE sga_datos_censales.cp_proc,						-- CP procedencia
--pHora_sem_trab_al LIKE sga_datos_censales.hora_sem_trab_alum,	-- horas sem. trab. alu. Tabla sga_horas_sem_trab
pSit_laboral_alu LIKE sga_datos_censales.sit_laboral_alu,		-- sit. laboral alu. Tabla sga_sit_laboral
pAct_econom_alum LIKE sga_datos_censales.act_econom_alum,		-- actividad econ. alu. Tabla sga_act_economica
pe_mail LIKE sga_datos_censales.e_mail,							-- e_mail
pSit_laboral_padre LIKE sga_datos_censales.sit_laboral_padre,	-- sit. laboral padre. Tabla sga_sit_laboral
pSit_laboral_madre LIKE sga_datos_censales.sit_laboral_madre,	-- sit. laboral madre. Tabla sga_sit_laboral
pSit_laboral_pareja LIKE u820_datos_cen_aux.sit_laboral_pareja,	-- sit. laboral pareja. Tabla sga_sit_laboral
pdet_rama_act_alum LIKE sga_datos_censales.det_rama_act_alum,	-- det. rama act. econ. alu. Tabla u820_rama_actividad
pcoopera LIKE u820_datos_cen_aux.coopera,						-- cooperadora

-- CAMPOS NUEVOS
pcelular_numero LIKE sga_datos_cen_aux.celular_numero, 			-- celular numero
pcelular_compania LIKE sga_datos_cen_aux.celular_compania, 		-- celular compania (CTI, PERSO, UNIFO, MOVI, MOVIC, NEXTE, SKYTE, CLARO)
palu_otestsup_niv LIKE sga_datos_cen_aux2.alu_otestsup_niv, 	-- alu_otros est. sup nivel. (1- Terciario; 2- Universitario)
palu_otestsup_uni LIKE sga_datos_cen_aux2.alu_otestsup_uni, 	-- alu_otros est. sup univ. En caso de ser de otro pais
palu_otestsup_carr LIKE sga_datos_cen_aux2.alu_otestsup_carr, 	-- alu_otros est. sup carrera. En caso de ser de otro pais o no
palu_otestsup_esta LIKE sga_datos_cen_aux2.alu_otestsup_esta, 	-- alu_otros est. sup estado, (1- Abandono; 2- Continua; 3- Termino)
pvive_con_conyuge LIKE sga_datos_cen_aux.vive_con_conyuge, 		-- vive_con_conyuge
pvive_con_padre LIKE sga_datos_cen_aux.vive_con_padre, 			-- vive_con_padre
pvive_con_madre LIKE sga_datos_cen_aux.vive_con_madre,			-- vive_con_madre
pvive_con_hijos LIKE sga_datos_cen_aux.vive_con_hijos,			-- vive_con_hijos
pvive_con_hermanos LIKE sga_datos_cen_aux.vive_con_hermanos,	-- vive_con_hermanos
ppadre_vive LIKE sga_datos_cen_aux.padre_vive,					-- padre vive ('S'; 'N')
pmadre_vive LIKE sga_datos_cen_aux.madre_vive,					-- madre vive ('S'; 'N')
pviven_padres LIKE sga_datos_censales.viven_padres,				-- viven padres ('S'; 'N')
pult_est_cur_padre LIKE sga_datos_censales.ult_est_cur_padre, 	-- ult. est. cursados padre
pult_est_cur_madre LIKE sga_datos_censales.ult_est_cur_madre, 	-- ult. est. cursados madre
pult_est_cur_pareja LIKE u820_datos_cen_aux.ult_est_cur_pareja,	-- ult. est. cursados pareja
pred_social1 LIKE u820_datos_cen_aux.red_social1, 				-- red social 1
pred_social2 LIKE u820_datos_cen_aux.red_social2, 				-- red social 2
pred_social3 LIKE u820_datos_cen_aux.red_social3, 				-- red social 3
ppais_uni_est_sup LIKE u820_datos_cen_aux.pais_uni_est_sup,		-- pais_universidad_est_sup. En caso de ser otro pais o no
pinst_uni_est_sup LIKE u820_datos_cen_aux.inst_uni_est_sup,		-- instituto_universidad_est_sup. En caso de ser nacional FK a tabla int_arau_instituc
--pcarr_uni_est_sup LIKE u820_datos_cen_aux.carr_uni_est_sup,		-- carrera_universidad_est_sup. En caso de ser nacional FK a tabla int_arau_titulos
palu_otestsup_cant_mat LIKE u820_datos_cen_aux.alu_otestsup_cant_mat,		-- alu_otros est. sup. cant. mat.
pcant_hora_sem_trab_alum LIKE u820_datos_cen_aux.cant_hora_sem_trab_alum,	-- cant_hora_sem_trab_alum
palu_req_acces_fisica LIKE u820_datos_cen_aux.alu_req_acces_fisica,			-- alu_requiere_acces_fisica ('S'; 'N')
palu_req_acces_com LIKE u820_datos_cen_aux.alu_req_acces_com,	-- alu_requerimientos_acces_comunicacional FK a tabla u820req_comunicacion
pcateg_ocup_alum LIKE sga_datos_censales.categ_ocup_alum 		-- categoria ocupacional
)
       RETURNING smallint,      -- 0- OK, -1- Error, 1-Observaciones
                 varchar(255);  -- mensaje


DEFINE iStatus                smallint;
DEFINE vcMsg                  varchar(255);

--variables para el manejo de excepciones
DEFINE sql_err                integer;
DEFINE isam_err               integer;
DEFINE error_info             varchar(76);
DEFINE v_user_error           varchar(10);

-- variables locales.
DEFINE vcNivel      VARCHAR(20);
DEFINE vd_Fecha     DATE;
DEFINE vc_Rtn       CHAR(1);

-- blk de excepciones
 ON EXCEPTION SET sql_err, isam_err, error_info                                        
   LET iStatus = sql_err ;
   LET vcMsg = isam_err ;
    RETURN iStatus, vcMsg;
END EXCEPTION; 


BEGIN

  -- inicializaciones.
  LET iStatus = 0 ;
  LET vcMsg = 'Ok';

  -- Verifico si la persona tiene algun Dato Censal cargado.
  EXECUTE PROCEDURE sp_dato_cen_valido ( pUnidad_academica, pNro_inscripcion ) INTO vc_Rtn;
  
  IF vc_Rtn = "I" THEN
     EXECUTE PROCEDURE sp_crea_datocensal( pUnidad_academica, pNro_inscripcion );
  END IF;
  
  -- busco la fecha de relevamiento a actualizar.
  SELECT MAX(fecha_relevamiento)
    INTO vd_Fecha
    FROM sga_datos_censales
   WHERE unidad_academica = pUnidad_academica
     AND nro_inscripcion  = pNro_inscripcion;
  
  -- Update de los datos censales con las actualizaciones de la operacion.
  UPDATE sga_datos_censales
     SET fecha_actualiz = pfecha_relevamien,
	te_per_lect = pTe_per_lect ,
	estado_civil = pEstado_civil,
	calle_per_lect = pCalle_per_lect,
	numero_per_lect = pNumero_per_lect,
	piso_per_lect = pPiso_per_lect,
	dpto_per_lect = pDpto_per_lect,
	unidad_per_lect = pUnidad_per_lect,
	loc_per_lect = pLoc_per_lect,
	cp_per_lect = pCp_per_lect ,
	calle_proc = pCalle_proc ,
	numero_proc = pNumero_proc ,
	piso_proc = pPiso_proc ,
	dpto_proc = pDpto_proc ,
	unidad_proc = pUnidad_proc ,
	loc_proc = pLoc_proc ,
	cp_proc = pCp_proc ,
	hora_sem_trab_alum = case when pcant_hora_sem_trab_alum > 0 and pcant_hora_sem_trab_alum < 21 then 1 
						when pcant_hora_sem_trab_alum > 20 and pcant_hora_sem_trab_alum < 36 then 2 
						when pcant_hora_sem_trab_alum > 35 then 3
						else 4 end,
	sit_laboral_alu = pSit_laboral_alu ,
	act_econom_alum = pAct_econom_alum,
	det_rama_act_alum = pdet_rama_act_alum,
	sit_laboral_padre = pSit_laboral_padre ,
	sit_laboral_madre = pSit_laboral_madre,
	e_mail = pe_mail,
	-- NUEVOS CAMPOS
	viven_padres = pviven_padres,
	ult_est_cur_padre = pult_est_cur_padre,
	ult_est_cur_madre = pult_est_cur_madre,
	categ_ocup_alum = pcateg_ocup_alum
   WHERE unidad_academica   = pUnidad_academica
     AND nro_inscripcion    = pNro_inscripcion
     AND fecha_relevamiento = vd_Fecha;

-- Hace Update;
  UPDATE sga_datos_cen_aux
     -- DATOS NUEVOS
	 SET celular_numero = pcelular_numero,
	 celular_compania = pcelular_compania,
	 vive_con_conyuge = pvive_con_conyuge,
	 vive_con_padre = pvive_con_padre,
	 vive_con_madre = pvive_con_madre,
	 vive_con_hijos = pvive_con_hijos,
	 vive_con_hermanos = pvive_con_hermanos,
	 padre_vive = ppadre_vive,
	 madre_vive = pmadre_vive
   WHERE unidad_academica   = pUnidad_academica
     AND nro_inscripcion    = pNro_inscripcion
     AND fecha_relevamiento = vd_Fecha; 

-- Hace Update;
  UPDATE sga_datos_cen_aux2
     -- DATOS NUEVOS
	 SET alu_otestsup_niv = palu_otestsup_niv,
	 alu_otestsup_uni = palu_otestsup_uni,
	 alu_otestsup_carr = palu_otestsup_carr,
	 alu_otestsup_esta = palu_otestsup_esta
   WHERE unidad_academica   = pUnidad_academica
     AND nro_inscripcion    = pNro_inscripcion
     AND fecha_relevamiento = vd_Fecha; 
	 
--Hace Update;
  UPDATE u820_datos_cen_aux
     SET coopera =  pcoopera,
	 --DATOS NUEVOS
	 sit_laboral_pareja = psit_laboral_pareja,
	 ult_est_cur_pareja = pult_est_cur_pareja,
	 red_social1 = pred_social1,
	 red_social2 = pred_social2,
	 red_social3 = pred_social3,
	 pais_uni_est_sup = ppais_uni_est_sup,
	 inst_uni_est_sup = pinst_uni_est_sup,
	 --carr_uni_est_sup = pcarr_uni_est_sup,
	 alu_otestsup_cant_mat = palu_otestsup_cant_mat,
	 cant_hora_sem_trab_alum = pcant_hora_sem_trab_alum,
	 alu_req_acces_fisica = palu_req_acces_fisica,
	 alu_req_acces_com = palu_req_acces_com	 
   WHERE unidad_academica   = pUnidad_academica
     AND nro_inscripcion    = pNro_inscripcion
     AND fecha_relevamiento = vd_Fecha; 
     

   RETURN iStatus, vcMsg;
   
END;
END PROCEDURE;
-- *******************************************************************************
-- execute PROCEDURE sp820_i_reinsc_a('FICH','3262',2006,'03/10/2006','111111111111','4', null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, 2, null, 1, 1, 1, 1, 1);

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_i_reinsc_a 
-- *****************************************************************************
revoke execute on "dba".sp820_i_reinsc_a from public;
grant execute on "dba".sp820_i_reinsc_a to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_i_reinsc_a to internet; -- Rol de usuario de Internet