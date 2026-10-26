CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ws_periodos_lectivos') THEN
		DROP PROCEDURE ws_periodos_lectivos;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP PROCEDURE "dba".ws_periodos_lectivos;
CREATE PROCEDURE "dba".ws_periodos_lectivos(
    p_anio_academico LIKE sga_unidades_acad.unidad_academica
)
RETURNING 
	VARCHAR(20),	-- periodo lectivo
	date,			-- inicio_dictado
	date			-- fin_dictado

DEFINE _periodo_lectivo	LIKE sga_periodos_lect.periodo_lectivo;
DEFINE _inicio_dictado	LIKE sga_periodos_lect.inicio_dictado;
DEFINE _fin_dictado		LIKE sga_periodos_lect.fin_dictado;

FOREACH
	SELECT periodo_lectivo, inicio_dictado, fin_dictado
	INTO _periodo_lectivo, _inicio_dictado, _fin_dictado
	FROM sga_periodos_lect
	WHERE anio_academico = p_anio_academico 
	ORDER BY 1

	RETURN _periodo_lectivo, _inicio_dictado, _fin_dictado WITH RESUME;

END FOREACH;

END PROCEDURE;
-- EXECUTE PROCEDURE ws_periodos_lectivos(2023);

revoke execute ON "dba".ws_periodos_lectivos from public;
grant execute ON "dba".ws_periodos_lectivos to guarani; -- Rol de usuarios de Gestion
grant execute ON "dba".ws_periodos_lectivos to internet; -- Rol de usuario de Internet

