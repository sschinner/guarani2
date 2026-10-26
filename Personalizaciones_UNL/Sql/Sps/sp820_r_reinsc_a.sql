CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_r_reinsc_a') THEN
		DROP PROCEDURE sp820_r_reinsc_a;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.02.0
-- 
-- Procedure sp820_r_reinsc_a

--OJO!!! es remplazado por el original sp_r_reinsc_anual q esta actualizado en la version 2.9.0
-- *******************************************************************************
CREATE PROCEDURE "dba".sp820_r_reinsc_a ( p_unidad_academica like sga_datos_censales.unidad_academica,
                                     p_nro_inscripcion like sga_datos_censales.nro_inscripcion,
                                     p_periodo like sga_periodo_insc.periodo_inscripcio )
       RETURNING VARCHAR(5), -- UA		0
	VARCHAR(10), -- nro_inscripcion	1
	VARCHAR(20), -- periodo		2
	DATE, -- fecha relevamiento		3
	VARCHAR(18), -- TE periodo lectivo	4
	INTEGER, -- estado civil		5
	VARCHAR(50), -- calle		6
	VARCHAR(5), -- nro.		7
	VARCHAR(3), -- piso		8
	VARCHAR(5), -- dpto		9
	VARCHAR(3), -- unidad		10
	INTEGER, -- localidad		11
	VARCHAR(100), -- loc. nombre	12	
	VARCHAR(6), -- cp			13
	VARCHAR(50), -- calle procedencia	14
	VARCHAR(5), -- nro.		15
	VARCHAR(3), -- piso		16
	VARCHAR(5), -- dpto.		17
	VARCHAR(3), -- unidad		18
	INTEGER, -- localidad		19
	VARCHAR(100), -- loc. nombre	20	
	VARCHAR(6), -- cp			21
	INTEGER, -- horas sem. trab. alu. Tabla sga_horas_sem_trab	22
	INTEGER, -- sit. laboral alu. Tabla sga_sit_laboral			23
	INTEGER, -- actividad econ. alu. Tabla sga_act_economica		24
	INTEGER, -- sit. laboral padre. Tabla sga_sit_laboral		25
	INTEGER, -- sit. laboral madre. Tabla sga_sit_laboral		26
	varchar(50), -- e_mail	27

	INTEGER, -- sit. laboral pareja. Tabla sga_sit_laboral		28
	varchar(60), -- det. rama act. econ. alu. Tabla u820_rama_actividad	29
	char(1), -- cooperadora	30		
	char(18), -- celular numero	31
	varchar(5), -- celular compania (CTI, PERSO, UNIFO, MOVI, MOVIC, NEXTE, SKYTE, CLARO)	32
	char(1), -- alu_otros est. sup nivel. (1- Terciario; 2- Universitario)				33
	varchar(255), -- alu_otros est. sup univ. En caso de ser de otro pais				34
	varchar(255), -- alu_otros est. sup carrera. En caso de ser de otro pais o no			35
	char(1), -- alu_otros est. sup estado, (1- Abandono; 2- Continua; 3- Termino)			36
 	INTEGER, -- vive_con_conyuge		37
	INTEGER, -- vive_con_padre			38
	INTEGER, -- vive_con_madre			39
	INTEGER, -- vive_con_hijos			40
	INTEGER, -- vive_con_hermanos		41

	char(1), -- padre vive ('S'; 'N')			42
	char(1), -- madre vive ('S'; 'N')			43
	char(1), -- viven padres ('S'; 'N')		44
	INTEGER, -- ult. est. cursados padre		45
	INTEGER, -- ult. est. cursados madre		46
	INTEGER, -- sit. laboral pareja			47
	INTEGER, -- ult. est. cursados pareja		48
	varchar(255), -- red social 1			49
	varchar(255), -- red social 2			50
	varchar(255), -- red social 3			51
	INTEGER, -- pais_universidad_est_sup. En caso de ser otro pais o no				52
	INTEGER, -- instituto_universidad_est_sup. En caso de ser nacional FK a tabla int_arau_instituc	53
	--INTEGER, -- carrera_universidad_est_sup. En caso de ser nacional FK a tabla int_arau_titulos	
	INTEGER, -- alu_otros est. sup. cant. mat.						54
	INTEGER, -- cant_hora_sem_trab_alum							55

	char(1), -- alu_requiere_acces_fisica ('S'; 'N')						56
	INTEGER, -- alu_requerimientos_acces_comunicacional FK a tabla u820req_comunicacion		57
	INTEGER; -- categoria ocupacional							58

DEFINE v_unidad_academica like sga_datos_censales.unidad_academica;
DEFINE v_nro_inscripcion like sga_datos_censales.nro_inscripcion;
DEFINE v_periodo like sga_periodo_insc.periodo_inscripcio;
DEFINE v_fecha_relevamien like sga_datos_censales.fecha_relevamiento;
DEFINE v_te_per_lect like sga_datos_censales.te_per_lect;
DEFINE v_estado_civil like sga_datos_censales.estado_civil;
DEFINE v_calle_per_lect like sga_datos_censales.calle_per_lect;
DEFINE v_numero_per_lect like sga_datos_censales.numero_per_lect;
DEFINE v_piso_per_lect like sga_datos_censales.piso_per_lect;
DEFINE v_dpto_per_lect like sga_datos_censales.dpto_per_lect;
DEFINE v_unidad_per_lect like sga_datos_censales.unidad_per_lect;
DEFINE v_loc_per_lect like sga_datos_censales.loc_per_lect;
DEFINE v_loc_per_lect_nom    LIKE mug_localidades.nombre;
DEFINE v_cp_per_lect LIKE sga_datos_censales.cp_per_lect;
DEFINE v_calle_proc like sga_datos_censales.calle_proc;
DEFINE v_numero_proc like sga_datos_censales.numero_proc;
DEFINE v_piso_proc like sga_datos_censales.piso_proc;
DEFINE v_dpto_proc like sga_datos_censales.dpto_proc;
DEFINE v_unidad_proc like sga_datos_censales.unidad_proc;
DEFINE v_loc_proc like sga_datos_censales.loc_proc;
DEFINE v_loc_proc_nom    LIKE mug_localidades.nombre;
DEFINE v_cp_proc LIKE sga_datos_censales.cp_proc;
DEFINE v_hora_sem_trab_al LIKE sga_datos_censales.hora_sem_trab_alum;
DEFINE v_sit_laboral_alu LIKE sga_datos_censales.sit_laboral_alu;
DEFINE v_act_econom_alum LIKE sga_datos_censales.act_econom_alum;
DEFINE v_det_rama_act_alum LIKE sga_datos_censales.det_rama_act_alum;
DEFINE v_sit_laboral_pad LIKE sga_datos_censales.sit_laboral_padre;
DEFINE v_sit_laboral_mad LIKE sga_datos_censales.sit_laboral_madre;
DEFINE v_sit_laboral_pareja LIKE u820_datos_cen_aux.sit_laboral_pareja;
--DEFINE v_sector_act_econ LIKE u820_datos_cen_aux.sector_act_econ;
DEFINE v_e_mail LIKE sga_datos_censales.e_mail;
DEFINE v_coopera LIKE u820_datos_cen_aux.coopera;

DEFINE v_celular_numero  LIKE sga_datos_cen_aux.celular_numero;
DEFINE v_celular_compania  LIKE sga_datos_cen_aux.celular_compania;

DEFINE v_alu_otestsup_niv  LIKE sga_datos_cen_aux2.alu_otestsup_niv;
DEFINE v_alu_otestsup_uni  LIKE sga_datos_cen_aux2.alu_otestsup_uni;
DEFINE v_alu_otestsup_carr  LIKE sga_datos_cen_aux2.alu_otestsup_carr;
DEFINE v_alu_otestsup_esta  LIKE sga_datos_cen_aux2.alu_otestsup_esta;
DEFINE v_vive_con_conyuge  LIKE sga_datos_cen_aux.vive_con_conyuge;
DEFINE v_vive_con_padre LIKE sga_datos_cen_aux.vive_con_padre;
DEFINE v_vive_con_madre LIKE sga_datos_cen_aux.vive_con_madre;
DEFINE v_vive_con_hijos LIKE sga_datos_cen_aux.vive_con_hijos;
DEFINE v_vive_con_hermanos LIKE sga_datos_cen_aux.vive_con_hermanos;
DEFINE v_padre_vive  LIKE sga_datos_cen_aux.padre_vive;
DEFINE v_madre_vive  LIKE sga_datos_cen_aux.madre_vive;
DEFINE v_viven_padres LIKE sga_datos_censales.viven_padres;

DEFINE v_ult_est_cur_padre LIKE sga_datos_censales.ult_est_cur_padre;
DEFINE v_ult_est_cur_madre LIKE sga_datos_censales.ult_est_cur_madre;

DEFINE v_ult_est_cur_pareja  LIKE u820_datos_cen_aux.ult_est_cur_pareja;
DEFINE v_red_social1  LIKE u820_datos_cen_aux.red_social1;
DEFINE v_red_social2  LIKE u820_datos_cen_aux.red_social2;
DEFINE v_red_social3  LIKE u820_datos_cen_aux.red_social3;
DEFINE v_pais_uni_est_sup  LIKE u820_datos_cen_aux.pais_uni_est_sup;
DEFINE v_inst_uni_est_sup  LIKE u820_datos_cen_aux.inst_uni_est_sup;
DEFINE v_alu_otestsup_cant_mat  LIKE u820_datos_cen_aux.alu_otestsup_cant_mat;
DEFINE v_cant_hora_sem_trab_alum  LIKE u820_datos_cen_aux.cant_hora_sem_trab_alum;
DEFINE v_alu_req_acces_fisica  LIKE u820_datos_cen_aux.alu_req_acces_fisica;
DEFINE v_alu_req_acces_com  LIKE u820_datos_cen_aux.alu_req_acces_com;
DEFINE v_categ_ocup_alum LIKE sga_datos_censales.categ_ocup_alum;

DEFINE v_count integer;
DEFINE vd_fecha like sga_datos_censales.fecha_relevamiento;

let v_unidad_academica = null;
let v_nro_inscripcion = null;
let v_periodo = null;
let v_fecha_relevamien = null;
let v_te_per_lect = null;
let v_estado_civil = null;
let v_calle_per_lect = null;
let v_numero_per_lect = null;
let v_piso_per_lect = null;
let v_dpto_per_lect = null;
let v_unidad_per_lect = null;
let v_loc_per_lect = null;
let v_loc_per_lect_nom = null;
let v_cp_per_lect = null;
let v_calle_proc = null;
let v_numero_proc = null;
let v_piso_proc = null;
let v_dpto_proc = null;
let v_unidad_proc = null;
let v_loc_proc = null;
let v_loc_proc_nom = null;
let v_cp_proc = null;
let v_hora_sem_trab_al = null;
let v_sit_laboral_alu = null;
let v_act_econom_alum = null;
let v_det_rama_act_alum = null;
let v_sit_laboral_pad = null;
let v_sit_laboral_mad = null;
let v_sit_laboral_pareja = null;
-- let v_sector_act_econ = null;
let v_e_mail = null;
let v_coopera = null;

let v_celular_numero  = null;
let v_celular_compania = null;

let v_alu_otestsup_niv = null;
let v_alu_otestsup_uni = null;
let v_alu_otestsup_carr = null;
let v_alu_otestsup_esta = null;
let v_vive_con_conyuge = null;
let v_vive_con_padre = null;
let v_vive_con_madre = null;
let v_vive_con_hijos = null;
let v_vive_con_hermanos = null;
let v_padre_vive = null;
let v_madre_vive = null;
let v_viven_padres = null;

let v_ult_est_cur_padre = null;
let v_ult_est_cur_madre = null;

let v_ult_est_cur_pareja = null;
let v_red_social1 = null;
let v_red_social2 = null;
let v_red_social3 = null;
let v_pais_uni_est_sup = null;
let v_inst_uni_est_sup = null;

let v_alu_otestsup_cant_mat = null;
let v_cant_hora_sem_trab_alum = null;
let v_alu_req_acces_fisica = null;
let v_alu_req_acces_com = null;
let v_categ_ocup_alum = null;

BEGIN

   -- Pone valores iniciales en los campos
   LET v_unidad_academica = p_unidad_academica;
   LET v_nro_inscripcion = p_nro_inscripcion;
   LET v_periodo = p_periodo;
   LET v_fecha_relevamien = CURRENT YEAR TO DAY;
   LET v_te_per_lect = null;
   LET v_estado_civil = 1;
   
   SELECT COUNT(*)
     INTO v_count
     FROM sga_datos_censales
    WHERE unidad_academica = p_unidad_academica
      AND nro_inscripcion = p_nro_inscripcion;

   IF v_count >= 1 THEN
      
      -- averiguo cual es el ultimo.
      SELECT MAX(fecha_relevamiento)
        INTO vd_Fecha
        FROM sga_datos_censales
       WHERE unidad_academica = p_unidad_academica
         AND nro_inscripcion = p_nro_inscripcion;
      
       SELECT dat.unidad_academica,
	dat.nro_inscripcion,
	p_periodo,
	CURRENT YEAR TO DAY,
	dat.te_per_lect,
	dat.estado_civil,
	dat.calle_per_lect,
	dat.numero_per_lect,
	dat.piso_per_lect,
	dat.dpto_per_lect,
	dat.unidad_per_lect,
	dat.loc_per_lect,
	dat.cp_per_lect,
	dat.calle_proc,
	dat.numero_proc,
	dat.piso_proc,
	dat.dpto_proc,
	dat.unidad_proc,
	dat.loc_proc,
	dat.cp_proc,
	dat.hora_sem_trab_alum,
	dat.sit_laboral_alu,
	dat.act_econom_alum,
                dat.det_rama_act_alum,
	dat.sit_laboral_padre,
	dat.sit_laboral_madre,
	dat.e_mail,

	dat_aux.celular_numero,
	dat_aux.celular_compania,

	dat_aux2.alu_otestsup_niv,
	dat_aux2.alu_otestsup_uni,
	dat_aux2.alu_otestsup_carr,
	dat_aux2.alu_otestsup_esta,

	dat_aux.vive_con_conyuge,
	dat_aux.vive_con_padre,
	dat_aux.vive_con_madre,
	dat_aux.vive_con_hijos,
	dat_aux.vive_con_hermanos,

	dat_aux.padre_vive,
	dat_aux.madre_vive,
	dat.viven_padres,
		
	dat.ult_est_cur_padre,
	dat.ult_est_cur_madre,
	dat.categ_ocup_alum

	INTO v_unidad_academica,
		v_nro_inscripcion,
		v_periodo,
		v_fecha_relevamien,
		v_te_per_lect,
		v_estado_civil,
		v_calle_per_lect,
		v_numero_per_lect,
		v_piso_per_lect,
		v_dpto_per_lect,
		v_unidad_per_lect,
		v_loc_per_lect,
		v_cp_per_lect,
		v_calle_proc,
		v_numero_proc,
		v_piso_proc,
		v_dpto_proc,
		v_unidad_proc,
		v_loc_proc,
		v_cp_proc,
		v_hora_sem_trab_al,
		v_sit_laboral_alu,
		v_act_econom_alum,
		v_det_rama_act_alum,
		v_sit_laboral_pad,	
		v_sit_laboral_mad,
		v_e_mail,

		v_celular_numero,
		v_celular_compania,

		v_alu_otestsup_niv,
		v_alu_otestsup_uni,
		v_alu_otestsup_carr,
		v_alu_otestsup_esta,
		v_vive_con_conyuge,
		v_vive_con_padre,
		v_vive_con_madre,
		v_vive_con_hijos,
		v_vive_con_hermanos,
		v_padre_vive,
		v_madre_vive,
		v_viven_padres,

		v_ult_est_cur_padre,
		v_ult_est_cur_madre,
		v_categ_ocup_alum
	
        FROM sga_datos_censales dat
	join sga_datos_cen_aux dat_aux
	on dat.unidad_academica = dat_aux.unidad_academica
		and dat.nro_inscripcion = dat_aux.nro_inscripcion
		and dat.fecha_relevamiento = dat_aux.fecha_relevamiento
	join sga_datos_cen_aux2 dat_aux2
	on dat.unidad_academica = dat_aux2.unidad_academica
		and dat.nro_inscripcion = dat_aux2.nro_inscripcion
		and dat.fecha_relevamiento = dat_aux2.fecha_relevamiento
	left join mdp_celular_comp comp
	on dat_aux.celular_compania = comp.celular_compania
       WHERE dat.unidad_academica   = p_unidad_academica
         AND dat.nro_inscripcion    = p_nro_inscripcion
         AND dat.fecha_relevamiento = vd_Fecha;

        SELECT coopera, 
	sit_laboral_pareja, 
	ult_est_cur_pareja, 
	red_social1, red_social2, red_social3, 
	pais_uni_est_sup, inst_uni_est_sup, alu_otestsup_cant_mat, 
	cant_hora_sem_trab_alum, 
	alu_req_acces_fisica, alu_req_acces_com
	INTO v_coopera,
	v_sit_laboral_pareja,
	v_ult_est_cur_pareja,
	v_red_social1,
	v_red_social2,
	v_red_social3,
	v_pais_uni_est_sup, v_inst_uni_est_sup, v_alu_otestsup_cant_mat, 
	v_cant_hora_sem_trab_alum, 
	v_alu_req_acces_fisica, v_alu_req_acces_com	

        FROM u820_datos_cen_aux u820_d
		left join u820_req_comunicacion u820_r
		on u820_d.alu_req_acces_com = u820_r.req_comunicacion
         WHERE u820_d.unidad_academica   = p_unidad_academica
         AND u820_d.nro_inscripcion    = p_nro_inscripcion
         AND u820_d.fecha_relevamiento = vd_Fecha;


   END IF; 


   
   -- Pone valores en los campos que quedaron en nulo
   IF v_unidad_academica IS NULL THEN
   	let v_unidad_academica = p_unidad_academica;
   END IF;
   IF v_nro_inscripcion IS NULL THEN
   	let v_nro_inscripcion = p_nro_inscripcion;
   END IF;
   IF v_periodo IS NULL THEN
   	let v_periodo = p_periodo;
   END IF;
   IF v_fecha_relevamien IS NULL THEN
   	let v_fecha_relevamien = CURRENT YEAR TO DAY;
   END IF;

   IF v_loc_per_lect IS NULL THEN
      LET v_loc_per_lect_nom    = NULL;
   ELSE
      SELECT mug_localidades.nombre
        INTO v_loc_per_lect_nom
        FROM mug_localidades
       WHERE mug_localidades.localidad = v_loc_per_lect;
   END IF;

   IF v_loc_proc IS NULL THEN
      LET v_loc_proc_nom    = NULL;
   ELSE
      SELECT mug_localidades.nombre
        INTO v_loc_proc_nom
        FROM mug_localidades
       WHERE mug_localidades.localidad = v_loc_proc;
   END IF;

   RETURN v_unidad_academica,	--0
	v_nro_inscripcion,		--1
	v_periodo,			--2
	v_fecha_relevamien,		--3

	v_te_per_lect,		--4
	v_estado_civil,		--5
	v_calle_per_lect,		--6
	v_numero_per_lect,		--7
	v_piso_per_lect,		--8
	v_dpto_per_lect,		--9
	v_unidad_per_lect,		--10
	v_loc_per_lect,		--11

	v_loc_per_lect_nom,		--12
	v_cp_per_lect,		--13
	v_calle_proc,		--14
	v_numero_proc,		--15
	v_piso_proc,		--16
	v_dpto_proc,		--17
	v_unidad_proc,		--18
	v_loc_proc,		--19
	v_loc_proc_nom,		--20
	v_cp_proc,		--21
	v_hora_sem_trab_al,		--22
	v_sit_laboral_alu,		--23
	v_act_econom_alum,		--24
	v_sit_laboral_pad,		--25
	v_sit_laboral_mad,		--26
	v_e_mail,			--27
	v_sit_laboral_pareja,		--28

	v_det_rama_act_alum,               --29
	v_coopera,		--30

	v_celular_numero,
	v_celular_compania,

	v_alu_otestsup_niv,
	v_alu_otestsup_uni,
	v_alu_otestsup_carr,
	v_alu_otestsup_esta,
	v_vive_con_conyuge,
	v_vive_con_padre,
	v_vive_con_madre,
	v_vive_con_hijos,
	v_vive_con_hermanos,
	v_padre_vive,
	v_madre_vive,
	v_viven_padres,

	v_ult_est_cur_padre,
	v_ult_est_cur_madre,

	v_sit_laboral_pareja,
	v_ult_est_cur_pareja,
	v_red_social1,
	v_red_social2,
	v_red_social3,
	v_pais_uni_est_sup, v_inst_uni_est_sup, v_alu_otestsup_cant_mat, 
	v_cant_hora_sem_trab_alum, 
	v_alu_req_acces_fisica, v_alu_req_acces_com, v_categ_ocup_alum;

                   
END;
END PROCEDURE;


-- execute PROCEDURE "dba".sp820_r_reinsc_a ( 'FBCB', 'FBCB-6119',2012);

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_r_reinsc_a 
-- *****************************************************************************
revoke execute on "dba".sp820_r_reinsc_a from public;
grant execute on "dba".sp820_r_reinsc_a to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_r_reinsc_a to internet; -- Rol de usuario de Internet