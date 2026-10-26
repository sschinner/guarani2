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

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SP: sp820_pad_centro
-- Ultima modificacion: Version 1.9, 2.9.1
--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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
		and a.carrera not in ('03', '04')

	Union

	Select a.legajo, a.carrera

	from sga_alumnos a

		join sga_carrera_aspira car
			join sga_periodo_insc insc
			on car.periodo_inscripcio = insc.periodo_inscripcio and insc.tipo in ('A', 'I')

		on a.nro_inscripcion = car.nro_inscripcion and a.carrera = car.carrera

	where a.regular = 'S'
		and a.calidad = 'A'
		and a.carrera not in ('03', '04')
		and insc.anio_academico = panio_academico

	into temp temp_alumnos with no log;

	create index idx_temp_alu on temp_alumnos (legajo, carrera);

FOREACH SELECT distinct a.legajo, p.apellido, p.nombres, p.nro_documento

   INTO vlegajo, vapellido,vnombres, vnro_documento

     from temp_alumnos t

	join sga_alumnos a

		join sga_personas p

		  on a.nro_inscripcion = p.nro_inscripcion

	on t.legajo = a.legajo

	and t.carrera = a.carrera
	and a.sede = psede
    order by p.apellido, p.nombres

return  vlegajo, vapellido, vnombres, vnro_documento, panio_academico  WITH RESUME; 

END FOREACH;

drop table temp_alumnos;

end;
end procedure;

-- execute procedure dba.sp820_pad_centro (2008);

-- ******************** FIN PROCESO sp820_pad_centro ********************

revoke execute on "dba".sp820_pad_centro from public;
grant execute on "dba".sp820_pad_centro to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_pad_centro to internet; -- Rol de usuario de Internet
