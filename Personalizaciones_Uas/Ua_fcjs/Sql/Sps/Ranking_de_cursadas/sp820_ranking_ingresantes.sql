CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_setseed') THEN
		DROP PROCEDURE sp_setseed;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_random') THEN
		DROP PROCEDURE sp_random;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_ranking_ing') THEN
		DROP PROCEDURE sp820_ranking_ing;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

--	generar orden de recorrido aleatorio para inscripciones
--	priorizar las inscripciones por alumno de acuerdo a fecha-hora de inscripcion
--	obtener la máxima prioridad Xmax
--	para cada prioridad X desde 1 a Xmax
--		recorrer inscripciones disponibles para la prioridad X segun orden generado
--			si la comision de la inscripcion actual tiene cupo y no hay superposicion horaria con alguna inscripcion aceptada
--				marcar como aceptada la inscripcion
--				si la cantidad de inscripciones aceptadas llego al limite para el alumno
--					marcar el resto de las inscripciones como rechazadas
--				sino
--					marcar como rechazadas el resto de las inscripciones a la materia recien aceptada
--				fin
--			sino
--				marcar la inscripcion como reclazada
--			fin
--		fin
--	fin



CREATE PROCEDURE "dba".sp_setseed(n INTEGER)
	DEFINE GLOBAL seed DECIMAL(10) DEFAULT 1;
	LET seed = n;
END PROCEDURE;
-- *************** Fin del procedimiento "dba".sp_setseed ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_setseed 
-- *****************************************************************************
revoke execute on "dba".sp_setseed from public;
grant execute on "dba".sp_setseed to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_setseed to internet; -- Rol de usuario de Internet

CREATE PROCEDURE "dba".sp_random() RETURNING INTEGER;
	DEFINE GLOBAL seed DECIMAL(10) DEFAULT 1;
	DEFINE d DECIMAL(20,0);
	LET d = (seed * 1103515245) + 12345;
	-- MOD function does not handle 20-digit values...  Dammit!!
	LET seed = d - 4294967296 * TRUNC(d / 4294967296);
	RETURN MOD(TRUNC(seed / 65536), 32768);
END PROCEDURE;
-- *************** Fin del procedimiento "dba".sp_random ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_random 
-- *****************************************************************************
revoke execute on "dba".sp_random from public;
grant execute on "dba".sp_random to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_random to internet; -- Rol de usuario de Internet

--DROP PROCEDURE "dba".sp820_ranking_ing;
CREATE PROCEDURE "dba".sp820_ranking_ing
	(pAnioAcademico	LIKE	sga_comisiones.anio_academico,
	pPeriodoLectivo	LIKE	sga_comisiones.periodo_lectivo)
RETURNING varchar(10);

/*
	RETURNING
		varchar(5),		-- unidad academica
		varchar(5),		-- carrera

		varchar(15),		-- legajo
		integer,			-- comision
		char(1),			-- estado
		date,			-- fecha inscripcion
		int,			-- cantidad da aprobadas
		char(1);			-- ingreso
*/


DEFINE	vc_carrera LIKE sga_insc_cursadas.carrera; 
DEFINE	vc_plan LIKE sga_insc_cursadas.plan; 
DEFINE	vc_legajo, aux_legajo LIKE sga_insc_cursadas.legajo;
DEFINE	vc_materia LIKE sga_materias.materia;
DEFINE	vd_fecha LIKE sga_insc_cursadas.fecha_inscripcion;
DEFINE	vi_comision LIKE sga_insc_cursadas.comision;

DEFINE	v_correccion, vi_ultimo, ax_cupo, ax_cant_mat integer;
DEFINE	vi_cant_aprob INTEGER;
DEFINE	vi_prioridad INTEGER;
DEFINE	vi_orden INTEGER;
DEFINE	cupo, aux_comision, vi_cant_insc, vi_comision_con_cupo integer;

DEFINE	iStatus INTEGER;
DEFINE	vcMsg VARCHAR(255);
DEFINE	aux_cant INTEGER;
DEFINE	aux_carrera LIKE sga_insc_cursadas.carrera; 
DEFINE	i INTEGER;
DEFINE	aux_max_fecha LIKE sga_insc_cursadas.fecha_inscripcion;
DEFINE	aux_fecha LIKE sga_insc_cursadas.fecha_inscripcion;
DEFINE	vi_ver_rank INTEGER;


-- Return:
DEFINE	vcUnidadAcademica, vc_unidad_academica LIKE sga_alumnos.unidad_academica;
DEFINE	vcCarrera LIKE sga_alumnos.carrera;
DEFINE	vcLegajo LIKE sga_alumnos.legajo;
DEFINE	viComision INTEGER;
DEFINE	vcEstado CHAR(1);
DEFINE	dFecInscripcion DATE;
DEFINE	viPrioridadElegida INTEGER;
DEFINE	vbIngreso CHAR(1);

LET vcUnidadAcademica = "";
LET vcCarrera = "";
LET vcLegajo = "";
LET viComision = 0;
LET vcEstado = "";
LET dFecInscripcion = null;
LET ax_cant_mat = 0;
LET vbIngreso = "";


BEGIN
     ON EXCEPTION IN (-206)
       -- Tabla no existe continuo el proceso	
      END EXCEPTION WITH RESUME;
      DROP TABLE aux_comisiones;
END;

BEGIN
     ON EXCEPTION IN (-206)
       -- Tabla no existe continuo el proceso	
      END EXCEPTION WITH RESUME;
      DROP TABLE aux_insc_cursadas;
END;

BEGIN
     ON EXCEPTION IN (-206)
       -- Tabla no existe continuo el proceso	
      END EXCEPTION WITH RESUME;
      DROP TABLE aux_legajos;
END;

-- **************************************************************************************
-- Pongo en un temporal las inscripciones aceptadas del periodo a procesar
-- **************************************************************************************
-- estado:	-- P: pendiente

	-- A: ingreso
	-- H: superposicion horaria
	-- C: cantidad materias
	-- O: ingreso a otra comision
	-- U: cupo de la comision

SELECT i.unidad_academica, i.carrera, i.plan, i.legajo, i.comision AS comision, c.materia AS materia,
	i.fecha_inscripcion, 0 AS cant_aprob, 'P' AS estado, 'N' as ingreso, 0 AS prioridad, 0 AS orden, 0 as cant_aprob_real
FROM sga_insc_cursadas i
	JOIN sga_comisiones c
	  ON i.comision = c.comision
WHERE i.estado in ( 'A', 'E')
	AND c.anio_academico = pAnioAcademico
	
AND c.periodo_lectivo = pPeriodoLectivo
	AND c.materia in ('1', '2', '3','4','TS002','TS003','TS004','TS005','TS006','TS007',11,220)
INTO TEMP aux_insc_cursadas;



-- ******************************************************************************
-- Ahora actualizo el la cantidad de aprobadas 
-- ******************************************************************************
LET vi_cant_aprob = 0;

FOREACH SELECT unidad_academica, carrera, legajo
	INTO vc_unidad_academica, vc_carrera, vc_legajo
	FROM aux_insc_cursadas

	SELECT plan INTO vc_plan

	FROM sga_alumnos
	WHERE carrera = vc_carrera
		and legajo = vc_legajo;

	EXECUTE PROCEDURE sp820_can_mat_apro_alu (vc_unidad_academica, vc_carrera, vc_legajo) INTO vi_cant_aprob;

	LET v_correccion = 0;

	SELECT CASE WHEN correccion IS NULL THEN 0
 ELSE correccion END
		INTO v_correccion
	FROM u820_equiv_cant_mat
	WHERE carrera = vc_carrera
		AND plan = vc_plan
		AND cantidad = vi_cant_aprob;

	UPDATE aux_insc_cursadas
	SET cant_aprob = v_correccion,
		cant_aprob_real = vi_cant_aprob
	WHERE unidad_academica =  vc_unidad_academica
		AND legajo = vc_legajo 
		AND carrera = vc_carrera; 
	
END FOREACH;

-- ******************************************************************************
-- Priorizo las inscripciones según la fecha/hora de inscripción
-- ******************************************************************************
LET vi_prioridad = 0;

FOREACH SELECT legajo, comision, fecha_inscripcion
	INTO vc_legajo, vi_comision, aux_fecha
	FROM aux_insc_cursadas
	ORDER BY fecha_inscripcion

	SELECT MAX(prioridad)+1 INTO vi_prioridad
	FROM aux_insc_cursadas
	WHERE legajo = vc_legajo;

	UPDATE aux_insc_cursadas
	SET prioridad = vi_prioridad
	WHERE legajo = vc_legajo
		and comision = vi_comision;
END FOREACH;


-- ******************************************************************************
-- Doy orden aleatorio
-- ******************************************************************************
UPDATE aux_insc_cursadas
SET orden = sp_random();

-- *********************************************************
-- Recorro primero por cantidad de materias para no dejar fuera por cupo a ninguno de ellos
-- *********************************************************
FOREACH SELECT DISTINCT prioridad
	INTO vi_prioridad
	FROM aux_insc_cursadas
	ORDER BY prioridad

	FOREACH SELECT legajo, comision, materia, cant_aprob, orden
		INTO vc_legajo, vi_comision, vc_materia, vi_cant_aprob, vi_orden
		FROM aux_insc_cursadas
		WHERE prioridad = vi_prioridad
		AND estado = "P"
			and cant_aprob > 0
		ORDER BY cant_aprob desc, orden

		-- Calculo del cupo
		LET cupo = 0;
		LET cupo = (SELECT CASE WHEN capacidad IS NULL THEN
							0
						ELSE
							capacidad
						END
			FROM sga_comisiones
			WHERE comision = vi_comision);
	

		--  si el cupo esta vacio o es null asumo ilimitado
		IF cupo = 0 THEN
			LET cupo = 9999;
		END IF;

		-- veo los inscriptos
		SELECT count(*) INTO vi_cant_insc
		FROM aux_insc_cursadas
		WHERE comision = vi_comision
			AND ingreso = "S";

		IF vi_cant_insc >= cupo THEN
			UPDATE aux_insc_cursadas
			SET estado = "U"
			WHERE legajo = vc_legajo
				and comision = vi_comision;
		ELSE
			SELECT count(*) INTO aux_cant
				FROM aux_insc_cursadas
				WHERE legajo = vc_legajo
				
	AND ingreso = "S"
					AND estado = "A";
			IF (aux_cant >= 3) THEN
				UPDATE aux_insc_cursadas
				SET estado = "C"
				WHERE legajo = vc_legajo
					and comision = vi_comision;
			ELSE
				EXECUTE PROCEDURE ctr820_superph (vc_unidad_academica, vc_carrera, vc_legajo, vi_comision) INTO iStatus, vcMsg;
					IF iStatus <> 1 THEN
					UPDATE aux_insc_cursadas
					SET estado = 'H'
					WHERE legajo = vc_legajo
						AND comision = vi_comision; 
				ELSE
					UPDATE aux_insc_cursadas
					SET ingreso = "S",
						estado = "A"
					WHERE legajo = vc_legajo
						and comision = vi_comision;

					UPDATE aux_insc_cursadas
					SET estado = "O"
					WHERE legajo = vc_legajo
						AND materia = vc_materia
						AND comision <> vi_comision

						AND estado = "P";
				END IF;
			END IF;
		END IF;
	END FOREACH;
END FOREACH;


-- *********************************************************
-- Recorro para cada prioridad con tope 1
-- *********************************************************
FOREACH SELECT DISTINCT prioridad
	INTO vi_prioridad
	FROM aux_insc_cursadas
	ORDER BY prioridad

	FOREACH SELECT legajo, comision, materia, cant_aprob, orden
		INTO vc_legajo, vi_comision, vc_materia, vi_cant_aprob, vi_orden
		FROM aux_insc_cursadas
		WHERE prioridad = vi_prioridad
		AND estado = "P"
		ORDER BY cant_aprob desc, orden

		-- Calculo del cupo
		LET cupo = 0;
		LET cupo = (SELECT CASE WHEN capacidad IS NULL THEN
							0
						ELSE
							capacidad
						END
			FROM sga_comisiones
			WHERE comision = vi_comision);
	

		--  si el cupo esta vacio o es null asumo ilimitado
		IF cupo = 0 THEN
			LET cupo = 9999;
		END IF;

		-- veo los inscriptos
		SELECT count(*) INTO vi_cant_insc
		FROM aux_insc_cursadas
		WHERE comision = vi_comision
			AND ingreso = "S";

		IF vi_cant_insc >= cupo THEN
			UPDATE aux_insc_cursadas
			SET estado = "U"
			WHERE legajo = vc_legajo
				and comision = vi_comision;
		ELSE
			SELECT count(*) INTO aux_cant
				FROM aux_insc_cursadas
				WHERE legajo = vc_legajo
					AND ingreso = "S"
					AND estado = "A";
			IF (aux_cant >= 1) THEN
				UPDATE aux_insc_cursadas
				SET estado = "C"
				WHERE legajo = vc_legajo
					and comision = vi_comision;
			ELSE
				EXECUTE PROCEDURE ctr820_superph (vc_unidad_academica, vc_carrera, vc_legajo, vi_comision) INTO iStatus, vcMsg;
					IF iStatus <> 1 THEN
					UPDATE aux_insc_cursadas
					SET estado = 'H'
					WHERE legajo = vc_legajo
						AND comision = vi_comision; 
				ELSE
					UPDATE aux_insc_cursadas
					SET ingreso = "S",
						estado = "A"
					WHERE legajo = vc_legajo
						and comision = vi_comision;

					UPDATE aux_insc_cursadas
					SET estado = "O"
					WHERE legajo = vc_legajo
						AND materia = vc_materia
						AND comision <> vi_comision
						AND estado = "P";
				END IF;
			END IF;
		END IF;
	END FOREACH;
END FOREACH;


update aux_insc_cursadas
set estado = "P"
where estado = "C";


-- *********************************************************
-- Recorro para cada prioridad con tope 2
-- *********************************************************
FOREACH SELECT DISTINCT prioridad
	INTO vi_prioridad
	FROM aux_insc_cursadas
	ORDER BY prioridad

	FOREACH SELECT legajo, comision, materia, cant_aprob, orden
		INTO vc_legajo, vi_comision, vc_materia, vi_cant_aprob, vi_orden
		FROM aux_insc_cursadas
		WHERE prioridad = vi_prioridad
		AND estado = "P"
		ORDER BY cant_aprob desc, orden

		-- Calculo del cupo
		LET cupo = 0;
		LET cupo = (SELECT CASE WHEN capacidad IS NULL THEN
							0
						ELSE
							capacidad
						END
			FROM sga_comisiones
			WHERE comision = vi_comision);
	

		--  si el cupo esta vacio o es null asumo ilimitado
		IF cupo = 0 THEN
			LET cupo = 9999;
		END IF;

		-- veo los inscriptos
		SELECT count(*) INTO vi_cant_insc
		FROM aux_insc_cursadas
		WHERE comision = vi_comision
			AND ingreso = "S";

		IF vi_cant_insc >= cupo THEN
			UPDATE aux_insc_cursadas
			SET estado = "U"
			WHERE legajo = vc_legajo
				and comision = vi_comision;
		ELSE
			SELECT count(*) INTO aux_cant
				FROM aux_insc_cursadas
				WHERE legajo = vc_legajo
					AND ingreso = "S"
					AND estado = "A";
			IF (aux_cant >= 2) THEN
				UPDATE aux_insc_cursadas


				SET estado = "C"
				WHERE legajo = vc_legajo
					and comision = vi_comision;
			ELSE
				EXECUTE PROCEDURE ctr820_superph (vc_unidad_academica, vc_carrera, vc_legajo, vi_comision) INTO iStatus, vcMsg;
					IF iStatus <> 1 THEN
					UPDATE aux_insc_cursadas
					SET estado = 'H'
					WHERE legajo = vc_legajo
						AND comision = vi_comision; 
				ELSE
					UPDATE aux_insc_cursadas
					SET ingreso = "S",
						estado = "A"
					WHERE legajo = vc_legajo
						and comision = vi_comision;



					UPDATE aux_insc_cursadas
					SET estado = "O"
					WHERE legajo = vc_legajo
						AND materia = vc_materia
						AND comision <> vi_comision
						AND estado = "P";
				END IF;
			END IF;
		END IF;
	END FOREACH;
END FOREACH;


update aux_insc_cursadas
set estado = "P"
where estado = "C";


-- *********************************************************
-- Recorro para cada prioridad con tope 3
-- *********************************************************
FOREACH SELECT DISTINCT prioridad
	INTO vi_prioridad
	FROM aux_insc_cursadas
	ORDER BY prioridad

	FOREACH SELECT legajo, comision, materia, cant_aprob, orden
		INTO vc_legajo, vi_comision, vc_materia, vi_cant_aprob, vi_orden
		FROM aux_insc_cursadas
		WHERE prioridad = vi_prioridad
		AND estado = "P"
		ORDER BY cant_aprob desc, orden

		-- Calculo del cupo
		LET cupo = 0;
		LET cupo = (SELECT CASE WHEN capacidad IS NULL THEN
							0
						ELSE
							capacidad
						END
			FROM sga_comisiones
			WHERE comision = vi_comision);
	

		--  si el cupo esta vacio o es null asumo ilimitado
		IF cupo = 0 THEN
			LET cupo = 9999;
		END IF;

		-- veo los inscriptos
		SELECT count(*) INTO vi_cant_insc
		FROM aux_insc_cursadas
		WHERE comision = vi_comision
			AND ingreso = "S";

		IF vi_cant_insc >= cupo THEN
			UPDATE aux_insc_cursadas
			SET estado = "U"
			WHERE legajo = vc_legajo
				and comision = vi_comision;
		ELSE
			SELECT count(*) INTO aux_cant
				FROM aux_insc_cursadas
				WHERE legajo = vc_legajo
					AND ingreso = "S"
					AND estado = "A";
			IF (aux_cant >= 3) THEN
				UPDATE aux_insc_cursadas
				SET estado = "C"
				WHERE legajo = vc_legajo
					and comision = vi_comision;
			ELSE
				EXECUTE PROCEDURE ctr820_superph (vc_unidad_academica, vc_carrera, vc_legajo, vi_comision) INTO iStatus, vcMsg;
					IF iStatus <> 1 THEN
					UPDATE aux_insc_cursadas
					SET estado = 'H'
					WHERE legajo = vc_legajo
						AND comision = vi_comision; 
				ELSE
					UPDATE aux_insc_cursadas

					SET ingreso = "S",
						estado = "A"
					WHERE legajo = vc_legajo
						and comision = vi_comision;

					UPDATE aux_insc_cursadas
					SET estado = "O"
					WHERE legajo = vc_legajo
						AND materia = vc_materia
						AND comision <> vi_comision
						AND estado = "P";
				END IF;
			END IF;
		END IF;
	END FOREACH;
END FOREACH;


-- ***************************************************************
-- Ahora ranking como quedo en u820_rank_curs
-- ***************************************************************
select max(version_ranking) into vi_ver_rank from u820_rank_curs;
IF vi_ver_rank IS NULL THEN
	LET vi_ver_rank = 0;
END IF;
LET vi_ver_rank = vi_ver_rank + 1;


INSERT INTO u820_rank_curs (unidad_academica, carrera, legajo, comision, estado, fecha_inscripcion, cant_aprob, ingreso, cert_trabajo,
	cant_aprob_real, plan, version_ranking)
SELECT unidad_academica, carrera, legajo, comision, estado, fecha_inscripcion, cant_aprob, ingreso, 'N' as cert_trabajo,
	cant_aprob_real, plan, vi_ver_rank
	FROM aux_insc_cursadas;

/*
FOREACH SELECT unidad_academica, carrera, legajo, comision, estado, fecha_inscripcion, cant_aprob, ingreso
	INTO  vcUnidadAcademica, vcCarrera, vcLegajo, viComision, vcEstado, dFecInscripcion, ax_ca
nt_mat, vbIngreso
	FROM aux_insc_cursadas
	--WHERE estado = 'A'
	--	AND ingreso = 'S'
	ORDER BY unidad_academica, comision, cant_aprob desc

	RETURN vcUnidadAcademica, vcCarrera, vcLegajo, viComision, vcEstado, dFecInscripcion,
		ax_cant_mat, vbIngr
eso WITH RESUME ;
END FOREACH;
*/

END PROCEDURE;
-- *************** Fin del procedimiento "dba".sp820_ranking_ing ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_ranking_ing 
-- *****************************************************************************
revoke execute on "dba".sp820_ranking_ing from public;
grant execute on "dba".sp820_ranking_ing to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_ranking_ing to internet; -- Rol de usuario de Internet