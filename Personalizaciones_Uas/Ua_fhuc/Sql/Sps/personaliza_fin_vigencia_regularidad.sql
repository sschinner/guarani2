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

-- anuales pasan de 16 turnos de examen a 23 meses 
-- cuatrimestrales pasan de 14 tunos de examen a 20 meses 
-- seminarios cutrimestral del 1er cuatrimestre pasan de 12 turnos de examen a 17 meses 
-- seminarios cuatrimestral del 2do cuatrimestre pasan de 12 turnos de examen a 17 meses 
	
-- Retorna la Fecha de fin de regularidad según FCV. 5 Cuatrimestres. Para las asignaturas que se cursan en el 1er. Cuatrimestre, se le agregan los dos primeros turnos del año. Las del 2do. Cuatrimestre terminan justo en Agosto.
-- Segun resolucion para la Asignatura FISIOLOGIA (materia Anual) se amplio la regularidad a 6 Cuatrimestres
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

-- if vc_materia = '10010' then
-- 	RETURN MDY( month(n_fecha_fin_per), day(n_fecha_fin_per), year(n_fecha_fin_per) + 3);
-- else

if (month(n_fecha_fin_per)) <= 7 then
	if (SUBSTR(vc_nombre_materia,1, 9) = "Seminario") then
		RETURN MDY( 11,30,year(n_fecha_fin_per) + 1);       -- Materias con nombre Seminario: 17 meses
	else
		RETURN MDY( 3,1,year(n_fecha_fin_per) + 2);       -- Materias del 1er. Cuatrimestre: 20 meses
	end if;
else
	if (month(n_fecha_ini_per)) <= 4 then	
		RETURN MDY( 10,31,year(n_fecha_fin_per) + 2);	-- Materias Anuales: 23 meses
	else
		if (SUBSTR(vc_nombre_materia,1, 9) = "Seminario") then
			RETURN MDY( 4,30,year(n_fecha_fin_per) + 2);       -- Materias con nombre Seminario: 17 meses
		else
			RETURN MDY( 7,31,year(n_fecha_fin_per) + 2);	-- Materias del 2do. Cuatrimestre: 20 meses
		end if;
	end if;
end if;

END

END PROCEDURE;

-- *************** Fin del procedimiento "dba".sp_fe_fin_vig_reg ********************

REVOKE execute ON "dba".sp_fe_fin_vig_reg FROM public;
GRANT execute ON "dba".sp_fe_fin_vig_reg to guarani; -- Rol de usuarios de Gestion
GRANT execute ON "dba".sp_fe_fin_vig_reg to internet; -- Rol de usuario de Internet

-- EXECUTE PROCEDURE "dba".sp_fe_fin_vig_reg ("4688", null);    -- 1er. Cuatrimestre 2009
-- EXECUTE PROCEDURE "dba".sp_fe_fin_vig_reg ("5306", null);    -- 2do. Cuatrimestre 2009
-- EXECUTE PROCEDURE "dba".sp_fe_fin_vig_reg ("4743", null);    -- Seminario 1er. Cuatrimestre 2009
-- EXECUTE PROCEDURE "dba".sp_fe_fin_vig_reg ("5408", null);    -- Seminario 2do. Cuatrimestre 2009	