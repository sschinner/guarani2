execute procedure sp820_pa("FBCB","0302","26093482-3");

  

  SELECT version_actual 
	FROM sga_planes
		WHERE carrera = '0301'
		AND plan	= (SELECT plan FROM sga_alumnos WHERE carrera = '0301' AND legajo = '28240561-6')


  SELECT * 
	FROM vw_hist_academica
		WHERE unidad_academica	=	'FBCB'
		AND carrera		=	'0301'
		AND legajo		=	'28240561-6'
		INTO TEMP temporalito;


  SELECT SUM(sga_det_escala.valor_numerico), Count(sga_det_escala.nota) 
	FROM temporalito, sga_atrib_mat_plan, sga_det_escala
		WHERE temporalito.nota IS NOT NULL
		--AND (temp_histacadprom.resultado		=	pTodas OR  pTodas = 'S')
		AND sga_atrib_mat_plan.unidad_academica	=	temporalito.unidad_academica
		AND sga_atrib_mat_plan.carrera		=	temporalito.carrera
		AND sga_atrib_mat_plan.plan			=	temporalito.plan
		AND sga_atrib_mat_plan.version		=	temporalito.version
		AND sga_atrib_mat_plan.materia		=	temporalito.materia
		-- AND sga_atrib_mat_plan.promediable		=	'S'
		AND sga_atrib_mat_plan.materia in (SELECT materia FROM sga_atrib_mat_plan WHERE carrera = '0301' AND plan = '1997' AND version = '35')
		AND sga_det_escala.escala_notas		=	temporalito.escala_notas
		AND sga_det_escala.nota			=	temporalito.nota;

