-- generar orden de recorrido aleatorio para inscripciones
-- priorizar las inscripciones por alumno de acuerdo a fecha-hora de inscripcion
-- obtener la máxima prioridad Xmax
-- para cada prioridad X desde 1 a Xmax
--	recorrer inscripciones disponibles para la prioridad X segun orden generado
--		si la comision de la inscripcion actual tiene cupo y no hay superposicion horaria con alguna inscripcion aceptada
--			marcar como aceptada la inscripcion
--			si la cantidad de inscripciones aceptadas llego al limite para el alumno
--				marcar el resto de las inscripciones como rechazadas
--			sino
--				marcar como rechazadas el resto de las inscripciones a la materia recien aceptada
--			fin
--		sino
--			marcar la inscripcion como reclazada
--		fin
--	fin
-- fin


-- *************************************************************************************************
-- SP: sp820_seleComCurAle
-- Descripcion: Selecciona aleatoriamente los inscriptos a distintas comisiones según
-- su prioridad de eleccion
-- Fecha: 01/12/2006
--
-- Recibe:		- Anio Academico
--		- Período Lectivo
--			
-- Retorna:	
-- **************************************************************************************************

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_selecomcurale') THEN
		DROP PROCEDURE sp820_selecomcurale;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

CREATE PROCEDURE "dba".sp820_seleComCurAle 	(a_ua VARCHAR(5), a_fecha_ult_upd DATE)
-- Variante del procedure que actualiza la historia academica, lo hace para todas las carreras y para los alumnos 
-- cuya fecha de ultima actualizacion es anterior a la fecha dada como argumento

DEFINE 	n_cant_legajo	INTEGER;
DEFINE	s_legajo		VARCHAR(15);
DEFINE	n_cant_lgen_alu	INTEGER;
DEFINE	d_fecha		DATETIME YEAR TO SECOND;
DEFINE	n_cant_carrera	INTEGER; 
DEFINE	s_carrera		VARCHAR(5);

ON EXCEPTION IN (-310)
-- TABLA TEMPORAL EXISTE
	DELETE FROM  tmp_carrera;
	DELETE FROM  tmp_alumno;
END EXCEPTION WITH RESUME;

LET d_fecha = CURRENT;

CREATE TEMP TABLE tmp_carrera
	(
	carrera	VARCHAR(5)
	)  WITH NO LOG;

CREATE TEMP TABLE tmp_alumno
	(
	legajo	VARCHAR(15),
	carrera	VARCHAR(5)
	)  WITH NO LOG;

INSERT INTO tmp_alumno
	SELECT	legajo, 
		carrera 
	FROM sga_lgen_hacad_alu
	WHERE unidad_academica = a_ua
	AND       fecha < a_fecha_ult_upd  ;

-- Agregar los alumnos que no tienen historia academica generada desde antes, los que no estan en sga_lgen_hacad_alu
INSERT INTO tmp_alumno
	SELECT	legajo,
		carrera
	FROM	sga_alumnos
	WHERE	sga_alumnos.unidad_academica = a_ua
	AND	NOT EXISTS (SELECT lgen.legajo,
				      lgen.carrera
			        FROM    sga_lgen_hacad_alu lgen
			        WHERE lgen.unidad_academica = a_ua
			        AND	       lgen.legajo = sga_alumnos.legajo
			        AND	       lgen.carrera = sga_alumnos.carrera
			);


INSERT INTO tmp_carrera
	SELECT DISTINCT carrera
	FROM		tmp_alumno;

SELECT COUNT(*)
INTO	n_cant_carrera
FROM	tmp_carrera;

WHILE n_cant_carrera > 0

	SELECT MIN(carrera)
	INTO	s_carrera
	FROM	tmp_carrera;

	DELETE FROM	tmp_carrera
	WHERE		carrera = s_carrera;

	SELECT COUNT(*)
	INTO	n_cant_legajo
	FROM	tmp_alumno
	WHERE	carrera = s_carrera;

	WHILE n_cant_legajo > 0 

		SELECT	MIN( legajo)
		INTO	s_legajo
		FROM	tmp_alumno
		WHERE	carrera = s_carrera;

		DELETE FROM tmp_alumno
		WHERE	legajo = s_legajo
		AND	carrera = s_carrera;

		-- BORRAR TODA LA INFORMACION DE LA TABLA sga_hist_acade_aux para el legajo
		DELETE FROM sga_hist_acade_aux
		WHERE	unidad_academica = a_ua
		AND	carrera = s_carrera
		AND	legajo = s_legajo;
	
		INSERT INTO	sga_hist_acade_aux
			SELECT  unidad_academica, carrera, legajo, materia, fecha, resultado, nota, forma_aprobacion, tipo_acta, acta, acta_promocion, nro_resolucion, plan, version
			FROM	vw_hist_academica
			WHERE	unidad_academica = a_ua
			AND	carrera = s_carrera
			AND	legajo = s_legajo;

		-- Si el alumno existe en la tabla sga_lgen_hacad_alu: Actualizar la fecha de ultima actualizacion para el legajo 
		-- Si no existe, generar el registro
		SELECT COUNT(*)
		INTO	n_cant_lgen_alu
		FROM 	sga_lgen_hacad_alu
		WHERE	unidad_academica = a_ua
		AND	carrera = s_carrera
		AND	legajo = s_legajo;

		LET d_fecha = CURRENT;

		IF n_cant_lgen_alu = 0 THEN
			INSERT INTO	sga_lgen_hacad_alu
				(unidad_academica,
				 carrera,
				 legajo,
				 fecha
				)
			VALUES(a_ua,
				s_carrera,
				s_legajo,
				d_fecha
				);
		ELSE
			UPDATE	sga_lgen_hacad_alu
			SET	fecha = d_fecha
			WHERE	unidad_academica = a_ua
			AND	carrera = s_carrera
			AND	legajo = s_legajo;
		END IF;

		COMMIT WORK;
		BEGIN WORK;

		-- Volver a preguntar la cantidad de legajos de la tabla temporal
		SELECT COUNT(*)
		INTO	n_cant_legajo
		FROM	tmp_alumno
		WHERE	carrera = s_carrera;

	END WHILE;

	-- Volver a preguntar la cantidad de carreras de la tabla temporal
	SELECT COUNT(*)
	INTO	n_cant_carrera
	FROM	tmp_carrera;

END WHILE;

-- SALE CUANDO LA TEMPORAL ESTA VACIA

DROP TABLE 	tmp_alumno;
DROP TABLE	tmp_carrera;

END PROCEDURE;
-- *************** Fin del procedimiento "dba".sp820_seleComCurAle ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_seleComCurAle 
-- *****************************************************************************
revoke execute on "dba".sp820_seleComCurAle from public;
grant execute on "dba".sp820_seleComCurAle to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_seleComCurAle to internet; -- Rol de usuario de Internet