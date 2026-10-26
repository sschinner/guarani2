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
CREATE PROCEDURE "dba".sp_fe_fin_vig_reg(
	p_comision LIKE sga_comisiones.comision, 
	pFecha DATE)
--   (p_comision  LIKE sga_comisiones.comision)
returning date;
	
-- Retorna la Fecha de fin de regularidad según FIQ

DEFINE fecha_fin_per Date;
DEFINE v_materia LIKE sga_materias.materia;

LET fecha_fin_per = NULL;
LET v_materia = NULL;

-------------------------------------------------------------------------------------------------
-- Busco a qué materia corresponde la comisión y si esta materia pertenece o no a una genérica --
-------------------------------------------------------------------------------------------------
FOREACH SELECT unique(materia_generica)
			INTO v_materia
			FROM sga_opt_generica
			WHERE TRIM(materia_optativa)||TRIM(carrera)||TRIM(plan) IN (SELECT TRIM(materia)||TRIM(carrera)||TRIM(plan)
																	FROM sga_comisiones
																	WHERE comision = p_comision)
																	
			EXIT FOREACH;
END FOREACH;

IF (v_materia IS NULL) THEN
	-- Materia NO pertenece a una materia generica
		SELECT materia
			INTO v_materia
			FROM sga_comisiones
			WHERE comision = p_comision;
END IF;
	


------------------------------------------------------------------------------------
-- Defino la fecha de regularidad de la materia dependiendo a qué ciclo pertenece --
------------------------------------------------------------------------------------

-- ciclo intemedio y superior
SELECT distinct(p.fecha_fin)  
	INTO fecha_fin_per
	FROM sga_comisiones c 
		JOIN sga_periodos_lect p
		ON c.anio_academico = p.anio_academico
		AND c.periodo_lectivo = p.periodo_lectivo
			JOIN sga_atrib_mat_plan m
			ON m.materia = v_materia
			AND m.carrera = c.carrera
			AND m.plan = c.plan
				JOIN sga_ciclos_plan a
				ON a.carrera = m.carrera
				AND a.plan = m.plan
					JOIN sga_materias_ciclo ci
					ON ci.ciclo = a.ciclo
					AND ci.materia = m.materia
	WHERE  c.comision = p_comision 
	AND (
	-- Carrera: 00001; Plan: 1999
	a.ciclo="Q0011" or a.ciclo="Q0012" or a.ciclo="Q0013" or
	-- Carrera: 00002; Plan: 1999
	a.ciclo="M0003" or a.ciclo="M0004" or a.ciclo="M0005" or a.ciclo="M0006" or
	-- Carrera: 00003; Plan: 2000
	a.ciclo="L0004" or a.ciclo="L0013" or a.ciclo="L0012" or a.ciclo="L0011" or
	-- Carrera: 00003; Plan: 2000R
	a.ciclo="30002" or a.ciclo="30003" or a.ciclo="3CA04" or 
	-- Carrera: 00005; Plan: 1999
	a.ciclo="A0006" or a.ciclo="A0007" or a.ciclo="A0008" or
	-- Carrera: 00006; Plan: 1999
	a.ciclo="I0011" or a.ciclo="I0004" or a.ciclo="I0007" or a.ciclo="I0008" or
	-- Carrera: 00006; Plan: 1999R
	a.ciclo="I0013" or a.ciclo="I0014" or a.ciclo="I0015" or a.ciclo="I0016" or
	-- Carrera: 00006; Plan: 2008
	a.ciclo="60002" or a.ciclo="60003" or a.ciclo="60004" or a.ciclo="60005" or a.ciclo="60006" or
	-- Carrera: 00007; Plan: 1999
	a.ciclo="D0005" or a.ciclo="D0006" or
	-- Carrera: 00007; Plan: 2009
	a.ciclo="70002" or a.ciclo="70003" or
	-- Carrera: 00008; Plan: 2003
	a.ciclo="C0002" or
	-- Carrera: 00009; Plan: 2004
	a.ciclo="P0002" or a.ciclo="P0003" or a.ciclo="P0004" or a.ciclo="P0005" or
	-- Carrera: 00010; Plan: 2005
	a.ciclo="C0003" or
	-- Carrera: 00011; Plan: 2006
	a.ciclo="IM002" or a.ciclo="IM003" or a.ciclo="IM004" or
	-- Carrera: 00012; Plan: 2006
	a.ciclo="LM002" or a.ciclo="LM003" or a.ciclo="LM004" or
	-- Carrera: 90006; Plan: 2008
	a.ciclo="6AUNL"
	);

IF fecha_fin_per is not null THEN
	if month(fecha_fin_per)  < 8 then
		RETURN MDY( 8,31,year(fecha_fin_per) + 2);
	else
		RETURN MDY( 3,31,year(fecha_fin_per) + 3);
	end if;
END IF;

-- ciclo inicial

SELECT distinct(p.fecha_fin) 
	INTO fecha_fin_per
	FROM sga_comisiones c 
		JOIN sga_periodos_lect p
		ON c.anio_academico = p.anio_academico
		AND c.periodo_lectivo = p.periodo_lectivo
			JOIN sga_atrib_mat_plan m
			ON m.materia = v_materia
			AND m.carrera = c.carrera
			AND m.plan = c.plan
				JOIN sga_ciclos_plan a
				ON a.carrera = m.carrera
				AND a.plan = m.plan
					JOIN sga_materias_ciclo ci
					ON ci.ciclo = a.ciclo
					AND ci.materia = m.materia
	WHERE  c.comision = p_comision 
	AND ( 
	-- Carrera: 00001; Plan: 1999
	a.ciclo="Q0016" or 
	-- Carrera: 00002; Plan: 1999
	a.ciclo="M0001" or
	-- Carrera: 00003; Plan: 2000
	a.ciclo="L0003" or
	-- Carrera: 00003; Plan: 2000R
	a.ciclo="30001" or
	-- Carrera: 00005; Plan: 1999
	a.ciclo="A0010" or
	-- Carrera: 00006; Plan: 1999
	a.ciclo="I0010" or
	-- Carrera: 00006; Plan: 1999R
	a.ciclo="I0012" or
	-- Carrera: 00006; Plan: 2008
	a.ciclo="60001" or
	-- Carrera: 00007; Plan: 1999
	a.ciclo="D0001" or
	-- Carrera: 00007; Plan: 2009
	a.ciclo="70001" or
	-- Carrera: 00008; Plan: 2003
	a.ciclo="C0001" or
	-- Carrera: 00009; Plan: 2004
	a.ciclo="P0001" or 
	-- Carrera: 00011; Plan: 2006
	a.ciclo="IM001" or
	-- Carrera: 00012; Plan: 2006	
	a.ciclo="LM001"
	);

IF fecha_fin_per is not null THEN
	if month(fecha_fin_per)  < 8 then
		RETURN MDY( 8,31,year(fecha_fin_per) + 1);
	else
		RETURN MDY( 3,31,year(fecha_fin_per) + 2);
	end if;
ELSE 
	SELECT distinct(p.fecha_fin)  
		INTO fecha_fin_per
		FROM sga_comisiones c 
			JOIN sga_periodos_lect p
			ON c.anio_academico = p.anio_academico
			AND c.periodo_lectivo = p.periodo_lectivo
		WHERE  c.comision = p_comision;
	
	if month(fecha_fin_per) < 8 then
		RETURN MDY( 8,31,year(fecha_fin_per) + 2);
	else
		RETURN MDY( 3,31,year(fecha_fin_per) + 3);
	end if;	
END IF;

END PROCEDURE;

-- *************** Fin del procedimiento "dba".sp_fe_fin_vig_reg ******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_fe_fin_vig_reg
-- *****************************************************************************
revoke execute on "dba".sp_fe_fin_vig_reg from public;
grant execute on "dba".sp_fe_fin_vig_reg to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_fe_fin_vig_reg to internet; -- Rol de usuario de Internet