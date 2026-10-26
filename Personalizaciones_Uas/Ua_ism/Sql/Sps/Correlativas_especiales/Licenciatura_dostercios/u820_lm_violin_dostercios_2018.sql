CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_lm_violin_dostercios_2018') THEN
		DROP PROCEDURE u820_lm_violin_dostercios_2018;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

create procedure "dba".u820_lm_violin_dostercios_2018	(v_unidad_acad	like sga_alumnos.unidad_academica,
					v_carrera		like sga_alumnos.carrera,
					v_legajo		like sga_alumnos.legajo,
					v_materia		like sga_actas_examen.materia,
					v_plan		like sga_alumnos.plan,
					v_version		like sga_actas_examen.version)
returning smallint, varchar(255);

begin
define v_resu numeric(1);
define v_c_resu char(76);
define v_titulo char(2);
define sResultado char(1);
define n_cant_apro integer;
define v_creditos integer;

let v_c_resu = " ";

--Obtiene la cantidad de materias del primer ciclo aprobadas

select count (*) into n_cant_apro
from vw_hist_academica h 
where resultado = "A"
	and h.unidad_academica = v_unidad_acad
	and h.carrera = v_carrera
	and h.legajo = v_legajo
	and materia in (select materia from sga_materias_ciclo where ciclo = 'FB022');

-- U820 ********************************************************************
-- Obtener el titulo final correcto
-- U820 ********************************************************************
-- Orientacion Base.	
-- Recupero el Titulo de Grado del Plan-Version

SELECT ori.titulo 
INTO v_titulo
FROM sga_orientaciones ori
	join sga_titulos tit
	on ori.unidad_academica = tit.unidad_academica
	and ori.titulo = tit.titulo and tit.nivel <> 'GRADO'
WHERE ori.unidad_academica  = v_unidad_acad
AND ori.carrera = v_carrera  
AND ori.plan = v_plan 
AND ori.orientacion = '0';


-- *************************************************************************************************************************************
-- U820
-- 2/3 de 16 materias = 11
-- *************************************************************************************************************************************
if n_cant_apro >= 11 then
	let v_resu = 1;
else
	let v_resu = -1;
	let v_c_resu = "No tenés dos tercios del primer ciclo aprobado";
end if;

return v_resu, v_c_resu;
end;

end procedure;


-- *************** Fin del procedimiento "dba".u820_lm_violin_dostercios_2018 ******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".u820_lm_violin_dostercios_2018
-- *****************************************************************************
revoke execute on "dba".u820_lm_violin_dostercios_2018 from public;
grant execute on "dba".u820_lm_violin_dostercios_2018 to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_lm_violin_dostercios_2018 to internet; -- Rol de usuario de Internet