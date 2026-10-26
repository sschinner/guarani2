CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_fe_fin_vig_reg') THEN
		DROP PROCEDURE sp_fe_fin_vig_reg;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

CREATE PROCEDURE sp_fe_fin_vig_reg
   (p_comision  LIKE sga_comisiones.comision, pFecha  DATE)
   RETURNING date;
	
-- Retorna la Fecha dos años despues
RETURN MDY( month(today),day(today),year(today) + 30);

END PROCEDURE;

-- *************** Fin del procedimiento  ******************

-- *****************************************************************************
-- Permisos del procedimiento 
-- *****************************************************************************
revoke execute on "dba".sp_fe_fin_vig_reg from public;
grant execute on "dba".sp_fe_fin_vig_reg to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_fe_fin_vig_reg to internet; -- Rol de usuario de Internet