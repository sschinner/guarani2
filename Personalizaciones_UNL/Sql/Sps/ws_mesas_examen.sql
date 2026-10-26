CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ws_mesas_examen') THEN
		DROP PROCEDURE ws_mesas_examen;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP PROCEDURE "dba".ws_mesas_examen;
CREATE PROCEDURE "dba".ws_mesas_examen(
    p_anio_academico	LIKE sga_mesas_examen.anio_academico,
    p_turno_examen		LIKE sga_mesas_examen.turno_examen
)
RETURNING 
	VARCHAR(15),	-- mesa_examen
	VARCHAR(5),		-- elemento_codigo
	VARCHAR(255),	-- turno _elemento_nombre
	varchar(255),	-- carrera_nombre
	varchar(20)		-- mesa_codigo

DEFINE _mesa_examen			LIKE sga_mesas_examen.mesa_examen;
DEFINE _elemento_codigo		LIKE sga_materias.materia;
DEFINE _elemento_nombre		LIKE sga_materias.nombre;
DEFINE _propuesta_nombre	LIKE sga_carreras.nombre;
DEFINE _mesa_codigo			VARCHAR(20);

FOREACH
	SELECT M.mesa_examen, E.materia, E.nombre, C.nombre as propuesta_nombre, M.materia || M.mesa_examen
		INTO _mesa_examen, _elemento_codigo, _elemento_nombre, _propuesta_nombre, _mesa_codigo
	FROM sga_mesas_examen M
	JOIN sga_materias E			ON M.materia = E.materia
	LEFT JOIN sga_carreras C	ON M.carrera = C.carrera
	WHERE M.anio_academico = p_anio_academico AND M.turno_examen = p_turno_examen
	ORDER BY 4

	RETURN _mesa_examen, _elemento_codigo, _elemento_nombre, _propuesta_nombre, _mesa_codigo WITH RESUME;

END FOREACH;

END PROCEDURE;
-- EXECUTE PROCEDURE ws_mesas_examen(2024, 'MAYO');

revoke execute ON "dba".ws_mesas_examen from public;
grant execute ON "dba".ws_mesas_examen to guarani; -- Rol de usuarios de Gestion
grant execute ON "dba".ws_mesas_examen to internet; -- Rol de usuario de Internet