CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_insc_carr') THEN
		DROP PROCEDURE sp820_insc_carr;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- *************** COMIENZO DEL PROCEDURE sp820_insc_carrera ***************
-- ************************************************************************
-- SP que genera una inscripcion a carrera, a partir de datos de CEMED
-- en un período dado
-- ************************************************************************
-- DROP PROCEDURE "dba".sp820_insc_carr;
      
CREATE PROCEDURE "dba".sp820_insc_carr(
	pAnioAcademico LIKE sga_periodo_insc.anio_academico,
	pCarrera LIKE sga_carreras.carrera,
	pFechaInscripcion LIKE sga_datos_censales.fecha_relevamiento,
	pApellido LIKE sga_personas.apellido,
	pNombres LIKE sga_personas.nombres,
	pPaisDocumento LIKE sga_personas.pais_documento,
	pTipoDocumento LIKE sga_personas.tipo_documento,
	pNroDocumento LIKE sga_personas.nro_documento,
	pSexo LIKE sga_personas.sexo)
	Returning INT,VARCHAR(80);

-- Descripcion de Parámetros:

-- pAnioAcademico: año academico de la inscripcion a carrera (Integer)
-- pCarrera: carrera a la que se va a inscribir (Varchar(5))
-- pFechaInscripcion: fecha de la inscripcion como aspirante a la carrera (mm/dd/yyyy)
-- pApellido (Varchar (30))
-- pNombres (Varchar (30))
-- pPaisDocumento 
-- pTipoDocumento (Integer)
-- pNroDocumento (Decimal (15,0))
-- pSexo (char(1))

-- Descripcion de Return:
-- INT: 	0 - OK
--	-1 - Error
-- VARCHAR(80): string con la descripcion del error
	
DEFINE aunidad_academica LIKE sga_datos_censales.unidad_academica;
DEFINE aanio_academico LIKE sga_periodo_insc.anio_academico;
DEFINE aperiodo_inscripcio LIKE sga_periodo_insc.periodo_inscripcio;
DEFINE afecha_inicio LIKE sga_periodo_insc.fecha_inicio;
DEFINE anro_inscripcion LIKE sga_personas.nro_inscripcion;
DEFINE aux_nro_inscripcion int;
DEFINE aLegajo LIKE sga_alumnos.legajo;

DEFINE sql_err, isam_err  	int;
DEFINE error_info         	varchar(80);
DEFINE vcUserError		varchar(10);
DEFINE iStatus			int;
DEFINE vcMsg			varchar(100);
DEFINE vinacionalidad		int;


  -- si hay algun error
ON EXCEPTION SET sql_err, isam_err, error_Info                                        

      LET vcUserError  = '800401' ;
      LET iStatus 	  = -1; 
      LET vcMsg 	  =  vcUserError || ',' || sql_err || ' - ' || error_Info;
      RETURN iStatus, vcMsg;
END EXCEPTION;
--------------------------------------------------


LET aunidad_academica = NULL;
LET aanio_academico = NULL;
LET aperiodo_inscripcio = NULL;
LET afecha_inicio = NULL;
LET anro_inscripcion = NULL;
LET aLegajo = NULL;
LET aux_nro_inscripcion = NULL;
LET error_info = NULL;
LET sql_err = 0;
LET isam_err = 0;
LET iStatus = 0;
LET vcMsg = NULL;
LET vinacionalidad = NULL;

------------------------------------------------------------------------------------ 
-- Obtengo datos generales de inscripcion a la carrera.

-- Obtengo la Unidad Academica.
Select unidad_academica Into aunidad_academica 
from sga_unidades_acad;

IF pPaisDocumento = 54 THEN
	LET vinacionalidad = 1;
ELSE
	LET vinacionalidad = 2;
END IF;

-- Obtengo el periodo de Inscripcion. No pueden existir en Guarani Periodos de inscripcion superpuestos.
/*
Select max(periodo_inscripcio)  Into aperiodo_inscripcio
from sga_periodo_insc 
where anio_academico = pAnioAcademico
	and pFechaInscripcion between fecha_inicio and fecha_fin and tipo in ('I', 'A');
*/
Let aperiodo_inscripcio = pAnioAcademico;
------------------------------------------------------------------------------------ 

------------------------------------------------------------------------------------ 
-- Verifico si existe la persona
Select nro_inscripcion Into anro_inscripcion
		from sga_personas
		where tipo_documento = pTipoDocumento 
			and nro_documento = pNroDocumento
			and unidad_academica = aunidad_academica
			and pais_documento = pPaisDocumento;
			

IF anro_inscripcion is not null THEN
	------------------------------------------------------------------------------------ 
	-- Busco la carrera con carrera aspira rechazada y del mismo período de inscripción.
	------------------------------------------------------------------------------------ 
  	IF EXISTS (SELECT ' ' FROM sga_carrera_aspira, sga_situacion_asp
	              WHERE sga_carrera_aspira.unidad_academica = aunidad_academica
                	AND sga_carrera_aspira.nro_inscripcion = anro_inscripcion
	                AND sga_carrera_aspira.carrera = pCarrera
               		 AND sga_situacion_asp.resultado_asp = 'R'
	                AND sga_carrera_aspira.periodo_inscripcio = aperiodo_inscripcio 
                	AND sga_carrera_aspira.situacion_asp = sga_situacion_asp.situacion_asp) THEN
	                -- Error
			LET vcMsg = "Ud. posee una inscripción a la carrera rechazada en el año academico " || pAnioAcademico;
			LET iStatus = -1;
                	RETURN iStatus, vcMsg;	
		
	END IF;

	------------------------------------------------------------------------------------ 
	-- Controlo si ya es aspirante en esta carrera en el periodo o ya es alumno
	------------------------------------------------------------------------------------ 
	IF EXISTS (SELECT ' ' FROM sga_carrera_aspira, sga_alumnos, sga_situacion_asp
		     WHERE sga_carrera_aspira.unidad_academica = aunidad_academica
                		AND sga_carrera_aspira.nro_inscripcion = anro_inscripcion
                		AND sga_carrera_aspira.carrera = pCarrera
                		AND sga_situacion_asp.resultado_asp <> 'R'
                		-- AND sga_carrera_aspira.periodo_inscripcio <> aperiodo_inscripcio 
                		AND sga_carrera_aspira.situacion_asp = sga_situacion_asp.situacion_asp
                		AND sga_alumnos.unidad_academica = sga_carrera_aspira.unidad_academica
                		AND sga_alumnos.carrera = sga_carrera_aspira.carrera
                		AND sga_alumnos.nro_inscripcion = sga_carrera_aspira.nro_inscripcion) THEN

                		-- Error
				LET vcMsg = 'La persona ya es Alumno en esta Carrera.';
				LET iStatus = -1;
                		RETURN iStatus, vcMsg;	
	END IF;
	
	IF NOT EXISTS (SELECT ' ' FROM sga_carrera_aspira, sga_situacion_asp
              		WHERE sga_carrera_aspira.unidad_academica = aunidad_academica
	                AND sga_carrera_aspira.nro_inscripcion = anro_inscripcion
                	AND sga_carrera_aspira.carrera = pCarrera
	                AND sga_situacion_asp.resultado_asp <> 'R'
	                AND sga_carrera_aspira.periodo_inscripcio = aperiodo_inscripcio 
                	AND sga_carrera_aspira.situacion_asp = sga_situacion_asp.situacion_asp) THEN
		
		-- Hacer inscripcion de aspirante
		
		Insert Into sga_carrera_aspira 
		values (aunidad_academica, pCarrera, anro_inscripcion, aperiodo_inscripcio, pFechaInscripcion, '00000', null, 'I', null, null, 'AC', null, null, null, null);
	END IF;
	
ELSE
	execute procedure sp_nro_inscripcion(aunidad_academica) into anro_inscripcion;
	insert into sga_personas (UNIDAD_ACADEMICA,  NRO_INSCRIPCION, FECHA_INSCRIPCION,  APELLIDO, NOMBRES, PAIS_DOCUMENTO, TIPO_DOCUMENTO, NRO_DOCUMENTO, NUMERO_CUIL, SEXO, FECHA_NACIMIENTO, aborigen, nacionalidad) values (
			aunidad_academica, anro_inscripcion, pfechaInscripcion, pApellido, pNombres, pPaisDocumento, pTipoDocumento, pNroDocumento, null, pSexo, null, 'N', vinacionalidad);

	Insert Into sga_carrera_aspira 
		values (aunidad_academica, pCarrera, anro_inscripcion, aperiodo_inscripcio, pFechaInscripcion, '00000', null, 'I', null, null, 'AC', null, null, null, null);


END IF;

execute procedure sp_crear_alumno(aunidad_academica, anro_inscripcion, pCarrera, null, null) Into aLegajo ,sql_err, isam_err, error_info;

IF sql_err < 0 THEN
	LET iStatus 	  = -1 ; 
	LET vcMsg 	  = sql_err || ' - ' || error_Info;
END IF;
RETURN iStatus, vcMsg;


END PROCEDURE;
-- *************** FIN DEL PROCEDURE sp820_insc_carr ***************

-- *****************************************************************************
-- Permisos del procedimiento
-- *****************************************************************************
revoke execute on "dba".sp820_insc_carr from public;
grant execute on "dba".sp820_insc_carr to siguv_consulta; -- Rol de usuarios de SIGUV
grant execute on "dba".sp820_insc_carr to ue_siguv_guarani; -- Rol de usuarios de SIGUV
