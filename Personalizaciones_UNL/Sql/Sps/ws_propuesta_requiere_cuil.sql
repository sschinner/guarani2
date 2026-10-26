CREATE PROCEDURE "dba".verifica_objeto()

BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ws_propuesta_requiere_cuil') THEN
		DROP PROCEDURE ws_propuesta_requiere_cuil ;
	END IF;		
END

END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

CREATE PROCEDURE "dba".ws_propuesta_requiere_cuil (p_carrera LIKE sga_carreras.carrera)
RETURNING varchar(5)

BEGIN
        RETURN (SELECT carrera FROM sga_carreras_grupo WHERE grupo_carrera = 'NCUIL' AND carrera = p_carrera);
            
END
END PROCEDURE;
-- *****************************************************************************
-- Permisos del procedimiento "dba".ws_propuesta_requiere_cuil 
-- *****************************************************************************
revoke execute on "dba".ws_propuesta_requiere_cuil from public;
grant execute on "dba".ws_propuesta_requiere_cuil to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ws_propuesta_requiere_cuil to internet; -- Rol de usuario de Internet