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

CREATE PROCEDURE "dba".sp_fe_fin_vig_reg
   (p_comision  LIKE sga_comisiones.comision, pFecha  DATE)
   RETURNING date;
	
-- Retorna la Fecha de fin de regularidad

DEFINE fecha_fin_per Date;
DEFINE v_periodo_lectivo varchar(20);
Define vc_materia like sga_materias.materia;
Define vc_nombre_materia like sga_materias.nombre;


-- Obtener la materia de la comision
Select m.materia, m.nombre Into vc_materia, vc_nombre_materia
	from sga_comisiones c, sga_materias m
	where c.comision = p_comision
	and c.materia = m.materia;


Select p.fecha_fin, p.periodo_lectivo Into fecha_fin_per, v_periodo_lectivo
	From sga_comisiones c join
		sga_periodos_lect p
			on c.anio_academico = p.anio_academico
				and c.periodo_lectivo = p.periodo_lectivo
	where c.comision = p_comision;

	
if ((vc_materia == "TS001") or (vc_materia == "TS010") or (vc_materia == "TS013") or
	(vc_materia == "TS015") or (vc_materia == "TS017") or (vc_materia == "TS021") or
	(vc_materia == "TS028") or (vc_materia == "TS032")) then
		RETURN MDY( 10,1,year(fecha_fin_per) + 1);
	else
		RETURN MDY( month(fecha_fin_per),day(fecha_fin_per),year(fecha_fin_per) + 2);
end if;

END PROCEDURE;
-- *************** Fin del procedimiento "dba".sp_fe_fin_vig_reg  ******************

-- *****************************************************************************
-- Permisos del procedimiento 
-- *****************************************************************************
revoke execute on "dba".sp_fe_fin_vig_reg from public;
grant execute on "dba".sp_fe_fin_vig_reg to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_fe_fin_vig_reg to internet; -- Rol de usuario de Internet