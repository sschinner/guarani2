drop procedure "dba".sp820_pad_centro;
create procedure "dba".sp820_pad_centro(pAnio_academico Varchar(4), psede LIKE sga_alumnos.sede)

returning 	varchar(15), -- legajo
	varchar(30),  -- apellido
	varchar(30),  -- nombres
	varchar(15),  -- nro. de documento
	varchar (4); -- año academico
 
  DEFINE vlegajo varchar(15);
  DEFINE vaprobadas int;
  DEFINE vapellido, vnombres varchar(30);
  DEFINE vnro_documento varchar(15);
  DEFINE vc_carrera varchar(5); 
  DEFINE	vc_materia	varchar(5);

   --vars para el manejo de excepciones

   DEFINE sql_err	 			integer;
   DEFINE isam_err 				integer;
   DEFINE error_info				varchar(76);

   ON EXCEPTION SET sql_err, isam_err, error_info                                        
      RAISE EXCEPTION  sql_err, isam_err, error_info;
   END EXCEPTION;     

BEGIN
	-- CREA EL TEMPORAL CON LOS CURSOS DE INGRESO APROBADOS

	select *
	from  vw_hist_academica
	where resultado = "A"
		and materia in (select materia from u820_cursos_ing)
	into temp temp_academica with no log;
	
	create index idx_temp_academica on temp_academica (legajo, carrera, materia);

	-- crea temporal con alumnos
	Select a.legajo, a.carrera
	from sga_alumnos a
		join sga_reinscripcion r -- Que esten reinscriptos al Año Academico
		on a.legajo = r.legajo and a.carrera = r.carrera and r.anio_academico = panio_academico

		where a.regular = 'S'
		 and (a.calidad = 'A' or a.calidad = 'I')
		and a.carrera <> '0200'

	Union
	
	Select a.legajo, a.carrera
	from sga_alumnos a
		join sga_carrera_aspira car
			join sga_periodo_insc insc
			on car.periodo_inscripcio = insc.periodo_inscripcio and insc.tipo in ('A', 'I')
		on a.nro_inscripcion = car.nro_inscripcion and a.carrera = car.carrera
	where insc.anio_academico = panio_academico
	and a.carrera <> '0200'

	into temp temp_alumnos with no log;

	create index idx_temp_alu on temp_alumnos (legajo, carrera);

----
SELECT  distinct a.legajo, p.apellido, p.nombres, p.nro_documento
     from temp_alumnos t
	join sga_alumnos a
		join sga_personas p
		  on a.nro_inscripcion = p.nro_inscripcion
	on t.legajo = a.legajo
	and t.carrera = a.carrera
	and a.sede = psede
                 into temp temp2_alumnos with no log;

update  temp2_alumnos set  apellido = REPLACE(apellido,"á","a"), nombres = REPLACE(nombres,"á","a");
update  temp2_alumnos set apellido = REPLACE(apellido,"ó","o"), nombres= REPLACE(nombres,"ó","o");
update  temp2_alumnos set apellido = REPLACE(apellido,"é","e"), nombres= REPLACE(nombres,"é","e");
update  temp2_alumnos set apellido = REPLACE(apellido,"í","i"), nombres = REPLACE(nombres,"í","i");
update  temp2_alumnos set apellido = REPLACE(apellido,"ú","u"), nombres = REPLACE(nombres,"ú","u");


FOREACH SELECT distinct legajo, apellido, nombres, nro_documento
   INTO vlegajo, vapellido,vnombres, vnro_documento
     from temp2_alumnos 
    order by apellido, nombres
return  vlegajo, vapellido, vnombres, vnro_documento, panio_academico  WITH RESUME; 

END FOREACH;

drop table temp_academica;
drop table temp_alumnos;

end ;
end procedure                                                                                                                                            
                                                                                                                                                                                                                                                              
