CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_lic_gest_edu_3_mat') THEN
		DROP PROCEDURE "dba".u820_lic_gest_edu_3_mat;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


--Drop procedure u820_lic_gest_edu_3_mat; 

Create procedure "dba".u820_lic_gest_edu_3_mat (v_unidad_acad	like sga_alumnos.unidad_academica,v_carrera	like sga_alumnos.carrera,v_legajo	like sga_alumnos.legajo,v_materia	like sga_actas_examen.materia,v_plan	like sga_alumnos.plan,v_version		like sga_actas_examen.version)

		returning smallint, varchar(255);
begin
define v_resu numeric(1);
define v_c_resu char(76);
define n_cant_ciclo integer;
define n_cant_apro integer;



let v_c_resu = " ";


-- Obtiene la cantidad de materias del Ciclo Básico Aprobadas

Select count (*) Into n_cant_apro
From vw_hist_academica h 
Where resultado = "A"
	and h.unidad_academica = v_unidad_acad
	and h.carrera = v_carrera
	and h.legajo = v_legajo
	and materia in ("GE001","GE002","GE003","GE004","GE005","GE006","GE007","GE009","GE010");

-- *************************************************************************************************************************************
-- U820
-- Cantidad de materias aprobadas necesarios para pasar el control: se considera tener aprobada 3 materias de la carrera definidas arriba. 
-- *************************************************************************************************************************************
if v_plan = "2001" then 

	If n_cant_apro >= 3 Then
		let v_resu = 1;
	else
		let v_resu = -1;
		let v_c_resu = "Debes aprobar al menos 3 materias";
	end if;
end if;

return v_resu, v_c_resu;

end;

end procedure;

-- *****************************************************************************
-- Permisos del Control "dba".sp_correlativa_esp 
-- *****************************************************************************
revoke execute on "dba".u820_lic_gest_edu_3_mat from public;
grant execute on "dba".u820_lic_gest_edu_3_mat to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_lic_gest_edu_3_mat to internet; -- Rol de usuario de Internet
