CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_cur_simul') THEN
		DROP PROCEDURE u820_cur_simul;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.7.0
-- Procedure u820_cur_simul 
-- Origen del requerimiento:
-- Usa a:
-- Hace uso de:
-- *****************************************************************************

create procedure "dba".u820_cur_simul(p_legajo like sga_alumnos.legajo, p_carrera like sga_alumnos.carrera, p_condicion char(1))
	returning char(15), char(30), char(30), char(5), char(30), char(5), char(5), char(30), char(5), int, char(5), char(60), char(1);

	-- DEFINE LAS VARIABLES QUE VA A UTILIZAR
	define v_legajo like sga_alumnos.legajo;
	define v_nombre_a like sga_personas.nombres;
	define v_apellido_a like sga_personas.apellido;
	define v_carrera_origen like sga_alumnos.carrera;
	define v_nombre_co like sga_carreras.nombre_reducido;
	define v_plan_origen like sga_alumnos.plan;
	define v_carrera_destino like sga_alumnos.carrera;
	define v_nombre_cd like sga_carreras.nombre_reducido;
	define v_plan_destino like sga_alumnos.plan;
	define v_grupo_equiv like sga_equiv_definida.grupo_equivalencia;
	define v_materia like sga_materia_equiv.materia;
	define v_nombre_m like sga_materias.nombre_reducido;
	define v_condicion like sga_materia_equiv.condicion;
	define v_seguir int;

	create temp table resultados (	legajo			char(15),
				apellido_a		char(30),
				nombre_a			char(30),
				carrera_origen		char(5),
				nombre_co		char(30),
				plan_origen		char(5),
				carrera_destino		char(5),
				nombre_cd		char(30),
				plan_destino		char(5), 
				grupo_equiv		int, 
				materia			char(5), 
				nombre_m		char(60), 
				condicion			char(1));

	-- CICLO CON LOS ALUMNOS CON CURSADO SIMULTANEO
	foreach 	select 	a1.legajo,
			p.apellido,
			p.nombres,
			a1.carrera as carrera_origen,
			c1.nombre_reducido as nombre_co,
			a1.plan as plan_origen,
			a2.carrera as carrera_destino,
			c2.nombre_reducido as nombre_cd,
			a2.plan as plan_destino

		into 	v_legajo,
			v_apellido_a,
			v_nombre_a,
			v_carrera_origen,
			v_nombre_co,
			v_plan_origen,
			v_carrera_destino,
			v_nombre_cd,
			v_plan_destino
		from sga_alumnos a1
			join sga_alumnos a2
				join sga_carreras c2
				  on a2.carrera = c2.carrera
			  on a1.legajo = a2.legajo
				and a1.carrera <> a2.carrera
				and a1.calidad = "A"
				and a1.regular = "S"
				and a2.calidad = "A"
				and a2.regular = "S"
			join sga_carreras c1
			  on a1.carrera = c1.carrera
			join sga_personas p
			  on a1.nro_inscripcion = p.nro_inscripcion
		where (a1.legajo = p_legajo or p_legajo = "")
			and (a2.carrera = p_carrera or p_carrera = "")

		-- CICLO POR CADA EQUIVALENCIA DEFINIDA EN LA MATRIZ PARA LA CARRERA DE ORIGEN Y DESTINO DEL ALUMNO
		foreach	select grupo_equivalencia
			into v_grupo_equiv
			from sga_equiv_definida
			where carrera_origen = v_carrera_origen
				and plan_origen = v_plan_origen
				and carrera = v_carrera_destino
				and plan = v_plan_destino
			and version in (select version_actual from sga_planes where carrera = v_carrera_destino and plan = v_plan_destino)

			-- SI EL ORIGEN O DESTINO TIENEN CONDICION 2, NO SE TOMAN EN CUENTA POR EL MOMENTO
			if not exists(	select *
					from sga_materia_equiv
					where grupo_equivalencia = v_grupo_equiv
						and condicion = "2") then
	
				let v_seguir = 1;

				-- VERIFICO QUE TENGA TODO LO NECESARIO EN EL ORIGEN DE LA EQUIVALENCIA ACTUAL
				foreach	select e.materia, e.condicion, m.nombre_reducido
					into v_materia, v_condicion, v_nombre_m
					from sga_materia_equiv e
						join sga_materias m
						  on e.materia = m.materia
					where e.origen_destino = "O"
						and e.grupo_equivalencia = v_grupo_equiv

					-- SI EL ORIGEN DEBE ESTAR APROBADO, VERIFICO QUE LO ESTÉ
					if v_condicion = "A" then
						if not exists(	select *
								from vw_hist_academica
								where legajo = v_legajo
									and carrera = v_carrera_origen
									and plan = v_plan_origen
									and materia = v_materia
									and resultado in ("A", "P")) then
							let v_seguir = 0;
							exit foreach;
						end if;
					end if;

					-- SI EL ORIGEN DEBE ESTAR REGULARIZADO, VERIFICO QUE LO ESTÉ
					if v_condicion = "R" then
						if not exists(	select *
								from sga_cursadas cu
									join sga_comisiones co
									  on cu.comision = co.comision
								where cu.legajo = v_legajo
									and cu.carrera = v_carrera_origen
									and cu.plan = v_plan_origen
									and co.materia = v_materia
									and cu.resultado in ("A", "P")
									and cu.fin_vigencia_regul > today)
----------------------------------------------------
								and not exists(	select *
										from sga_equiv_parcial
										where legajo = v_legajo
											and carrera = v_carrera_origen
											and plan = v_plan_origen
											and materia = v_materia
											and resultado in ("A", "P")
											and fin_de_vigencia > today) then
----------------------------------------------------
							let v_seguir = 0;
							exit foreach;
						end if;
					end if;
				end foreach;

				-- SI SEGUIR ESTÁ AÚN EN 1, ES PORQUE CUMPLE CON LOS REQUISITOS DE ORIGEN, HAY
				--	QUE VER SI TIENE LOS DESTINOS
				if v_seguir = 1 then

					-- CICLO CON LAS MATERIAS DE DESTINO QUE DEBE TENER
					foreach	select e.materia, e.condicion, m.nombre_reducido
						into v_materia, v_condicion, v_nombre_m
						from sga_materia_equiv e
							join sga_materias m
							  on e.materia = m.materia
						where e.origen_destino = "D"
							and e.grupo_equivalencia = v_grupo_equiv

						-- COMPRUEBO QUE TENGA LAS APROBADAS QUE DEBE TENER
						if v_condicion = "A" then
							if not exists(	select *
									from vw_hist_academica
									where legajo = v_legajo
										and carrera = v_carrera_destino
										and plan = v_plan_destino
										and materia = v_materia
										and resultado in ("A", "P")) then
								if exists(	select *
									from resultados
									where legajo = v_legajo
										and carrera_origen = v_carrera_origen
										and plan_origen = v_plan_origen
										and carrera_destino = v_carrera_destino
										and plan_destino = v_plan_destino
										and condicion = "R") then
									delete from resultados
									where legajo = v_legajo
										and carrera_origen = v_carrera_origen
										and plan_origen = v_plan_origen
										and carrera_destino = v_carrera_destino
										and plan_destino = v_plan_destino
										and condicion = "R";
								end if;
								insert into resultados values(v_legajo, v_apellido_a, v_nombre_a,
									v_carrera_origen, v_nombre_co, v_plan_origen,
									v_carrera_destino, v_nombre_cd, v_plan_destino, 
									v_grupo_equiv, v_materia, v_nombre_m,
									 v_condicion);
							end if;
						end if;

						-- COMPRUEBO QUE TENGA LAS REGULARIZADAS
						if v_condicion = "R" then
							if not exists(	select *
									from sga_cursadas cu
										join sga_comisiones co
										  on cu.comision = co.comision
									where cu.legajo = v_legajo
										and cu.carrera = v_carrera_destino
										and cu.plan = v_plan_destino
										and co.materia = v_materia
										and cu.resultado in ("A", "P")
										and cu.fin_vigencia_regul > today)
-----------------------------------------------------
									and not exists(	select *
											from sga_equiv_parcial
											where legajo = v_legajo
												and carrera = v_carrera_destino
												and plan = v_plan_destino
												and materia = v_materia
												and resultado in ("A", "P")
												and fin_de_vigencia > today) 
-----------------------------------------------------
									and not exists(	select *
											from vw_hist_academica
											where legajo = v_legajo
												and carrera = v_carrera_destino
												and plan = v_plan_destino
												and materia = v_materia
												and resultado in ("A", "P")) then
								if not exists(	select *
										from resultados
										where legajo = v_legajo
											and carrera_origen = v_carrera_origen
											and plan_origen = v_plan_origen
											and carrera_destino = v_carrera_destino
											and plan_destino = v_plan_destino
											and materia = v_materia
											and condicion = "A") then

										insert into resultados values(v_legajo, v_apellido_a,
											v_nombre_a, v_carrera_origen,
											 v_nombre_co, v_plan_origen, 
											v_carrera_destino, 
											v_nombre_cd, v_plan_destino, 
											v_grupo_equiv, v_materia, v_nombre_m,
											v_condicion);
								end if;
							end if;
						end if;
					end foreach;
				end if;
			end if;
		end foreach;
	end foreach;

	-- DEVUELVO LOS RESULTADOS
	foreach		select *
			into v_legajo, v_apellido_a, v_nombre_a,
				v_carrera_origen, v_nombre_co, v_plan_origen,
				v_carrera_destino, v_nombre_cd, v_plan_destino,
				v_grupo_equiv, v_materia, v_nombre_m,
				v_condicion
			from resultados
			where condicion = p_condicion or p_condicion = "T"
			order by 1, 4, 6, 7, 9, 11
		return v_legajo, v_apellido_a, v_nombre_a,
				v_carrera_origen, v_nombre_co, v_plan_origen,
				v_carrera_destino, v_nombre_cd, v_plan_destino,
				v_grupo_equiv, v_materia, v_nombre_m,
				v_condicion with resume;
	end foreach;

	drop table resultados;
end procedure;
-- *****************************************************************************
revoke execute on u820_cur_simul from public;

grant execute on u820_cur_simul to guarani; -- Rol de usuarios de Gestión
grant execute on u820_cur_simul to internet; -- Usuario de internet
