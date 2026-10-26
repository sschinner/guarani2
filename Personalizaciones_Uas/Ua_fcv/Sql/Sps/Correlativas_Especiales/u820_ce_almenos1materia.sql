CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_ce_almenos1materia') THEN
		DROP PROCEDURE u820_ce_almenos1materia;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


--Drop procedure u820_ce_almenos1materia; 

-- *************************************************************************************************
-- Ultima modificacion: Version 2.9.1
-- *************************************************************************************************

Create procedure "dba".u820_ce_almenos1materia (v_unidad_acad	like sga_alumnos.unidad_academica,v_carrera	like sga_alumnos.carrera,v_legajo	like sga_alumnos.legajo,v_materia	like sga_actas_examen.materia,v_plan	like sga_alumnos.plan,v_version		like sga_actas_examen.version)

		returning smallint, varchar(255);
begin
define v_resu numeric(1);
define v_c_resu char(76);
define n_cant_ciclo integer;
define n_cant_apro integer;

 DEFINE iStatus 		smallint;	-- status
 DEFINE vcMsg 		varchar(255);	-- mensaje y parametros
 DEFINE vcUserError	varchar(100);

let v_c_resu = " ";


-- Obtiene la cantidad de materias del Ciclo Básico Aprobadas

Select count (*) Into n_cant_apro
From vw_hist_academica h 
Where resultado = "A"
	and h.unidad_academica = v_unidad_acad
	and h.carrera = v_carrera
	and h.legajo = v_legajo
	and materia not in ("10100","10101","10115","10116","10177","10088","10125","10087","CCP-B","CCP-M","CCP-Q","CCP-P","CCP-U");

-- *************************************************************************************************************************************
-- U820
-- Cantidad de materias aprobadas necesarios para pasar el control: se considera tener aprobada 1 materia de la carrera excepto las definidas arriba. 
-- *************************************************************************************************************************************
if v_plan = "2011" then 

	If n_cant_apro >= 1 Then
		let iStatus = 1;
		let vcMsg ='OK';
	else
		let  iStatus = -1;
		let vcUserError = '82007037';
		LET vcMsg = vcUserError;
	end if;
end if;


RETURN iStatus, vcMsg;
end;
end procedure;

--Execute procedure "dba".u820_ce_almenos1materia("FCV", "01", "38170638-3", "10007", 2011, 1)

-- ******************** FIN PROCESO u820_ce_almenos1materia ********************

revoke execute on "dba".u820_ce_almenos1materia from public;
grant execute on "dba".u820_ce_almenos1materia to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_ce_almenos1materia to internet; -- Rol de usuario de Internet