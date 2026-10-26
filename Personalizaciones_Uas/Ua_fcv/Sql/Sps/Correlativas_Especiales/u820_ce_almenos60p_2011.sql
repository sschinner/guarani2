CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_ce_almenos60p_2011') THEN
		DROP PROCEDURE u820_ce_almenos60p_2011;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

--Execute procedure u820_ce_almenos60p_2011("FCV", "01", "34563272-6", "10020", 2011, 1)

-- *************************************************************************************************
-- Ultima modificacion: Version 2.9.1
-- *************************************************************************************************

Create procedure "dba".u820_ce_almenos60p_2011 (v_unidad_acad	like sga_alumnos.unidad_academica,
				v_carrera		like sga_alumnos.carrera,
				v_legajo		like sga_alumnos.legajo,
				v_materia		like sga_actas_examen.materia,
				v_plan		like sga_alumnos.plan,
				
v_version		like sga_actas_examen.version)
				
		returning smallint, varchar(255);
begin
define v_resu numeric(1);
define v_c_resu char(76);
define n_cant_ciclo integer;
define n_cant_apro integer;
define mat_aprob integer;

let v_c_resu = " ";
let mat_aprob = 0;

-- Obtiene la cantidad de materias del Ciclo Básico Aprobadas

Select count (*) Into n_cant_apro
From vw_hist_academica h 
Where resultado = "A"
	and h.unidad_academica = v_unidad_acad
	and h.carrera = v_carrera
	and h.legajo = v_legajo
	and materia in ('10001', '10002', '10003', '10004', '10005', '10006', '10007', '10008', '10009', '10010', '10011', '10012', '10013', '10014', '10015', '10016', '10108', '10109', '10110', '10111');


Select count (*) Into mat_aprob
From vw_hist_academica h 
Where resultado = "A"
	and h.unidad_academica = v_unidad_acad
	and h.carrera = v_carrera
	and h.legajo = v_legajo
	and materia = '10110';
-- *************************************************************************************************************************************
-- U820
-- Cantidad de materias aprobadas necesarios para pasar el control: se considero como eo 60% de 16 materias = 11/10 según plan del alumno. (modificado provisoriamente por memorando interno 02/09)
-- *************************************************************************************************************************************


	If ((n_cant_apro >= 9)  AND (mat_aprob >= 1))Then
		let v_resu = 1;
	else
		let v_resu = -1;
		let v_c_resu = "No has aprobado el 60% de las materias del Ciclo Básico";
	end if;



return v_resu, v_c_resu;
end;
end procedure;

-- ******************** FIN PROCESO u820_ce_almenos60p_2011 ********************

revoke execute on "dba".u820_ce_almenos60p_2011 from public;
grant execute on "dba".u820_ce_almenos60p_2011 to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_ce_almenos60p_2011 to internet; -- Rol de usuario de Internet