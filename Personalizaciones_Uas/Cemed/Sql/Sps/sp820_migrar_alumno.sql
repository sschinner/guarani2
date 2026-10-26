CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_migrar_alumno') THEN
		DROP PROCEDURE sp820_migrar_alumno;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

CREATE PROCEDURE "dba".sp820_migrar_alumno(
	pAnioAcademico LIKE sga_periodo_insc.anio_academico,
	pCarrera LIKE sga_carreras.carrera,
	pFechaInscripcion date,
	pApellido LIKE sga_personas.apellido,
	pNombres LIKE sga_personas.nombres,
	pPaisDocumento LIKE sga_personas.pais_documento,
	pTipoDocumento LIKE sga_personas.tipo_documento,
	pNroDocumento LIKE sga_personas.nro_documento,
	pFechaNacimiento LIKE sga_personas.fecha_nacimiento,
	pLocalidadNacimiento LIKE sga_personas.loc_nacimiento,
	pSexo LIKE sga_personas.sexo,
	pUsuario LIKE aca_usuarios_ag.identificacion)
	Returning INT,VARCHAR(80);

DEFINE pNroInscripcion	varchar(20);

DEFINE sql_err, isam_err  	int;
DEFINE error_info         	varchar(80);
DEFINE vcUserError	varchar(10);
DEFINE iStatus		int;
DEFINE vcMsg		varchar(100);

  -- si hay algun error
ON EXCEPTION SET sql_err, isam_err, error_Info                                        

      LET vcUserError  = '800401' ;
      LET iStatus 	  = -1; 
      LET vcMsg 	  =  vcUserError || ',' || sql_err || ' - ' || error_Info;
      RETURN iStatus, vcMsg;
END EXCEPTION;
--------------------------------------------------

LET error_info = NULL;
LET sql_err = 0;
LET isam_err = 0;
LET iStatus = 0;
LET vcMsg = NULL;

--Inscribo al alumno

EXECUTE PROCEDURE sp820_insc_carr(pAnioAcademico, pCarrera, pFechaInscripcion, pApellido, pNombres, pPaisDocumento, pTipoDocumento, pNroDocumento, pSexo) Into iStatus, VcMsg;

--Recupero el nro_inscripcion del alumno que acabo de inscribir

select distinct nro_inscripcion into pNroInscripcion
from sga_personas 
where nro_documento = pNroDocumento
and tipo_documento = pTipoDocumento
and pais_documento = pPaisDocumento;

update sga_personas
set fecha_nacimiento = pFechaNacimiento, loc_nacimiento = pLocalidadNacimiento
where nro_inscripcion = pNroInscripcion;

--Actualizo el usuario para el alumno en cuestión


BEGIN
  -- si hay algun error
ON EXCEPTION SET sql_err, isam_err, error_Info                                        

      LET vcUserError  = '800401' ;
      LET iStatus 	  = -1; 
      LET vcMsg 	  =  vcUserError || ',' || sql_err || ' - ' || error_Info;
      ROLLBACK;
      RETURN iStatus, vcMsg;
END EXCEPTION;

BEGIN WORK;
--set triggers tu_usuarios_ag disabled;
set triggers for aca_usuarios_ag disabled;

update aca_usuarios_ag set  clave = '$2a$10$5LaDrTjOTnQr7lEmj13mxu43sstp29F4rL.M9578ROPK4NKghzsi6', identificacion = pUsuario
    where nro_inscripcion =  pNroInscripcion;

set triggers for aca_usuarios_ag enabled;
-- set triggers tu_usuarios_ag enabled;        

COMMIT WORK;

END

return iStatus, VcMsg WITH RESUME;


END PROCEDURE;
-- *************************** Fin del procedimiento *******************************

-- *****************************************************************************
-- Permisos del procedimiento
-- *****************************************************************************
revoke execute on "dba".sp820_migrar_alumno from public;
grant execute on "dba".sp820_migrar_alumno to siguv_consulta; -- Rol de usuarios de SIGUV
grant execute on "dba".sp820_migrar_alumno to ue_siguv_guarani; -- Rol de usuarios de SIGUV

{
execute PROCEDURE "dba".sp820_migrar_alumno(
	'2020',
	'ICI',
	today,
	'Azcoaga',
	'Jorge',
	54,
	0,
	'214276051',
	'14/01/1970',
	'3100',
	'1',
	'214276051');


select first 10 * from sga_personas WHERE nro_documento = '214276051';
select  * from aca_usuarios_ag WHERE nro_inscripcion   = 'CCI-14235';

select distinct 'set triggers for ' || tab.tabname || ' enabled;' from sysobjstate obj
	join systables tab
	on obj.tabid = tab.tabid
where objtype = 'T' and state = 'D';
}