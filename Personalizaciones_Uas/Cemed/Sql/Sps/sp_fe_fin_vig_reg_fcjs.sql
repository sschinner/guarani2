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
-- Ultima version de modificacion: 2.01.1
--
-- Recibe:   - Codigo de Comision
--
-- Retorna:  - Fecha Fin de Vigencia de Regularidad
--
-- Hoy NO esta utilizando el codigo de Comision ni la Fecha de Regularidad.
-- Pero si se quisiese ver cual es la materia o periodo lectivo de la cursada entonces se busca
-- por la comision. O si la fecha de fin de vigencia depende de la fecha en que se regularizo la materia.
-- **********************************************************************
-- DROP PROCEDURE "dba".sp_fe_fin_vig_reg;
CREATE PROCEDURE "dba".sp_fe_fin_vig_reg
   (p_comision  LIKE sga_comisiones.comision, pFecha  DATE)
   RETURNING DATE;
	
-- Retorna la Fecha de fin de regularidad según pedido de CEMED FJCS ticket #53513. 14 meses para todas las asignaturas.

BEGIN

IF (month(today)) <= 10 THEN
	RETURN MDY(month(today)+2, day(today), year(today)+1);
ELSE
	IF ((month(today)-10) == 2 AND ((day(today)) BETWEEN 29 AND 31)) THEN
		RETURN MDY(3,1, year(today)+2);
	ELSE
		RETURN MDY(month(today)-10,day(today), year(today)+2);
	END IF;
END IF;

END

END PROCEDURE;

-- *************** Fin del procedimiento "dba".sp_fe_fin_vig_reg ******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_fe_fin_vig_reg
-- *****************************************************************************
revoke execute on "dba".sp_fe_fin_vig_reg from public;
grant execute on "dba".sp_fe_fin_vig_reg to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_fe_fin_vig_reg to internet; -- Rol de usuario de Internet
