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

create procedure "dba".sp820_pad_centro(pAnio_academico Varchar(4), psede LIKE sga_alumnos.sede)

returning 	varchar(15), -- legajo
	varchar(30),  -- apellido
	varchar(30),  -- nombres
	varchar(15),  -- nro. de documento
	varchar(4); -- año academico
 
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

select legajo, carrera, plan
from sga_alumnos
where  regular = "S"
	and calidad = "A" 
	and carrera <> '12'
	and (
		-- Que este reinscripto si no es ingresante.
		legajo in (select legajo
			from sga_reinscripcion
			where anio_academico = panio_academico)

		OR
		-- Que sea ingresante al año academico seleccionado.

		nro_inscripcion||carrera in (Select c.nro_inscripcion||a.carrera
					from sga_alumnos a
						join sga_carrera_aspira c
							join sga_periodo_insc p
							on c.periodo_inscripcio = p.periodo_inscripcio and p.anio_academico = pAnio_academico
						  on a.nro_inscripcion = c.nro_inscripcion
						and a.carrera = c.carrera))

						into temp temp_alum_centro with no log;

 FOREACH SELECT distinct a.legajo, p.apellido, p.nombres, p.nro_documento
   INTO vlegajo, vapellido,vnombres, vnro_documento
     from temp_alum_centro t
	join sga_alumnos a
		join sga_personas p
		  on a.nro_inscripcion = p.nro_inscripcion
	  on t.legajo = a.legajo
		and t.carrera = a.carrera
		and t.plan = a.plan
		and a.sede = psede
    order by p.apellido, p.nombres

return  vlegajo, vapellido, vnombres, vnro_documento, panio_academico  WITH RESUME; 

END FOREACH;

drop table temp_alum_centro;

end ;
end procedure;
-- *************** Fin del procedimiento "dba".sp820_pad_centro *******************

-- execute procedure "dba".sp820_pad_centro(2002);

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_pad_centro 
-- *****************************************************************************
revoke execute on "dba".sp820_pad_centro from public;
grant execute on "dba".sp820_pad_centro to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_pad_centro to internet; -- Rol de usuario de Internet