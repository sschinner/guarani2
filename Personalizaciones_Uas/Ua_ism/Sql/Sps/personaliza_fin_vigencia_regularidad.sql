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
    define v_fecha_regul	like	sga_det_acta_curs.fecha_regularidad;


Select p.fecha_fin Into v_fecha_regul
	From sga_comisiones c join
		sga_periodos_lect p
			on c.anio_academico = p.anio_academico
				and c.periodo_lectivo = p.periodo_lectivo
	where c.comision = p_comision;

if v_fecha_regul is null then
	let v_fecha_regul = today;
end if;

-- ISM: Extender la regularidad por 26 meses (18 turnos de examenes)
if month(v_fecha_regul) <= 7 then
	RETURN MDY( 8,1,year(v_fecha_regul) + 2);
else
	RETURN MDY( 12,31,year(v_fecha_regul) + 2);
end if;

END
PROCEDURE;
-- *************** Fin del procedimiento "dba".sp_fe_fin_vig_reg********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_fe_fin_vig_reg
-- *****************************************************************************
revoke execute on "dba".sp_fe_fin_vig_reg from public;
grant execute on "dba".sp_fe_fin_vig_reg to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_fe_fin_vig_reg to internet; -- Rol de usuario de Internet
