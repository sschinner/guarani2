CREATE PROCEDURE verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_ctrlcierperinsc') THEN
		DROP PROCEDURE sp_ctrlcierperinsc;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE verifica_objeto();

DROP PROCEDURE verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 1.7.0
-- Versión de Ultima modificación 2.05.0, 2.6.0, 2.6.1, 2.9.0, 2.9.2
-- Procedure sp_ctrlcierperinsc
--
-- Control de cierre de período de inscripción.
--
-- Retorna solo los aspirantes y alumnos condicionales con motivo de rechazo,
-- 	o con motivo por el cual no pudieron ser rechazados.
-- 	varchar(5) Carrera
--	varchar(255) nombre carrera
--	integer     1 -> Nro. Inscripción / 2 -> Legajo
--	varchar(15) Legajo o Nro. de inscrpición
--	integer     1 -> Procesado sin problemas / 2 -> Alumno Condicional No rechazado por poseer Hist. Acad. Válida
--	varchar(255) Descripción motivo
-- 	varchar(30)  apellido
-- 	varchar(30)  nombres
-- 	varchar(20)  tipo y nro de documento
-- *****************************************************************************
-- DROP PROCEDURE sp_ctrlcierperinsc;
CREATE PROCEDURE sp_ctrlcierperinsc ( 
	punidad_academica LIKE sga_unidades_acad.unidad_academica,
	pperiodo_inscrip LIKE sga_periodo_insc.periodo_inscripcio,
	pOperacion LIKE acc_operaciones.operacion
	)
  RETURNING VARCHAR(5), VARCHAR(255), INTEGER, VARCHAR(15), INTEGER, VARCHAR(255), VARCHAR(30), VARCHAR(30), VARCHAR(20);

-- pOperacion =  Es para indicar si el sp es llamado desde la operacion de cierre de periodo de inscripcion o del reporte de aspirantes a rechazar

-- Variables para el manejo de excepciones
DEFINE SQLErr             integer;
DEFINE ISAMError          integer;
DEFINE errorInfo          varchar(76);

-- Variables utilizados para el manejo de cada inscripto.
DEFINE vOperacionCierre  LIKE acc_operaciones.operacion;
DEFINE ls_Carrera          LIKE sga_carrera_aspira.carrera;
DEFINE lseq_Carrera          LIKE sga_carrera_aspira.carrera;
DEFINE ls_Nro_inscrip      LIKE sga_carrera_aspira.nro_inscripcion;
DEFINE ls_situacion_asp    LIKE sga_carrera_aspira.situacion_asp;
DEFINE ls_legajo           LIKE sga_alumnos.legajo;
DEFINE lseq_legajo           LIKE sga_alumnos.legajo;
DEFINE li_es_val_histAcad  INTEGER;
DEFINE li_no_cumplio 	   INTEGER;
DEFINE ls_nom_carrera	   LIKE sga_carreras.nombre;
DEFINE ls_apellido, ls_nombres	  varchar(30);
DEFINE ls_tipo_nro_doc	  varchar(20);
DEFINE ls_baja_insc	 char(1);

DEFINE vcMensaje           VARCHAR(255);
DEFINE viModificacion      INTEGER;
DEFINE vdFechaMod	LIKE sga_cambioscalidad.fecha;
DEFINE vi_equivalencia	LIKE sga_mov_equiv.equivalencia;
DEFINE vdfecha LIKE sga_eq_equiv_equiv.fecha;
DEFINE vplan LIKE  sga_eq_equiv_equiv.plan;
DEFINE vversion LIKE   sga_eq_equiv_equiv.version;
DEFINE vorigen LIKE  sga_eq_equiv_equiv.origen;
DEFINE vestado LIKE  sga_eq_equiv_equiv.estado;

-- Variables utilizadas para el manejo de info del período de inscripción.
DEFINE ld_fec_cierr_leg	   LIKE sga_periodo_insc.fec_cierre_req_leg;
DEFINE ld_fec_cierr_req    LIKE sga_periodo_insc.fecha_cierre_req;
DEFINE vc_prorroga_venc    char(1);
DEFINE vc_obligatorio_leg  char(1);
DEFINE vc_requisito        LIKE sga_requisitos.requisito;
DEFINE vd_prorroga_hasta   LIKE sga_req_cumplidos.f_prorroga_hasta;
DEFINE vc_tiene_prorroga   varchar(1);
DEFINE vc_rechazo_aspiran varchar(40);

DEFINE vc_rechazar varchar(1);


-- Si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo
	RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;

BEGIN

 BEGIN
	on exception in (-206)
	-- tabla no existe
	end exception with resume;
	drop table tmp_req_no_cumplid;
	drop  table tmp_no_adeudan_req;
 END;

 LET vOperacionCierre = 'mat00018';  -- Cierre de Periodo de Inscripcion a carreras
 LET ls_legajo 	      = NULL;
 LET li_es_val_histAcad = NULL;
 LET vcMensaje = NULL;
 LET vi_equivalencia = NULL;
 LET vdfecha = NULL;
 LET vplan = NULL;
 LET vversion = NULL;
 LET vorigen = NULL;
 LET vestado = NULL;
LET vc_rechazar = 'N';

 -- Parametro usado para indicar si se dan de baja las inscripciones a examenes y cursadas
 IF pOperacion = vOperacionCierre THEN  
   -- Solo se dan de baja las inscripciones en la operacion de Control de cierre de Periodo de inscripcion
   LET ls_baja_insc = 'S';
 ELSE	 
   LET ls_baja_insc = 'N';
 END IF;
 
-- creo una tabla para guardar a los que no adeudan requisitos
create temp table tmp_no_adeudan_req (
	unidad_academica varchar(5),
	carrera varchar(5),
	nro_inscripcion varchar(10),
	situacion_asp varchar(2));

-- inserto en la tabla aquellos que no tienen requisitos para cumplir
-- o que están exceptuados de todos
INSERT INTO tmp_no_adeudan_req
SELECT sca.unidad_academica,
	sca.carrera,
	sca.nro_inscripcion,
	sca.situacion_asp
FROM sga_carrera_aspira sca,
	sga_periodo_insc spi,
	sga_carreras sc
WHERE spi.periodo_inscripcio = sca.periodo_inscripcio  and
	sca.unidad_academica = sc.unidad_academica and
	sca.carrera = sc.carrera and
	sca.situacion_asp in ('AC','IC') and
	NOT EXISTS (SELECT '' FROM sga_req_cumplidos src
	             WHERE sca.unidad_academica = src.unidad_academica  
	             AND  sca.nro_inscripcion = src.nro_inscripcion  
	             AND  sca.carrera = src.carrera 
	             AND (src.exceptuado is null or src.exceptuado <>'S') 
	            ) AND
	sca.unidad_academica = punidad_academica  AND
	sca.periodo_inscripcio = pperiodo_inscrip;

-- agrego los requisitos exceptuados
-- puesto que un alumno puede estar exceptuado de todos
INSERT INTO tmp_no_adeudan_req
SELECT sca.unidad_academica,
	sca.carrera,
	sca.nro_inscripcion,
	sca.situacion_asp
FROM sga_carrera_aspira sca,
	sga_periodo_insc spi,
	sga_carreras sc,
	sga_req_cumplidos src
WHERE spi.periodo_inscripcio = sca.periodo_inscripcio  AND
	sca.unidad_academica = src.unidad_academica  AND
	sca.nro_inscripcion = src.nro_inscripcion  AND
	sca.carrera = src.carrera  AND
	sca.unidad_academica = sc.unidad_academica AND
	sca.carrera = sc.carrera AND
	src.exceptuado = 'S' AND
	sca.situacion_asp in ('AC','IC') AND
	 sca.unidad_academica = punidad_academica  AND
	 sca.periodo_inscripcio = pperiodo_inscrip
	-- UNL820: solo interesan los requisitos obligatorios
	AND src.obligatoriedad = 'S';
	-- UNL820: solo interesan los requisitos obligatorios


-- inserto en una temporaria a todos
-- los que estan en sga_req_cumplidos y que no estén exceptuados
-- el campo fecha_testeo es la fecha en la cual debe/ió cumplirse el requisito
SELECT sca.unidad_academica,
	sca.carrera,
	sca.nro_inscripcion,
	sca.situacion_asp,
	sc.nombre,
	src.requisito,
	srca.es_oblig_legajo oblig_legajo_car,
	sru.es_oblig_legajo oblig_legajo_ua,
	src.fecha_presentacion,
	spi.fecha_cierre_req,
	spi.fec_cierre_req_leg,
	src.f_prorroga_hasta as prorroga,
	sfer.fecha_cierre_req as exepcion,
	spi.fecha_cierre_req as fecha_testeo -- por defecto la fecha de cierre de requisitos de legajo
FROM sga_carrera_aspira as sca,
	sga_periodo_insc as spi,
	sga_carreras as sc,
	sga_req_cumplidos as src,
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

	sfer.periodo_inscripcio = sca.periodo_inscripcio and
	sfer.requisito = src.requisito and

	sca.unidad_academica = sc.unidad_academica and
	sca.carrera = sc.carrera and

	(src.exceptuado is null OR src.exceptuado <>'S') and
	sca.situacion_asp in ('AC','IC') and
	sca.unidad_academica = punidad_academica  AND
	sca.periodo_inscripcio = pperiodo_inscrip

	-- UNL820: solo interesan los requisitos obligatorios
	AND src.obligatoriedad = 'S'
	-- UNL820: solo interesan los requisitos obligatorios

INTO TEMP tmp_req_no_cumplid WITH NO LOG;

-- AQUI DEBERÍAMOS AGREGAR COMO NO CUMPLIDOS, LOS REQUISITOS DEFINIDOS COMO OBLIGATORIOS EN EL PERÍODO DE INSCRIPCIÓN Y QUE NO ESTAN AGREGADOS AL ALUMNO (RELACIONADOS EN LA TABLA DE REQ_CUMPLIDOS)



IF DBINFO("sqlca.sqlerrd2") > 0 THEN
	-- proceso las fechas

	-- si es obligatorio para legajo va la fecha de legajo
	UPDATE tmp_req_no_cumplid set fecha_testeo = fec_cierre_req_leg 
	 WHERE (oblig_legajo_car is not null and oblig_legajo_car ='S')
	   OR (oblig_legajo_ua is not null and oblig_legajo_ua ='S');

	-- si hay exepciones, las considero
	UPDATE tmp_req_no_cumplid set fecha_testeo = exepcion where exepcion IS NOT NULL;

	-- si hay prorroga tambien
	UPDATE tmp_req_no_cumplid set fecha_testeo = prorroga where prorroga IS NOT NULL;

	-- *************************************************************************************************************
	-- U820: Considero fecha particular para el requisito UNL03. Posteriormente, si no esta cumplido, se verificará si tiene alguno de los supletorios.
	-- *************************************************************************************************************
	UPDATE tmp_req_no_cumplid set fecha_testeo = fec_cierre_req_leg where requisito = 'UNL03';
	-- *************************************************************************************************************


	-- paso a la de no adeudan todos los requisitos cumplidos
	INSERT INTO tmp_no_adeudan_req
	SELECT unidad_academica, carrera, nro_inscripcion, situacion_asp
	  FROM tmp_req_no_cumplid
	 WHERE fecha_presentacion <= fecha_testeo 
	   AND fecha_presentacion IS NOT NULL;

	-- borro los que se presentaron en término
	DELETE FROM tmp_req_no_cumplid WHERE fecha_presentacion<=fecha_testeo AND fecha_presentacion IS NOT NULL;

	
	-- *************************************************************************************************************
	-- U820: borro los que presentaron UNL03 sin importar la fecha
	-- *************************************************************************************************************
	DELETE FROM tmp_req_no_cumplid WHERE fecha_presentacion IS NOT NULL AND requisito = 'UNL03';
	-- *************************************************************************************************************

	-- borro de la tabla de no adeudan a los que están en la de adeudados
	DELETE FROM tmp_no_adeudan_req
	  WHERE EXISTS (SELECT '' FROM tmp_req_no_cumplid as RNC
	                 WHERE tmp_no_adeudan_req.unidad_academica = RNC.unidad_academica
	                   AND tmp_no_adeudan_req.CARRERA = RNC.carrera
	                   AND tmp_no_adeudan_req.nro_inscripcion = RNC.nro_inscripcion);

	-- borro los que todavía no se vencieron
	delete from tmp_req_no_cumplid where fecha_testeo>=today;

	-- en este punto los que están en tmp_no_adeudan_req
	-- son todos los que no adeudan requisitos y que no tienen legajo.

	-- los que quedan en tmp_req_no_cumplid son los que hay que rechazar
	FOREACH SELECT distinct carrera, tmp.nro_inscripcion, situacion_asp, nombre, apellido, nombres, mtd.desc_abreviada || '  ' || sp.nro_documento
	    INTO ls_Carrera, ls_Nro_inscrip, ls_situacion_asp, ls_nom_carrera, ls_apellido, ls_nombres, ls_tipo_nro_doc
	    FROM tmp_req_no_cumplid tmp, sga_personas sp, mdp_tipo_documento mtd
	   WHERE tmp.unidad_academica = sp.unidad_academica
	     AND tmp.nro_inscripcion = sp.nro_inscripcion
	     AND sp.tipo_documento = mtd.tipo_documento

		LET vc_rechazar = 'N';
		--*************************************************************
		-- si el aspirante es AC
		--*************************************************************
		IF ls_situacion_asp = 'AC' then
			-- si no presento ningun requisito
			IF (select count(*)
				from tmp_req_no_cumplid
				where unidad_academica=punidad_academica
				  and carrera = ls_Carrera
				  and nro_inscripcion = ls_nro_inscrip
				  and fecha_presentacion is not null)=0 then
				
				IF pOperacion = vOperacionCierre THEN
				   -- Solo cambio estado si es en la operacion de cierre de periodo de inscripcion
				   UPDATE sga_carrera_aspira
				      SET situacion_asp = 'RF'
				    WHERE unidad_academica = punidad_academica
				      AND carrera = ls_Carrera
				      AND nro_inscripcion = ls_Nro_inscrip
				      AND periodo_inscripcio = pperiodo_inscrip;

				   -- esto está de mas, puesto que no presentó ninguno
				   EXECUTE PROCEDURE sp_req_cump_a_hist(punidad_academica, ls_Carrera, NULL, ls_Nro_inscrip);
				END IF;
				
				-- Aspirante por pasar la fecha de cierre de requisitos para la generación de legajo.
				IF pOperacion = vOperacionCierre THEN
				   LET vcMensaje = 'Aspirante Rechazado. Ya venció la fecha de cierre de requisitos obligatorios para la generación de legajo';
				ELSE
				   LET vcMensaje = 'Ya venció la fecha de cierre de requisitos obligatorios para la generación de legajo';
				END IF;
				RETURN ls_Carrera, ls_nom_carrera, 1, ls_Nro_inscrip, 1, vcMensaje, ls_apellido, ls_nombres, ls_tipo_nro_doc WITH RESUME;

			--*************************************************************
			-- si los presentó fuera de fecha
			ELSE
				IF pOperacion = vOperacionCierre THEN
					UPDATE sga_carrera_aspira
					  SET situacion_asp = 'RF'
					WHERE unidad_academica = punidad_academica
						AND carrera = ls_Carrera
						AND nro_inscripcion = ls_Nro_inscrip
						AND periodo_inscripcio = pperiodo_inscrip;

					-- Paso los requisitos cumplidos a la tabla de historicos, y elimino los mismos de la tabla de cumplidos
					EXECUTE PROCEDURE sp_req_cump_a_hist(punidad_academica, ls_Carrera, NULL, ls_Nro_inscrip);
				END IF;
				
				-- Aspirante por pasar la fecha de cierre de requisitos para la generación de legajo.
				IF pOperacion = vOperacionCierre THEN
				   LET vcMensaje = 'Aspirante Rechazado. Requisito obligatorio para la generación de legajo presentado fuera de fecha.';
				ELSE
				   LET vcMensaje = 'Requisito obligatorio para la generación de legajo presentado fuera de fecha.';
				END IF;	
				RETURN ls_Carrera,ls_nom_carrera,1,ls_Nro_inscrip,1,vcMensaje, ls_apellido, ls_nombres, ls_tipo_nro_doc WITH RESUME;

			END IF;
		ELSE
			--*************************************************************
			-- si el aspirante es IC (Inscripto Condicional)
			--*************************************************************
			--*************************************************************
			-- si tiene historia academica valida lo dejo como está
			-- Obtener el legajo del inscripto a carrera.
			--*************************************************************
			-- *************************************************************************************************************
			-- U820: se personaliza para no rechazar al alumno condicional UNL. Aquel que al 30/04 (fecha cierre req. p/legajo) presentó algún requisito supletorio al de título.
			-- *************************************************************************************************************

			-- Si lo estoy rechazando por un requisito obligatorio que no es el de titulo, entonces lo rechazo.
			IF EXISTS (SELECT '*' FROM tmp_req_no_cumplid 
					WHERE nro_inscripcion = ls_Nro_inscrip
					AND carrera = ls_Carrera
					AND requisito NOT IN ('UNL03', 'UNL07', 'UNL15', 'UNL16', 'UNL17', 'UNL18', 'UNL19', 'POS01', 'POS02', 'POS08', 'UNL20', 'UNL21', 'UNL22')
					) THEN

				LET vc_rechazar = 'S';
			END IF;


			IF NOT EXISTS (SELECT '*' FROM sga_req_cumplidos 
					WHERE nro_inscripcion = ls_Nro_inscrip
					AND carrera = ls_Carrera
					AND requisito IN ('UNL03', 'UNL07', 'UNL15', 'UNL16', 'UNL17', 'UNL18', 'UNL19', 'POS01', 'POS02','POS08', 'UNL20', 'UNL21', 'UNL22')
					AND (fecha_presentacion is not null 
						OR  exceptuado = 'S')
					) THEN
				LET vc_rechazar = 'S';
			END IF;

			IF vc_rechazar = 'S' THEN

				SELECT legajo INTO ls_legajo  FROM sga_alumnos  WHERE unidad_academica = punidad_academica AND carrera = ls_Carrera AND nro_inscripcion = ls_Nro_inscrip;

				-- *************************************************************************************************************
				-- U820: INVALIDAR HA DE EQUIVALENCIAS DE LA CARRERA EN CUESTION
				-- EN CASO DE QUE TENGA OTRO TIPO DE HA, NO SE INVALIDARÁ Y QUEDARÁ A CRITERIO DEL OPERADOR
				-- sp_mov_equiv; sp_equiv_eq_equiv: determinar todas la equivalencia y borrarlas una a una.
				-- *************************************************************************************************************

				-- OBTENER TODAS LA EQUIVALENCIAS DEL ALUMNO E INVALIDARLAS
				FOREACH SELECT equivalencia, fecha, plan, version, estado INTO vi_equivalencia, vdfecha, vplan, vversion, vestado
					from sga_equiv_otorgada
					where carrera = ls_Carrera
						and legajo = ls_legajo
						and estado <> 'I'
					
					EXECUTE PROCEDURE sp_mov_equiv (vi_equivalencia, 2, 'Ord. C.S.: 6/15','Ordenanza CS 6/2015 - Ingreso Año 2017');
			
				 --OBTENER TODAS LAS EQUIV_EQUIV DEL ALUMNO E INVALIDARLAS
					IF EXISTS (SELECT '*' FROM sga_equiv_equiv where equivalencia = vi_equivalencia) THEN
						FOREACH SELECT carrera, legajo INTO lseq_Carrera, lseq_legajo FROM sga_equiv_equiv where equivalencia = vi_equivalencia
						
						EXECUTE PROCEDURE sp_equiv_eq_equiv (punidad_academica, lseq_Carrera, lseq_legajo, vi_equivalencia, 2, 'Ord. C.S.: 6/15','Ordenanza CS 6/2015 - Ingreso Año 2017');
						END FOREACH;	
					END IF;

				END FOREACH;



				-- *************************************************************************************************************
				-- U820: INVALIDAR HA DE EQUIVALENCIAS DE LA CARRERA EN CUESTION
				-- sp_mov_equiv; sp_equiv_eq_equiv: determinar todas la equivalencia y borrarlas una a una.
				-- *************************************************************************************************************

			
				-- Obtener la validéz de la historia académica del aspirante con legajo.
				EXECUTE PROCEDURE sp_es_val_histAcad(punidad_academica,ls_Carrera,ls_legajo) INTO li_es_val_histAcad;
		    
			
				IF li_es_val_histAcad = 1 THEN
					-- Aspirante por pasar la fecha de cierre de requisitos para la generación de legajo.
					IF pOperacion = vOperacionCierre THEN
						LET vcMensaje = 'Alumno Condicional No Rechazado por poseer Historia Académica Válida.';
					ELSE
						LET vcMensaje = 'Alumno Condicional que posee Historia Académica válida.';
					END IF;	
				
					RETURN ls_Carrera,ls_nom_carrera,2,ls_legajo,2,vcMensaje, ls_apellido, ls_nombres, ls_tipo_nro_doc WITH RESUME;
					CONTINUE FOREACH;
				END IF;
			

				--**************************************************************
				-- control de inscripciones activas
				--**************************************************************
				EXECUTE PROCEDURE sp_tiene_insc_act(punidad_academica,ls_Carrera,ls_legajo, ls_baja_insc) INTO li_es_val_histAcad, vcMensaje;
				-- li_es_val_histAcad: 1 = si el alumno puede ser rechazado / -1 = si tiene actividad no borrable

				-- *****************************************************************************************			
				-- U820 Se personaliza para no tener en cuenta inscripciones aunque esten las actas generadas
				-- *****************************************************************************************

				--IF li_es_val_histAcad = -1 THEN
				--	IF pOperacion = vOperacionCierre THEN
				--		RETURN ls_Carrera,ls_nom_carrera,2,ls_legajo,2,vcMensaje, ls_apellido, ls_nombres, ls_tipo_nro_doc WITH RESUME;
				--	END IF;	
				--	CONTINUE FOREACH;
				--END IF;

				-- *****************************************************************************************			
				-- U820 Se personaliza para no tener en cuenta inscripciones aunque esten las actas generadas
				-- *****************************************************************************************			

				IF pOperacion = vOperacionCierre THEN  
					--*************************************************************
					-- si no
					-- Se pasa la situación de aspirante a 'RR'(Alu. Rechazado en el período Insc. al no cumplir req. Oblig.).
					--*************************************************************

					-- *****************************************************************************************
					-- U820: se personaliza para no rechazar al alumno condicional UNL. Aquel que al 30/04 (fecha cierre req. p/legajo) presentó algún requisito supletorio al de título.
					-- *****************************************************************************************

					--IF NOT EXISTS (SELECT '*' FROM sga_req_cumplidos 
					--		WHERE nro_inscripcion = ls_Nro_inscrip
					--		AND carrera = ls_Carrera
					--		AND requisito IN ('UNL03', 'UNL07', 'UNL15', 'UNL16', 'UNL17', 'UNL18', 'UNL19', 'POS01', 'POS02')
					--		AND (fecha_presentacion is not null 
					--			OR  exceptuado = 'S')
					--		) THEN

					UPDATE sga_carrera_aspira
					SET situacion_asp = 'RR'
					WHERE unidad_academica = punidad_academica
					  AND carrera = ls_Carrera
					  AND nro_inscripcion = ls_Nro_inscrip
					  AND periodo_inscripcio = pperiodo_inscrip;
					--ELSE
					--	CONTINUE FOREACH;

					--END IF;
					-- *************************************************************************************************************
					-- U820: se personaliza para no rechazar al alumno condicional UNL. Aquel que al 30/04 presentó algún requisito supletorio al de título.
					-- *************************************************************************************************************
				END IF;

				-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				-- Cambiar la calidad del alumno a pasivo.
				-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				IF pOperacion = vOperacionCierre THEN
				   LET vcMensaje = 'Alumno Condicional Rechazado. Venció la fecha de cierre de requisitos obligatorios.';
				ELSE
				   LET vcMensaje = 'Venció la fecha de cierre de requisitos obligatorios.';
				END IF;

				IF pOperacion = vOperacionCierre THEN

					-- *****************************************************************************************
					-- U820: se personaliza para no rechazar al alumno condicional UNL. Aquel que al 30/04 (fecha cierre req. p/legajo) presentó algún requisito supletorio al de título.
					-- *****************************************************************************************

				--IF NOT EXISTS (SELECT '*' FROM sga_req_cumplidos 
				--		WHERE nro_inscripcion = ls_Nro_inscrip
				--		AND carrera = ls_Carrera
				--		AND requisito IN ('UNL03', 'UNL07', 'UNL15', 'UNL16', 'UNL17', 'UNL18', 'UNL19', 'POS01', 'POS02')
				--		AND (fecha_presentacion is not null 
				--			OR  exceptuado = 'S')
				--		) THEN
					UPDATE sga_alumnos
					  SET calidad = 'P'
					WHERE unidad_academica = punidad_academica
					  AND carrera = ls_Carrera
					  AND legajo = ls_legajo;


					-- Busco el ultimo registro insertado, ya que el UPDATE de calidad del Alumno
					-- inserta un registro en la tabla sga_cambios_calidad
					LET viModificacion = NULL;
	
					FOREACH SELECT modificacion, fecha
						INTO viModificacion, vdFechaMod
						FROM sga_cambioscalidad
						WHERE unidad_academica = punidad_academica
						  AND carrera = ls_Carrera
						  AND legajo = ls_legajo
						ORDER BY fecha  DESC

						EXIT FOREACH;
					END FOREACH;

					-- El registro ya fue insertado, asi que actualizo el motivo y las observaciones
					UPDATE sga_cambioscalidad
						SET motivo = 5,   --  Pasivo por falta de requisitos...
						    observaciones = vcMensaje
						WHERE unidad_academica = punidad_academica
						  AND carrera = ls_Carrera
						  AND legajo = ls_legajo
						  AND modificacion = viModificacion;
	
					-- Paso los requisitos cumplidos a la tabla de historicos, y elimino los mismos de la tabla de cumplidos
					EXECUTE PROCEDURE sp_req_cump_a_hist(punidad_academica, ls_Carrera, ls_legajo, NULL);

					-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				--END IF;
				-- *************************************************************************************************************
				-- U820: se personaliza para no rechazar al alumno condicional UNL. Aquel que al 30/04 presentó algún requisito supletorio al de título.
				-- *************************************************************************************************************


				END IF; -- pOperacion = vOperacionCierre

				-- Aspirante por pasar la fecha de cierre de requisitos para la generación de legajo.
				RETURN ls_Carrera,ls_nom_carrera,2,ls_legajo,1,vcMensaje, ls_apellido, ls_nombres, ls_tipo_nro_doc WITH RESUME;
			ELSE
				CONTINUE FOREACH;
			END IF;
		END IF; -- situacion asp

	END FOREACH;  -- todos los que tenian requisitos no cumplidos

END IF;  -- DBINFO()

IF (select count(*) from tmp_no_adeudan_req) > 0 THEN

	-- aca empiezo a procesar los que no adeudan requisitos.
	-- los AC van a control, los IC deben pasar a IL
	-- primero controlo que el año académico en el que estoy parado
	-- sea posterior al del periodo de inscripcion
	IF (SELECT saa.fecha_fin FROM sga_periodo_insc spi, sga_anio_academico saa
		WHERE spi.periodo_inscripcio=pperiodo_inscrip AND spi.anio_academico = saa.anio_academico
		) < TODAY THEN

		-- busco el parametro del sistema para ver que hago
		EXECUTE PROCEDURE sp_param_sistema('rechazar_aspirante_al_terminar_anio_acad') into vc_rechazo_aspiran;

		IF vc_rechazo_aspiran = 'S' THEN
			-- proceso los aspirantes (AC)

			FOREACH SELECT distinct tnar.carrera, tnar.nro_inscripcion, nombre, apellido, nombres, mtd.desc_abreviada || '  ' || sp.nro_documento
				into ls_Carrera, ls_Nro_inscrip, ls_nom_carrera, ls_apellido, ls_nombres, ls_tipo_nro_doc
				from tmp_no_adeudan_req tnar,  sga_personas sp, mdp_tipo_documento mtd, sga_carreras sc
				where tnar.unidad_academica = sp.unidad_academica
					and tnar.nro_inscripcion = sp.nro_inscripcion
					and sp.tipo_documento = mtd.tipo_documento
					and situacion_asp='AC'
					and tnar.unidad_academica = sc.unidad_academica
					and tnar.carrera = sc.carrera
				IF pOperacion = vOperacionCierre THEN
					UPDATE sga_carrera_aspira
					   SET situacion_asp = 'RF'
					 WHERE unidad_academica = punidad_academica
					   AND carrera = ls_Carrera
					   AND nro_inscripcion = ls_Nro_inscrip
					   AND periodo_inscripcio = pperiodo_inscrip;

					-- Paso los requisitos cumplidos a la tabla de historicos, y elimino los mismos de la tabla de cumplidos
					EXECUTE PROCEDURE sp_req_cump_a_hist(punidad_academica, ls_Carrera, NULL, ls_Nro_inscrip);
				
				END IF; --pOperacion = vOperacionCierre
				
				-- Aspirante por pasar la fecha de cierre de requisitos para la generación de legajo.
				IF pOperacion = vOperacionCierre THEN
				    LET vcMensaje = 'Aspirante Rechazado. Vencimiento del Año Académico';
				ELSE
				    LET vcMensaje = 'Vencimiento del Año Académico';
				END IF;
				RETURN ls_Carrera,ls_nom_carrera,1,ls_Nro_inscrip,1,vcMensaje, ls_apellido, ls_nombres, ls_tipo_nro_doc WITH RESUME;

			END FOREACH; -- a los que no se les genero legajo

		END IF; -- rechazo los aspirantes
	END IF; -- ya paso el año

	IF pOperacion = vOperacionCierre THEN
		-- ahora paso los IC a IL
		FOREACH select distinct tnar.carrera, tnar.nro_inscripcion, nombre, apellido, nombres, mtd.desc_abreviada || '  ' || sp.nro_documento
			into ls_Carrera, ls_Nro_inscrip, ls_nom_carrera, ls_apellido, ls_nombres, ls_tipo_nro_doc
			FROM tmp_no_adeudan_req tnar,  sga_personas sp, mdp_tipo_documento mtd, sga_carreras sc
			WHERE tnar.unidad_academica = sp.unidad_academica
			  and tnar.nro_inscripcion = sp.nro_inscripcion
			  and sp.tipo_documento = mtd.tipo_documento
			  and situacion_asp='IC'
			  and tnar.unidad_academica=sc.unidad_academica
			  and tnar.carrera = sc.carrera

			UPDATE sga_carrera_aspira
			SET situacion_asp = 'IL'
			WHERE unidad_academica = punidad_academica
			  AND carrera = ls_Carrera
			  AND nro_inscripcion = ls_Nro_inscrip
			  AND periodo_inscripcio = pperiodo_inscrip;

			-- Ingresante condicional aceptado. Se lo pasa a estado "Ingresante con legajo".
			LET vcMensaje = 'Alumno Condicional pasado a Alumno con legajo.';
			RETURN ls_Carrera,ls_nom_carrera,1,ls_Nro_inscrip,1,vcMensaje, ls_apellido, ls_nombres, ls_tipo_nro_doc WITH RESUME;

		END FOREACH; -- a los que no se les genero legajo
	END IF; -- pOperacion = vOperacionCierre

END IF;  -- tmp_no_adeudan_req

	BEGIN
		on exception in (-206)
		end exception with resume;
		DROP TABLE tmp_req_no_cumplid;
		DROP TABLE tmp_no_adeudan_req;
	END;
END;

END PROCEDURE;
-- ********************** Fin del procedure sp_ctrlcierperinsc **********************

GRANT EXECUTE ON  sp_ctrlcierperinsc TO public;

