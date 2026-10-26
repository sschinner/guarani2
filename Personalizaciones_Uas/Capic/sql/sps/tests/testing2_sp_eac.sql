	pUA	pCarrera	pLegajo	pMateria


 -- Se obtiene la ultima version del plan activo correspondiente a la carrera del alumno

  SELECT version_actual
	 FROM sga_planes
		WHERE carrera	=	'0303'
		AND plan		=	(SELECT plan FROM sga_alumnos WHERE carrera = '0303' AND legajo = '28303957-4')



select * from vw_hist_academica
where legajo = '29980129-6'



select * from sga_atrib_mat_plan
where carrera = '0303'
and materia = 'LN002'
and plan = '2004'
and version = '7'




execute procedure sp820_eac("FBCB","0302","27518379-4","21001")	--->	1900	1

execute procedure sp820_eac("FBCB","0303","32556627-9","LN004")	--->	2005	1

execute procedure sp820_eac("FBCB","0302","31627739-8","22006")	--->	2003	2

execute procedure sp820_eac("FBCB","0301","29980129-6","12005")	--->	2001	2

execute procedure sp820_eac("FBCB","0301","29855493-6","11002")	--->	2003	1

execute procedure sp820_eac("FBCB","0302","23880089-7","22023")	--->	1994	5
	
execute procedure sp820_eac("FBCB","0302","27862988-8","22006")	--->	2007	2

execute procedure sp820_eac("FBCB","0303","18564451-7","LN008")	--->	2006	2

execute procedure sp820_eac("FBCB","0303","28303957-4","LN002")	--->	2008	1


select * from sga_alumnos
where carrera = '0303'
order by 7



