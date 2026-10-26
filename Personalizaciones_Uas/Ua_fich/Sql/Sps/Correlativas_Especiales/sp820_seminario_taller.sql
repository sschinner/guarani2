CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_ce_sem_taller') THEN
		DROP PROCEDURE u820_ce_sem_taller;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();
 
create procedure "dba".u820_ce_sem_taller(	v_unidad_acad	like sga_alumnos.unidad_academica,
				v_carrera		like sga_alumnos.carrera,
				v_legajo		like sga_alumnos.legajo,
				v_materia		like sga_actas_examen.materia,
				v_plan		like sga_alumnos.plan,
				v_version		like sga_actas_examen.version)
				
		returning smallint, varchar(255);
begin
define v_resu numeric(1);
define v_c_resu char(76);

let v_c_resu = " ";

if exists(	select *
	from sga_alumnos
	where legajo = v_legajo
		and  year(fecha_ingreso) < 2002) then

	let v_resu = 1;
else
	if exists(	select a.fecha_ingreso, da.resultado, da.nota
		from sga_alumnos a
			join sga_detalle_acta da
				join sga_actas_examen ae
				  on da.acta = ae.acta
			  on a.legajo = da.legajo
		where da.resultado = "A"
			and a.carrera = v_carrera
			and a.legajo = v_legajo
			and ae.materia = "00418")
		or exists(
		select a.fecha_ingreso, dap.resultado, dap.nota
		from sga_alumnos a
			join sga_det_acta_promo dap
				join sga_actas_promo ap
					join sga_comisiones c
					  on ap.comision = c.comision
				  on dap.acta = ap.acta
			  on a.legajo = dap.legajo
		where dap.resultado = "A"
			and a.carrera = v_carrera
			and a.legajo = v_legajo
			and c.materia = "00418")
		or exists(
		select a.fecha_ingreso, eo.resultado, eo.nota
		from sga_alumnos a
			join sga_equiv_otorgada eo
			  on a.legajo = eo.legajo
		where eo.resultado = "A"
			and a.carrera = v_carrera
			and a.legajo = v_legajo
			and eo.materia = "00418") then

		let v_resu = 1;
	else
		let v_resu = -1;
		let v_c_resu = "No ha aprobado la materia SEMINARIO TALLER y es ingresante 2002 o posterior";
	end if;
end if;

return v_resu, v_c_resu;
end;
end procedure;
-- *************** Fin del procedimiento "dba".u820_ce_sem_taller ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".u820_ce_sem_taller
-- *****************************************************************************
revoke execute on "dba".u820_ce_sem_taller from public;
grant execute on "dba".u820_ce_sem_taller to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_ce_sem_taller to internet; -- Rol de usuario de Internet