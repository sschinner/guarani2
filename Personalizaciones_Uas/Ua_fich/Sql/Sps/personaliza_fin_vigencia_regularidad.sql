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
/*     define v_acta		like	sga_actas_cursado.acta;

select acta into v_acta
from sga_actas_cursado
where comision = p_comision;


select max(fecha_regularidad) into v_fecha_regul
from sga_det_acta_curs
where fecha_regularidad is not null
	and acta = v_acta;
*/

Select p.fecha_fin Into v_fecha_regul
	From sga_comisiones c join
		sga_periodos_lect p
			on c.anio_academico = p.anio_academico
				and c.periodo_lectivo = p.periodo_lectivo
	where c.comision = p_comision;

if v_fecha_regul is null then
	let v_fecha_regul = today;
end if;

if month(v_fecha_regul) <= 7 then
	RETURN MDY( 3,10,year(v_fecha_regul) + 2);
else
	RETURN MDY( 8,10,year(v_fecha_regul) + 2);
end if;

/*	
if month(v_fecha_regul) <= 3 then
	if day(v_fecha_regul) >30 and month(v_fecha_regul) + 9 in (4, 6, 9, 11) then
		return mdy(month(v_fecha_regul) + 9, 30, year(v_fecha_regul) + 1);
	end if;	

	if day(v_fecha_regul) >28 and month(v_fecha_regul) + 9 = 2 then
		return mdy(month(v_fecha_regul) + 9, 28, year(v_fecha_regul) + 1);
	end if;

	return mdy(month(v_fecha_regul) + 9, day(v_fecha_regul), year(v_fecha_regul) + 1);

else
	if day(v_fecha_regul) >30 and month(v_fecha_regul) - 3 in (4, 6, 9, 11) then
	
	return mdy(month(v_fecha_regul) - 3, 30, year(v_fecha_regul) + 2);
	end if;

	if day(v_fecha_regul) >28 and month(v_fecha_regul) - 3 = 2 then
		return mdy(month(v_fecha_regul) - 3, 28, year(v_fecha_regul) + 2);
	end if;

	return mdy(month(v_fecha_regul) - 3, day(v_fecha_regul), year(v_fecha_regul) + 2);
end if;
*/

END
PROCEDURE;
-- *************** Fin del procedimiento "dba".sp_fe_fin_vig_reg********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_fe_fin_vig_reg
-- *****************************************************************************
revoke execute on "dba".sp_fe_fin_vig_reg from public;
grant execute on "dba".sp_fe_fin_vig_reg to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_fe_fin_vig_reg to internet; -- Rol de usuario de Internet