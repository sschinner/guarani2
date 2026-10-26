execute procedure sp820_ga("FHUC","02","30489578-4")

select * from vw_hist_academica
where legajo = '30489578-4'
and carrera = '02'


--SELECT plan FROM sga_alumnos
--		WHERE carrera	=	'02'
--		AND legajo	=	'30489578-4'

 -- Se obtiene la ultima version del plan activo correspondiente a la carrera del alumno
SELECT version_actual FROM sga_planes
		WHERE carrera	=	'02'
		AND plan		=	( SELECT plan FROM sga_alumnos WHERE carrera = '02' AND legajo = '30489578-4' )



-- calculamos la cantidad de materias del plan, que sean obligatorias y de tipo normal o genérica
  SELECT COUNT(*) 
	FROM sga_atrib_mat_plan a, sga_materias m
		WHERE a.carrera	=	'02'
		AND a.plan	=	'2001'
		AND a.version	=	'1'
		AND a.materia	=	m.materia
		AND a.obligatoria	=	'S'
		AND a.tipo_materia	in	('N','G');



  SELECT a.*
	FROM vw_hist_academica h, sga_atrib_mat_plan a
		WHERE h.legajo	=	'30489578-4'
		AND h.carrera	=	'02'
        AND h.carrera = a.carrera
		AND h.plan	=	'2001'
		AND a.version	=	'1'
		AND h.resultado	=	'A'
		AND h.materia	=	a.materia
		AND a.obligatoria	=	'S'
		AND a.tipo_materia	in	('N','G');

