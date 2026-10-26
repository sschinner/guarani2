-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.7.0
-- Procedure u820_cupo_subcomi;
-- 
-- Procedimiento de Actualizacion de cupos en forma automatica. Deberia haber un parametro nuevo que diga en cuanto actualizar, para que sea mas -- flexible.
-- *****************************************************************************
 
CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_cupo_subcomi') THEN
		DROP PROCEDURE u820_cupo_subcomi;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

CREATE PROCEDURE "dba".u820_cupo_subcomi(pComision LIKE sga_comisiones.comision)

BEGIN

	-- Defino las variables que voy a utilizar
	define v_anio_academico	like sga_comisiones.anio_academico;
	define v_periodo_lectivo	like sga_comisiones.periodo_lectivo;
	define v_materia		like sga_comisiones.materia;

	-- Cargo las variables con los datos de la comision
	select anio_academico, periodo_lectivo, materia into v_anio_academico, v_periodo_lectivo, v_materia
	from sga_comisiones
	where comision = pcomision;

if v_materia not in ('IA006', 'IRH06', 'IF001', 'IF004', 'IF003', 'IF002', 'AG004', 'PT005', 'IA008', 'IRH08', 'AG008', 'IF009') then -- Hago la actualización de cupos

-- Saco la capacidad por tipo de subcomision. 
-- Elimina los Tipos de Subcomisiones que tienen Null o 0 en alguna subcomision. En este caso, no se tiene que actualizar los cupos de las subcomisiones del tipo ese.

	select max(c.materia) as materia, s.comision, s.tipo_clase, sum(s.capacidad) as capacidad
	from sga_comisiones c
		left join sga_subcomisiones s
		on c.comision = s.comision
	
	where  s.insc_habilitada = "S"
		and c.comision = pComision 
		and materia || s.comision || s.tipo_clase Not In (select max(c.materia) || s.comision || s.tipo_clase
							from sga_comisiones c
							left join sga_subcomisiones s
							on c.comision = s.comision
			
			where  s.insc_habilitada = "S"
						and c.comision = pComision 
						and (s.capacidad Is Null or s.capacidad = 0)
						group by s.comision, s.tipo_clase)


	group by s.comision, s.tipo_clase
	into temp temp_cap;

-- Saco la cantidad de inscriptos por tipo de subcomision.

	select max(c.materia) as materia, s.comision, s.tipo_clase, count(*) as cantidad
	from sga_comisiones c
		left join sga_subcomisiones s
			left join sga_insc_subcom i
			  on s.comision = i.comision
			 and s.subcomision = i.subcomision 
		on c.comision = s.comision
	
	where  s.insc_habilitada = "S"
		and c.comision = pComision 
	group by s.comision, s.tipo_clase
	into temp temp_insc;

-- Saco los que tienen que actualizarse. Las cantidades de inscripciones existentes - las capacidades de las subcomisiones que tiene cupo.

	select t1.materia, t1.comision, t1.tipo_clase, t3.cantidad, t1.capacidad
	from temp_cap t1 join temp_insc t3
		on t1.comision = t3.comision
		and t1.tipo_clase = t3.tipo_clase
		and t1.materia = t3.materia
			
	where (t3.cantidad) >= (t1.capacidad)
	order by 1
	into temp temp_materias;

-- Actualizo los cupos de las subcomisiones.

	update sga_subcomisiones
	set capacidad = capacidad+5
	where comision||tipo_clase In (select comision||tipo_clase  from temp_materias);

	drop table temp_cap;
	drop table temp_insc;
	drop table temp_materias;
end if;

END;
END PROCEDURE
;
-- *********************** Fin del control "dba".u820_cupo_subcomi ***********************

-- *****************************************************************************
-- Permisos del Control "dba".u820_cupo_subcomi
-- *****************************************************************************
revoke execute on "dba".u820_cupo_subcomi from public;
grant execute on "dba".u820_cupo_subcomi to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_cupo_subcomi to internet; -- Rol de usuario de Internet

