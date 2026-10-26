CREATE PROCEDURE verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_fe_fin_vig_reg') THEN
		DROP PROCEDURE sp_fe_fin_vig_reg;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE verifica_objeto();
DROP PROCEDURE verifica_objeto();

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
--DROP PROCEDURE "dba".sp_fe_fin_vig_reg;
CREATE PROCEDURE "dba".sp_fe_fin_vig_reg
   (p_comision  LIKE sga_comisiones.comision, pFecha  DATE)
   RETURNING date;
-- Retorna la Fecha de fin de regularidad

Define n_periodo Varchar(20);
Define n_fecha_fin_per Date;
Define n_fecha_ini_per Date;
Define vc_materia like sga_materias.materia;
Define vc_nombre_materia like sga_materias.nombre;

BEGIN
-- Obtener el período de dictado de la materia.
Select p.fecha_inicio, p.fecha_fin, c.periodo_lectivo Into n_fecha_ini_per, n_fecha_fin_per, n_periodo
	From sga_comisiones c join
		sga_periodos_lect p
			on c.anio_academico = p.anio_academico
				and c.periodo_lectivo = p.periodo_lectivo
	where c.comision = p_comision;

-- Obtener la materia de la comision
Select m.materia, m.nombre Into vc_materia, vc_nombre_materia
	from sga_comisiones c, sga_materias m
	where c.comision = p_comision
	and c.materia = m.materia;

	
if (month(n_fecha_fin_per)) >= 10 then
	if (month(n_fecha_ini_per)) <= 4 then	
		RETURN MDY( 10,1,year(n_fecha_fin_per) + 1);	-- Materias Anuales: 1 Año
	end if;
end if;

	RETURN MDY( 7,31,year(n_fecha_fin_per) + 2);	-- Materias Cuatrimestrales (VER!!!)

END

END PROCEDURE;



