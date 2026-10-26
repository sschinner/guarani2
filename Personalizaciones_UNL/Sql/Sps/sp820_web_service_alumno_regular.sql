CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_webseralureg') THEN
		DROP PROCEDURE sp820_webseralureg;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.5.2
-- Procedure sp820_WebSerAluReg
-- *****************************************************************************
CREATE PROCEDURE "dba".sp820_webseralureg (ptipo_documento integer, pnro_documento varchar(15), psexo  char(1), pfecha varchar(10))
       RETURNING --	CHAR(1200); -- prueba de return de cust_qry
	varchar(5), -- ua
	char(1), -- Regular: S - No Regular: N - No existe la persona por tipo y nro. de documento: X
	VARCHAR(60), -- apellido en la BD
	VARCHAR(60); -- nombre en la BD

-- variables de retorno.
DEFINE vc_UA                 LIKE sga_personas.unidad_academica;
DEFINE vc_PersonaApellido    LIKE sga_personas.apellido;
DEFINE vc_PersonaNombres     LIKE sga_personas.nombres;
DEFINE vc_retorno, vc_retorno_ant, vc_boleto char(1);

-- variables auxiliares

DEFINE vianio_academico like sga_periodo_insc.anio_academico;
DEFINE vianio_inscripcio like sga_periodo_insc.anio_academico;
DEFINE dFDesde		date;
DEFINE vc_situacion_asp LIKE sga_carrera_aspira.situacion_asp;
DEFINE vc_calidad char(1);
DEFINE vc_carrera varchar(5);
DEFINE vc_legajo varchar(15);
DEFINE vi_cant_aprobadas integer;

BEGIN

   -- Inicializaciones.
LET vc_UA                = NULL;
LET vc_boleto 	= NULL;
LET vc_PersonaApellido   = NULL;
LET vc_PersonaNombres    = NULL;
LET vc_retorno = 'X';
LET vc_retorno_ant = 'X';
LET vianio_academico = NULL;
LET vianio_inscripcio = NULL;
LET vc_situacion_asp = NULL;
LET vc_calidad = 'I';

LET dFDesde = stringToDate( pFecha, '%d/%m/%Y');

IF ptipo_documento = 1 THEN
	LET ptipo_documento = 0;
ELSE
	LET ptipo_documento = 99;
END IF;

IF psexo  = 'M' THEN
	LET psexo  = '1';
ELSE
	LET psexo  = '2';
END IF;

-- datos personales.
FOREACH SELECT per.unidad_academica,
	per.apellido,
	per.nombres,
	perinsc.anio_academico,
	asp.situacion_asp,
	alu.calidad,
	alu.legajo,
	alu.carrera
INTO vc_UA,
	vc_PersonaApellido,
	vc_PersonaNombres,
	vianio_inscripcio,
	vc_situacion_asp,
	vc_calidad,
	vc_legajo,
	vc_carrera
FROM sga_personas per
	join sga_carrera_aspira asp
		on per.nro_inscripcion = asp.nro_inscripcion
	join sga_periodo_insc perinsc
		on asp.periodo_inscripcio = perinsc.periodo_inscripcio and asp.situacion_asp in ( 'IL', 'IC', 'AC')
	left join sga_alumnos alu
		on asp.nro_inscripcion = alu.nro_inscripcion
		and asp.carrera = alu.carrera
		
WHERE tipo_documento = ptipo_documento
	AND nro_documento = pnro_documento
	-- AND sexo = psexo

IF vc_calidad is NULL THEN
	LET vc_calidad = 'I';
END IF;


-- Verificaci�n si es aspirante (no tiene generado legajo)
IF vc_situacion_asp in ('IL', 'IC')  and vc_calidad in ('A', 'P') THEN

	{
	-- Verifico la autorizaci�n de la difusi�n de la regularidad
	SELECT boleto_estudiantil Into vc_boleto 
	FROM u820_boleto_estudiantil dat
		join sga_personas per
		on dat.unidad_academica = per.unidad_academica
		and dat.nro_inscripcion = per.nro_inscripcion
	WHERE per.tipo_documento = ptipo_documento
	AND per.nro_documento = pnro_documento
	AND per.sexo = psexo
	AND dat.fecha_relevamiento = (select max(fecha_relevamiento) 
				from u820_boleto_estudiantil
				where unidad_academica = dat.unidad_academica
				and nro_inscripcion = dat.nro_inscripcion);

	IF vc_boleto = 'S' THEN
	}

	-- datos del a�o academico
	SELECT max(anio_academico)   Into vianio_academico
	FROM sga_anio_academico
	WHERE dFDesde between fecha_inicio and fecha_fin;

	IF vianio_academico is NULL THEN
		LET vianio_academico = YEAR(TODAY);
	END IF;

	IF vianio_academico <> vianio_inscripcio THEN
		-- datos de la carrera, reinscripcion y el alumno.
		IF EXISTS (SELECT '*' FROM sga_personas per
			join sga_carrera_aspira asp
				join sga_alumnos alu
					join sga_reinscripcion reinsc
					on alu.unidad_academica = reinsc.unidad_academica
					and alu.legajo = reinsc.legajo
					and alu.carrera = reinsc.carrera
				on asp.nro_inscripcion = alu.nro_inscripcion
				and asp.carrera = alu.carrera
			on per.nro_inscripcion = asp.nro_inscripcion
			WHERE alu.regular = 'S'
			AND alu.calidad = 'A'
			AND per.tipo_documento = ptipo_documento
			AND per.nro_documento = pnro_documento
			AND asp.situacion_asp in ('IL', 'IC')
			AND reinsc.anio_academico = vianio_academico) THEN 
		
			LET vc_retorno = 'S';
			
			select count(*) into vi_cant_aprobadas
			from vw_hist_academica
			where
				unidad_academica = vc_UA
				AND    carrera = vc_carrera  
				AND    legajo  = vc_legajo
				AND    resultado = 'A'
				AND    fecha > TODAY - 365 UNITS DAY;

			IF (vi_cant_aprobadas = 0) THEN
				LET vc_retorno_ant = 'N';
			END IF;

			RETURN vc_UA, vc_retorno , vc_PersonaApellido, vc_PersonaNombres;
		ELSE
			LET vc_retorno_ant = 'N';
		END IF;

	ELSE
	
		-- Esta verificaci�n es por si el ingresante esta Pasivo o No Regular.
		IF EXISTS (SELECT '*' FROM sga_personas per
			join sga_carrera_aspira asp
				join sga_alumnos alu
				on asp.nro_inscripcion = alu.nro_inscripcion
				and asp.carrera = alu.carrera
			on per.nro_inscripcion = asp.nro_inscripcion
			WHERE alu.regular = 'S'
			AND alu.calidad = 'A'
			AND per.tipo_documento = ptipo_documento
			AND per.nro_documento = pnro_documento
			AND asp.situacion_asp in ('IL', 'IC')) THEN 
	
			LET vc_retorno = 'S';
			RETURN vc_UA, vc_retorno , vc_PersonaApellido, vc_PersonaNombres;
		ELSE
			LET vc_retorno_ant = 'N';
		END IF;

	END IF;     

	{
	ELSE --no autoriza la difusi�n de sus datos
		LET vc_retorno = 'D';
		RETURN vc_UA, vc_retorno , vc_PersonaApellido, vc_PersonaNombres;

	END IF;

	}
ELSE

	IF vc_situacion_asp = 'AC' THEN
		-- Pendiente de verificaci�n
		LET vc_retorno_ant = 'P';
	ELSE
		-- No regular: puede ser (RR; RF) � (Egresado; Abandono)
		LET vc_retorno_ant = 'N';
	END IF;

END IF; -- Verificaci�n si es aspirante (no tiene generado legajo)

IF vc_retorno_ant = 'P' THEN
	LET vc_retorno = 'P';
ELIF vc_retorno = 'X' AND vc_retorno_ant = 'N' THEN
	LET vc_retorno = 'N';

END IF;

END FOREACH;

RETURN vc_UA, vc_retorno , vc_PersonaApellido, vc_PersonaNombres;

END;
END PROCEDURE;
-- ********************************** FIN PROCESO **********************************

-- EXECUTE PROCEDURE sp820_WebSerAluReg (1, 37282533, 'F', '10/06/2012');
-- EXECUTE PROCEDURE "dba".sp820_WebSerAluReg (1, 33945226, 'M', '02/01/2011');
-- EXECUTE PROCEDURE "dba".sp820_WebSerAluReg (1, 276002774, 'F', '02/01/2010');


-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_WebSerAluReg 
-- *****************************************************************************
revoke execute on "dba".sp820_WebSerAluReg from public;
grant execute on "dba".sp820_WebSerAluReg to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_WebSerAluReg to internet; -- Rol de usuario de Internet