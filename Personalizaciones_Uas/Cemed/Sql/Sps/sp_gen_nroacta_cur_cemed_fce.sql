CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_gen_nroacta_cur') THEN
		DROP PROCEDURE sp_gen_nroacta_cur;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

create procedure "dba".sp_gen_nroacta_cur(p_unidad_academica  LIKE sga_actas_cursado.unidad_academica, 
    p_comision  LIKE sga_actas_cursado.comision, 
    p_libro  LIKE sga_actas_cursado.libro) 
   returning integer;

DEFINE  v_acta LIKE sga_actas_cursado.acta;
LET v_acta = 0;
   --------------------------------------------------------------
   -- Selecciono el maximo nro de Acta de la Tabla de Actas de Cursados
   --------------------------------------------------------------
   SELECT MAX(acta) INTO v_acta
	FROM sga_actas_cursado
	WHERE unidad_academica = p_unidad_academica;
   IF v_acta IS NULL or v_acta = 0 THEN  
	LET v_acta = 1;
   ELSE
      LET v_acta = v_acta + 1;
   END IF;
   RETURN v_acta;
end procedure;


-- *****************************************************************************
-- Permisos del procedimiento
-- *****************************************************************************
revoke execute on "dba".sp_gen_nroacta_cur from public;
grant execute on "dba".sp_gen_nroacta_cur to guarani; -- Rol de usuarios de Gestión
grant execute on "dba".sp_gen_nroacta_cur to internet; -- Usuario de internet
