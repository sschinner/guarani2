CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_reporte_req_cum') THEN
		DROP PROCEDURE sp_reporte_req_cum;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Versión 2.05.0
-- p_req_vencidos_no varchar(1),  (V vencidos / N no vencidos / T todos
-- p_req_obligatorios ( O obligatorios , L obligatorios para generacion de legajo, N no obligatorios
-- *******************************************************************************

-- execute procedure  sp_reporte_req_cum('2008','TODOS','IC','T','O','00000')
create procedure "dba".sp_reporte_req_cum (p_periodoinscripc like sga_carrera_aspira.periodo_inscripcio, p_carrera like sga_carrera_aspira.carrera, p_situacion_aspir like sga_carrera_aspira.situacion_asp, p_req_vencidos_no varchar(1), p_req_obligatorios varchar(1), p_requisito varchar(5))
returning
	varchar(5), -- unidad_academica
	varchar(10), -- nro_inscripcion
	varchar(30), -- apellido
	varchar(30), -- nombres
	varchar(3), -- tipo de documento
	varchar(15), -- nro de documento
	integer, -- requisitos adeudados
	varchar(5), -- carrera
	varchar(255), -- nombre carrera
	varchar(15); -- legajo

-- Variables para el manejo de excepciones
DEFINE SQLErr             integer;
DEFINE ISAMError          integer;
DEFINE errorInfo          varchar(76);

-- variables para el return
define vc_ua varchar(5);
define vc_nro_inscripcion varchar(10);
define vc_apellido varchar(30);
define vc_nombres varchar(30);
define vc_tipo_doc varchar(3);
define vi_nro_documento varchar(15);
define vc_carrera varchar(5);
define vc_nombre_carrera varchar(255);
define vi_req_adeudados integer;
define vc_legajo varchar(15);

Define vi_req_venc_ua integer;
define vi_req_no_venc_ua integer;
Define vi_req_venc_leg integer;
define vi_req_no_venc_leg integer;

Define vi_req_venc_noobli integer;
define vi_req_no_ve_noobl integer;

Define vc_oblig_ua varchar(1);
Define vc_oblig_car varchar(1);
Define vc_oblig_ua_leg varchar(1);
Define vc_oblig_car_leg varchar(1);

Define vd_cierre_req date;   
Define vd_cierre_req_leg date;
Define vd_prorroga date;
Define vd_cierre_excep date;

-- Si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo
	RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;


begin

-- de acuerdo al filtro de personas a procesar
foreach select sca.unidad_academica, sca.nro_inscripcion, apellido, nombres, desc_abreviada, nro_documento, legajo, sca.carrera, sc.nombre
	into vc_ua, vc_nro_inscripcion, vc_apellido, vc_nombres, vc_tipo_doc, vi_nro_documento, vc_legajo, vc_carrera, vc_nombre_carrera
	from sga_carrera_aspira sca, 
		sga_personas sp,
		sga_carreras sc, 
		mdp_tipo_documento mtd,
		outer(sga_alumnos sa)
	where sca.periodo_inscripcio = p_periodoinscripc
		and (p_carrera='TODOS' or  sca.carrera = p_carrera)
		and sca.situacion_asp = p_situacion_aspir
		and sca.unidad_academica = sp.unidad_academica
		and sca.nro_inscripcion = sp.nro_inscripcion
		and sca.unidad_academica = sc.unidad_academica
		and sca.carrera = sc.carrera
		and sca.unidad_academica = sa.unidad_academica
		and sca.nro_inscripcion = sa.nro_inscripcion
		and sca.carrera = sa.carrera
		and sp.tipo_documento = mtd.tipo_documento

	let vi_req_adeudados = 0;
	let vi_req_venc_ua = 0;
	let vi_req_no_venc_ua = 0;
	let vi_req_venc_leg = 0;
	let vi_req_no_venc_leg = 0;
	let vi_req_no_ve_noobl = 0;
	let vi_req_venc_noobli = 0;
	let vc_oblig_ua = null;
	let vc_oblig_car = null;
	let vc_oblig_ua_leg = null;
	let vc_oblig_car_leg = null;

	-- cuento los requisitos obligatorios que no cumplió
	foreach SELECT sru.obligatoriedad as oblig_ua,   
			sru.es_oblig_legajo as oblig_legajo_ua,   
			srca.obligatoriedad as oblig_car,   
			srca.es_oblig_legajo as oblig_legajo_car,   
			spi.fecha_cierre_req,   
			spi.fec_cierre_req_leg,   
			src.f_prorroga_hasta as excepcion,
			sfer.fecha_cierre_req
		into vc_oblig_ua, vc_oblig_ua_leg, vc_oblig_car, vc_oblig_car_leg, vd_cierre_req, vd_cierre_req_leg, vd_prorroga, vd_cierre_excep
		FROM sga_carrera_aspira sca,   
			sga_periodo_insc spi,   
			sga_req_cumplidos src,   
			outer(sga_requisitos_car srca),   
			outer(sga_requisitos_ua sru),
			outer(sga_fec_excep_req sfer)
		WHERE spi.periodo_inscripcio = sca.periodo_inscripcio  and  
			sca.unidad_academica = src.unidad_academica  and  
			sca.nro_inscripcion = src.nro_inscripcion  AND  
			sca.carrera = src.carrera  AND  

			src.unidad_academica = sru.unidad_academica  and  
			src.requisito = sru.requisito  AND  

			src.unidad_academica = srca.unidad_academica  and  
			src.carrera = srca.carrera  AND  
			src.requisito = srca.requisito  AND  

			src.fecha_presentacion is null and
			(src.exceptuado is null or src.exceptuado <>'S') and

			sfer.periodo_inscripcio = sca.periodo_inscripcio and
			sfer.requisito = src.requisito and

			 sca.unidad_academica = vc_ua  AND  
			 sca.nro_inscripcion = vc_nro_inscripcion  AND  
			 sca.periodo_inscripcio = p_periodoinscripc  AND  
			 sca.carrera = vc_carrera and
			(src.requisito = p_requisito or p_requisito = '00000')

			if (vd_prorroga is not null and vd_prorroga >= today) then
				-- si está prorrogado y no esta vencido
				if (vc_oblig_ua_leg = 'S' or vc_oblig_car_leg = 'S' ) then
					let vi_req_no_venc_leg = vi_req_no_venc_leg + 1;
					let vi_req_no_venc_ua = vi_req_no_venc_ua + 1;
				else
					let vi_req_no_venc_ua = vi_req_no_venc_ua + 1;
				end if
				continue foreach;
			elif (vd_prorroga is not null and vd_prorroga < today) then
				-- si esta prorrogado y vencido
				if (vc_oblig_ua_leg = 'S' or vc_oblig_car_leg = 'S' ) then
					-- obligatorio legajo
					let vi_req_venc_leg = vi_req_venc_leg + 1;
					let vi_req_venc_ua = vi_req_venc_ua + 1;
				else
					-- obligatorio ua
					let vi_req_venc_ua = vi_req_venc_ua + 1;
				end if
				continue foreach;
			end if;

			-- no está prorrogado
			if (vc_oblig_ua_leg = 'S' or vc_oblig_car_leg = 'S' ) then
				-- si es obligatorio para generar legajo en la ua o la carrera
				if vd_cierre_excep is not null then
					let vd_cierre_req_leg = vd_cierre_excep;
				end if;
				if vd_cierre_req_leg >= today then
					-- si no esta vencido
					let vi_req_no_venc_leg = vi_req_no_venc_leg + 1;
				else
					-- si está vencido
					let vi_req_venc_leg = vi_req_venc_leg + 1;
				end if
			end if;

			if (vc_oblig_ua = 'S' or vc_oblig_car = 'S' ) then
				-- tiene que ser requisito de la ua o carrera pero no para legajo
				if vd_cierre_excep is not null then
					let vd_cierre_req = vd_cierre_excep;
				end if;
				if vd_cierre_req >= today then
					-- si no esta vencido
					let vi_req_no_venc_ua = vi_req_no_venc_ua + 1;
				else
					-- si está vencido
					let vi_req_venc_ua = vi_req_venc_ua + 1;
				end if
			end if;

			-- requisito no obligatorio pero obligado al alumno
			if vc_oblig_ua = 'N' or vc_oblig_car ='N' then
				-- tiene que ser requisito no obligatorio
				if vd_cierre_excep is not null then
					let vd_cierre_req = vd_cierre_excep;
				end if;
				if vd_cierre_req >= today then
					-- si no esta vencido
					let vi_req_no_ve_noobl = vi_req_no_ve_noobl + 1;
				else
					-- si está vencido
					let vi_req_venc_noobli = vi_req_venc_noobli + 1;
				end if
			end if;
			
		end foreach;

	if p_req_obligatorios = 'O' then
		-- obligatorios para la ua que no cumplió
		if vi_req_venc_ua + vi_req_no_venc_ua > 0 then
			if p_req_vencidos_no = 'V' then
				-- vencidos
				let vi_req_adeudados = vi_req_venc_ua + vi_req_venc_noobli;
			elif p_req_vencidos_no = 'N' then
				-- no vencidos
				let vi_req_adeudados = vi_req_no_venc_ua + vi_req_no_ve_noobl;
			else 
				-- todos
				let vi_req_adeudados = vi_req_venc_ua + vi_req_no_venc_ua + vi_req_venc_noobli + vi_req_no_ve_noobl;
			end if;

		end if;

	else 
	-- U820
		if p_req_obligatorios = 'N' then
			if p_req_vencidos_no = 'V' then
				-- vencidos
				let vi_req_adeudados = vi_req_venc_ua + vi_req_venc_noobli;
			elif p_req_vencidos_no = 'N' then
				-- no vencidos
				let vi_req_adeudados = vi_req_no_venc_ua + vi_req_no_ve_noobl;
			else 
				-- todos
				let vi_req_adeudados = vi_req_venc_ua + vi_req_no_venc_ua + vi_req_venc_noobli + vi_req_no_ve_noobl;
			end if;
		else 

			if vi_req_venc_leg + vi_req_no_venc_leg > 0 then
				-- requisitos obligatorios para generación de legajo que no cumplió
				if p_req_vencidos_no = 'V' then
					-- vencidos
					let vi_req_adeudados = vi_req_venc_leg;
				elif p_req_vencidos_no = 'N' then
					-- no vencidos
					let vi_req_adeudados = vi_req_no_venc_leg;
				else 
					-- todos
					let vi_req_adeudados = vi_req_venc_leg + vi_req_no_venc_leg;
				end if;

			end if;
		end if;
	end if

	if vi_req_adeudados > 0 then
		return vc_ua, vc_nro_inscripcion, vc_apellido, vc_nombres, vc_tipo_doc, vi_nro_documento, vi_req_adeudados, vc_carrera, vc_nombre_carrera, vc_legajo with resume;
	end if;


end foreach

end;

end procedure;
-- *******************************************************************************
-- *****************************************************************************

-- Permisos del procedimiento "dba".sp_reporte_req_cum

-- *****************************************************************************

revoke execute on "dba".sp_reporte_req_cum from public;
grant execute on "dba".sp_reporte_req_cum to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_reporte_req_cum to internet; -- Rol de usuario de Internet

