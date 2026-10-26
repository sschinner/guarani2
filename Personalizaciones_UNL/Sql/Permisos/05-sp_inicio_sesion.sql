CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_inicio_sesion') THEN
		DROP PROCEDURE sp_inicio_sesion;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Procedimiento Original personalizado para restringir permisos a Roles
-- Inicialmente creado para Secretaria Academica
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Procedure de Inicio de Session
-- Setea el Modo de Lockeo, en espera.
-- 
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

CREATE PROCEDURE "dba".sp_inicio_sesion(pDB varchar(18))
BEGIN 
 DEFINE stienelog  char(1);
-- Verifico el Modo de la Base. Debe tener logging
 EXECUTE PROCEDURE sp_tiene_log(pDB) INTO stienelog;
 IF sTieneLog <> 'S' THEN
	raise exception -746,0,'La Base de Datos debe tener "Logging". Contacte al Administrador de BD';
 END IF;

-- Verfica si existen triggers desactivados,
 IF EXISTS (select '*' from sysobjstate obj
	join systables tab
	on obj.tabid = tab.tabid
 where objtype = 'T' and state = 'D') THEN
	raise exception -746,0,'Existen "Triggers" de la BD Desactivados. Contacte al Admin. de BD';
 END IF;


-- Modo de Lockeo.
 SET LOCK MODE TO WAIT 3;
 SET ROLE guarani;


END;
END PROCEDURE;

-- *****************************************************************************
-- Permisos del procedimiento 
-- *****************************************************************************
grant execute on "dba".sp_inicio_sesion to public;
-- grant execute on "dba".sp_inicio_sesion to guarani; -- Rol de usuarios de Gestion
-- grant execute on "dba".sp_inicio_sesion to internet; -- Rol de usuario de Internet
