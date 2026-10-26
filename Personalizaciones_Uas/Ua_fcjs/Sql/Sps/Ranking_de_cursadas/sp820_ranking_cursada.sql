CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_ranking_cursada') THEN
		DROP PROCEDURE sp820_ranking_cursada;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

CREATE PROCEDURE "dba".sp820_ranking_cursada
	(pAnioAcademico	LIKE	sga_comisiones.anio_academico,
	pPeriodoLectivo	LIKE	sga_comisiones.periodo_lectivo,
	p_Tolerancia	INTEGER)
	RETURNING	varchar(50);



-- SE PODRIA PENSAR EN OTROS PARAMETROS: CANT.  MATERIAS A INSCRIBIR; TOLERANCIA

DEFINE	vc_carrera LIKE sga_insc_cursadas.carrera; 
DEFINE	vc_plan LIKE sga_insc_cursadas.plan; 
DEFINE	vc_legajo, aux_legajo LIKE sga_insc_cursadas.legajo;
DEFINE	vd_fecha LIKE sga_insc_cursadas.fecha_inscripcion;
DEFINE	vi_comision LIKE sga_insc_cursadas.comision;

DEFINE	v_correccion INTEGER;
--DEFINE	vi_ultimo INTEGER;
DEFINE	ax_cupo INTEGER;
DEFINE	ax_cant_mat INTEGER;
DEFINE	vi_Cant_aprob INTEGER;
DEFINE	cupo INTEGER;
--DEFINE	 aux_comision INTEGER;
DEFINE	vi_cant_insc INTEGER;
DEFINE	vi_comision_con_cupo INTEGER;

DEFINE	iStatus INTEGER;
DEFINE	vcMsg VARCHAR(255);
DEFINE	aux_cant INTEGER;
DEFINE	aux_carrera LIKE sga_insc_cursadas.carrera; 
DEFINE	i INTEGER;
DEFINE	aux_max_fecha LIKE sga_insc_cursadas.fecha_inscripcion;

-- Return:
DEFINE	vcUnidadAcademica LIKE sga_alumnos.unidad_academica;
DEFINE	vc_unidad_academica LIKE sga_alumnos.unidad_academica;
DEFINE	vcCarrera LIKE sga_alumnos.carrera;
DEFINE	vcLegajo LIKE sga_alumnos.legajo;
DEFINE	viComision INTEGER;
DEFINE	vcEstado CHAR(1);
DEFINE	dFecInscripcion DATE;
--DEFINE	viPrioridadElegida INTEGER;
DEFINE	vbIngreso CHAR(1);
DEFINE vi_version_ranking INTEGER;

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

BEGIN
     ON EXCEPTION IN (-206)
       -- Tabla no existe continuo el proceso	
      END EXCEPTION WITH RESUME;
      DROP TABLE comisiones_rankeadas;
END;

BEGIN

ON EXCEPTION IN (-206)
       -- Tabla no existe continuo el proceso	
      END EXCEPTION WITH RESUME;
      DROP TABLE alumnos_rankeados;
END;

-- **************************************************************************************
-- Pongo en un temporal las inscripciones aceptadas del periodo a procesar
--	que no figuren en ranking o en acta de cursado
-- **************************************************************************************
-- Busco las comisiones con actas creadas del per�odo o rankeadas
SELECT DISTINCT i.comision
FROM sga_curs_pendiente i
	JOIN sga_comisiones c
	  ON i.comision = c.comision
WHERE c.anio_academico = pAnioAcademico
	AND c.periodo_lectivo = pPeriodoLectivo
UNION
SELECT DISTINCT i.comision
FROM u820_rank_curs i
	JOIN sga_comisiones c
	  ON i.comision = c.comision
WHERE c.anio_academico = pAnioAcademico
	AND c.periodo_lectivo = pPeriodoLectivo
INTO TEMP comisiones_rankeadas;

SELECT p.carrera ||"*"|| p.legajo ||"*"|| co.comision as rankeados
FROM
comisiones_rankeadas co
	join sga_curs_pendiente p
	  on co.comision = p.comision
UNION
SELECT p.carrera ||"*"|| p.legajo ||"*"|| co.comision
FROM comisiones_rankeadas co
	join u820_rank_curs p
	  on co.comision = p.comision
INTO TEMP alumnos_rankeados;

SELECT i.unidad_academica, i.carrera, i.plan, i.legajo, i.comision, i.fecha_inscripcion, 0 as cant_aprob, 'A' as estado, 'N' as ingreso, 'N' as cert_trabajo, 0 as cant_aprob_real, 'S' as procesar
-- ************************************************#######################################*****************************************************************
, c.materia
-- ************************************************#######################################*****************************************************************
FROM sga_insc_cursadas i
	JOIN sga_comisiones c
	  ON i.comision = c.comision
WHERE i.estado in ( 'A', 'E')
	AND c.anio_academico = pAnioAcademico
	AND c.periodo_lectivo = pPeriodoLectivo
	AND i.carrera ||"*"|| i.legajo ||"*"|| i.comision NOT IN (	SELECT *
							FROM alumnos_rankeados)
INTO TEMP aux_insc_cursadas;

-- ******************************************************************************
-- Ahora rankeo el los inscriptos calculando la cantidad de materias aprobadas

--	y ponderando los trabajadores de acuerdo a la presentaci�n del
--	certificado (Esto ultimo para no promocionales)
-- ******************************************************************************
UPDATE aux_insc_cursadas
SET cant_aprob = cant_aprob + 1000,
	cert_trabajo = 'S'
WHERE legajo IN (	SELECT legajo
		FROM sga_req_cumplidos r
			JOIN sga_alumnos a
			  ON r.nro_inscripcion = a.nro_inscripcion
				and r.carrera = a.carrera
		WHERE r.requisito = 'CT')	    				-- Aqu� va el c�digo del requisito !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	AND comision NOT IN (	SELECT comision
				FROM sga_comisiones c
				WHERE c.anio_academico = pAnioAcademico
					AND c.periodo_lectivo = pPeriodoLectivo
					AND c.turno = "N");

LET vi_cant_aprob = 0;


FOREACH SELECT DISTINCT unidad_academica, carrera, legajo
	INTO vc_unidad_academica, vc_carrera, vc_legajo
	FROM aux_insc_cursadas

	SELECT plan INTO vc_plan
	FROM sga_alumnos
	WHERE carrera = vc_carrera
		and legajo = vc_legajo;

	EXECUTE PROCEDURE sp820_can_mat_apro_alu (vc_unidad_academica, vc_carrera, vc_legajo) INTO vi_cant_aprob;

	LET v_correccion = 0;

	SELECT CASE WHEN correccion IS NULL THEN 0 ELSE correccion END
		INTO v_correccion
	FROM u820_equiv_cant_mat
	WHERE carrera = vc_carrera

		AND plan = vc_plan
		AND cantidad = vi_cant_aprob;

	UPDATE aux_insc_cursadas
	SET cant_aprob = cant_aprob + v_correccion,
		cant_aprob_real = vi_cant_aprob
	WHERE unidad_academica =  vc_unidad_academica
		AND legajo = vc_legajo 
		AND carrera = vc_carrera; 
	
END FOREACH;

-- *********************************************************
-- Incorporo alumnos que ya est�n cursando
-- *********************************************************
insert into aux_insc_cursadas
select p.unidad_academica, p.carrera, p.plan, p.legajo, p.comision, "1900-01-01 00:00:00" as fecha_inscripcion, 0 as cant_aprob, 'A' as estado, 'S' as ingreso, '' as cert_trabajo, 0 as cant_aprob_real, 'N' as procesar
-- ************************************************#######################################*****************************************************************
, c.materia
-- ************************************************#######################################*****************************************************************
from sga_curs_pendiente p
-- ************************************************#######################################*****************************************************************
	join sga_comisiones c
	  on p.comision = c.comision
-- ************************************************#######################################*****************************************************************
where p.comision IN (	SELECT comision
			FROM comisiones_rankeadas);


-- *********************************************************
-- Actualizo si entra o no segun el Cupo-Tolerancia
-- *********************************************************
-- Selecciono las comisiones a procesar (Con nuevos inscriptos)
SELECT DISTINCT comision
FROM aux_insc_cursadas
WHERE procesar = "S"
INTO TEMP aux_comisiones;

FOREACH SELECT comision
		INTO vi_comision
	FROM aux_comisiones

	-- Calculo del cupo maximo (con la tolerancia)
	LET cupo = (SELECT CASE WHEN capacidad IS NULL THEN
						0
					ELSE
						
capacidad
					END
		FROM sga_comisiones
		WHERE comision = vi_comision);
	
	--  si el cupo esta vacio o es null asumo ilimitado
	IF cupo = 0 THEN
		UPDATE aux_insc_cursadas
			SET ingreso = 'S'
			WHERE comision = vi_comision
				AND procesar = "S";
	ELSE
		-- Si el cupo no est� vacio veo hasta que grupo de materias entran
		LET cupo = cupo + (cupo * p_tolerancia / 100);
		LET cupo =  TRUNC(cupo); 

--		LET ax_cupo = 0;
		LET ax_cant_mat = 0;

		-- Calculo la base de alumnos que ya est�n aceptados en la comisi�n
		SELECT count(*)
			INTO ax_cupo
			FROM aux_insc_cursadas
			WHERE comision = vi_comision
				AND procesar = "N";

		-- Voy marcando por cantidad de materias mientras no se pase del cupo
		FOREACH SELECT cant_aprob, count(*)
				INTO vi_cant_aprob, vi_cant_insc  
			FROM aux_insc_cursadas
			WHERE comision = vi_comision
				AND procesar = "S"
			GROUP BY cant_aprob
			ORDER BY cant_aprob DESC
		
			-- voy sumando por grupos de aprobadas
			LET ax_cupo = ax_cupo + vi_cant_insc;

			-- Pregunto si no se paso, y si es as� marco el grupo
			IF ax_cupo <= cupo THEN
				UPDATE aux_insc_cursadas
				SET ingreso = 'S'
				WHERE comision = vi_comision
					AND cant_aprob = vi_cant_aprob
					AND procesar = "S";
		
	END IF;
		END FOREACH;
	END IF;
END FOREACH;


-- *****************************************************************************************************************************************************************
-- Controlo Superposicion Horaria de las inscripciones Aceptadas (ctr820_superph):
-- Aca lo que hacemos es recorrer las inscripciones del alumno en orden de prioridad (cantidad de materias) del mas alto al mas bajo
-- y en el control horario comparar con las inscripciones de MAS ALTA PRIORIDAD ACEPTADAS.
-- *****************************************************************************************************************************************************************

-- PARA CADA ALUMNO DE LA COMISION
FOREACH SELECT unidad_academica, carrera, legajo, comision, fecha_inscripcion
	INTO vc_unidad_academica, vc_carrera, vc_legajo, vi_comision, vd_fecha
FROM aux_insc_cursadas
WHERE ingreso = 'S'
	AND procesar = 'S'
ORDER BY legajo, fecha_inscripcion

	EXECUTE PROCEDURE ctr820_superph(vc_unidad_academica, vc_carrera, vc_legajo, vi_comision) INTO iStatus, vcMsg;
	IF iStatus <> 1 THEN
		UPDATE aux_insc_cursadas
		SET estado = 'H',
			ingreso = "N"
		WHERE legajo = vc_legajo 
			AND carrera = vc_carrera 
			AND comision = vi_comision; 
	END IF;
END FOREACH;

-- *******************************************************************************
-- Controla Cantidad Maxima de Materias a las que se puede inscribir
-- *******************************************************************************
SELECT legajo, carrera, COUNT(*) as cantidad
FROM aux_insc_cursadas
WHERE ingreso = 'S'
-- ************************************************#######################################*****************************************************************
	and materia not in ("19", "27", "232", "234", "264", "80", "81", "82")
-- ************************************************#######################################*****************************************************************
GROUP BY legajo, carrera
HAVING COUNT(*) > 3
INTO TEMP aux_legajos;

LET aux_cant = 0;
LET aux_legajo = '';
LET aux_carrera = '';

FOREACH SELECT legajo, carrera, cantidad
	INTO aux_legajo, aux_carrera, aux_cant
FROM aux_legajos

	FOR i = 1 TO aux_cant - 3
		SELECT MAX(fecha_inscripcion)
			INTO aux_max_fecha
		FROM aux_insc_cursadas
		WHERE legajo = aux_legajo
			AND carrera = aux_carrera 
-- ************************************************#######################################*****************************************************************
			and materia not in ("19", "27", "232", "234", "264", "80", "81", "82")
-- ************************************************#######################################*****************************************************************
			AND ingreso = 'S';

		UPDATE aux_insc_cursadas
		SET estado = 'C',
			ingreso = "N"
		WHERE legajo = aux_legajo
			AND carrera = aux_carrera 
			AND ingreso = 'S'
			AND fecha_inscripcion = aux_max_fecha; 
	END FOR;
END FOREACH;


BEGIN
	ON EXCEPTION IN (-206)
	-- Tabla no existe continuo el proceso	
	END EXCEPTION WITH RESUME;
	DROP TABLE aux_comisiones;
END;


-- ***************************************************************
-- Ahora paso los que entraron en el cupo pero no quedaron aceptados a ingreso='N'
-- ***************************************************************
UPDATE aux_insc_cursadas
SET ingreso='N'
WHERE estado <> 'A';


-- ***************************************************************
-- Ahora el ranking es: estado = 'A' and ingreso = 'S'
-- ***************************************************************
select max(version_ranking) into vi_version_ranking from u820_rank_curs;
IF vi_version_ranking IS NULL THEN
	LET vi_version_ranking = 0;
END IF;
LET vi_version_ranking = vi_version_ranking + 1;



INSERT INTO u820_rank_curs (unidad_academica, carrera, legajo, comision, estado, fecha_inscripcion, cant_aprob, ingreso, cert_trabajo,
	cant_aprob_real, plan, version_ranking)
SELECT unidad_academica, carrera, legajo, comision, estado, fecha_inscripcion, cant_aprob, ingreso, cert_trabajo, cant_aprob_real, plan, vi_version_ranking
	FROM aux_insc_cursadas
	WHERE procesar = "S";


END PROCEDURE;
-- *************** Fin del procedimiento "dba".sp820_ranking_cursada ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_ranking_cursada 
-- *****************************************************************************
revoke execute on "dba".sp820_ranking_cursada from public;
grant execute on "dba".sp820_ranking_cursada to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_ranking_cursada to internet; -- Rol de usuario de Internet