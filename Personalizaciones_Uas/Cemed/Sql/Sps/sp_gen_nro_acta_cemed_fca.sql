CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_gen_nro_acta') THEN
		DROP PROCEDURE sp_gen_nro_acta;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

create procedure "dba".sp_gen_nro_acta
   (p_unidad_academica  LIKE sga_actas_examen.unidad_academica,
    p_materia LIKE sga_actas_examen.materia ,
    p_anio_academico LIKE sga_actas_examen.anio_academico ,
    p_turno_examen LIKE sga_actas_examen.turno_examen ,
    p_mesa_examen  LIKE sga_actas_examen.mesa_examen ,
    p_llamado  LIKE sga_actas_examen.llamado ,
    p_tipo_acta    LIKE  sga_actas_examen.tipo_acta,
    p_libro    LIKE  sga_actas_examen.libro) 
   returning varchar(10);
begin

   DEFINE acta LIKE sga_actas_examen.acta;
   DEFINE v_carrera LIKE sga_carreras.carrera;

   --------------------------------------------------------------
   -- Selecciono el maximo nro de Acta
   --------------------------------------------------------------

select carrera into v_carrera
	from sga_mesas_examen
	where unidad_academica = p_unidad_academica
		and anio_academico = p_anio_academico
		and turno_examen = p_turno_examen
		and mesa_examen = p_mesa_examen
		and materia = p_materia;

if not exists 
(select * from u820_ult_nro_acta where anio_academico = p_anio_academico and unidad_academica = p_unidad_academica and carrera = v_carrera) then
	insert into u820_ult_nro_acta (unidad_academica, carrera, anio_academico, proximo_nro, prox_nro_rec) values (p_unidad_academica, v_carrera, p_anio_academico, 1, 1);
end if;

if p_tipo_acta = "R" then
	select max(prox_nro_rec) into acta
	from u820_ult_nro_acta
	where anio_academico = p_anio_academico
		and unidad_academica = p_unidad_academica;

	let acta = "DRE" || lpad(acta, 4, '0')  || "/" || substr(p_anio_academico, 3);

	update u820_ult_nro_acta
	set prox_nro_rec = prox_nro_rec + 1
	where anio_academico = p_anio_academico
		and unidad_academica = p_unidad_academica;
else
	select max(proximo_nro) into acta
	from u820_ult_nro_acta
	where anio_academico = p_anio_academico
		and unidad_academica = p_unidad_academica
		and carrera = v_carrera;

	if v_carrera = '001' then
		let acta = "TA" || lpad(acta, 4, '0') || "/" || substr(p_anio_academico, 3);
	end if;
	if v_carrera = '005' then
		let acta = "TE" || lpad(acta, 4, '0') || "/" || substr(p_anio_academico, 3);
	end if;
	if v_carrera = '007' then
		let acta = "TP" || lpad(acta, 4, '0') || "/" || substr(p_anio_academico, 3);
	end if;
	if v_carrera = '' then
		let acta = "D" || lpad(acta, 4, '0') || "/" || substr(p_anio_academico, 3);
	end if;
	if v_carrera = '006' then
		let acta = "TAE" || lpad(acta, 4, '0') || "/" || substr(p_anio_academico, 3);
	end if;
	update u820_ult_nro_acta
	set proximo_nro = proximo_nro + 1
	where anio_academico = p_anio_academico
		and unidad_academica = p_unidad_academica
		and carrera = v_carrera;
end if;


return acta;
end;
end procedure;



-- *****************************************************************************
-- Permisos del procedimiento
-- *****************************************************************************
revoke execute on "dba".sp_gen_nro_acta from public;
grant execute on "dba".sp_gen_nro_acta to guarani; -- Rol de usuarios de Gestión
grant execute on "dba".sp_gen_nro_acta to internet; -- Usuario de internet
