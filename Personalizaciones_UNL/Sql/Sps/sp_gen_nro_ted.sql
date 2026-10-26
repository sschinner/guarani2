CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_gen_nro_ted') THEN
		DROP PROCEDURE sp_gen_nro_ted;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ************************ PROCEDURE sp_gen_nro_ted ************************ 
-- Este procedimiento calcula el nro. de expediente del tramite, si es que no se colocó uno en el formulario de carga.
-- Para UNL, para unificar, se propone que sea el nro. expediente otorgado por Mesa de Entrada.
-- ***************************************************************************************
-- Creating procedure
CREATE PROCEDURE "dba".sp_gen_nro_ted( p_unidad_academica  LIKE sga_titulos_otorg.unidad_academica ) 
       RETURNING varchar(20);


  DEFINE iNroTED   integer;
  DEFINE vcNroTED  varchar(20);


  BEGIN
   

-- **************************************
-- U820: Para UNL, se propone que sea el nro. expediente otorgado por Mesa de Entrada.
-- **************************************

   LET vcNroTED = 'S/N';

   RETURN vcNroTED;

END;

END PROCEDURE;
-- *****************************************************************************
revoke execute on "dba".sp_gen_nro_ted from public;
grant execute on "dba".sp_gen_nro_ted to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_gen_nro_ted to internet; -- Rol de usuario de Internet
