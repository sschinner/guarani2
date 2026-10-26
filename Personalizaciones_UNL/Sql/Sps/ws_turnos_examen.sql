CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ws_turnos_examen') THEN
		DROP PROCEDURE ws_turnos_examen;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP PROCEDURE "dba".ws_turnos_examen;
CREATE PROCEDURE "dba".ws_turnos_examen(
    p_anio_academico LIKE sga_unidades_acad.unidad_academica
)
RETURNING 
	VARCHAR(60),	-- turno_examen
	VARCHAR(60),	-- nombre
	VARCHAR(10),	-- turno tipo
	date,			-- inicio
	date			-- fin

DEFINE _turno_examen	LIKE sga_turnos_examen.turno_examen;
DEFINE _nombre			LIKE sga_turnos_examen.nombre;
DEFINE _turno_tipo		VARCHAR(10);
DEFINE _fecha_inicio	LIKE sga_turnos_examen.fecha_inicio;
DEFINE _fecha_fin		LIKE sga_turnos_examen.fecha_fin;

FOREACH
	SELECT turno_examen as turno_examen, nombre, CASE WHEN tipo_de_turno = 'N' THEN 'Normal' WHEN tipo_de_turno = 'E' THEN 'Especial' WHEN tipo_de_turno = 'A' THEN 'Adicional' END, fecha_inicio, fecha_fin
	INTO _turno_examen, _nombre, _turno_tipo, _fecha_inicio, _fecha_fin
	FROM sga_turnos_examen
	WHERE anio_academico = p_anio_academico 
	ORDER BY 1

	RETURN _turno_examen, _nombre, _turno_tipo, _fecha_inicio, _fecha_fin WITH RESUME;

END FOREACH;

END PROCEDURE;
-- EXECUTE PROCEDURE ws_turnos_examen(2023);

revoke execute ON "dba".ws_turnos_examen from public;
grant execute ON "dba".ws_turnos_examen to guarani; -- Rol de usuarios de Gestion
grant execute ON "dba".ws_turnos_examen to internet; -- Rol de usuario de Internet