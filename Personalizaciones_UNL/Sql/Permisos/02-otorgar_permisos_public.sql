-- *******************************************************************************
-- VALIDACION DE USUARIO CORRECTO PARA LA EJECUCION DEL SCRIPT
-- 
-- SI SALE UN MENSAJE DE ERROR, NO CONTINUE CON LA EJECUCION DEL SCRIPT
-- TIENE QUE VOLVER A LOGUEARSE AL SQL-EDITOR CON EL USUARIO 'dba'
-- *******************************************************************************
EXECUTE PROCEDURE sp_soy_dba();
-- *******************************************************************************
-- *****************************************************************************************
-- El siguiente script esta comentado en bloque, para que no sea contemplado en la migración
-- *****************************************************************************************
{
-- Se da permiso para que no de error el script que sigue mas abajo
select "grant select on " || tabname || " to public;"
	from systables
	where tabid >= 100 and tabname not like 'pbcat%'
	and owner = "dba";


--Se modifica el esquema de permisos 
select "revoke select on " || tabname || " from public;"
	from systables
	where tabid >= 100 and tabname not like 'pbcat%'
	and owner = "dba";

--Este grant se realiza para permitir la consulta a tablas de log, desde Guaraní (Operaciones de Auditoría)
select "grant select  on " || tabname || " to public;"
	from systables
	where tabid >= 100
	and tabname like "log_%"
	and owner = "dba";
grant select on app_versiones to public;
}
