
-- *******************************************************************************
-- VALIDACION DE USUARIO CORRECTO PARA LA EJECUCION DEL SCRIPT
-- 
-- SI SALE UN MENSAJE DE ERROR, NO CONTINUE CON LA EJECUCION DEL SCRIPT
-- TIENE QUE VOLVER A LOGUEARSE AL SQL-EDITOR CON EL USUARIO 'dba'
-- *******************************************************************************
EXECUTE PROCEDURE sp_soy_dba();
-- *******************************************************************************

{
-- *****************************************************************************************************************************************************************************
-- SECCION PARA OBTENER POSIBLES PERMISOSOTORGADOS A siguv_consulta, Y QUE DEN PROBLEMAS AL INTENTAR CREAR EL ROL.
-- *****************************************************************************************************************************************************************************

select "revoke select, insert, update, delete, alter, index, references on " || tb.tabname || " from siguv_consulta;"
	from systables tb
		join systabauth ata
		on tb.tabid = ata.tabid
	where tb.tabid >= 100 and ata.grantee = "siguv_consulta"; 

select "revoke execute on "|| procname || " from siguv_consulta;" 
	from sysprocedures proc
		join sysprocauth aut
		on proc.procid = aut.procid
where mode in ('O', 'R') and aut.grantee = 'siguv_consulta' and procauth = 'e' and proc.owner = 'dba';

revoke connect from  siguv_consulta;

}


-- Verificar rol de consulta para siguv
CREATE PROCEDURE verifica_objeto()
BEGIN
	IF NOT EXISTS (SELECT username
			FROM sysusers
			WHERE username = 'siguv_consulta') THEN

			create role siguv_consulta;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE verifica_objeto();
DROP PROCEDURE verifica_objeto();


-- Doy permisos a tablas
-- grant select, insert, update on "dba".aca_usuarios_ag to siguv_consulta;
grant select, insert, update on "dba".sga_carrera_aspira to siguv_consulta;
grant select, insert, update on "dba".sga_personas to siguv_consulta;
grant select, insert, update on "dba".u820_adeuda_cuota to siguv_consulta;
grant select on "dba".sga_personas to siguv_consulta;
grant select on "dba".sga_alumnos to siguv_consulta;
grant select on "dba".vw_hist_academica to siguv_consulta;
grant select on "dba".sga_cursadas to siguv_consulta;
grant select on "dba".sga_comisiones to siguv_consulta;
grant select on "dba".sga_curs_pendiente to siguv_consulta;
grant select on "dba".sga_turnos_examen to siguv_consulta;
grant select on "dba".sga_insc_examen to siguv_consulta;
grant select on "dba".sga_atrib_mat_plan to siguv_consulta;
grant select on "dba".sga_carreras to siguv_consulta;
grant select on "dba".sga_llamados_mesa to siguv_consulta;
grant select on "dba".sga_prestamos to siguv_consulta;
grant select on "dba".sga_insc_cursadas to siguv_consulta;
grant select on "dba".sga_periodos_lect to siguv_consulta;

-- Doy permiso de ejecucion a SPs
grant execute on "dba".sp820_cambiarclaveag to siguv_consulta;
grant execute on "dba".sp820_insc_carr to siguv_consulta;
grant execute on "dba".sp820_migrar_alumno to siguv_consulta;
grant execute on "dba".sp_i_datos_censales_sur2 to siguv_consulta;
grant execute on "dba".sp_u_datos_personales to siguv_consulta;
grant execute on "dba".sp_param_sistema to siguv_consulta;
grant execute on "dba".sp_crea_datocensal to siguv_consulta;

-- Doy permisos a tablas
-- grant select, insert, update on "dba".aca_usuarios_ag to ue_siguv_guarani;
grant select, insert, update on "dba".sga_carrera_aspira to ue_siguv_guarani;
grant select, insert, update on "dba".sga_personas to ue_siguv_guarani;
grant select, insert, update on "dba".u820_adeuda_cuota to ue_siguv_guarani; 
grant select on "dba".sga_personas to ue_siguv_guarani;
grant select on "dba".sga_alumnos to ue_siguv_guarani;
grant select on "dba".vw_hist_academica to ue_siguv_guarani;
grant select on "dba".sga_cursadas to ue_siguv_guarani;
grant select on "dba".sga_comisiones to ue_siguv_guarani;
grant select on "dba".sga_curs_pendiente to ue_siguv_guarani;
grant select on "dba".sga_turnos_examen to ue_siguv_guarani;
grant select on "dba".sga_insc_examen to ue_siguv_guarani;
grant select on "dba".sga_atrib_mat_plan to ue_siguv_guarani;
grant select on "dba".sga_carreras to ue_siguv_guarani;
grant select on "dba".sga_llamados_mesa to ue_siguv_guarani;
grant select on "dba".sga_prestamos to ue_siguv_guarani;
grant select on "dba".sga_insc_cursadas to ue_siguv_guarani;
grant select on "dba".sga_periodos_lect to ue_siguv_guarani;

-- Doy permiso de ejecucion a SPs
grant execute on "dba".sp820_cambiarclaveag to ue_siguv_guarani;
grant execute on "dba".sp820_insc_carr to ue_siguv_guarani;
grant execute on "dba".sp820_migrar_alumno to ue_siguv_guarani;
grant execute on "dba".sp_i_datos_censales_sur2 to ue_siguv_guarani;
grant execute on "dba".sp_u_datos_personales to ue_siguv_guarani;
grant execute on "dba".sp_param_sistema to ue_siguv_guarani;
grant execute on "dba".sp_crea_datocensal to ue_siguv_guarani;

-- PERMISOS GUARANI
grant connect to ue_siguv_guarani;
grant siguv_consulta to ue_siguv_guarani;




