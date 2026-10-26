CREATE PROCEDURE verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_gen_nro_acta') THEN
		DROP PROCEDURE sp_gen_nro_acta;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE verifica_objeto();
DROP PROCEDURE verifica_objeto();


create procedure "dba".sp_gen_nro_acta(p_unidad_academica  LIKE sga_actas_examen.unidad_academica,
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
   DEFINE danio_acta LIKE sga_turnos_examen.anio_academico;
   --------------------------------------------------------------
   -- Selecciono el maximo nro de Acta
   --------------------------------------------------------------
-- select Year(fecha_inicio) Into danio_acta From sga_turnos_examen where anio_academico = p_anio_academico and turno_examen = p_turno_examen;

-- if not exists (select * from u820_ult_nro_acta where anio_academico = danio_acta  and unidad_academica = p_unidad_academica) then
--	insert into u820_ult_nro_acta (unidad_academica, anio_academico, proximo_nro, prox_nro_rec) values (p_unidad_academica, danio_acta , 1, 1);
-- end if;

if p_tipo_acta = "R" then
	select max(prox_nro_rec) into acta
	from u820_ult_nro_acta
	where unidad_academica = p_unidad_academica;
--		and anio_academico = danio_acta

	let acta = "REC" || lpad(acta, 6, '0');

	update u820_ult_nro_acta
	set prox_nro_rec = prox_nro_rec + 1
	where unidad_academica = p_unidad_academica;
--		and anio_academico = danio_acta 
else
	select max(proximo_nro) into acta
	from u820_ult_nro_acta
	where unidad_academica = p_unidad_academica;
--		and anio_academico = danio_acta

--	let acta = lpad(acta, 6, '0');

	update u820_ult_nro_acta
	set proximo_nro = proximo_nro + 1
	where unidad_academica = p_unidad_academica;
--		and anio_academico = danio_acta
end if;


return acta;
end;
end procedure;


-- execute procedure sp_gen_nro_acta   ('FADU',    'A0101' ,    2002,    'Unico',    '',    1,    'N',    '') 

