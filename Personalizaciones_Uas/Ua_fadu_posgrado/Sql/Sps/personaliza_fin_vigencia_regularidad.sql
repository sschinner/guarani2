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

CREATE PROCEDURE "dba".sp_fe_fin_vig_reg
	(p_comision  LIKE sga_comisiones.comision, pFecha  DATE)
	RETURNING date;

DEFINE fecha_fin_per Date;

Select p.fecha_fin Into fecha_fin_per
	From sga_comisiones c join
		sga_periodos_lect p
			on c.anio_academico = p.anio_academico
				and c.periodo_lectivo = p.periodo_lectivo
	where c.comision = p_comision;
	
RETURN MDY(month(fecha_fin_per),day(fecha_fin_per),year(fecha_fin_per));

END PROCEDURE;

-- *************** Fin del procedimiento  ******************

-- *****************************************************************************
-- Permisos del procedimiento 
-- *****************************************************************************
revoke execute on "dba".sp_fe_fin_vig_reg from public;
grant execute on "dba".sp_fe_fin_vig_reg to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_fe_fin_vig_reg to internet; -- Rol de usuario de Internet