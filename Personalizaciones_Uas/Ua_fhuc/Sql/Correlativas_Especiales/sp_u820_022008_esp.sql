CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_022008_esp') THEN
		DROP PROCEDURE u820_022008_esp;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


--drop procedure "dba".u820_022008_esp;
create procedure "dba".u820_022008_esp(	v_unidad_acad	like sga_alumnos.unidad_academica,
					v_carrera		like sga_alumnos.carrera,
					v_legajo		like sga_alumnos.legajo,
					v_materia		like sga_actas_examen.materia,
					v_plan		like sga_alumnos.plan,
					v_version		like sga_actas_examen.version)
				
		returning smallint, varchar(255);



DEFINE sqlerr		integer;
DEFINE isamerr		integer;
DEFINE errorinfo		varchar(76);
DEFINE v_resu		numeric(1);
DEFINE v_c_resu		char(76);
DEFINE v_cantidad		numeric(5);

DEFINE vcTitulo LIKE sga_titulos.titulo;
DEFINE sResulProc char(1);
DEFINE sCreditos integer; -- Variable nueva de la versión 2.06 que devuelve los creditos de la materia generica


-- si hay algun error
ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo
	RETURN -1, errorInfo;
END EXCEPTION;

BEGIN
	
LET v_resu = 1;
LET v_c_resu = "";
LET sResulProc = '';
LET sCreditos = 0;
LET v_cantidad = 0;

	select distinct materia
	from vw_hist_academica 
	where legajo =v_legajo
		and resultado = 'A'
		and materia in ("BIO01", "BIO02", "BIO03", "BIO04", "BIO05", "BIO06", "BIO07", "BIO08", "BIO09", "BIO10", "BIO11", "BIO12", "FD003", "FG004", "FG001", "FG002", "FG003") 
	Into Temp aux_materias;

-- Recupero el Titulo de Grado del Plan-Version
	SELECT sga_orientaciones.titulo
		INTO vcTitulo
		FROM sga_orientaciones, sga_titulos
		WHERE sga_orientaciones.unidad_academica = v_unidad_acad
		AND sga_orientaciones.carrera = v_carrera
		AND sga_orientaciones.plan = v_plan
		AND sga_orientaciones.orientacion = '0'
		AND sga_orientaciones.unidad_academica = sga_titulos.unidad_academica
		AND sga_orientaciones.titulo = sga_titulos.titulo
		AND sga_titulos.nivel = 'GRADO';
		
	EXECUTE PROCEDURE sp_resultGenerica(v_unidad_acad, v_carrera, v_legajo, vcTitulo, '0', "OLBAB") INTO sResulProc, sCreditos;
	
	select count(*) into v_cantidad
	from aux_materias h;
	
	IF sResulProc == 'A' THEN
		LET v_cantidad = v_cantidad + 1;
	END IF;


	if v_cantidad < 8 then
		let v_resu = -1;
		let v_c_resu = '82001000';
	end if;

	drop table aux_materias;
	return v_resu, v_c_resu;
end;

end procedure;

-- *************** Fin del procedimiento "dba".u820_022008_esp ********************

REVOKE execute ON "dba".u820_022008_esp FROM public;
GRANT execute ON "dba".u820_022008_esp to guarani; -- Rol de usuarios de Gestion
GRANT execute ON "dba".u820_022008_esp to internet; -- Rol de usuario de Internet
