CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_cambio_in_exa') THEN
		DROP PROCEDURE u820_cambio_in_exa;
	END IF;
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_cambio_in_exa') THEN
		DROP PROCEDURE sp820_cambio_in_exa;
	END IF;			
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- U820 *************************************************************************************************************************
-- Este procedimiento cambia el tipo de la condición de las inscripciones al momento de generar un acta de examen, por si estaba como 
--	libre y llegaron las listas de regularidad antes de crear el acta.
-- Una cosa es el tipo de inscripcion a la mesa (Libre o Regular) y otro es la condicion de Regularidad Obtenida en la materia.
-- U820 *************************************************************************************************************************
create procedure "dba".sp820_cambio_in_exa(Punidad_academica like sga_insc_examen.unidad_academica,
				Panio_academico like sga_insc_examen.anio_academico,
				Pturno_examen like sga_insc_examen.turno_examen,
				PMesa_examen like sga_insc_examen.mesa_examen,
				PLlamado like sga_insc_examen.llamado,
				PMateria like sga_insc_examen.materia)

 define a_nro	like sga_insc_examen.nro_transaccion;		--Almacena temporalmente el número de transaccion que se procesa
 define a_legajo	like sga_insc_examen.legajo;			--Almacena temporalmente el legajo que seprocesa
 define a_materia	like sga_insc_examen.materia;		--Almacena temporalmente la materia que se procesa
 define a_carrera	like sga_insc_examen.carrera;			--Almacena temporalmente la carrera de la inscripcion
 define a_ult_regul	like sga_cond_regular.resultado;		--Es en donde se pone la última regularidad del alumno/materia en que se inscribe
 define a_tipo_insc	like sga_insc_examen.tipo_inscripcion;		--Es el tipo de inscripcion que esta registrado
 define a_tipo_mesa	like sga_insc_examen.tipo_inscripcion;		--Es el tipo de inscripcion que acepta la mesa
 define a_fecha	like sga_det_acta_curs.fecha_regularidad;	--Es la ultima fecha en que se registro la regularidad de un alumno

 define a_unidad_academica	like sga_insc_examen.unidad_academica;	--Unidad académica de la inscripcion
 define a_anio_academico	like sga_insc_examen.anio_academico;		--Anio académico de la inscripcion
 define a_mesa		like sga_insc_examen.mesa_examen;		--Mesa de la inscripcion
 define a_mesa_nueva	like sga_insc_examen.mesa_examen;		--Variable donde se guardara la mesa en la que se debe colocar la insc.
 define a_turno		like sga_insc_examen.turno_examen;		--Turno de la inscripcion
define a_llamado 		like sga_insc_examen.llamado; -- Llamado de inscripcion


begin



	begin work;
	set triggers for sga_insc_examen disabled;
	--Recorre las inscripciones a procesar
	foreach
	select i.nro_transaccion, i.legajo, i.materia, i.unidad_academica, i.anio_academico, i.mesa_examen, i.turno_examen, i.llamado, i.carrera
		into a_nro, a_legajo, a_materia, a_unidad_academica, a_anio_academico, a_mesa, a_turno, a_llamado, a_carrera
	from sga_insc_examen i
		where i.unidad_academica = Punidad_academica and
		i.anio_academico = Panio_academico and		-- Para un año y turno especifico
		i.turno_examen = Pturno_examen and
		i.mesa_examen = Pmesa_examen and
		i.materia = Pmateria
		
		--Obtiene el/los tipos que acepta la mesa
		select admite_libres into a_tipo_mesa
		from sga_mesas_examen
		where unidad_academica = a_unidad_academica
			and materia = a_materia
			and anio_academico = a_anio_academico
			and turno_examen = a_turno
			and mesa_examen = a_mesa;

		--Obtiene el tipo de inscripcion actual
		select tipo_inscripcion into a_tipo_insc
		from sga_insc_examen
		where unidad_academica = a_unidad_academica
			and carrera = a_carrera
			and LEGAJO = a_legajo
		              	and MATERIA = a_materia
			and ANIO_ACADEMICO = a_anio_academico
			and TURNO_EXAMEN = a_turno
			and MESA_EXAMEN = a_mesa
			and LLAMADO = a_llamado;

		-- Esto se cambio para que tomara la vista de cursadas
		--Obtiene la ultimafecha de regularidad
		select max(fecha_regularidad) into a_fecha
		from sga_cursadas
		where legajo = a_legajo
			and materia = a_materia;

		--Obtiene la regularidad para la ultima fecha antes obtenida
		select max(resultado) into a_ult_regul
		from sga_cursadas
		where legajo = a_legajo
			and materia = a_materia
			and fecha_regularidad = a_fecha
			and fin_vigencia_regul > today;

		--Cambia el tipo de inscripcion y la mesa en caso de ser necesario
		if (a_tipo_insc = "L" and a_ult_regul = "A") then
			if a_tipo_mesa in ("A","R") then
				update sga_insc_examen
				set tipo_inscripcion = "R"
				where unidad_academica = a_unidad_academica
				and carrera = a_carrera
				and LEGAJO = a_legajo
			              	and MATERIA = a_materia
				and ANIO_ACADEMICO = a_anio_academico
				and TURNO_EXAMEN = a_turno
				and MESA_EXAMEN = a_mesa
				and LLAMADO = a_llamado;
			else
				--Obtiene la mesa para regulares
				select min(a.mesa_examen) into a_mesa_nueva
				from sga_mesas_examen m
					left join sga_actas_examen a
					  on m.turno_examen = a.turno_examen
						and m.mesa_examen = a.mesa_examen
						and m.anio_academico = a.anio_academico
				where m.unidad_academica = a_unidad_academica
					and m.materia = a_materia
					and m.anio_academico = a_anio_academico
					and m.turno_examen = a_turno
					and (m.carrera = a_carrera or m.carrera is null)
					and m.admite_libres in ("A","R")
					and a.mesa_examen is null;


				--Si encontro mesa, actualiza los campos

				if a_mesa_nueva is not null then
					
					update sga_insc_examen
					set tipo_inscripcion = "R",
						mesa_examen = a_mesa_nueva
					where unidad_academica = a_unidad_academica
					and carrera = a_carrera
					and LEGAJO = a_legajo
				              	and MATERIA = a_materia
					and ANIO_ACADEMICO = a_anio_academico
					and TURNO_EXAMEN = a_turno
					and MESA_EXAMEN = a_mesa
					and LLAMADO = a_llamado;
					
				end if;
			end if;
		    elif (a_tipo_insc = "R" and a_ult_regul != "A") then
			if a_tipo_mesa in ("A","L") then
				update sga_insc_examen
				set tipo_inscripcion = "L"
				where unidad_academica = a_unidad_academica
				and carrera = a_carrera
				and LEGAJO = a_legajo
			              	and MATERIA = a_materia
				and ANIO_ACADEMICO = a_anio_academico
				and TURNO_EXAMEN = a_turno
				and MESA_EXAMEN = a_mesa
				and LLAMADO = a_llamado;


			else
				--Obtiene la mesa para libres
				select min(m.mesa_examen) into a_mesa_nueva
				from sga_mesas_examen m
					left join sga_actas_examen a
					  on m.turno_examen = a.turno_examen
						and m.mesa_examen = a.mesa_examen
						and m.anio_academico = a.anio_academico
				where m.unidad_academica = a_unidad_academica
					and m.materia = a_materia
					and m.anio_academico = a_anio_academico
					and m.turno_examen = a_turno
					and (m.carrera = a_carrera or m.carrera is null)
					and m.admite_libres in ("L", "A")
					and a.mesa_examen is null;

				--Si encontro mesa, actualiza los campos
				if a_mesa_nueva is not null then
					
					update sga_insc_examen
					set tipo_inscripcion = "L",
						mesa_examen = a_mesa_nueva
					where unidad_academica = a_unidad_academica
					and carrera = a_carrera
					and LEGAJO = a_legajo
				              	and MATERIA = a_materia
					and ANIO_ACADEMICO = a_anio_academico
					and TURNO_EXAMEN = a_turno
					and MESA_EXAMEN = a_mesa
					and LLAMADO = a_llamado;
					
				end if;
			end if;
		end if;

	end foreach;

	commit work;
set triggers for sga_insc_examen enabled;
end;

end procedure;

-- *****************************************************************************

-- Permisos del procedimiento "dba".sp820_cambio_in_exa

-- *****************************************************************************
revoke execute on "dba".sp820_cambio_in_exa from public;
grant execute on "dba".sp820_cambio_in_exa to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_cambio_in_exa to internet; -- Rol de usuario de Internet