CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_param_sistema') THEN
		DROP PROCEDURE sp_param_sistema;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ***************************************************************************************************************
-- Funcion que retorna el Valor del Parametro pasado como parametro segun la Unidad Academica 
-- del Usuario
-- 
-- ***************************************************************************************************************

create procedure "dba".sp_param_sistema (p_campo LIKE sga_param_sistema.parametro ) returning varchar(40);
Begin
  define lvalor LIKE sga_param_sistema.valor;
-- ***************************************************************************************
-- U820: se personaliza para evitar problemas con usuarios externos no creados en guarani.
-- ***************************************************************************************

--  SELECT TRIM(sga_param_sistema.valor) INTO lvalor
--	FROM sga_datos_usuarios, sga_param_sistema
--	WHERE sga_datos_usuarios.usuario = USER 
--	     AND sga_datos_usuarios.unidad_academica = sga_param_sistema.unidad_academica 
--	     AND  sga_param_sistema.parametro = p_campo;
  SELECT TRIM(sga_param_sistema.valor) INTO lvalor
	FROM sga_param_sistema
	WHERE sga_param_sistema.parametro = p_campo;
-- ***************************************************************************************
  IF DBINFO("sqlca.sqlerrd2") <= 0 THEN
     LET lvalor = NULL;
  END IF;
 RETURN lvalor;
End;
end procedure;
-- *****************************************************************************
-- Permisos del procedimiento
-- *****************************************************************************
-- revoke execute on "dba".sp_param_sistema from public;
grant execute on "dba".sp_param_sistema to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_param_sistema to siguv_consulta; -- Rol de usuarios de SIGUV
grant execute on "dba".sp_param_sistema to ue_siguv_guarani; -- Rol de usuarios de SIGUV
