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
   RETURNING date;
	
-- Retorna la Fecha de fin de regularidad según pedido de FADU ticket #50304. 18 meses para todas las asignaturas.

Define n_periodo Varchar(20);
Define n_fecha_fin_per Date;

BEGIN

-- Obtener el período de dictado de la materia.

Select p.fecha_fin, c.periodo_lectivo Into n_fecha_fin_per, n_periodo
	From sga_comisiones c join
		sga_periodos_lect p
			on c.anio_academico = p.anio_academico
				and c.periodo_lectivo = p.periodo_lectivo
	where c.comision = p_comision;


if (month(n_fecha_fin_per)) <= 7 then
	RETURN MDY( 12,31,year(n_fecha_fin_per) + 1);
else
	RETURN MDY( 06,30,year(n_fecha_fin_per) + 2);
end if;



END

END PROCEDURE;

-- *************** Fin del procedimiento "dba".sp_fe_fin_vig_reg ******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_fe_fin_vig_reg
-- *****************************************************************************
revoke execute on "dba".sp_fe_fin_vig_reg from public;
grant execute on "dba".sp_fe_fin_vig_reg to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_fe_fin_vig_reg to internet; -- Rol de usuario de Internet
