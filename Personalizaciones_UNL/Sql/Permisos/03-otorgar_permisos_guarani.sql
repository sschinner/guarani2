-- *******************************************************************************
-- VALIDACION DE USUARIO CORRECTO PARA LA EJECUCION DEL SCRIPT
-- 
-- SI SALE UN MENSAJE DE ERROR, NO CONTINUE CON LA EJECUCION DEL SCRIPT
-- TIENE QUE VOLVER A LOGUEARSE AL SQL-EDITOR CON EL USUARIO 'dba'
-- *******************************************************************************
EXECUTE PROCEDURE sp_soy_dba();
-- *******************************************************************************
--select * from systabauth where grantee = 'guarani';
--select * from systables where tabid = 1026;
--select * from sysusers where username = 'guarani';

CREATE PROCEDURE verifica_objeto()
BEGIN
	IF NOT EXISTS (SELECT username
			FROM sysusers
			WHERE username = 'guarani') THEN

			create role guarani;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE verifica_objeto();
DROP PROCEDURE verifica_objeto();

-- *****************************************************************************************
-- El siguiente script esta comentado en bloque, para que no sea contemplado en la migración
-- *****************************************************************************************
{
-- select "grant select  on " || tabname || " to guarani;"
select "grant select  on " || tabname || " to internet; " || "grant select  on " || tabname || " to guarani;"
	from systables
	where tabid >= 100
	and tabname like "log_%"
	and owner = "dba";

-- select "grant select, update, insert, delete, alter, index, references on " || tabname || " to guarani;"
select "grant select, update, insert, delete on " || tabname || " to internet; " || "grant select, update, insert, delete on " || tabname || " to guarani;"
	from systables
	where tabid >= 100
	and tabname not like "log_%"
	and tabtype = "T"
	and owner = "dba";

-- select "grant select on " || tabname || " to guarani;"
select "grant select on " || tabname || " to internet; " || "grant select on " || tabname || " to guarani;"
	from systables
	where tabid >= 100
	and tabname not like "log_%"
	and tabtype = "V"
	and owner = "dba";

-- Permisos particulares para la personalización de Prorrogas de Cursado
-- Por algun motivo no toma el permiso de select del role guarani.
-- grant select on u831_prorrogas  to public;
grant select on sga_det_acta_curs  to public;  
grant select on sga_actas_cursado to public;   
grant select on sga_materias  to public;
grant select on sga_comisiones  to public;
grant select on sga_certificados TO public;

-- Procedimientos
select "revoke execute on "|| procname || " from public;" 
	from sysprocedures proc
		join sysprocauth aut
		on proc.procid = aut.procid
where mode in ('O', 'R') and aut.grantee = 'public' and procauth = 'e' and proc.owner = 'dba';

select "revoke execute on "|| procname || " from guarani;" 
	from sysprocedures proc
		join sysprocauth aut
		on proc.procid = aut.procid
where mode in ('O', 'R') and aut.grantee = 'guarani' and procauth = 'e' and proc.owner = 'dba';

select "grant execute on "|| procname || " to guarani;" 
from sysprocedures where mode in ('O', 'R') and owner = 'dba';

select "grant execute on "|| procname || " to internet;" 
from sysprocedures where mode in ('O', 'R') and owner = 'dba';

}
