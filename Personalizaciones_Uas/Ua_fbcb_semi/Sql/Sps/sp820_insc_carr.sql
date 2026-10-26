-- *************** COMIENZO DEL PROCEDURE sp820_insc_carrera ***************
-- ************************************************************************
-- SP que genera una inscripcion a carrera, a partir de datos de CEMED
-- en un período dado
-- ************************************************************************
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

CREATE PROCEDURE "dba".sp820_insc_carr(
	pUnidadAcademica LIKE sga_unidades_acad.unidad_academica,
	pAnioAcademico LIKE sga_periodo_insc.anio_academico,
	pCarrera LIKE sga_carreras.carrera,
	pFechaInscripcion LIKE sga_datos_censales.fecha_relevamiento,
	pApellido LIKE sga_personas.apellido,
	pNombres LIKE sga_personas.nombres,
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



  -- si hay algun error
ON EXCEPTION SET sql_err, isam_err, error_Info                                        

      LET vcUserError  = '800401' ;
      LET iStatus 	  = -1; 
      LET vcMsg 	  =  vcUserError || ',' || sql_err || ' - ' || error_Info;
      RETURN iStatus, vcMsg;
END EXCEPTION;
--------------------------------------------------


-- LET aunidad_academica = NULL;
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

------------------------------------------------------------------------------------ 
-- Obtengo datos generales de inscripcion a la carrera.

-- Obtengo la Unidad Academica.
LET aunidad_academica = pUnidadAcademica;

-- Obtengo el periodo de Inscripcion. No pueden existir en Guarani Periodos de inscripcion superpuestos.
Select periodo_inscripcio Into aperiodo_inscripcio
from sga_periodo_insc
where anio_academico = pAnioAcademico
and tipo = 'I';

------------------------------------------------------------------------------------ 
-- Verifico si existe la persona
Select nro_inscripcion Into anro_inscripcion
		from sga_personas
		where tipo_documento = pTipoDocumento 
			and nro_documento = pNroDocumento
			and unidad_academica = aunidad_academica;
			
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
			LET vcMsg = 'Ud. posee una inscripción a la carrera rechazada en el año academico ' || pAnioAcademico;
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
		values (aunidad_academica, pCarrera, anro_inscripcion, aperiodo_inscripcio, pFechaInscripcion, '00001', null, 'I', null, null, 'AC', null, null, null, null);
	END IF;
	
ELSE
	execute procedure sp_nro_inscripcion(aunidad_academica) into anro_inscripcion;
	insert into sga_personas values (
			aunidad_academica,
			anro_inscripcion,
			pfechaInscripcion,
			pApellido,
			pNombres,
			54,
			pTipoDocumento,
			pNroDocumento,
			null,
			pSexo,
			null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, 'N', null, null, null, null, null, null, null, null);

	Insert Into sga_carrera_aspira 
		values (aunidad_academica, pCarrera, anro_inscripcion, aperiodo_inscripcio, pFechaInscripcion, '00001', null, 'I', null, null, 'AC', null, null, null, null);


END IF;

execute procedure sp_crear_alumno(aunidad_academica, anro_inscripcion, pCarrera, null, null) Into aLegajo ,sql_err, isam_err, error_info;

IF sql_err < 0 THEN
	LET iStatus 	  = -1 ; 
	LET vcMsg 	  = sql_err || ' - ' || error_Info;
END IF;
RETURN iStatus, vcMsg;


END PROCEDURE;
-- *************** Fin del procedimiento "dba".sp820_insc_carr ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_insc_carr 
-- *****************************************************************************
revoke execute on "dba".sp820_insc_carr from public;
grant execute on "dba".sp820_insc_carr to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_insc_carr to internet; -- Rol de usuario de Internet

-- *************************** Pruebas de ejecucion **********************************
--  execute PROCEDURE "dba".sp820_insc_carr ('2013', 'CC006', '4/8/2013', 'Gómez', 'Cristian Daniel', 0, 21489205, 1);