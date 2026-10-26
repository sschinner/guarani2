-- execute procedure sp820_padron ('2', '10-10-2019', '01-10-2019', '2019', '1', '00000');

drop procedure "dba".sp820_padron;
create procedure "dba".sp820_padron(	pcant_materias	LIKE	dba.sga_alumnos.calidad,
				pFechaComisio	 varchar(10),
				pFechaCierre	 varchar(10),
				pAnio_academico		Varchar(4),
				pcant_mat_NI	LIKE	dba.sga_alumnos.calidad,
				psede LIKE dba.sga_sedes.sede)

returning 	varchar(15), -- legajo
	varchar(30),  -- apellido
	varchar(30),  -- nombres
	varchar(4), -- anio academico
  	varchar (255); -- sede

  DEFINE vfecha_NI Date;
  DEFINE vcAnio_Acad LIKE sga_anio_academico.anio_academico;
  DEFINE vcInicio LIKE sga_anio_academico.fecha_inicio;
  DEFINE vcFin LIKE sga_anio_academico.fecha_fin;
  DEFINE vcAntAnio_Academico LIKE sga_anio_academico.anio_academico;
  DEFINE vcAntInicio LIKE sga_anio_academico.fecha_inicio;
  DEFINE vcAntFin LIKE sga_anio_academico.fecha_fin;

  DEFINE dFDesde		date;

  DEFINE dFCierre		date;

  DEFINE vlegajo varchar(15);
  DEFINE vaprobadas int;
  DEFINE vapellido, vnombres varchar(30);
  DEFINE vccarrera varchar(30);
  DEFINE v_materia	varchar(5); 
  DEFINE v_carrera	varchar(5);
  DEFINE v_plan	varchar(5);
  DEFINE vcSede LIKE dba.sga_sedes.nombre;
   --vars para el manejo de excepciones
   DEFINE sql_err	 			integer;
   DEFINE isam_err 				integer;
   DEFINE error_info				varchar(76);

   ON EXCEPTION SET sql_err, isam_err, error_info                                        
      RAISE EXCEPTION  sql_err, isam_err, error_info;
   END EXCEPTION;     

BEGIN

  LET dFDesde = stringToDate( pFechaComisio, '%d-%m-%Y');
  LET dFCierre = stringToDate( pFechaCierre, '%d-%m-%Y');

-- **********************************************************************
-- EN DESUSO: ATENCION, SE INTERPRETA DE LA RESOLUCIÓN QUE LOS EXAMENES A CONSIDERAR CORRESPONDEN A LOS DEL "AÑO 
-- CALENDARIO" DE LA ELECCION O ANTERIOR. POR LO TANTO ESTE CALCULO DE "AÑO ACADEMICO" NO SE USA MAS.
-- **********************************************************************
-- Calcular el Año Academico, fecha DESDE y HASTA Correspondiente al Año Academico Seleccionado (pAnio_academico).

Select anio_academico, fecha_inicio, fecha_fin Into vcAnio_acad, vcInicio, vcFin
	From sga_anio_academico 
	where anio_academico = pAnio_academico;

-- Calcular el Año Academico, fecha DESDE y HASTA Correspondiente Año anterior al Año Academico Seleccionado (pAnio_academico).

Select anio_academico, fecha_inicio, vcInicio Into vcAntAnio_academico, vcAntInicio, vcAntFin
	From sga_anio_academico
	where anio_academico = pAnio_academico - 1;
-- **********************************************************************

-- **********************************************************************
-- INICIO DEL PROCESO
-- **********************************************************************
-- ************************************************************************************************
-- Condición para los Alumnos Ingresantes: pcant_materias aprobadas por examen
-- ************************************************************************************************
	-- CREA EL TEMPORAL CON LA HISTORIA ACADEMICA INGRESANTES
	-- Según Ordenanza 1/2013
	select legajo, carrera, plan, forma_aprobacion, materia, fecha
	from  vw_hist_academica
	where resultado = "A"
		-- and (forma_aprobacion = "Examen" or materia in (select materia from u820_cursos_ing))
		and (forma_aprobacion IN ("Examen", "Promoción", "Examen equivalente")) 
		and materia not in (select materia from u820_cursos_ing)
	into temp temp_academica_ing with no log;
	
	create index idx_temp_academica_ing on temp_academica_ing (legajo, carrera, materia);

	-- crea temporal con ingresantes
	Select a.legajo, a.carrera, a.plan
	from sga_alumnos a
		join sga_carrera_aspira c
			join sga_periodo_insc p
			on c.periodo_inscripcio = p.periodo_inscripcio and p.anio_academico = vcAnio_acad
		  on a.nro_inscripcion = c.nro_inscripcion
			and a.carrera = c.carrera
	where a.regular = 'S'
		and a.calidad = 'A' and a.carrera in (select carrera from sga_carreras_grupo where grupo_carrera = '00001')
	into temp temp_ingresantes with no log;

	create index idx_temp_ingresantes on temp_ingresantes (legajo, carrera, plan);
	

	--*****************************************************************************************
	-- Según Ordenanza 1/2013 ya no se tienen en cuenta los cursos de Ingreso
	-- Ingresantes con cursos de ingreso obligatorios aprobados en la carrera.
	{
	foreach	select carrera, plan, materia into v_carrera, v_plan, v_materia
		from u820_cursos_ing
		where obligatoria = 'S'

		delete from temp_ingresantes
		where legajo||carrera||plan not in (	select legajo||carrera||plan
					from temp_academica_ing
					where carrera = v_carrera
						and plan = v_plan
						and materia = v_materia)
			and carrera = v_carrera
			and plan = v_plan;
	end foreach;
	}		
	--*****************************************************************************************

	Select a.legajo, a.carrera
	from temp_ingresantes a
		join temp_academica_ing h		
		  on a.legajo = h.legajo
			and a.carrera = h.carrera
			--and h.materia Not IN (select materia from u820_cursos_ing)
			--and h.forma_aprobacion = 'Examen'
			and h.fecha <= dFCierre 
	group by a.legajo, a.carrera
	having count (*) >= pcant_materias

	UNION
	
	-- Nueva condición según Res. UA 2019
	select distinct insc.legajo, insc.carrera  
	from sga_insc_cursadas insc
	join sga_alumnos alu
		on insc.carrera = alu.carrera and insc.legajo = alu.legajo
	join sga_carrera_aspira aspi
		on aspi.nro_inscripcion = alu.nro_inscripcion and aspi.carrera = alu.carrera
	join sga_periodo_insc perinsc
		on aspi.periodo_inscripcio = perinsc.periodo_inscripcio
	join sga_comisiones com
		on insc.comision = com.comision
	join sga_eval_parc_alum eval 
		on insc.comision = eval.comision and insc.legajo = eval.legajo
	where com.anio_academico = vcAnio_acad and eval.resultado = 'A'
		and alu.plan = '02-05' and alu.carrera = '0205'
		and perinsc.anio_academico = vcAnio_acad
		and com.materia in ('1015', '1025', '1045', '1055')
		
	Into temp temp1_al with no log;


-- ************************************************************************************************
-- Condición para los Alumnos No Ingresantes: pcant_mat_NI aprobadas por examen
-- Que tenga: (dos materias aprobadas dentro de los 365 días anteriores a la fecha de cierre del padrón)
-- NO FILTRO POR PLAN
-- ************************************************************************************************
	-- CREA EL TEMPORAL CON LA HISTORIA ACADEMICA  DE LOS NO INGRESANTES

	select a.nro_inscripcion, a.legajo, a.carrera, max(a.calidad) as calidad,
	--sum (case when year(vw.fecha) = (vcAnio_acad - 1 )then 1 else 0 end) as apro_anio_ant,
	--sum (case when year(vw.fecha) = vcAnio_acad then 1 else 0 end) as apro_anio_curso
	count(*) as apro
	from  vw_hist_academica vw
	join sga_alumnos a
		on a.legajo = vw.legajo
		and a.carrera = vw.carrera
	where vw.resultado = "A"
		and (vw.forma_aprobacion IN ( "Examen", "Promoción", "Examen equivalente" ) and vw.materia not in (select materia from u820_cursos_ing))
		and a.regular = 'S'
		and a.calidad in ('A', 'E')
		-- and vw.fecha <= dFCierre
		and (dFCierre - vw.fecha) between 0 and 365
	group by a.nro_inscripcion, a.legajo, a.carrera
	having count(*) >= pcant_mat_NI
	--having sum (case when year(vw.fecha) = (vcAnio_acad - 1 )then 1 else 0 end) >= pcant_mat_NI
	--	OR
	--	sum (case when year(vw.fecha) = vcAnio_acad then 1 else 0 end) >= pcant_mat_NI
	into temp temp_academica_no_ing with no log;

	create index idx_temp_academica_no_ing on temp_academica_no_ing (nro_inscripcion, legajo, carrera);

	Select a.legajo, a.carrera
	from temp_academica_no_ing a
		join sga_carrera_aspira c
		on a.nro_inscripcion = c.nro_inscripcion
			and a.carrera = c.carrera
		join sga_periodo_insc p -- Que no sean Ingresantes
			on c.periodo_inscripcio = p.periodo_inscripcio and p.anio_academico < vcAnio_acad
		join sga_reinscripcion r -- Que esten reinscriptos al Año Academico
		on a.legajo = r.legajo and a.carrera = r.carrera and r.anio_academico = vcAnio_acad
	where  a.carrera in (select carrera from sga_carreras_grupo where grupo_carrera = '00001')
		and a.calidad = 'A'

into temp temp2_al with no log;

-- *******************************************
-- Union de los alumnos seleccionados
-- *******************************************

select legajo, carrera from temp1_al

UNION

select legajo, carrera from temp2_al

UNION

-- ************************************************************************************************
-- Condición Egresados: egresados dentro de los ultimos 6 meses según ordenanza 1 del 2013.
-- ************************************************************************************************
	Select a.legajo, a.carrera
	from sga_titulos_otorg tit
		join temp_academica_no_ing a
			on tit.carrera = a.carrera and tit.legajo = a.legajo
	where dFCierre - tit.fecha_egreso <= 183
		and a.calidad = 'E'
		and a.carrera in (select carrera from sga_carreras_grupo where grupo_carrera = '00001')

into temp temp_alumnos with no log;


SELECT distinct a.legajo, p.apellido, p.nombres, sed.nombre
      from temp_alumnos t
	join sga_alumnos a
		on t.legajo = a.legajo
		and t.carrera = a.carrera
	join sga_personas p
		  on a.nro_inscripcion = p.nro_inscripcion
	join sga_sedes sed
	  on a.sede = sed.sede and a.sede = psede

into temp temp2_alumnos with no log;

update  temp2_alumnos set  apellido = REPLACE(apellido,"á","a"), nombres = REPLACE(nombres,"á","a");
update  temp2_alumnos set apellido = REPLACE(apellido,"ó","o"), nombres= REPLACE(nombres,"ó","o");
update  temp2_alumnos set apellido = REPLACE(apellido,"é","e"), nombres= REPLACE(nombres,"é","e");
update  temp2_alumnos set apellido = REPLACE(apellido,"í","i"), nombres = REPLACE(nombres,"í","i");
update  temp2_alumnos set apellido = REPLACE(apellido,"ú","u"), nombres = REPLACE(nombres,"ú","u");


FOREACH SELECT distinct legajo, apellido, nombres, nombre
   INTO vlegajo, vapellido,vnombres, vcSede
     from temp2_alumnos 
    order by 2, 3

return  vlegajo, vapellido, vnombres, vcAnio_Acad, vcSede  WITH RESUME; 
END FOREACH;

drop table temp_alumnos;
drop table temp2_alumnos;
drop table temp1_al;
drop table temp2_al;
drop table temp_academica_ing;
drop table temp_academica_no_ing;
drop table temp_ingresantes;

end ;
end procedure;
                                                                                        
