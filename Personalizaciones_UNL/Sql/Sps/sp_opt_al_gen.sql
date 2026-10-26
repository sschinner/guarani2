CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_opt_al_gen') THEN
		DROP PROCEDURE sp_opt_al_gen;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.11.0
-- Ultima version de modificacion: 2.02.0, 2.6.0
-- Procedure sp_opt_al_gen
--
-- Retorna las optativas aprobadas y regularizadas de un alumno, y a la genérica
--  que esta asignada.
--
-- Retorna:   * Optativa (Código de Materia)
--	 * Tipo Aprabación (Aprobada('A') - Regularizada('R'))
--	* Código Materia Genérica a la cual esta asignada.
-- 	* Plan en que la aprobó/regularizó
-- 	* version en que la aprobó/regularizo
-- U820 Se obtienen las regularizadas que aún no hayan vencido
-- *****************************************************************************
-- DROP PROCEDURE sp_opt_al_gen;
CREATE PROCEDURE "dba".sp_opt_al_gen( pUnidadAcademica LIKE sga_alumnos.unidad_academica, pCarrera LIKE sga_alumnos.carrera, pLegajo LIKE sga_alumnos.legajo )
   RETURNING varchar(5),char(1),varchar(5), varchar(5), varchar(5);

DEFINE ls_materia_opt LIKE sga_materias.materia;
DEFINE ls_result char(1);
DEFINE ls_generica LIKE sga_materias.materia;
DEFINE ls_plan LIKE sga_planes.plan;
DEFINE ls_version_actual LIKE sga_planes.version_actual;
DEFINE ls_plan_apro LIKE sga_planes.plan;
DEFINE ls_version_apro LIKE sga_planes.version_actual;

BEGIN

begin
   on exception in (-206)
    -- Tabla no existe continuo el proceso
   end exception with resume;
   DROP TABLE tmp_mat_opt;
   DROP TABLE tmp_mat_opt2;
end;

 -- Tabla temporal TMP_MAT_OPT.
CREATE TEMP TABLE  TMP_MAT_OPT
    (materia varchar(5), resultado char(1), plan varchar(5), version varchar(5)) WITH NO LOG;

CREATE TEMP TABLE  TMP_MAT_OPT2
    (materia varchar(5), resultado char(1), plan varchar(5), version varchar(5)) WITH NO LOG;

--Obtener el plan y la versión actual del alumno
EXECUTE PROCEDURE sp_plan_de_alumno(punidadAcademica, pCarrera, pLegajo, Current year to second)  INTO	ls_plan,ls_version_actual;

-- Obtener las materias optativas aprobadas en la carrera (no importa en que plan o version).
-- Solo trae materias que esten en el plan-version actual del alumno.
INSERT INTO TMP_MAT_OPT2
SELECT vha.materia, vha.resultado, atm.plan, atm.version
	FROM vw_hist_academica as vha,
		sga_atrib_mat_plan as atm
	WHERE 	vha.unidad_academica = pUnidadAcademica
		AND vha.carrera = pCarrera
		AND vha.legajo = pLegajo
		AND atm.unidad_academica = vha.unidad_academica
		AND atm.carrera = vha.carrera
		AND atm.plan = ls_plan         -- AND vha.plan = atm.plan
		AND atm.version = ls_version_actual   -- AND vha.version = atm.version
		AND atm.materia = vha.materia
		AND atm.tipo_materia <> 'G'
		AND vha.resultado = 'A'
-- y que la materia sea una optativa de una generica
-- perteneciente al plan del alumno
		AND vha.materia IN (SELECT materia_optativa
				    FROM sga_mat_genericas as smg,
				        sga_atrib_mat_plan as samp
				    WHERE smg.unidad_academica = samp.unidad_academica
					and smg.materia_generica = samp.materia
					and samp.unidad_academica = pUnidadAcademica
					and samp.carrera = pCarrera
					and samp.plan = ls_plan
					and samp.version = ls_version_actual
					and samp.tipo_materia ='G');

		-- AND  atm.tipo_materia = 'O'   -- Se saco porque puede estar con el tipo N - Normal

-- Obtener las materias optativas regularizadas.
INSERT INTO TMP_MAT_OPT
SELECT cur.materia, 'R', atm.plan, atm.version
	FROM sga_cursadas as cur ,
		sga_atrib_mat_plan as atm
	WHERE cur.unidad_academica = pUnidadAcademica
		AND cur.carrera = pCarrera
		AND cur.legajo  = pLegajo
		AND atm.unidad_academica = cur.unidad_academica
		AND atm.carrera = cur.carrera
		AND atm.plan    = ls_plan              -- cur.plan
		AND atm.version = ls_version_actual    -- cur.version
		AND atm.materia = cur.materia
		AND atm.tipo_materia <> 'G'
		AND cur.resultado = 'A'
		AND cur.materia NOT IN (SELECT materia FROM TMP_MAT_OPT2)
			-- y que la materia sea una optativa de una generica
			-- perteneciente al plan del alumno
		AND cur.materia IN (SELECT materia_optativa
				FROM sga_mat_genericas as smg,
					sga_atrib_mat_plan as samp
				WHERE smg.unidad_academica = samp.unidad_academica
					and smg.materia_generica = samp.materia
					and samp.unidad_academica = pUnidadAcademica
					and samp.carrera = pCarrera
					and samp.plan = ls_plan
					and samp.version = ls_version_actual
					and samp.tipo_materia ='G')
		-- U820 Saco las regularizadas que aún no hayan vencido
		AND cur.fin_vigencia_regul > TODAY;
		-- U820 Saco las regularizadas que aún no hayan vencido
		-- AND atm.tipo_materia = 'O'

INSERT INTO TMP_MAT_OPT
	SELECT * FROM tmp_mat_opt2;


-- Recorrer las optativas
FOREACH SELECT materia, resultado, plan, version
	INTO ls_materia_opt, ls_result, ls_plan_apro, ls_version_apro
	FROM TMP_MAT_OPT

	-- Inicializar el código de genérica en nulo.
	LET ls_generica  = null;

	-- Verificar si el alumno tiene la optativa en alguna genérica en especial.

	SELECT 	materia_generica
	INTO	ls_generica
	FROM 	sga_opt_gen_alumno
	WHERE 	unidad_academica = pUnidadAcademica
		AND	carrera = pCarrera
		AND	legajo = pLegajo
		AND materia_optativa = ls_materia_opt
		AND materia_generica in (select distinct materia 
					FROM  sga_atrib_mat_plan
					WHERE unidad_academica = pUnidadAcademica
						AND carrera = pCarrera
						AND plan    = ls_plan_apro
						AND version = ls_version_apro
						AND tipo_materia = 'G');

	RETURN ls_materia_opt,ls_result,ls_generica, ls_plan_apro, ls_version_apro WITH RESUME;

    -- Si no tiene genérica especificada, entonces tomo por default la del Plan.
	IF ls_generica IS NULL THEN

		-- si existe en la orientacion del alumno busco la optativa ahi.
		-- Solo si el alumno eligió orientación.
		FOREACH SELECT materia_generica
			INTO ls_generica
			FROM sga_opt_gen_orie as sogo,
				sga_orient_alumno as soa
			WHERE sogo.unidad_academica = soa.unidad_academica  AND
				sogo.carrera = soa.carrera  AND
				sogo.plan = soa.plan  AND
				sogo.titulo = soa.titulo AND
				sogo.orientacion = soa.orientacion AND
				sogo.version = ls_version_apro AND
				soa.unidad_academica = pUnidadAcademica AND
				soa.carrera = pCarrera AND
				soa.legajo = pLegajo AND
				materia_optativa = ls_materia_opt

			RETURN ls_materia_opt,ls_result,ls_generica, ls_plan_apro, ls_version_apro WITH RESUME;

		END FOREACH;

	ELSE
		CONTINUE FOREACH;
	END IF;

	IF ls_generica IS NULL THEN
	            -- Default de la optativa en una genérica dentro de las orientaciones del Plan.
	            -- Orientacion distinta de la orientación básica (0)
		FOREACH SELECT materia_generica
			INTO ls_generica
			FROM sga_titulos_plan as tp,
				sga_opt_gen_orie as sogo,
				sga_titulos as st
			WHERE tp.unidad_academica = pUnidadAcademica AND
				tp.carrera = pCarrera AND
				tp.plan = ls_plan AND
			--	st.nivel = 'GRADO' AND
				sogo.unidad_academica = tp.unidad_academica AND
				sogo.carrera = tp.carrera  AND
				sogo.plan= tp.plan AND
				sogo.titulo  = tp.titulo AND
				sogo.orientacion <> '0' AND
				sogo.version = ls_version_apro AND
				materia_optativa = ls_materia_opt and
				tp.unidad_academica=st.unidad_academica and
				tp.titulo = st.titulo

			RETURN ls_materia_opt,ls_result,ls_generica, ls_plan_apro, ls_version_apro WITH RESUME;

		END FOREACH;

	ELSE
		CONTINUE FOREACH;
	END IF;

	-- si tampoco esta en la orientacion busco la default
	IF ls_generica IS NULL THEN
		FOREACH  SELECT materia_generica
			INTO  ls_generica
			FROM  sga_opt_generica
			WHERE unidad_academica = pUnidadAcademica
				AND carrera = pCarrera
				AND plan    = ls_plan_apro
				AND version = ls_version_apro
				AND materia_optativa = ls_materia_opt

			RETURN ls_materia_opt,ls_result,ls_generica, ls_plan_apro, ls_version_apro WITH RESUME;
		END FOREACH;

	ELSE
		CONTINUE FOREACH;
	END IF;

--	RETURN ls_materia_opt,ls_result,ls_generica, ls_plan_apro, ls_version_apro WITH RESUME;

END FOREACH;

begin
   on exception in (-206)
    -- Tabla no existe continuo el proceso
   end exception with resume;
   DROP TABLE tmp_mat_opt;
   DROP TABLE tmp_mat_opt2;
end;

END;

END PROCEDURE;
-- +++++++++++++++ FIN PROCEDURE sp_opt_al_gen ++++++++++++++++++++++++++
revoke execute on "dba".sp_opt_al_gen from public;

grant execute on "dba".sp_opt_al_gen to guarani; -- Rol de usuarios de Gestión
grant execute on "dba".sp_opt_al_gen to internet; -- Usuario de internet
