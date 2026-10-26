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

create procedure "dba".sp820_pad_centro (pAnio_academico Varchar(4), psede LIKE sga_alumnos.sede)

returning 	varchar(15), -- legajo
	varchar(30),  -- apellido
	varchar(30),  -- nombres
	varchar(15),  -- nro. de documento
	varchar (4), -- anio academico
 	varchar(255), -- carrera
	varchar (255); -- sede
 
  DEFINE vlegajo varchar(15);
  DEFINE vaprobadas int;
  DEFINE vapellido, vnombres varchar(30);
  DEFINE vnro_documento varchar(15);
   DEFINE vcarrera varchar(255); 
  DEFINE vsede varchar(255);

   --vars para el manejo de excepciones
   DEFINE sql_err	 			integer;
   DEFINE isam_err 				integer;
   DEFINE error_info				varchar(76);

   ON EXCEPTION SET sql_err, isam_err, error_info                                        
      RAISE EXCEPTION  sql_err, isam_err, error_info;
   END EXCEPTION;     

BEGIN
	-- crea temporal con alumnos
	Select a.legajo, a.carrera
	from sga_alumnos a
		join sga_reinscripcion r -- Que esten reinscriptos al Año Academico
		on a.legajo = r.legajo and a.carrera = r.carrera and r.anio_academico = panio_academico
		where a.regular = 'S'
		and a.calidad = 'A'
	
	and a.carrera in ("0301", "0302", "0303", "0304")
	and a.sede = psede

	Union
	
	Select a.legajo, a.carrera
	from sga_alumnos a
		join sga_carrera_aspira car
		on a.nro_inscripcion = car.nro_inscripcion and a.carrera = car.carrera
		join sga_periodo_insc insc
		on car.periodo_inscripcio = insc.periodo_inscripcio and insc.tipo in ('A', 'I')
	where insc.anio_academico = panio_academico
		and a.regular = 'S'
		and a.calidad = 'A'
		and a.carrera in ("0301", "0302", "0303", "0304")
		and a.sede = psede

	into temp temp_alumnos with no log;

	create index idx_temp_alu on temp_alumnos (legajo, carrera);


FOREACH SELECT distinct a.legajo, p.apellido, p.nombres, p.nro_documento, max(car.nombre) as nombre_carrera, s.nombre
   INTO vlegajo, vapellido,vnombres, vnro_documento, vcarrera, vsede
     from sga_carreras car
	join temp_alumnos t
	on car.carrera = t.carrera
	join sga_alumnos a
		on t.legajo = a.legajo
		and t.carrera = a.carrera

	join sga_personas p
		on a.nro_inscripcion = p.nro_inscripcion
	join sga_sedes s
		on s.sede = a.sede
	where a.sede = psede
    group by a.legajo, p.apellido, p.nombres, p.nro_documento, s.nombre
    order by p.apellido, p.nombres



return  vlegajo, vapellido, vnombres, vnro_documento, panio_academico, vcarrera, vsede  WITH RESUME; 
END FOREACH;

drop table temp_alumnos;


end ;
end procedure;
-- *************** Fin del procedimiento "dba".sp820_pad_centro  ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_pad_centro  
-- *****************************************************************************
revoke execute on "dba".sp820_pad_centro  from public;
grant execute on "dba".sp820_pad_centro  to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_pad_centro  to internet; -- Rol de usuario de Internet

-- *************************** Pruebas de ejecucion **********************************
-- execute procedure "dba".sp820_pad_centro  (2019, '00001');
