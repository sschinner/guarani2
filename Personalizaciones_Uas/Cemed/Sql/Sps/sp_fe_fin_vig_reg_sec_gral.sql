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

-- **********************************************************************
-- Genera la Fecha de Finalización de Vigencia de la Regularidad de la
-- Cursada de una materia.
-- Recibe:   - Codigo de Comision
--
-- Retorna:  - Fecha Fin de Vigencia de Regularidad
--
-- Hoy NO esta utilizando el codigo de Comision. Pero si se quisiese
-- ver cual es la materia o periodo lectivo de la cursada entonces se busca
-- por la comision.
-- **********************************************************************

-- DROP PROCEDURE sp_fe_fin_vig_reg;
CREATE PROCEDURE sp_fe_fin_vig_reg
   (p_comision  LIKE sga_comisiones.comision, pFecha  DATE)
   RETURNING date;
	
DEFINE v_fecha_fin_vigencia_regularidad	date;

-- Retorna la Fecha 3 años después
RETURN MDY( month(today),day(today),year(today) + 3);

END PROCEDURE;
-- *************************** Fin del procedimiento ***************************

-- *****************************************************************************
-- Permisos del procedimiento
-- *****************************************************************************
revoke execute on "dba".sp_fe_fin_vig_reg from public;
grant execute on "dba".sp_fe_fin_vig_reg to guarani; -- Rol de usuarios de Gestión
grant execute on "dba".sp_fe_fin_vig_reg to internet; -- Usuario de internet



