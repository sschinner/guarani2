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
   --------------------------------------------------------------
   -- Selecciono el maximo nro de Acta
   --------------------------------------------------------------

if not exists(select * from u820_ult_nro_acta) then
	insert into u820_ult_nro_acta values ("ISM", 1, 1);
end if;

if p_tipo_acta = "R" then
	select max(prox_nro_rec) into acta
	from u820_ult_nro_acta
	where unidad_academica = p_unidad_academica;

	let acta = "REC" || lpad(acta, 7, '0');

	update u820_ult_nro_acta
	set prox_nro_rec = prox_nro_rec + 1;

else

	select max(proximo_nro) into acta
	from u820_ult_nro_acta
	where unidad_academica = p_unidad_academica;

	let acta = lpad(acta, 7, '0');

	update u820_ult_nro_acta
	set proximo_nro = proximo_nro + 1;

end if;

return acta;

end;

end procedure;

-- *************** Fin del procedimiento "dba".sp_gen_nro_acta ******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_gen_nro_acta
-- *****************************************************************************
revoke execute on "dba".sp_gen_nro_acta from public;
grant execute on "dba".sp_gen_nro_acta to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_gen_nro_acta to internet; -- Rol de usuario de Internet