CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_prof_fil_8_mat') THEN
		DROP PROCEDURE u820_prof_fil_8_mat;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();




--execute procedure u820_Prof_fil_8_mat('FHUC','12','37420895-4','',,)

--Drop procedure u820_Prof_fil_8_mat; 

Create procedure "dba".u820_Prof_fil_8_mat (v_unidad_acad	like sga_alumnos.unidad_academica,v_carrera	like sga_alumnos.carrera,v_legajo	like sga_alumnos.legajo,v_materia	like sga_actas_examen.materia,v_plan	like sga_alumnos.plan,v_version		like sga_actas_examen.version)

		returning smallint, varchar(255);
begin
define v_resu numeric(1);
define v_c_resu char(76);
define n_cant_ciclo integer;
define n_cant_apro integer;



let v_c_resu = " ";
let v_resu=NULL;

-- Obtiene la cantidad de materias del Ciclo Básico Aprobadas

Select count (*) Into n_cant_apro
From vw_hist_academica h 
Where resultado = "A"
	and h.unidad_academica = v_unidad_acad
	and h.carrera = v_carrera
	and h.legajo = v_legajo
	and materia in ("FIL01","FIL02","FIL03", "FIL04", "FIL11", "FIL12", "FIL13", "PF001", "PF002", "FG003", "FIL08", "FIL09", "FIL10",  "FIL14", "FIL47", "HIS01", "HIS02", "HIS11", "HIS18","HIS23","LET01", "LET02", "LET06",  "LET07", "LET10", "MAT01", "OF02", "SOC03", "SOC04", "FG002", "LET30", "LET08", "LET31", "LET28");

-- *************************************************************************************************************************************
-- U820
-- Cantidad de materias aprobadas necesarios para pasar el control: se considera tener aprobada 8 materias de la carrera definidas arriba. 
-- *************************************************************************************************************************************
if v_plan = "2000" then 

	If n_cant_apro > 7 Then
		let v_resu = 1;
	else
		let v_resu = -1;
		let v_c_resu = "Debes aprobar al menos 8 materias del primer ciclo";
	end if;
end if;


return v_resu, v_c_resu;
end;
end procedure;

-- *************** Fin del procedimiento "dba".u820_Prof_fil_8_mat ********************

REVOKE execute ON "dba".u820_Prof_fil_8_mat FROM public;
GRANT execute ON "dba".u820_Prof_fil_8_mat to guarani; -- Rol de usuarios de Gestion
GRANT execute ON "dba".u820_Prof_fil_8_mat to internet; -- Rol de usuario de Internet
