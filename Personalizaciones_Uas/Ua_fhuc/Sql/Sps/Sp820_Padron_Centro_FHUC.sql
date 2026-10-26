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


-- drop procedure dba.sp820_pad_centro;
create procedure "dba".sp820_pad_centro(pAnio_academico Varchar(4), psede LIKE sga_alumnos.sede)
returning 	varchar(15), -- legajo
	varchar(30),  -- apellido
	varchar(30),  -- nombres
	varchar(15),  -- nro. de documento
	varchar (4), -- año academico
 	varchar(255), -- carrera
 	varchar(255); -- sede


  DEFINE vlegajo varchar(15);
  DEFINE vaprobadas int;
  DEFINE vapellido, vnombres varchar(30);
  DEFINE vnro_documento varchar(15);
  DEFINE vsede varchar(255);
  DEFINE vcarrera varchar(255); 

   --vars para el manejo de excepciones
   DEFINE sql_err	 			integer;
   DEFINE isam_err 				integer;
   DEFINE error_info				varchar(76);

   ON EXCEPTION SET sql_err, isam_err, error_info                                        
      RAISE EXCEPTION  sql_err, isam_err, error_info;
   END EXCEPTION;     

BEGIN

	-- obtengo los alumnos con 1 materia curricular aprobada (no importa la forma) o 1 Regularizada vigente (esta condicion vale para Ingresante y Reinscriptos).

	select distinct legajo, carrera 
	from sga_cursadas
	where resultado = 'A' and fin_vigencia_regul >= today
		and  carrera in (select carrera from sga_carreras_grupo where grupo_carrera = '00001')

	Union

	select distinct legajo, carrera
	from vw_hist_academica
	where resultado = 'A' 
		and materia not in (select materia from u820_cursos_ing)
		and year(fecha) = panio_academico 
		and carrera in (select carrera from sga_carreras_grupo where grupo_carrera = '00001')
	into temp temp_acad with no log;

	create index idx_temp_acad on temp_acad (legajo, carrera);

	------------------------------------------------------------------------------------------------

	-- crea temporal con alumnos
	Select a.legajo, a.carrera
	from sga_alumnos a
		join sga_reinscripcion r -- Que esten reinscriptos al Año Academico
		on a.legajo = r.legajo and a.carrera = r.carrera and r.anio_academico = panio_academico
		where a.regular = 'S'
		and a.calidad = 'A'
		and  a.carrera in (select carrera from sga_carreras_grupo where grupo_carrera = '00001')

	Union
	
	
	Select a.legajo, a.carrera
	from sga_alumnos a
		join sga_carrera_aspira car
		on a.nro_inscripcion = car.nro_inscripcion and a.carrera = car.carrera
		join sga_periodo_insc  pi
		on car.periodo_inscripcio = pi.periodo_inscripcio
	where pi.anio_academico = panio_academico
		and a.regular = 'S'
		and a.calidad = 'A'
		and a.carrera in (select carrera from sga_carreras_grupo where grupo_carrera = '00001')
	into temp temp_alumnos with no log;

	create index idx_temp_alu on temp_alumnos (legajo, carrera);

	delete from temp_alumnos where not exists (select '' from temp_acad t
	where t.legajo = temp_alumnos.legajo
						and t.carrera = temp_alumnos.carrera);
	------------------------------------------------------------------------------------------------

FOREACH SELECT a.legajo, UPPER(p.apellido), p.nombres, p.nro_documento, max(car.nombre) as nombre_carrera, s.nombre -- se devuelve una de las carreras a la que esta inscripto
   INTO vlegajo, vapellido,vnombres, vnro_documento, vcarrera, vsede
     from sga_carreras car
	join temp_alumnos t
	join sga_alumnos a
		join sga_personas p
		  on a.nro_inscripcion = p.nro_inscripcion
	on t.legajo = a.legajo

	join sga_sedes s
		on s.sede = a.sede
	and t.carrera = a.carrera
	and a.sede = psede
	on car.carrera = t.carrera
    group by a.legajo, p.apellido, p.nombres, p.nro_documento, s.nombre
    order by 2, 3

return  vlegajo, vapellido, vnombres, vnro_documento, panio_academico, vcarrera, vsede  WITH RESUME; 

END FOREACH;

drop table temp_alumnos;
drop table temp_acad;

end ;
end procedure;

-- **************************  Fin del Procedure sp820_pad_centro **************************

REVOKE execute ON "dba".sp820_pad_centro FROM public;
GRANT execute ON "dba".sp820_pad_centro to guarani; -- Rol de usuarios de Gestion
GRANT execute ON "dba".sp820_pad_centro to internet; -- Rol de usuario de Internet

-- execute procedure dba.sp820_pad_centro (2017);
