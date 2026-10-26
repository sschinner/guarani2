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



CREATE PROCEDURE "dba".sp_setseed(n INTEGER)

	DEFINE GLOBAL seed DECIMAL(10) DEFAULT 1;

	LET seed = n;

END PROCEDURE;



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



CREATE PROCEDURE "dba".sp_random()
RETURNING INTEGER;

	DEFINE GLOBAL seed DECIMAL(10) DEFAULT 1;

	DEFINE d DECIMAL(20,0);

	LET d = (seed * 1103515245) + 12345;
	-- MOD function does not handle 20-digit values...  Dammit!!

	LET seed = d - 4294967296 * TRUNC(d / 4294967296);

	RETURN MOD(TRUNC(seed / 65536), 32768);

END PROCEDURE;

-- ********************************** FIN PROCESO "dba".sp_setseed **********************************


-- *****************************************************************************


-- Permisos del procedimiento "dba".sp_setseed 


-- *****************************************************************************


revoke execute on "dba".sp_setseed from public;


grant execute on "dba".sp_setseed to guarani;-- Rol de usuarios de Gestion


grant execute on "dba".sp_setseed to internet; -- Rol de usuario de Internet