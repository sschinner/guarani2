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
   DEFINE nro_acta INTEGER;

   --------------------------------------------------------------
   -- Selecciono el maximo nro de Acta
   --------------------------------------------------------------
   SELECT MAX(lpad(ae.acta, 10, '0')) INTO acta
	FROM sga_actas_examen ae
	WHERE ae.unidad_academica = p_unidad_academica
	 AND  ae.tipo_acta = p_tipo_acta
	 AND  ae.acta < 'A';

   IF acta IS NULL or acta = '' THEN  
	LET nro_acta = 1;
   ELSE
      LET nro_acta = TRIM(acta);
      LET nro_acta = nro_acta + 1;
   END IF;
   RETURN nro_acta;
end;
end procedure;

-- *****************************************************************************
-- Permisos del procedimiento
-- *****************************************************************************
revoke execute on "dba".sp_gen_nro_acta from public;
grant execute on "dba".sp_gen_nro_acta to guarani; -- Rol de usuarios de Gestión
grant execute on "dba".sp_gen_nro_acta to internet; -- Usuario de internet
