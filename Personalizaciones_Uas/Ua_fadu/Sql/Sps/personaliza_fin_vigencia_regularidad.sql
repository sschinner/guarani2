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

	define v_anio_academico like sga_comisiones.anio_academico;

	if exists(select '' from sga_comisiones where comision = p_comision and materia in ("D0320", "A0336")) 
		then
			RETURN pFecha;
	else
		if exists(select '' from sga_comisiones where comision = p_comision and materia in ("C0308", "C0304")) 
			then
				select anio_academico into v_anio_academico
					from sga_comisiones
					where comision = p_comision;
			
					RETURN MDY(12,31,v_anio_academico + 2);
		else
			select anio_academico into v_anio_academico
				from sga_comisiones
				where comision = p_comision;
			
				RETURN MDY(12,31,v_anio_academico + 3);
		end if;
	end if;
END PROCEDURE;

-- *************** Fin del procedimiento  ******************

-- *****************************************************************************
-- Permisos del procedimiento 
-- *****************************************************************************
revoke execute on "dba".sp_fe_fin_vig_reg from public;
grant execute on "dba".sp_fe_fin_vig_reg to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_fe_fin_vig_reg to internet; -- Rol de usuario de Internet