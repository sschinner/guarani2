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

-- Condicion de los alumnos: ser alumno activo y regular.

-- No ingresantes
select distinct a.legajo, p.apellido, p.nombres, p.nro_documento
from sga_personas p
	join sga_alumnos a
		join sga_reinscripcion r -- Que esten reinscriptos al Año Academico
		on a.legajo = r.legajo and a.carrera = r.carrera
			and r.anio_academico = panio_academico
	  on a.nro_inscripcion = p.nro_inscripcion
where a.calidad = 'A'
and a.regular = 'S'
and a.carrera not in ('4', '5')  -- Elimino los estudiantes externos y de intercambio
union
-- ingresantes
select distinct a.legajo, p.apellido, p.nombres, p.nro_documento
from sga_personas p
	join sga_periodo_insc pe -- Que sean Ingresantes
		join sga_carrera_aspira ca
			join sga_alumnos a
				on ca.nro_inscripcion = a.nro_inscripcion
				and ca.carrera = a.carrera
		on ca.periodo_inscripcio = pe.periodo_inscripcio 
		and pe.anio_academico = panio_academico
	on p.nro_inscripcion = ca.nro_inscripcion

where a.calidad = 'A'
and a.regular = 'S'
and a.carrera not in ('4', '5')  -- Elimino los estudiantes externos y de intercambio
and a.sede = psede
into temp temporal;


FOREACH SELECT distinct legajo, apellido, nombres, nro_documento INTO vlegajo, vapellido, vnombres, vnro_documento
from temporal

order by apellido, nombres

return  vlegajo, vapellido, vnombres, vnro_documento, panio_academico  WITH RESUME; 
END FOREACH

drop table temporal;

end
end procedure;
-- *************** Fin del procedimiento  ******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_pad_centro
-- *****************************************************************************
revoke execute on "dba".sp820_pad_centro from public;
grant execute on "dba".sp820_pad_centro to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_pad_centro to internet; -- Rol de usuario de Internet