  

 -- Se obtiene la ultima version del plan activo correspondiente a la carrera del alumno

  SELECT version_actual
	 FROM sga_planes
		WHERE carrera	=	'0303'
		AND plan		=	(SELECT plan FROM sga_alumnos WHERE carrera = '0303' AND legajo = '34787662-5')



SELECT m.nombre, m.nombre_reducido, m.materia, a.obligatoria, a.tipo_materia
	FROM sga_atrib_mat_plan a, sga_materias m
		WHERE a.carrera	=	'0303'
		AND a.plan	=	'2004'
		AND a.version	=	'7'
		AND a.materia	=	m.materia
		AND a.obligatoria	=	'S'
		AND a.tipo_materia	in	('N','G')
		ORDER BY 1;



select * from sga_materias

execute procedure sp820_ga("FBCB","0302","31627739-8")




select * from sga_alumnos
where carrera = '0303'
order by 7