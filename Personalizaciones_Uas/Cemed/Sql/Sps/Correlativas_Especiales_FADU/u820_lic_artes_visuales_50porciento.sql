CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_lic_artes_visuales_50porciento') THEN
		DROP PROCEDURE u820_lic_artes_visuales_50porciento;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

create procedure "dba".u820_lic_artes_visuales_50porciento	(v_unidad_acad	like sga_alumnos.unidad_academica,
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

--Obtiene la cantidad de materias del plan de estudios

select count (*) into n_cant_apro
from vw_hist_academica h 
where resultado = "A"
	and h.unidad_academica = v_unidad_acad
	and h.carrera = v_carrera
	and h.legajo = v_legajo
	and h.materia <> 'EUT';

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
	and ori.titulo = tit.titulo and tit.nivel = 'GRADO'
WHERE ori.unidad_academica  = v_unidad_acad
AND ori.carrera = v_carrera  
AND ori.plan = v_plan 
AND ori.orientacion = '0';

-- EXECUTE PROCEDURE sp_resultGenerica('FADU', '5', '36000814-3', '5', '0', 'OPC13') ;
-- SELECT * FROM vw_hist_academica WHERE legajo = '36000814-3' and materia = 'OPC13';

LET sResultado = '';

EXECUTE PROCEDURE sp_resultGenerica(v_unidad_acad, v_carrera, v_legajo, v_titulo, '0', 'OPC13') INTO sResultado, v_creditos;
      IF sResultado = 'A' THEN
         LET n_cant_apro = n_cant_apro + 1;
END IF; 

-- *************************************************************************************************************************************
-- U820
-- 50% de 16 materias obligatorias (incluyendo la generica) = 8
-- *************************************************************************************************************************************
if n_cant_apro >= 8 then
	let v_resu = 1;
else
	let v_resu = -1;
	let v_c_resu = "No tenés el 50% de las materias aprobadas";
end if;

return v_resu, v_c_resu;
end;

end procedure;


-- *************** Fin del procedimiento "dba".u820_lic_artes_visuales_50porciento ******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".u820_lic_artes_visuales_50porciento
-- *****************************************************************************
revoke execute on "dba".u820_lic_artes_visuales_50porciento from public;
grant execute on "dba".u820_lic_artes_visuales_50porciento to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_lic_artes_visuales_50porciento to internet; -- Rol de usuario de Internet

-- PRUEBAS
-- Pueden Cursar: SELECT * FROM sga_alumnos WHERE legajo LIKE '34537741-%'
-- EXECUTE PROCEDURE "dba".u820_lic_artes_visuales_50porciento	('FADU','5','36000814-3', 'LAV15', '2000','5');
-- EXECUTE PROCEDURE "dba".u820_lic_artes_visuales_50porciento	('FADU','5','29686236-2', 'LAV15', '2000','5');
-- EXECUTE PROCEDURE "dba".u820_lic_artes_visuales_50porciento	('FADU','5','35092225-3', 'LAV15', '2000','5');
-- NO Pueden Cursar:
-- EXECUTE PROCEDURE "dba".u820_lic_artes_visuales_50porciento	('FADU','5','26580241-2', 'LAV15', '2000','5');
-- EXECUTE PROCEDURE "dba".u820_lic_artes_visuales_50porciento	('FADU','5','16916043-4', 'LAV15', '2000','5');
-- EXECUTE PROCEDURE "dba".u820_lic_artes_visuales_50porciento	('FADU','5','34537741-8', 'LAV15', '2000','5');
