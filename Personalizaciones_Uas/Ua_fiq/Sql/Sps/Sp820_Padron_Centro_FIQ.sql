-- **********************************************************************
-- Elección Centro de Estudiantes
-- Condiciones: Padron Consejeros Estudiantiles + Propias de FIQ
-- **********************************************************************

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_pad_centro') THEN
		DROP PROCEDURE sp820_pad_centro;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- execute procedure sp820_pad_centro(2018, '00006');

create procedure "dba".sp820_pad_centro(pAnio_academico Varchar(4), psede LIKE sga_alumnos.sede)

returning 	varchar(15), -- legajo
	varchar(30),  -- apellido
	varchar(30),  -- nombres
	varchar(15),  -- nro. de documento
	varchar(4); -- anio academico


  DEFINE vfecha_NI Date;
  DEFINE vcAnio_Acad LIKE sga_anio_academico.anio_academico;
  DEFINE vcInicio LIKE sga_anio_academico.fecha_inicio;
  DEFINE vcFin LIKE sga_anio_academico.fecha_fin;
  DEFINE vcAntAnio_Academico LIKE sga_anio_academico.anio_academico;
  DEFINE vcAntInicio LIKE sga_anio_academico.fecha_inicio;
  DEFINE vcAntFin LIKE sga_anio_academico.fecha_fin;

  DEFINE	vcarrera	varchar(5);

  DEFINE dFDesde		date;

  DEFINE dFCierre		date;

  DEFINE vlegajo varchar(15);
  DEFINE vaprobadas int;
  DEFINE vapellido, vnombres varchar(30);
  DEFINE vccarrera varchar(30);
  DEFINE	v_materia	varchar(5); 
  DEFINE	v_carrera	varchar(5);
  DEFINE	v_plan	varchar(5);
DEFINE vnro_documento varchar(15);

DEFINE pcant_materias INTEGER;
	 
DEFINE pcant_mat_NI INTEGER;	
	 
   --vars para el manejo de excepciones
   DEFINE sql_err	 			integer;
   DEFINE isam_err 				integer;
   DEFINE error_info				varchar(76);

   ON EXCEPTION SET sql_err, isam_err, error_info                                        
      RAISE EXCEPTION  sql_err, isam_err, error_info;
   END EXCEPTION;     

BEGIN


  LET dFDesde = TODAY; --stringToDate( pFechaComisio, '%d-%m-%Y');
  LET dFCierre = TODAY; --stringToDate( pFechaCierre, '%d-%m-%Y');
  LET pcant_materias = 1;
  LET pcant_mat_NI = 2;

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
	-- CREA EL TEMPORAL CON LA HISTORIA ACADEMICA INGRESANTES. Examen + Cursos de Ingreso determinados
	-- Según Ordenanza 1/2013
	select legajo, carrera, plan, forma_aprobacion, materia, fecha
	from  vw_hist_academica
	where resultado = "A"
		--and (forma_aprobacion = "Examen" or materia in (select materia from u820_cursos_ing))
		-- --and (forma_aprobacion = "Examen")
		and (forma_aprobacion = "Examen" or materia in ('PRO01', 'PRO02', 'PRO03'))
		-- and materia not in (select materia from u820_cursos_ing)
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
		and a.carrera <> '90000'
	into temp temp_ingresantes with no log;

	create index idx_temp_ingresantes on temp_ingresantes (legajo, carrera, plan);

	-- Ingresantes con cursos de ingreso obligatorios aprobados en la carrera.
	-- Modificado para considerar solo cursos disciplinares de la carrera
	--foreach	select carrera, plan, materia into v_carrera, v_plan, v_materia
	--	from u820_cursos_ing
	--	where obligatoria = 'S' and materia in ('PRO01', 'PRO02', 'PRO03')
	--
	--	delete from temp_ingresantes
	--	where legajo||carrera||plan not in (	select legajo||carrera||plan
	--				from temp_academica_ing
	--				where carrera = v_carrera
	--					and plan = v_plan
	--					and materia = v_materia)
	--		and carrera = v_carrera
	--		and plan = v_plan;
	--end foreach;
		

	Select a.legajo, a.carrera
	from temp_ingresantes a
		join temp_academica_ing h		
		  on a.legajo = h.legajo
			and a.carrera = h.carrera
			-- and h.materia Not IN (select materia from u820_cursos_ing)
			-- Controlar que el curso sea obligatorio
			and h.carrera||h.plan||h.materia in (select carrera||plan||materia from u820_cursos_ing where obligatoria = 'S')
			-- and h.forma_aprobacion = 'Examen'
			and h.fecha <= dFCierre 
	group by a.legajo, a.carrera
	having count (*) >= pcant_materias

	-- Ó que el Ingresante tenga una regularizada
	UNION

	Select a.legajo, a.carrera
	from temp_ingresantes a
		join sga_cursadas h		
		  on a.legajo = h.legajo
			and a.carrera = h.carrera
			and h.materia Not IN (select materia from u820_cursos_ing)
			and h.resultado = 'A'
			and h.fin_vigencia_regul >= today
			and h.fecha_regularidad <= dFCierre 
	group by a.legajo, a.carrera
	having count (*) >= pcant_materias


	Into temp temp1_al with no log;

-- ************************************************************************************************
-- Condición para los Alumnos No Ingresantes: pcant_mat_NI aprobadas por examen
-- Que tenga: (2 materias aprobadas por examen el año calendario anterior al de comicios) O (2 materias aprobadas por examen el año calendario del comicio). (Es excluyente)
-- NO FILTRO POR PLAN
-- ************************************************************************************************
	-- CREA EL TEMPORAL CON LA HISTORIA ACADEMICA  DE LOS NO INGRESANTES

	select a.nro_inscripcion, a.legajo, a.carrera, max(a.calidad) as calidad
	-- sum (case when year(vw.fecha) = (vcAnio_acad - 1 )then 1 else 0 end) as apro_anio_ant,
	-- sum (case when year(vw.fecha) = vcAnio_acad then 1 else 0 end) as apro_anio_curso

	from  vw_hist_academica vw
	join sga_alumnos a
		on a.legajo = vw.legajo
		and a.carrera = vw.carrera
	where vw.resultado = "A"
		and (vw.forma_aprobacion = "Examen" and vw.materia not in (select materia from u820_cursos_ing))
		and a.regular = 'S'
		and a.calidad in ('A', 'E')
		and a.carrera <> '90000'
		-- and vw.fecha <= dFCierre
		and (dFCierre - vw.fecha) between 0 and 365
	group by a.nro_inscripcion, a.legajo, a.carrera
	having count(*) >= pcant_mat_NI
	-- having sum (case when year(vw.fecha) = (vcAnio_acad - 1 )then 1 else 0 end) >= pcant_mat_NI
	--	OR
	--	sum (case when year(vw.fecha) = vcAnio_acad then 1 else 0 end) >= pcant_mat_NI
	into temp temp_academica_no_ing;

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
		and a.carrera <> '90000'

into temp temp2_al;

-- *******************************************
-- Union de los alumnos seleccionados
-- *******************************************

select legajo, carrera from temp1_al

UNION

select legajo, carrera from temp2_al

UNION

-- ************************************************************************************************
-- Condición Egresados: egresados dentro de los ultimos 6 meses, que tengan: (2 materias aprobadas por examen el año anterior al de comicios) O (2 materias aprobadas por examen el año del comicio). (Es excluyente)
-- ************************************************************************************************
	Select a.legajo, a.carrera
	from sga_titulos_otorg tit
		join temp_academica_no_ing a
			on tit.carrera = a.carrera and tit.legajo = a.legajo
	where dFDesde - tit.fecha_egreso <= 183
		and a.calidad = 'E'
		and a.carrera <> '90000'
		and a.carrera in (select carrera from sga_carreras_grupo where grupo_carrera = '00001')


UNION 

-- ************************************************************************************************
-- Condición particular FIQ:  2- Haber regularizado una materia el 2do.cuatrimestre de 2013 o el 1er. Cuat. del 2014. 3- Haberse presentado a rendir en algún turno de exámenes desde el turno Diciembre 2013
-- ************************************************************************************************

SELECT distinct  a.legajo, a.carrera

     from sga_alumnos a
	join sga_personas p
	on a.nro_inscripcion = p.nro_inscripcion
	and a.regular = 'S'
	and a.calidad = 'A'
	and a.carrera <> '90000'
	and (a.legajo||a.carrera in (select legajo||carrera
					from vw_hist_academica
					where fecha >= MDY( 12,1,panio_academico-1)
					and forma_aprobacion IN ('Examen', 'Promoción')
					group by 1
					having count(*) >= 2)
		OR 
		a.legajo||a.carrera in (select legajo||carrera
					from sga_cursadas
					where fecha_regularidad >= MDY( 10,1,panio_academico-1)
					and resultado IN ('A', 'P'))
		




)

into temp temp_alumnos with no log;

FOREACH SELECT distinct a.legajo, UPPER(p.apellido), p.nombres, p.nro_documento
   INTO vlegajo, vapellido, vnombres, vnro_documento
     from temp_alumnos t
	join sga_alumnos a
		join sga_personas p
		  on a.nro_inscripcion = p.nro_inscripcion
	on t.legajo = a.legajo
	and t.carrera = a.carrera
	and a.sede = psede
    order by 2, 3

return  vlegajo, vapellido, vnombres, vnro_documento, vcAnio_Acad WITH RESUME; 

END FOREACH;

drop table temp_alumnos;
drop table temp1_al;
drop table temp2_al;
drop table temp_academica_ing;
drop table temp_academica_no_ing;
drop table temp_ingresantes;

end ;
end procedure;

--select current from sga_valor_inicial;
--EXECUTE PROCEDURE sp820_pad_centro('2014'); 
--select current from sga_valor_inicial;


-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_pad_centro
-- *****************************************************************************
revoke execute on "dba".sp820_pad_centro from public;
grant execute on "dba".sp820_pad_centro to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_pad_centro to internet; -- Rol de usuario de Internet
