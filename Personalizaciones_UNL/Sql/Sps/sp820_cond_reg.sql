CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_cond_reg') THEN
		DROP PROCEDURE sp820_cond_reg;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.7.0
-- Procedure sp820_cond_reg 
-- 
-- Procedimiento que recalcula la condición de regularidad del alumno.
-- Asociado al Trigger de Inserción en sga_detalle_acta
-- Es probable que durante la inscripción a exámenes, no se llegue con la carga de regularidades, por lo que
-- se debe recalcular esta condición al momento de generar el detalle del acta de exámen
-- *****************************************************************************
CREATE PROCEDURE "dba".sp820_cond_reg(
       n_tipo_acta like sga_actas_examen.tipo_acta,
       n_acta like sga_detalle_acta.acta,
       n_legajo like sga_detalle_acta.legajo)

RETURNING integer;

Define n_cond int;
Define n_materia varchar(5);
Define n_fecha Date;

BEGIN

	SELECT materia Into n_materia
		FROM	dba.sga_actas_examen
		WHERE  acta = n_acta
				and tipo_acta = n_tipo_acta;

	-- Obtiene la ultima regularidad adquirida.

	SELECT max (fecha_regularidad)  
		Into n_fecha
		FROM sga_cursadas
		WHERE legajo= n_legajo
		AND materia = n_materia;

	-- Obtiene la condición de la que aún esta vigente.

	SELECT max (case when cond_regularidad = 0 then
				case when resultado = 'A' then 4
				else 1
				end
				else cond_regularidad
				end)
		Into n_cond
		FROM sga_cursadas
		WHERE legajo = n_legajo  
		AND materia = n_materia  
		AND fecha_regularidad = n_fecha 
		AND fin_vigencia_regul >= Today
		-- Se agrega filtro para CAPIC: si la regularidad la obtuvo en otra UA, la inscripción se inserta como Libre.
		AND (nro_resolucion <> 'Equiv Capic' OR nro_resolucion is null OR nro_resolucion = '');

	If n_cond Is null Then
		Let n_cond = 1;
	End if;

END;
return n_cond;
END PROCEDURE;
-- *****************************************************************************

revoke execute on sp820_cond_reg from public;
grant execute on sp820_cond_reg to guarani; -- Rol de usuarios de Gestión
grant execute on sp820_cond_reg to internet; -- Usuario de internet

