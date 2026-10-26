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


-- POSIBLE PROCEDIMIENTO A BORRAR QUE SE DUPLICA EN LA MIGRACION. NO ESTOY SEGURO DONDE
-- Correccion en Presencial
select * from sysprocedures where procname like "sp_i_encuesta";
drop procedure sp_i_encuesta (char,char,char,char,char,char,char);


select "revoke select, insert, update, delete, alter, index, references on " || tb.tabname || " from public;"
	from systables tb
		join systabauth ata
		on tb.tabid = ata.tabid
	where tb.tabid >= 100 and ata.grantee = "public" and ata.tabauth <> "s--------" and ata.tabauth <> "S--------" and tabname not like 'pbcat%' and tb.owner = "dba";


-- Tablas a corregir el owner o eliminar si son temporales. Si son vistas se deben recrear con owner dba.
select * from systables
	where tabid >= 100 and owner <> 'dba' and tabname not like 'pbcat%';

}



-- SOLO PARA CEMED: Este revoke es para que se pueda crear el role guarani en CEMED y eliminar el usuario guarani
{
select "revoke select, insert, update, delete, alter, index, references on " || tb.tabname || " from guarani;"
	from systables tb
		join systabauth ata
		on tb.tabid = ata.tabid
	where tb.tabid >= 100 and ata.grantee = "guarani"; 

select "revoke execute on "|| procname || " from guarani;" 
	from sysprocedures proc
		join sysprocauth aut
		on proc.procid = aut.procid
where mode in ('O', 'R') and aut.grantee = 'guarani' and procauth = 'e' and proc.owner = 'dba';

revoke DBA from guarani;
revoke connect from guarani;

revoke DBA from uguarani;
revoke connect from uguarani;


-- Problema de script /Personalizaciones_Uas/Cemed/Sql/Sps/sp820_cambiarclaveag.sql
-- Ejecutar este script desde sqleditor

}


