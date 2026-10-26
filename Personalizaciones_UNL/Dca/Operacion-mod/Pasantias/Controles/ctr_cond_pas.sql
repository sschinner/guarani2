-- **************************************************************************
-- Control: ctr_cond_pas
-- Version 2.0
--
-- Controla que el alumno tenga los requisitos pedidos por la pasantía
-- 
-- Devuelve: integer                1 OK, -1 Error
--                  varchar(255)       Mensaje de Error
-- **************************************************************************
--  DROP PROCEDURE ctr_cond_pas;
CREATE PROCEDURE ctr_cond_pas (
	pUnidadAcademica		LIKE sga_unidades_acad.unidad_academica,
	pNroInscripcion		LIKE sga_personas.nro_inscripcion,
	pLegajo			LIKE sga_alumnos.legajo,
	pCarrera			LIKE sga_carreras.carrera,
	pPlan			LIKE sga_planes.plan,
	pIdPasantia		LIKE u820_pasantias.id_pasantia)
	RETURNING	SMALLINT,      -- status 1-OK/ -1 NO cumple condiciones
			VARCHAR(255);    -- MENSAJE. OK si cumple condiciones


-- var's para el manejo de excepciones
DEFINE sql_err	INTEGER;
DEFINE isam_err     INTEGER;
DEFINE error_info   VARCHAR(76);

-- var's locales
DEFINE vVersion			LIKE sga_planes.version_actual;
DEFINE vCierreParcial		LIKE sga_param_sistema.valor;
DEFINE vMensaje, vMensajeError	VARCHAR(255);
DEFINE vMateria			LIKE sga_materias.materia;
DEFINE vCondicion			CHAR(1);
DEFINE vResultado		VARCHAR(2);
DEFINE vMateriaRegParcial		CHAR(1);

DEFINE vCnt_materias		INTEGER;
DEFINE vPor_carrera		INTEGER;

DEFINE vCnt_max_materias		INTEGER;
DEFINE vPor_max_carrera		INTEGER;

DEFINE vCnt_materias_apro		INTEGER;
DEFINE vCnt_materias_plan		INTEGER;


-- blk de excepciones
ON EXCEPTION SET sql_err, isam_err, error_info                                        
	RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;      


BEGIN
-- por default el codigo de retorno es OK
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

BEGIN
	ON EXCEPTION IN (-206)
		-- Tabla no existe continuo el proceso	
	END EXCEPTION WITH RESUME;
	DROP TABLE tmp_hist_acad_mat;
END;

-- Tomo la cantidad de materias y el porcentaje pedido
SELECT cnt_materias, por_carrera, cnt_max_materias, por_max_carrera
	INTO vCnt_Materias, vPor_carrera, vCnt_max_materias, vPor_max_carrera
FROM u820_pasantias
WHERE id_pasantia = pIdPasantia;

IF vCnt_Materias IS NULL THEN
	LET vCnt_Materias = 0;
END IF;
IF vPor_carrera IS NULL THEN
	LET vPor_carrera = 0;
END IF;
IF vCnt_Max_Materias IS NULL OR vCnt_Max_Materias = 0 THEN
	LET vCnt_Max_Materias = 999;
END IF;
IF vPor_Max_carrera IS NULL OR vPor_Max_carrera = 0 THEN
	LET vPor_Max_carrera = 200; -- Para contemplar que la suma de optativas supere el 100%
END IF;




-- TMP_HIST_ACAD_MAT sera utilizada en otros procedures llamados desde este sp.
CREATE TEMP TABLE  tmp_hist_acad_mat (materia VARCHAR(5), resultado VARCHAR(2));

-- Cargo la versión actual del plan
SELECT version_actual, cnt_materias
	INTO vVersion, vCnt_Materias_Plan
FROM sga_planes
WHERE carrera = pCarrera
	AND plan = pPlan;

-- Cargo la tabla temporal con las materias rendidas por el alumno.
INSERT INTO  tmp_hist_acad_mat (materia, resultado) 
SELECT distinct materia, resultado 
	FROM vw_hist_academica 
	WHERE unidad_academica = pUnidadAcademica 
		AND carrera          = pCarrera 
		AND legajo           = pLegajo
		AND materia in (	SELECT a.materia
				FROM sga_atrib_mat_plan a
					LEFT JOIN u820_mat_exc_pas e
						ON a.carrera = e.carrera
						AND a.materia = e.materia
						AND a.plan = e.plan
				WHERE a.carrera = pCarrera 
					AND a.plan = pPlan
					AND a.version = vVersion
					AND e.carrera is null)
		AND resultado = 'A';


SELECT COUNT(*)
	INTO vCnt_materias_apro
FROM tmp_hist_acad_mat;



/*
-- Solo dejo las materias que el alumno aprobo.
DELETE FROM tmp_hist_acad_mat
WHERE resultado <> 'A';
*/

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Verifico si trabaja con cierres parciales. Busco fechas de las regularidades
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
EXECUTE PROCEDURE sp_param_sistema('cierre_parcial_acta_cursados') INTO vCierreParcial;


--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- recupero todas las correlativas OR de la materia 
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

LET vMensaje = '800320'; 
LET vResultado = 1;

FOREACH
	SELECT materia,
		condicion
	INTO vMateria, vCondicion
	FROM u820_cond_pas
	WHERE unidad_academica = pUnidadAcademica
		AND carrera          = pCarrera  
		AND plan             = pPlan
		AND id_pasantia = pIdPasantia


/*	-- Verifico si la materia esta aprobada
	IF (SELECT COUNT(*) FROM   tmp_hist_acad_mat WHERE materia =	vMateria) > 0 THEN
		LET vResultado = 1;
		LET vMensaje = '800320';
	ELSE
*/

	-- Si la materia no esta aprobada y cumple condiciones hasta ahora
	IF vResultado = 1 AND (SELECT COUNT(*) FROM   tmp_hist_acad_mat WHERE materia = vMateria) = 0 THEN
		EXECUTE PROCEDURE sp_evalua_materia(pUnidadAcademica,
							pCarrera, pLegajo, vMateria, 
							pPlan, vVersion, vCondicion)
							INTO  vResultado, vMensaje;	
		IF vResultado =  '-1' AND vCondicion = "R" THEN
			LET vMateriaRegParcial = 'N';	
			-- Si la Materia debe estar cursada...
			IF   vCierreParcial = 'S' and vCondicion = 'C' THEN
				-- Verifico si la regularidad esta Aprobada en un Cierre Parcial de Actas de Cursados
				IF (SELECT  count(*) FROM vw_reg_parciales
						WHERE unidad_academica   = pUnidadAcademica 
							AND  carrera = pCarrera 
							AND  legajo = pLegajo
							AND  materia =  vMateria
							AND  resultado in ('A','P') ) > 0 THEN
					-- Cumple con la correlativa.
					LET vMateriaRegParcial = 'S';	
					LET vResultado = 1;
					LET vMensaje = '800320';
				END IF;
			END IF;

			IF vMateriaRegParcial = 'N' THEN	
				LET vMensaje = (Select mascara  from mme_mensajes where mensaje = '820030');
			END IF; 
		ELSE

			LET vResultado = -1;
			LET vMensaje = (Select mascara  from mme_mensajes where mensaje = '820030');

		END IF;       
	END IF;
END FOREACH;


-- comprueba la cantidad de materias
IF vResultado = 1 and vCnt_materias_apro < vCnt_materias THEN
	LET vResultado = -1;
	LET vMensaje = (Select mascara from mme_mensajes where mensaje = '820031');
END IF;

-- comprueba el porcentaje de al materias
IF vResultado = 1 and vCnt_materias_apro / vCnt_materias_plan < vPor_carrera * .01 THEN
	LET vResultado = -1;
	LET vMensaje = (Select mascara  from mme_mensajes where mensaje = '820032');
END IF;

-- comprueba la cantidad máxima de materias
IF vResultado = 1 and vCnt_materias_apro > vCnt_max_materias THEN
	LET vResultado = -1;
	LET vMensaje = '820033';
END IF;

-- comprueba el porcentaje máximo de materias
IF vResultado = 1 and vCnt_materias_apro / vCnt_materias_plan > vPor_max_carrera * .01 THEN
	LET vResultado = -1;
	LET vMensaje = (Select mascara  from mme_mensajes where mensaje = '820034'); 
END IF;

-- EL mensaje solo estuvo en una linea...
RETURN vResultado, vMensaje WITH RESUME;
 
begin
	on exception in (-206)
	-- Tabla no existe continuo el proceso	
	end exception with resume;
	DROP TABLE tmp_hist_acad_mat;
end;

END;
END PROCEDURE;
-- ******************** FIN PROCESO ctr_cond_pas ********************

-- execute PROCEDURE ctr_cond_pas ('FCJS', '00086274','32370640-3','1','2000',176);
